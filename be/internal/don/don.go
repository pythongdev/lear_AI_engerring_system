// Package don giữ một cửa tạo lượt gọi cho mọi kênh, và các cửa duyệt, từ chối, rời quán.
package don

import (
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"regexp"
	"slices"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ban"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var TaoLuotGoi = authz.Door{Code: "don/tao_luot_goi", Need: authz.NeedCounterOrCustomer}

//go:embed sql/tao_luot_goi/them_don.sql
var themDon string

//go:embed sql/tao_luot_goi/them_dong.sql
var themDong string

//go:embed sql/tao_luot_goi/them_thanh_phan.sql
var themThanhPhan string

//go:embed sql/tao_luot_goi/them_lua_chon.sql
var themLuaChon string

//go:embed sql/tao_luot_goi/them_phien.sql
var themPhien string

//go:embed sql/tao_luot_goi/them_ban.sql
var themBan string

//go:embed sql/tao_luot_goi/khoa_phien.sql
var khoaPhien string

//go:embed sql/tao_luot_goi/doc_don.sql
var docDon string

type DongGoi struct {
	gia.DongYeuCau
	IsTakeaway bool `json:"is_takeaway"`
}
type YeuCauTaiQuay struct {
	SubmissionCode string    `json:"submission_code"`
	DiningTableID  int64     `json:"dining_table_id"`
	Lines          []DongGoi `json:"lines"`
	kenh           string    `json:"-"`
	ngoaiBan       *LienHe   `json:"-"`
}
type DaTao struct {
	LienHe         LienHe     `json:"-"`
	SalesOrderID   int64      `json:"sales_order_id"`
	TableSessionID int64      `json:"table_session_id"`
	DiningTableID  int64      `json:"dining_table_id"`
	ChannelCode    string     `json:"channel_code"`
	Status         string     `json:"status"`
	TotalVnd       int64      `json:"total_vnd"`
	Lines          []gia.Dong `json:"lines"`
}

var submissionPattern = regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

func Tao(ctx context.Context, pool *pgxpool.Pool, personID int64, yc YeuCauTaiQuay) (DaTao, error) {
	out, _, err := tao(ctx, pool, authz.Caller{PersonID: personID}, yc)
	return out, err
}

// Chỉ hai tranh chấp đã biết chạy lại cả giao dịch; không che lỗi database khác.
func canThuLai(err error) bool {
	var pg *pgconn.PgError
	return errors.As(err, &pg) && (pg.ConstraintName == "table_session_member_one_unpaid_session_key" || pg.ConstraintName == "sales_order_submission_code_key")
}
func tao(ctx context.Context, pool *pgxpool.Pool, caller authz.Caller, yc YeuCauTaiQuay) (DaTao, bool, error) {
	if !submissionPattern.MatchString(yc.SubmissionCode) {
		return DaTao{}, false, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "submission_code"}
	}
	if yc.ngoaiBan == nil && caller.QRCode == "" && yc.DiningTableID <= 0 {
		return DaTao{}, false, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"}
	}
	var out DaTao
	var replay bool
	var err error
	for attempt := 0; attempt < 4; attempt++ {
		out = DaTao{}
		replay = false
		err = authz.RunAs(ctx, pool, caller, TaoLuotGoi, func(tx pgx.Tx, g authz.Granted) error {
			// Đường QR kiểm mã trước dấu cả khi người đứng quầy gọi đường này.
			seat := g.Seat
			if caller.QRCode != "" && seat.QRCodeID == 0 {
				var err error
				seat, err = authz.CurrentTable(ctx, tx, caller.QRCode)
				if err != nil {
					return err
				}
			}
			saved, code, takeaways, err := docDaTao(ctx, tx, yc.SubmissionCode)
			if err == nil {
				same := saved.ChannelCode == "staff_pos" && saved.DiningTableID == yc.DiningTableID
				if caller.QRCode != "" {
					same = saved.ChannelCode == "qr_table" && code == caller.QRCode
				}
				if yc.ngoaiBan != nil {
					same = saved.ChannelCode == yc.kenh && cungLienHe(saved.LienHe, *yc.ngoaiBan)
				}
				if !same || !cungDong(saved.Lines, takeaways, yc.Lines) {
					return apierr.Error{Code: apierr.CodeSubmissionCodeConflict}
				}
				out = saved
				replay = true
				return nil
			}
			if !errors.Is(err, pgx.ErrNoRows) {
				return err
			}
			tableID := yc.DiningTableID
			var qrID *int64
			channel := "staff_pos"
			if caller.QRCode != "" {
				tableID = seat.DiningTableID
				qrID = &seat.QRCodeID
				channel = "qr_table"
			}
			if yc.ngoaiBan != nil {
				channel = yc.kenh
			}
			if err := xetNhanDon(ctx, tx, channel); err != nil {
				return err
			}
			var sessionID int64
			var sessionStatus string
			if yc.ngoaiBan == nil {
				if _, err := ban.Doc(ctx, tx, tableID); err != nil {
					return err
				}
				err = tx.QueryRow(ctx, khoaPhien, tableID).Scan(&sessionID, &sessionStatus)
				if errors.Is(err, pgx.ErrNoRows) {
					b, err := ban.Doc(ctx, tx, tableID)
					if err != nil {
						return err
					}
					if b.State == "needs_cleaning" {
						return apierr.Error{Code: apierr.CodeDiningTableNeedsCleaning}
					}
					// Không dùng kết quả kiểm phiên để chặn. Khoá duy nhất quyết tranh chấp tạo đầu.
					if err := tx.QueryRow(ctx, themPhien).Scan(&sessionID); err != nil {
						return err
					}
					if _, err := tx.Exec(ctx, themBan, sessionID, tableID); err != nil {
						return err
					}
					sessionStatus = "open"
				} else if err != nil {
					return err
				}
			}
			lines := make([]gia.DongYeuCau, len(yc.Lines))
			for i, d := range yc.Lines {
				lines[i] = d.DongYeuCau
			}
			kq, err := gia.Tinh(ctx, tx, lines)
			if err != nil {
				return err
			}
			status, err := vongdoi.TrangThaiDauDon(channel)
			if err != nil {
				return err
			}
			var lh LienHe
			if yc.ngoaiBan != nil {
				lh = *yc.ngoaiBan
			}
			if err := tx.QueryRow(ctx, themDon, channel, status, sessionID, tableID, yc.SubmissionCode, qrID, lh.HandoverCode, lh.CustomerPhone, lh.DeliveryAddress, lh.CustomerNeededAt, lh.CustomerName, lh.ContactNote).Scan(&out.SalesOrderID); err != nil {
				return err
			}
			for index, d := range kq.Lines {
				var dongID int64
				n := len(d.Components)
				query := themDong
				args := []any{out.SalesOrderID, d.Quantity, d.MenuItemID, d.ItemName, d.UnitPriceVnd, n}
				if yc.ngoaiBan == nil {
					args = append(args, yc.Lines[index].IsTakeaway)
				} else {
					query = themDongMangDi
				}
				if err := tx.QueryRow(ctx, query, args...).Scan(&dongID); err != nil {
					return err
				}
				for i, c := range d.Components {
					if _, err := tx.Exec(ctx, themThanhPhan, dongID, i+1, n, c.MenuComponentID, c.ComponentName, c.Quantity, c.TakesFilling, c.BasePriceVnd); err != nil {
						return err
					}
				}
				for _, o := range d.Options {
					if _, err := tx.Exec(ctx, themLuaChon, dongID, o.MenuOptionID, o.OptionGroupName, o.OptionName, o.SurchargeVnd); err != nil {
						return err
					}
				}
			}
			if (status == "confirmed" && sessionStatus == "open") || sessionStatus == "awaiting_payment" {
				if err := vongdoi.ChuyenPhien(ctx, tx, sessionID, "serving"); err != nil {
					return err
				}
			}
			out, _, _, err = docDaTao(ctx, tx, yc.SubmissionCode)
			return err
		})
		if !canThuLai(err) {
			break
		}
	}
	if err != nil {
		return DaTao{}, false, err
	}
	return out, replay, nil
}
func docDaTao(ctx context.Context, tx pgx.Tx, submission string) (DaTao, string, []bool, error) {
	var out DaTao
	var code string
	var raw, take, neededAt []byte
	err := tx.QueryRow(ctx, docDon, submission).Scan(&out.SalesOrderID, &out.TableSessionID, &out.DiningTableID, &out.ChannelCode, &out.Status, &code, &out.TotalVnd, &raw, &take, &out.LienHe.HandoverCode, &out.LienHe.CustomerPhone, &out.LienHe.DeliveryAddress, &neededAt, &out.LienHe.CustomerName, &out.LienHe.ContactNote)
	if err != nil {
		return DaTao{}, "", nil, err
	}
	// PostgreSQL kết xuất mốc JSON theo múi giờ phiên kết nối (hợp đồng §6).
	if err := json.Unmarshal(neededAt, &out.LienHe.CustomerNeededAt); err != nil {
		return DaTao{}, "", nil, err
	}
	if err := json.Unmarshal(raw, &out.Lines); err != nil {
		return DaTao{}, "", nil, err
	}
	var takeaways []bool
	err = json.Unmarshal(take, &takeaways)
	return out, code, takeaways, err
}
func cungDong(saved []gia.Dong, takeaways []bool, requested []DongGoi) bool {
	if len(saved) != len(requested) || len(takeaways) != len(saved) {
		return false
	}
	for i, d := range saved {
		r := requested[i]
		if d.MenuItemID != r.MenuItemID || d.Quantity != r.Quantity || takeaways[i] != r.IsTakeaway {
			return false
		}
		a := make([]int64, len(d.Options))
		for j, o := range d.Options {
			a[j] = o.MenuOptionID
		}
		b := slices.Clone(r.OptionIDs)
		slices.Sort(a)
		slices.Sort(b)
		if !slices.Equal(slices.Compact(a), slices.Compact(b)) {
			return false
		}
	}
	return true
}
