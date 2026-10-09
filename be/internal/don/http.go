package don

import (
	_ "embed"
	"encoding/json"
	"errors"
	"net/http"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var Duyet = authz.Door{Code: "don/duyet", Need: authz.NeedCounter}
var TuChoi = authz.Door{Code: "don/tu_choi", Need: authz.NeedCounter}

//go:embed sql/duyet/doc_phien.sql
var duyetDocPhien string

//go:embed sql/duyet/khoa_phien.sql
var duyetKhoaPhien string

//go:embed sql/duyet/khoa_don.sql
var duyetKhoaDon string

//go:embed sql/tu_choi/doc_phien.sql
var tuChoiDocPhien string

//go:embed sql/tu_choi/khoa_phien.sql
var tuChoiKhoaPhien string

//go:embed sql/tu_choi/khoa_don.sql
var tuChoiKhoaDon string

type handler struct {
	pool *pgxpool.Pool
	auth authz.Authenticator
}

func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	h := handler{pool, auth}
	mux.HandleFunc("POST /table-orders", h.taoTaiQuay)
	mux.HandleFunc("POST /qr-codes/{code}/orders", h.taoQR)
	mux.HandleFunc("POST /orders/{sales_order_id}/approval", h.duyet)
	mux.HandleFunc("POST /orders/{sales_order_id}/rejection", h.tuChoi)
}
func (h handler) person(r *http.Request) int64 {
	if h.auth == nil {
		return 0
	}
	id, _ := h.auth.PersonID(r)
	return id
}
func (h handler) taoTaiQuay(w http.ResponseWriter, r *http.Request) { h.taoHTTP(w, r, "") }
func (h handler) taoQR(w http.ResponseWriter, r *http.Request)      { h.taoHTTP(w, r, r.PathValue("code")) }
func (h handler) taoHTTP(w http.ResponseWriter, r *http.Request, qr string) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(w, r, &raw) {
		return
	}
	var yc YeuCauTaiQuay
	// Dấu kiểm trước mọi quyền, gồm cả lỗi kiểu của chính trường ấy.
	if err := json.Unmarshal(raw["submission_code"], &yc.SubmissionCode); err != nil || !submissionPattern.MatchString(yc.SubmissionCode) {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "submission_code"})
		return
	}
	for _, f := range []string{"table_session_id", "dining_table_id"} {
		if _, co := raw[f]; co && (f == "table_session_id" || qr != "") {
			apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: f})
			return
		}
	}
	if qr == "" {
		if err := json.Unmarshal(raw["dining_table_id"], &yc.DiningTableID); err != nil || yc.DiningTableID <= 0 {
			apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
			return
		}
	}
	if err := json.Unmarshal(raw["lines"], &yc.Lines); err != nil {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "lines"})
		return
	}
	out, replay, err := tao(r.Context(), h.pool, authz.Caller{PersonID: h.person(r), QRCode: qr}, yc)
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	status := http.StatusCreated
	if replay {
		status = http.StatusOK
	}
	apierr.JSON(w, status, out)
}
func (h handler) duyet(w http.ResponseWriter, r *http.Request) {
	h.chuyen(w, r, Duyet, "confirmed", duyetDocPhien, duyetKhoaPhien, duyetKhoaDon)
}
func (h handler) tuChoi(w http.ResponseWriter, r *http.Request) {
	h.chuyen(w, r, TuChoi, "cancelled", tuChoiDocPhien, tuChoiKhoaPhien, tuChoiKhoaDon)
}
func (h handler) chuyen(w http.ResponseWriter, r *http.Request, door authz.Door, den, doc, khoa, khoaDon string) {
	id, ok := apierr.ReadID(w, r, "sales_order_id")
	if !ok {
		return
	}
	var sessionID *int64
	var sessionStatus *string
	err := authz.Run(r.Context(), h.pool, h.person(r), door, func(tx pgx.Tx) error {
		if err := tx.QueryRow(r.Context(), doc, id).Scan(&sessionID); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		if sessionID != nil {
			if err := tx.QueryRow(r.Context(), khoa, *sessionID).Scan(&sessionStatus); err != nil {
				return err
			}
		}
		var status string
		if err := tx.QueryRow(r.Context(), khoaDon, id).Scan(&status); err != nil {
			return err
		}
		// Từ chối chờ duyệt khác cửa huỷ một đơn đã xác nhận (P3-09/P3-10).
		if status != "pending_confirmation" {
			return apierr.Error{Code: apierr.CodeOrderTransitionNotAllowed}
		}
		if err := vongdoi.ChuyenDon(r.Context(), tx, id, den); err != nil {
			return err
		}
		if den == "confirmed" && sessionID != nil && sessionStatus != nil && *sessionStatus == "open" {
			if err := vongdoi.ChuyenPhien(r.Context(), tx, *sessionID, "serving"); err != nil {
				return err
			}
			*sessionStatus = "serving"
		}
		return nil
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"sales_order_id": id, "status": den, "table_session_id": sessionID, "table_session_status": sessionStatus})
}
