package hoadon

import (
	_ "embed"
	"errors"
	"math"
	"net/http"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/db"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/tratruoc"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var TraoTaiQuay = authz.Door{Code: "hoadon/trao_tai_quay", Need: authz.NeedCounter}
var GiaoXong = authz.Door{Code: "hoadon/giao_xong", Need: authz.NeedPerson}
var Hoan = authz.Door{Code: "hoadon/hoan", Need: authz.NeedCounter}
var ThuNo = authz.Door{Code: "hoadon/thu_no", Need: authz.NeedCounter}
var TraLai = authz.Door{Code: "hoadon/tra_lai", Need: authz.NeedCounter}

//go:embed sql/trao_tai_quay/khoa.sql
var traoKhoa string

//go:embed sql/trao_tai_quay/tong.sql
var traoTong string

//go:embed sql/trao_tai_quay/viec.sql
var traoViec string

//go:embed sql/giao_xong/khoa.sql
var giaoKhoa string

//go:embed sql/giao_xong/tong.sql
var giaoTong string

//go:embed sql/hoan/khoa.sql
var hoanKhoa string

//go:embed sql/tra_lai/khoa.sql
var traKhoa string

//go:embed sql/thu_no/khoa.sql
var noKhoa string

//go:embed sql/thu_no/du.sql
var noDu string

//go:embed sql/thu_no/them.sql
var noThem string

//go:embed sql/no.sql
var danhSachNo string

type handler struct {
	pool *pgxpool.Pool
	auth authz.Authenticator
}

func (h handler) person(r *http.Request) int64 {
	if h.auth == nil {
		return 0
	}
	id, _ := h.auth.PersonID(r)
	return id
}
func tienRoutes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	h := handler{pool, auth}
	mux.HandleFunc("POST /orders/{sales_order_id}/handover", h.traoTaiQuay)
	mux.HandleFunc("POST /orders/{sales_order_id}/delivered", h.giaoXong)
	mux.HandleFunc("POST /bills/{bill_id}/refunds", h.hoan)
	mux.HandleFunc("POST /bills/{bill_id}/debt-collections", h.thuNo)
	mux.HandleFunc("POST /prepayments/{prepayment_id}/returns", h.traLai)
	mux.HandleFunc("GET /debts", h.docNo)
}
func sai(field string) error { return apierr.Error{Code: apierr.CodeInvalidRequest, Field: field} }

type ThanhToan struct {
	Cash            *int64  `json:"cash_vnd"`
	Transfer        *int64  `json:"transfer_vnd"`
	PrepaidCash     int64   `json:"prepaid_cash_vnd"`
	PrepaidTransfer int64   `json:"prepaid_transfer_vnd"`
	Debt            int64   `json:"debt_vnd"`
	Discount        int64   `json:"discount_vnd"`
	Debtor          *string `json:"debtor_name"`
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
	return nil
}

func (h handler) traoTaiQuay(w http.ResponseWriter, r *http.Request) {
	h.trao(w, r, TraoTaiQuay, traoKhoa, traoTong, false)
}
func (h handler) giaoXong(w http.ResponseWriter, r *http.Request) {
	h.trao(w, r, GiaoXong, giaoKhoa, giaoTong, true)
}
func (h handler) trao(w http.ResponseWriter, r *http.Request, cua authz.Door, khoa, tongSQL string, giao bool) {
	id, ok := apierr.ReadID(w, r, "sales_order_id")
	if !ok {
		return
	}
	var p ThanhToan
	if !apierr.ReadJSON(w, r, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(w, err)
		return
	}
	var bill, due int64
	err := authz.Run(r.Context(), h.pool, h.person(r), cua, func(tx pgx.Tx) error {
		if p.Discount > 0 {
			return apierr.Error{Code: apierr.CodeOrderDiscountUndecided}
		}
		if p.Debt > 0 {
			return apierr.Error{Code: apierr.CodeStandaloneDebtUndecided}
		}
		var phien *int64
		var status, kenh string
		var trao *string
		if err := tx.QueryRow(r.Context(), khoa, id).Scan(&phien, &status, &kenh, &trao); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(r.Context(), tx)
		if err != nil {
			return err
		}
		doorDelivery := trao != nil && *trao == "door_delivery"
		if phien != nil || giao != doorDelivery {
			return apierr.Error{Code: apierr.CodeOrderHandoverMismatch}
		}
		source := "in_progress"
		if giao {
			source = "delivering"
		}
		if status != source {
			return apierr.Error{Code: apierr.CodeOrderTransitionNotAllowed}
		}
		if err := vongdoi.KiemChuyenDon(status, "completed", kenh, trao); err != nil {
			return err
		}
		if !giao {
			var con bool
			if err := tx.QueryRow(r.Context(), traoViec, id).Scan(&con); err != nil {
				return err
			}
			if con {
				return apierr.Error{Code: apierr.CodeOrderJobsNotServed}
			}
		}
		if err := tx.QueryRow(r.Context(), tongSQL, id).Scan(&due); err != nil {
			return err
		}
		bill, err = Ghi(r.Context(), tx, NoiDung{Don: &id, Due: due, Cash: *p.Cash, Transfer: *p.Transfer, PrepaidCash: p.PrepaidCash, PrepaidTransfer: p.PrepaidTransfer, Debt: p.Debt, Debtor: p.Debtor, Moc: moc})
		if err != nil {
			return err
		}
		return vongdoi.ChuyenDon(r.Context(), tx, id, "completed")
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 201, map[string]any{"bill_id": bill, "sales_order_id": id, "due_vnd": due, "status": "completed"})
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
func (h handler) hoan(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "bill_id")
	if !ok {
		return
	}
	var p HoanYeuCau
	if !apierr.ReadJSON(w, r, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(w, err)
		return
	}
	var out int64
	err := authz.Run(r.Context(), h.pool, h.person(r), Hoan, func(tx pgx.Tx) error {
		var found int64
		if err := tx.QueryRow(r.Context(), hoanKhoa, id).Scan(&found); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeBillNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(r.Context(), tx)
		if err != nil {
			return err
		}
		out, err = GhiHoan(r.Context(), tx, &id, nil, *p.Amount, p.Method, &p.Source, p.Reason, moc)
		return err
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 201, map[string]any{"refund_id": out, "bill_id": id})
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
func (h handler) traLai(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "prepayment_id")
	if !ok {
		return
	}
	var p TraLaiYeuCau
	if !apierr.ReadJSON(w, r, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(w, err)
		return
	}
	var out int64
	amount := *p.Cash + *p.Transfer
	err := authz.Run(r.Context(), h.pool, h.person(r), TraLai, func(tx pgx.Tx) error {
		var found int64
		if err := tx.QueryRow(r.Context(), traKhoa, id).Scan(&found); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodePrepaymentNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(r.Context(), tx)
		if err != nil {
			return err
		}
		if _, err := tratruoc.KiemSoDu(r.Context(), tx, id, *p.Cash, *p.Transfer); err != nil {
			return err
		}
		out, err = GhiHoan(r.Context(), tx, nil, &id, amount, p.Method, nil, p.Reason, moc)
		if err != nil {
			return err
		}
		return tratruoc.Dung(r.Context(), tx, id, *p.Cash, *p.Transfer, nil, &out)
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 201, map[string]any{"refund_id": out, "prepayment_id": id, "amount_vnd": amount})
}

func (h handler) thuNo(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "bill_id")
	if !ok {
		return
	}
	var p tratruoc.PhanTien
	if !apierr.ReadJSON(w, r, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(w, err)
		return
	}
	var out, remaining int64
	err := authz.Run(r.Context(), h.pool, h.person(r), ThuNo, func(tx pgx.Tx) error {
		var debt int64
		if err := tx.QueryRow(r.Context(), noKhoa, id).Scan(&debt); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeBillNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(r.Context(), tx)
		if err != nil {
			return err
		}
		if debt == 0 {
			return apierr.Error{Code: apierr.CodeBillHasNoDebt}
		}
		var before *int64
		if err := tx.QueryRow(r.Context(), noDu, id).Scan(&before); err != nil {
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
		return tx.QueryRow(r.Context(), noThem, id, debt, *p.Cash, *p.Transfer, before, remaining, moc).Scan(&out)
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 201, map[string]any{"debt_collection_id": out, "bill_id": id, "remaining_vnd": remaining})
}

func (h handler) docNo(w http.ResponseWriter, r *http.Request) {
	debts := []map[string]any{}
	err := db.InTx(r.Context(), h.pool, func(tx pgx.Tx) error {
		rows, err := tx.Query(r.Context(), danhSachNo)
		if err != nil {
			return err
		}
		defer rows.Close()
		for rows.Next() {
			var id, debt, remain int64
			var name string
			if err := rows.Scan(&id, &name, &debt, &remain); err != nil {
				return err
			}
			debts = append(debts, map[string]any{"bill_id": id, "debtor_name": name, "debt_vnd": debt, "remaining_vnd": remain})
		}
		return rows.Err()
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 200, map[string]any{"debts": debts})
}
