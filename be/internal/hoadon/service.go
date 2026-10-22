// Package hoadon đóng phiên và ghi hoá đơn trong cùng một giao dịch.
package hoadon

import (
	"context"
	"errors"
	"math"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/phien"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/tratruoc"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var Dong = authz.Door{Code: "hoadon/dong", Need: authz.NeedCounter}
var TraoTaiQuay = authz.Door{Code: "hoadon/trao_tai_quay", Need: authz.NeedCounter}
var GiaoXong = authz.Door{Code: "hoadon/giao_xong", Need: authz.NeedPerson}
var Hoan = authz.Door{Code: "hoadon/hoan", Need: authz.NeedCounter}
var ThuNo = authz.Door{Code: "hoadon/thu_no", Need: authz.NeedCounter}
var TraLai = authz.Door{Code: "hoadon/tra_lai", Need: authz.NeedCounter}
var CuaGhi = authz.Door{Code: "hoadon/ghi", Need: authz.NeedCallingDoor}
var CuaGhiHoan = authz.Door{Code: "hoadon/ghi_hoan", Need: authz.NeedCallingDoor}

func sai(field string) error { return apierr.Error{Code: apierr.CodeInvalidRequest, Field: field} }

type ThanhToan struct {
	Cash                 *int64  `json:"cash_vnd"`
	Transfer             *int64  `json:"transfer_vnd"`
	PrepaidCash          int64   `json:"prepaid_cash_vnd"`
	PrepaidTransfer      int64   `json:"prepaid_transfer_vnd"`
	Debt                 int64   `json:"debt_vnd"`
	Discount             int64   `json:"discount_vnd"`
	DiscountCustomerName *string `json:"discount_customer_name"`
	Debtor               *string `json:"debtor_name"`
}

func (p ThanhToan) Kiem() error {
	var total int64
	for _, f := range []struct {
		name string
		v    *int64
	}{
		{"cash_vnd", p.Cash}, {"transfer_vnd", p.Transfer}, {"prepaid_cash_vnd", &p.PrepaidCash},
		{"prepaid_transfer_vnd", &p.PrepaidTransfer}, {"debt_vnd", &p.Debt}, {"discount_vnd", &p.Discount},
	} {
		if f.v == nil || *f.v < 0 || *f.v > math.MaxInt64-total {
			return sai(f.name)
		}
		total += *f.v
	}
	if p.Debtor != nil && strings.TrimSpace(*p.Debtor) == "" {
		return sai("debtor_name")
	}
	return kiemTenGiam(p.Discount, p.DiscountCustomerName)
}

func kiemTenGiam(discount int64, name *string) error {
	if (discount > 0 && (name == nil || strings.TrimSpace(*name) == "")) || (discount == 0 && name != nil) {
		return sai("discount_customer_name")
	}
	return nil
}

func kiemChuGiam(ctx context.Context, tx pgx.Tx, nguoi, discount int64) error {
	if discount <= 0 {
		return nil
	}
	owner, err := newRepository(tx).chuQuanGiamGia(ctx, nguoi)
	if err != nil {
		return err
	}
	if !owner {
		return apierr.Error{Code: apierr.CodeOwnerOnly}
	}
	return nil
}

type HoanYeuCau struct {
	Amount *int64 `json:"amount_vnd"`
	Method string `json:"method_code"`
	Source string `json:"source_method_code"`
	Reason string `json:"reason"`
}

func phuongThuc(s string) bool { return s == "cash" || s == "transfer" }
func (p HoanYeuCau) Kiem() error {
	if p.Amount == nil || *p.Amount <= 0 {
		return sai("amount_vnd")
	}
	if !phuongThuc(p.Method) {
		return sai("method_code")
	}
	if !phuongThuc(p.Source) {
		return sai("source_method_code")
	}
	if strings.TrimSpace(p.Reason) == "" {
		return sai("reason")
	}
	return nil
}

type TraLaiYeuCau struct {
	Method   string `json:"method_code"`
	Cash     *int64 `json:"take_cash_vnd"`
	Transfer *int64 `json:"take_transfer_vnd"`
	Reason   string `json:"reason"`
}

func (p TraLaiYeuCau) Kiem() error {
	if !phuongThuc(p.Method) {
		return sai("method_code")
	}
	for _, f := range []struct {
		name string
		v    *int64
	}{{"take_cash_vnd", p.Cash}, {"take_transfer_vnd", p.Transfer}} {
		if f.v == nil || *f.v < 0 {
			return sai(f.name)
		}
	}
	if *p.Cash > math.MaxInt64-*p.Transfer || *p.Cash+*p.Transfer == 0 {
		return sai("")
	}
	if strings.TrimSpace(p.Reason) == "" {
		return sai("reason")
	}
	return nil
}

type NoiDung struct {
	PaperLedgerID                                                     *int64
	PaperEntryCount, PaperPosition                                    *int32
	Phien, Don                                                        *int64
	Due, Cash, Transfer, PrepaidCash, PrepaidTransfer, Debt, Discount int64
	DiscountCustomerName                                              *string
	Debtor                                                            *string
	DebtNote                                                          *string
	Moc                                                               time.Time
}

// kiemPhanTien không ghi: dùng trước huỷ việc và ở cửa Ghi để giữ đúng một bộ kiểm tiền.
func kiemPhanTien(b NoiDung) error {
	// Trừ dần để tránh tràn bigint khi yêu cầu có nhiều phần tiền rất lớn.
	if b.Discount < 0 || b.Discount > b.Due {
		return sai("discount_vnd")
	}
	if err := kiemTenGiam(b.Discount, b.DiscountCustomerName); err != nil {
		return err
	}
	con := b.Due - b.Discount
	for _, v := range []int64{b.Cash, b.Transfer, b.PrepaidCash, b.PrepaidTransfer, b.Debt} {
		if v < 0 || v > con {
			return apierr.Error{Code: apierr.CodePaymentPartsMismatch}
		}
		con -= v
	}
	if con != 0 {
		return apierr.Error{Code: apierr.CodePaymentPartsMismatch}
	}
	if (b.Debt > 0) != (b.Debtor != nil) {
		return apierr.Error{Code: apierr.CodeDebtorNameMismatch}
	}
	return nil
}

// Ghi là ô thêm bill duy nhất; cửa gọi giữ khoá đơn/phiên và ngày chưa ký.
func Ghi(ctx context.Context, tx pgx.Tx, b NoiDung) (int64, error) {
	if err := kiemPhanTien(b); err != nil {
		return 0, err
	}
	repo := newRepository(tx)
	var khoan int64
	if b.PrepaidCash > 0 || b.PrepaidTransfer > 0 {
		var err error
		khoan, err = repo.khoaKhoanTraTruoc(ctx, b.Don)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, apierr.Error{Code: apierr.CodePrepaymentBalanceExceeded}
		}
		if err != nil {
			return 0, err
		}
	}
	if khoan != 0 {
		if _, err := tratruoc.KiemSoDu(ctx, tx, khoan, b.PrepaidCash, b.PrepaidTransfer); err != nil {
			return 0, err
		}
	}
	id, err := repo.themHoaDon(ctx, b)
	if err != nil {
		return 0, err
	}
	if khoan != 0 {
		err = tratruoc.Dung(ctx, tx, khoan, b.PrepaidCash, b.PrepaidTransfer, &id, nil)
	}
	return id, err
}

// GhiHoan là ô thêm refund duy nhất; trả lại trả trước nối mắt trong cùng giao dịch ở cửa gọi.
func GhiHoan(ctx context.Context, tx pgx.Tx, bill, prepayment *int64, amount int64, method string, source *string, reason string, moc time.Time) (int64, error) {
	return newRepository(tx).themHoan(ctx, bill, prepayment, amount, method, source, reason, moc)
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

// DongYeuCau là thân của cửa đóng phiên, đã qua kiểm hình ở handler.
type DongYeuCau struct {
	DiscountVnd          int64   `json:"discount_vnd"`
	DiscountCustomerName *string `json:"discount_customer_name"`
	CashVnd              *int64  `json:"cash_vnd"`
	TransferVnd          *int64  `json:"transfer_vnd"`
	DebtVnd              *int64  `json:"debt_vnd"`
	DebtorName           *string `json:"debtor_name"`
}

func (s *Service) DongPhien(ctx context.Context, nguoi, id int64, yc DongYeuCau) (bill, due int64, err error) {
	err = authz.Run(ctx, s.pool, nguoi, Dong, func(tx pgx.Tx) error {
		if err := kiemChuGiam(ctx, tx, nguoi, yc.DiscountVnd); err != nil {
			return err
		}
		repo := newRepository(tx)
		status, err := repo.khoaPhien(ctx, id)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeTableSessionNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(ctx, tx)
		if err != nil {
			return err
		}
		if err := vongdoi.KiemChuyenPhien(status, "closed"); err != nil {
			return err
		}
		dons, err := repo.khoaDonCuaPhien(ctx, id)
		if err != nil {
			return err
		}
		jobs, err := repo.khoaViecCuaPhien(ctx, id)
		if err != nil {
			return err
		}
		// Kiểm tất cả lời từ chối tiền trước câu ghi đầu tiên. Huỷ pending/made không đổi suất đã ra.
		due, err = phien.TongTien(ctx, tx, id)
		if err != nil {
			return err
		}
		b := NoiDung{Phien: &id, Due: due, Discount: yc.DiscountVnd, DiscountCustomerName: yc.DiscountCustomerName,
			Cash: *yc.CashVnd, Transfer: *yc.TransferVnd, Debt: *yc.DebtVnd, Debtor: yc.DebtorName, Moc: moc}
		if err := kiemPhanTien(b); err != nil {
			return err
		}
		daRa := map[int64]bool{}
		for _, j := range jobs {
			den := ""
			switch j.Status {
			case "served":
				daRa[j.SalesOrderID] = true
			case "pending":
				den = "cancelled"
			case "made":
				den = "discarded"
			}
			if den != "" {
				if err := vongdoi.ChuyenViec(ctx, tx, j.ID, den); err != nil {
					return err
				}
			}
		}
		coSuat, err := phien.DonCoSuatDaRa(ctx, tx, id)
		if err != nil {
			return err
		}
		for _, don := range coSuat {
			daRa[don] = true
		}
		for _, don := range dons {
			if don.Status == "completed" || don.Status == "cancelled" {
				continue
			}
			if err := vongdoi.ChotDonCuaPhien(ctx, tx, don.ID, daRa[don.ID]); err != nil {
				return err
			}
		}
		due, err = phien.TongTien(ctx, tx, id)
		if err != nil {
			return err
		}
		b.Due = due
		bill, err = Ghi(ctx, tx, b)
		if err != nil {
			return err
		}

		return vongdoi.ChuyenPhien(ctx, tx, id, "closed")
	})
	return bill, due, err
}

// Trao chạy cửa trao_tai_quay (giao = false) hoặc giao_xong (giao = true); p đã qua kiểm hình ở handler.
func (s *Service) Trao(ctx context.Context, nguoi, id int64, p ThanhToan, debtNote *string, giao bool) (bill, due int64, err error) {
	cua := TraoTaiQuay
	if giao {
		cua = GiaoXong
	}
	err = authz.Run(ctx, s.pool, nguoi, cua, func(tx pgx.Tx) error {
		if err := kiemChuGiam(ctx, tx, nguoi, p.Discount); err != nil {
			return err
		}
		if p.Debt > 0 {
			if debtNote == nil || strings.TrimSpace(*debtNote) == "" {
				return apierr.Error{Code: apierr.CodeDebtNoteRequired}
			}
			note := strings.TrimSpace(*debtNote)
			debtNote = &note
		}
		repo := newRepository(tx)
		d, err := repo.khoaDon(ctx, id, giao)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(ctx, tx)
		if err != nil {
			return err
		}
		doorDelivery := d.trao != nil && *d.trao == "door_delivery"
		if d.phien != nil || giao != doorDelivery {
			return apierr.Error{Code: apierr.CodeOrderHandoverMismatch}
		}
		source := "in_progress"
		if giao {
			source = "delivering"
		}
		if d.status != source {
			return apierr.Error{Code: apierr.CodeOrderTransitionNotAllowed}
		}
		if err := vongdoi.KiemChuyenDon(d.status, "completed", d.kenh, d.trao); err != nil {
			return err
		}
		if !giao {
			con, err := repo.conViecChuaRaBan(ctx, id)
			if err != nil {
				return err
			}
			if con {
				return apierr.Error{Code: apierr.CodeOrderJobsNotServed}
			}
		}
		if due, err = repo.tongDon(ctx, id, giao); err != nil {
			return err
		}
		bill, err = Ghi(ctx, tx, NoiDung{Don: &id, Due: due, Discount: p.Discount, DiscountCustomerName: p.DiscountCustomerName, Cash: *p.Cash, Transfer: *p.Transfer, PrepaidCash: p.PrepaidCash, PrepaidTransfer: p.PrepaidTransfer, Debt: p.Debt, Debtor: p.Debtor, DebtNote: debtNote, Moc: moc})
		if err != nil {
			return err
		}
		return vongdoi.ChuyenDon(ctx, tx, id, "completed")
	})
	return bill, due, err
}

func (s *Service) HoanTien(ctx context.Context, nguoi, id int64, p HoanYeuCau) (int64, error) {
	var out int64
	err := authz.Run(ctx, s.pool, nguoi, Hoan, func(tx pgx.Tx) error {
		if _, err := newRepository(tx).khoaHoaDonHoan(ctx, id); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeBillNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(ctx, tx)
		if err != nil {
			return err
		}
		out, err = GhiHoan(ctx, tx, &id, nil, *p.Amount, p.Method, &p.Source, p.Reason, moc)
		return err
	})
	return out, err
}

func (s *Service) TraLaiTraTruoc(ctx context.Context, nguoi, id int64, p TraLaiYeuCau) (int64, int64, error) {
	var out int64
	amount := *p.Cash + *p.Transfer
	err := authz.Run(ctx, s.pool, nguoi, TraLai, func(tx pgx.Tx) error {
		if _, err := newRepository(tx).khoaKhoanTraLai(ctx, id); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodePrepaymentNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(ctx, tx)
		if err != nil {
			return err
		}
		if _, err := tratruoc.KiemSoDu(ctx, tx, id, *p.Cash, *p.Transfer); err != nil {
			return err
		}
		out, err = GhiHoan(ctx, tx, nil, &id, amount, p.Method, nil, p.Reason, moc)
		if err != nil {
			return err
		}
		return tratruoc.Dung(ctx, tx, id, *p.Cash, *p.Transfer, nil, &out)
	})
	return out, amount, err
}

func (s *Service) ThuNoHoaDon(ctx context.Context, nguoi, id int64, p tratruoc.PhanTien) (int64, int64, error) {
	var out, remaining int64
	err := authz.Run(ctx, s.pool, nguoi, ThuNo, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		debt, err := repo.khoaHoaDonNo(ctx, id)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeBillNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(ctx, tx)
		if err != nil {
			return err
		}
		if debt == 0 {
			return apierr.Error{Code: apierr.CodeBillHasNoDebt}
		}
		before, err := repo.conNo(ctx, id)
		if err != nil {
			return err
		}
		remaining = debt
		if before != nil {
			remaining = *before
		}
		if remaining == 0 {
			return apierr.Error{Code: apierr.CodeDebtAlreadySettled}
		}
		paid := *p.Cash + *p.Transfer
		if paid > remaining {
			return apierr.Error{Code: apierr.CodeDebtOverpaid}
		}
		remaining -= paid
		out, err = repo.themThuNo(ctx, id, debt, *p.Cash, *p.Transfer, before, remaining, moc)
		return err
	})
	return out, remaining, err
}

func (s *Service) DanhSachNo(ctx context.Context) ([]map[string]any, error) {
	var debts []map[string]any
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		debts, err = newRepository(tx).danhSachNo(ctx)
		return err
	})
	return debts, err
}
