package don

import (
	"context"
	_ "embed"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/gia"
	"github.com/jackc/pgx/v5"
)

// DongHo trả now() của chính giao dịch; chỉ test thay nó.
var DongHo func(context.Context, pgx.Tx) (time.Time, error) = func(ctx context.Context, tx pgx.Tx) (time.Time, error) {
	var moc time.Time
	err := tx.QueryRow(ctx, "SELECT now()").Scan(&moc)
	return moc, err
}

// Giờ bán theo master_plan/shop-facts.md §1; hai đầu đều trong giờ (db/reconcile/i008.sql).
const gioMo = "06:00:00"
const gioDong = "11:00:00"

// Đây là các câu đọc của cửa tạo lượt gọi, không phải cửa ghi riêng (QC-13).
const docTamDung = `SELECT EXISTS (SELECT 1 FROM order_intake_pause
 WHERE tstzrange(started_at, ended_at, '[)') @> $1::timestamptz)`
const docNgoaiGio = `SELECT $1::timestamptz::time < TIME '` + gioMo + `' OR $1::timestamptz::time > TIME '` + gioDong + `'`
const docQuanMu = `SELECT EXISTS (SELECT 1 FROM shop_blind_spell
 WHERE tstzrange(started_at, ended_at, '[)') @> $1::timestamptz)`

func xetNhanDon(ctx context.Context, tx pgx.Tx, kenh string) error {
	moc, err := DongHo(ctx, tx)
	if err != nil {
		return err
	}
	var biChan bool
	if err := tx.QueryRow(ctx, docTamDung, moc).Scan(&biChan); err != nil {
		return err
	}
	if biChan {
		return apierr.Error{Code: apierr.CodeOrderIntakePaused}
	}
	// Phép đổi sang time dùng múi giờ phiên kết nối, không dùng múi giờ máy chạy Go.
	if err := tx.QueryRow(ctx, docNgoaiGio, moc).Scan(&biChan); err != nil {
		return err
	}
	if biChan {
		return apierr.Error{Code: apierr.CodeOutsideSellingHours}
	}
	if kenh == "delivery" || kenh == "pickup" || kenh == "qr_table" {
		if err := tx.QueryRow(ctx, docQuanMu, moc).Scan(&biChan); err != nil {
			return err
		}
		if biChan {
			return apierr.Error{Code: apierr.CodeShopNotSeeingOrders}
		}
	}
	return nil
}

//go:embed sql/tao_luot_goi/them_dong_mang_di.sql
var themDongMangDi string

type LienHe struct {
	HandoverCode     string     `json:"handover_code"`
	CustomerPhone    string     `json:"customer_phone"`
	DeliveryAddress  *string    `json:"delivery_address"`
	CustomerNeededAt *time.Time `json:"customer_needed_at"`
	CustomerName     *string    `json:"customer_name"`
	ContactNote      *string    `json:"contact_note"`
}

type DonMangDi struct {
	SalesOrderID int64      `json:"sales_order_id"`
	ChannelCode  string     `json:"channel_code"`
	Status       string     `json:"status"`
	TotalVnd     int64      `json:"total_vnd"`
	Lines        []gia.Dong `json:"lines"`
	LienHe
}

func cungChu(a, b *string) bool { return (a == nil && b == nil) || (a != nil && b != nil && *a == *b) }
func cungLienHe(a, b LienHe) bool {
	cungMoc := a.CustomerNeededAt == nil && b.CustomerNeededAt == nil ||
		a.CustomerNeededAt != nil && b.CustomerNeededAt != nil && a.CustomerNeededAt.Equal(*b.CustomerNeededAt)
	return a.HandoverCode == b.HandoverCode && a.CustomerPhone == b.CustomerPhone &&
		cungChu(a.DeliveryAddress, b.DeliveryAddress) && cungChu(a.CustomerName, b.CustomerName) &&
		cungChu(a.ContactNote, b.ContactNote) && cungMoc
}

func (h handler) taoOnline(w http.ResponseWriter, r *http.Request) { h.taoNgoaiBan(w, r, false) }
func (h handler) taoPhone(w http.ResponseWriter, r *http.Request)  { h.taoNgoaiBan(w, r, true) }
func (h handler) taoNgoaiBan(w http.ResponseWriter, r *http.Request, phone bool) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(w, r, &raw) {
		return
	}
	yc, err := docNgoaiBan(raw, phone)
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	// Khách web không đọc danh tính, kể cả yêu cầu có header của người trong quán.
	caller := authz.Caller{Online: true}
	if phone {
		caller = authz.Caller{PersonID: h.person(r)}
	}
	out, replay, err := tao(r.Context(), h.pool, caller, yc)
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	status := http.StatusCreated
	if replay {
		status = http.StatusOK
	}
	apierr.JSON(w, status, DonMangDi{SalesOrderID: out.SalesOrderID, ChannelCode: out.ChannelCode,
		Status: out.Status, TotalVnd: out.TotalVnd, Lines: out.Lines, LienHe: out.LienHe})
}

func docNgoaiBan(raw map[string]json.RawMessage, phone bool) (YeuCauTaiQuay, error) {
	var yc YeuCauTaiQuay
	sai := func(field string) (YeuCauTaiQuay, error) {
		return yc, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field}
	}
	if err := json.Unmarshal(raw["submission_code"], &yc.SubmissionCode); err != nil || !submissionPattern.MatchString(yc.SubmissionCode) {
		return sai("submission_code")
	}
	for _, f := range []string{"dining_table_id", "table_session_id"} {
		if _, co := raw[f]; co {
			return sai(f)
		}
	}
	var lh LienHe
	if phone {
		yc.kenh = "phone_preorder"
		if err := json.Unmarshal(raw["handover_code"], &lh.HandoverCode); err != nil || (lh.HandoverCode != "door_delivery" && lh.HandoverCode != "shop_pickup") {
			return sai("handover_code")
		}
	} else {
		if err := json.Unmarshal(raw["channel_code"], &yc.kenh); err != nil || (yc.kenh != "delivery" && yc.kenh != "pickup") {
			return sai("channel_code")
		}
		lh.HandoverCode = "shop_pickup"
		if yc.kenh == "delivery" {
			lh.HandoverCode = "door_delivery"
		}
	}
	if err := json.Unmarshal(raw["customer_phone"], &lh.CustomerPhone); err != nil || strings.TrimSpace(lh.CustomerPhone) == "" {
		return sai("customer_phone")
	}
	if v, co := raw["delivery_address"]; co {
		if err := json.Unmarshal(v, &lh.DeliveryAddress); err != nil {
			return sai("delivery_address")
		}
	}
	if lh.HandoverCode == "door_delivery" && (lh.DeliveryAddress == nil || strings.TrimSpace(*lh.DeliveryAddress) == "") {
		return sai("delivery_address")
	}
	if v, co := raw["customer_needed_at"]; co {
		// time.Time.UnmarshalJSON đòi RFC 3339 có độ lệch múi giờ.
		if err := json.Unmarshal(v, &lh.CustomerNeededAt); err != nil {
			return sai("customer_needed_at")
		}
		// PostgreSQL giữ mốc tới micro giây; cắt ngay ở đây để lần gửi lại so đúng với mốc đã ghi.
		if lh.CustomerNeededAt != nil {
			moc := lh.CustomerNeededAt.Add(-time.Duration(lh.CustomerNeededAt.Nanosecond() % 1000))
			lh.CustomerNeededAt = &moc
		}
	}
	if (phone || yc.kenh == "pickup") && lh.CustomerNeededAt == nil {
		return sai("customer_needed_at")
	}
	for _, f := range []struct {
		name  string
		value **string
	}{{"customer_name", &lh.CustomerName}, {"contact_note", &lh.ContactNote}} {
		if v, co := raw[f.name]; co {
			if err := json.Unmarshal(v, f.value); err != nil {
				return sai(f.name)
			}
		}
	}
	if err := kiemHinhDong(raw["lines"]); err != nil {
		return yc, err
	}
	var lines []gia.DongYeuCau
	if err := json.Unmarshal(raw["lines"], &lines); err != nil || len(lines) == 0 {
		return sai("lines")
	}
	yc.Lines = make([]DongGoi, len(lines))
	for i, line := range lines {
		yc.Lines[i].DongYeuCau = line
	}
	yc.ngoaiBan = &lh
	return yc, nil
}
