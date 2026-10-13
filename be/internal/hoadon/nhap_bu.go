package hoadon

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/don"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var NhapBu = authz.Door{Code: "hoadon/nhap_bu", Need: authz.NeedCounterOrOwner}

type NhapBuYeuCau struct {
	PaperPosition int32         `json:"paper_position"`
	SoldAt        time.Time     `json:"sold_at"`
	Kind          string        `json:"kind"`
	DiningTableID *int64        `json:"dining_table_id"`
	Items         []don.DongGoi `json:"items"`
	don.LienHe
	ThanhToan
	DebtNote *string `json:"debt_note"`
}
type NhapBuDaGhi struct {
	BillID         int64     `json:"bill_id"`
	SalesOrderID   int64     `json:"sales_order_id"`
	TableSessionID *int64    `json:"table_session_id"`
	PaperLedgerID  int64     `json:"paper_ledger_id"`
	PaperPosition  int32     `json:"paper_position"`
	SaleDate       string    `json:"sale_date"`
	BookedAt       time.Time `json:"booked_at"`
	DueVnd         int64     `json:"due_vnd"`
	Status         string    `json:"status"`
}

// Đọc từng trường để cả lỗi mốc RFC3339 cũng chỉ đúng field; không dùng giá do client gửi.
func docNhapBu(raw map[string]json.RawMessage) (NhapBuYeuCau, error) {
	var p NhapBuYeuCau
	for _, f := range []struct {
		name string
		v    any
	}{
		{"paper_position", &p.PaperPosition}, {"sold_at", &p.SoldAt}, {"kind", &p.Kind}, {"dining_table_id", &p.DiningTableID},
		{"handover_code", &p.HandoverCode}, {"customer_phone", &p.CustomerPhone}, {"customer_needed_at", &p.CustomerNeededAt},
		{"delivery_address", &p.DeliveryAddress}, {"customer_name", &p.CustomerName}, {"contact_note", &p.ContactNote},
		{"cash_vnd", &p.Cash}, {"transfer_vnd", &p.Transfer}, {"debt_vnd", &p.Debt}, {"debtor_name", &p.Debtor}, {"debt_note", &p.DebtNote},
		{"discount_vnd", &p.Discount}, {"discount_customer_name", &p.DiscountCustomerName},
		{"prepaid_cash_vnd", &p.PrepaidCash}, {"prepaid_transfer_vnd", &p.PrepaidTransfer},
	} {
		if v, ok := raw[f.name]; ok {
			if err := json.Unmarshal(v, f.v); err != nil {
				return p, sai(f.name)
			}
		}
	}
	if p.PaperPosition <= 0 {
		return p, sai("paper_position")
	}
	if p.SoldAt.IsZero() {
		return p, sai("sold_at")
	}
	p.SoldAt = p.SoldAt.Add(-time.Duration(p.SoldAt.Nanosecond() % 1000))
	if p.Kind != "table" && p.Kind != "takeaway" {
		return p, sai("kind")
	}
	if p.Kind == "table" {
		if p.DiningTableID == nil || *p.DiningTableID <= 0 {
			return p, sai("dining_table_id")
		}
		// Các trường ngoài bàn không được ghi vào đơn staff_pos.
		p.LienHe = don.LienHe{}
	} else {
		if p.DiningTableID != nil {
			return p, sai("dining_table_id")
		}
		if p.HandoverCode != "shop_pickup" && p.HandoverCode != "door_delivery" {
			return p, sai("handover_code")
		}
		if strings.TrimSpace(p.CustomerPhone) == "" {
			return p, sai("customer_phone")
		}
		if p.CustomerNeededAt == nil {
			return p, sai("customer_needed_at")
		}
		if p.HandoverCode == "door_delivery" && (p.DeliveryAddress == nil || strings.TrimSpace(*p.DeliveryAddress) == "") {
			return p, sai("delivery_address")
		}
		at := p.CustomerNeededAt.Add(-time.Duration(p.CustomerNeededAt.Nanosecond() % 1000))
		p.CustomerNeededAt = &at
	}
	if err := don.KiemHinhDong(raw["items"]); err != nil {
		return p, loiItems(err)
	}
	if err := json.Unmarshal(raw["items"], &p.Items); err != nil {
		return p, sai("items")
	}
	if p.Kind == "takeaway" {
		for i, d := range p.Items {
			if d.IsTakeaway {
				return p, sai(fmt.Sprintf("items[%d].is_takeaway", i))
			}
		}
	}
	if err := p.ThanhToan.Kiem(); err != nil {
		return p, err
	}
	if p.PrepaidCash != 0 {
		return p, sai("prepaid_cash_vnd")
	}
	if p.PrepaidTransfer != 0 {
		return p, sai("prepaid_transfer_vnd")
	}
	if p.Debt == 0 && p.DebtNote != nil {
		return p, sai("debt_note")
	}
	return p, nil
}
func loiItems(err error) error {
	var e apierr.Error
	if errors.As(err, &e) && strings.HasPrefix(e.Field, "lines") {
		e.Field = "items" + strings.TrimPrefix(e.Field, "lines")
		return e
	}
	return err
}

func (s *Service) NhapGiay(ctx context.Context, nguoi int64, ngay string, p NhapBuYeuCau) (NhapBuDaGhi, error) {
	out := NhapBuDaGhi{SaleDate: ngay, PaperPosition: p.PaperPosition, Status: "completed"}
	err := authz.Run(ctx, s.pool, nguoi, NhapBu, func(tx pgx.Tx) error {
		if err := ngayban.Khoa(ctx, tx, ngay, false); err != nil {
			return err
		}
		daKy, err := ngayban.DaKy(ctx, tx, ngay)
		if err != nil {
			return err
		}
		if daKy {
			return apierr.Error{Code: apierr.CodeSaleDayReconciled}
		}
		repo := newRepository(tx)
		ledger, count, err := repo.docSoNhapBu(ctx, ngay)
		if errors.Is(err, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodePaperLedgerMissing}
		}
		if err != nil {
			return err
		}
		if p.PaperPosition < 1 || p.PaperPosition > count {
			return sai("paper_position")
		}
		trung, err := repo.trungViTriGiay(ctx, ledger, p.PaperPosition)
		if err != nil {
			return err
		}
		if trung {
			return apierr.Error{Code: apierr.CodePaperPositionAlreadyEntered}
		}
		now, err := ngayban.DongHo(ctx, tx)
		if err != nil {
			return err
		}
		hop, booked, err := repo.mocNhapBu(ctx, p.SoldAt, ngay, now)
		if err != nil {
			return err
		}
		if !hop {
			return sai("sold_at")
		}
		if err := json.Unmarshal(booked, &out.BookedAt); err != nil {
			return err
		}
		if err := kiemChuGiam(ctx, tx, nguoi, p.Discount); err != nil {
			return err
		}
		var table int64
		if p.Kind == "table" {
			table = *p.DiningTableID
			co, err := repo.banNhapBu(ctx, table)
			if err != nil {
				return err
			}
			if !co {
				return sai("dining_table_id")
			}
		} else if p.Debt > 0 {
			if p.DebtNote == nil || strings.TrimSpace(*p.DebtNote) == "" {
				return apierr.Error{Code: apierr.CodeDebtNoteRequired}
			}
		}
		if p.DebtNote != nil {
			note := strings.TrimSpace(*p.DebtNote)
			p.DebtNote = &note
		}
		lines := make([]gia.DongYeuCau, len(p.Items))
		for i, d := range p.Items {
			lines[i] = d.DongYeuCau
		}
		kq, err := gia.Tinh(ctx, tx, lines, p.SoldAt)
		if err != nil {
			return loiItems(err)
		}
		out.PaperLedgerID, out.DueVnd = ledger, kq.TotalVnd
		return vongdoi.CoVet(ctx, tx, "nhập bù sổ giấy", func() error {
			out.SalesOrderID, out.TableSessionID, err = don.GhiNhapBu(ctx, tx, table, p.SoldAt, p.LienHe, p.Items, kq)
			if err != nil {
				return err
			}
			var order *int64
			if out.TableSessionID == nil {
				order = &out.SalesOrderID
			}
			out.BillID, err = Ghi(ctx, tx, NoiDung{Phien: out.TableSessionID, Don: order, Due: kq.TotalVnd,
				Cash: *p.Cash, Transfer: *p.Transfer, Debt: p.Debt, Debtor: p.Debtor, DebtNote: p.DebtNote,
				Discount: p.Discount, DiscountCustomerName: p.DiscountCustomerName, Moc: p.SoldAt,
				PaperLedgerID: &ledger, PaperEntryCount: &count, PaperPosition: &p.PaperPosition})
			return err
		})
	})
	if err != nil {
		return NhapBuDaGhi{}, err
	}
	return out, nil
}
