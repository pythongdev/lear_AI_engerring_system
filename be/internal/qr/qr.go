// Package qr giữ mã QR của bàn: khách vào bàn qua mã HIỆN HÀNH (I-023), chủ quán đổi mã (U-062).
// Lớp quyền của cửa: docs/product/3-be/02-vai-va-quyen.md (P3-05, ADR-085).
package qr

import (
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// DoiMa — cấp mã mới cho một bàn; mã cũ hết hiện hành cùng mốc. Chỉ chủ quán (U-062).
var DoiMa = authz.Door{Code: "qr/doi_ma", Need: authz.NeedOwner}

//go:embed sql/doi_ma/cap_ma.sql
var capMa string

// Mốc gửi xuống theo RFC 3339 có độ lệch, ở múi giờ của kết nối — múi giờ quán (QC-15).
const docMaVuaCap = `SELECT code, dining_table_id,
       to_char(issued_at, 'YYYY-MM-DD"T"HH24:MI:SS.USTZH:TZM')
  FROM qr_code WHERE id = $1`

// Một bản câu tra mã ở authz, tránh vòng import với lớp quay_hoac_khach.
type Querier = authz.Querier
type Seat = authz.Seat

func CurrentTable(ctx context.Context, q Querier, code string) (Seat, error) {
	return authz.CurrentTable(ctx, q, code)
}

// Routes đăng ký hai đường gọi của lát này.
func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	h := handler{pool: pool, auth: auth}
	mux.HandleFunc("GET /qr-codes/{code}", h.banCuaKhach)
	mux.HandleFunc("POST /dining-tables/{dining_table_id}/qr-code", h.doiMa)
}

type handler struct {
	pool *pgxpool.Pool
	auth authz.Authenticator
}

// banCuaKhach: khách mang mã, không mang bàn. Một định danh bàn gửi kèm bị từ chối, không dùng.
func (h handler) banCuaKhach(w http.ResponseWriter, r *http.Request) {
	if r.URL.Query().Has("dining_table_id") {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
		return
	}
	seat, err := CurrentTable(r.Context(), h.pool, r.PathValue("code"))
	if err != nil {
		writeErr(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"label": seat.Label})
}

type maVuaCap struct {
	Code          string `json:"code"`
	DiningTableID int64  `json:"dining_table_id"`
	IssuedAt      string `json:"issued_at"`
}

func (h handler) doiMa(w http.ResponseWriter, r *http.Request) {
	banID, err := strconv.ParseInt(r.PathValue("dining_table_id"), 10, 64)
	if err != nil || banID <= 0 {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
		return
	}
	nguoi, _ := h.auth.PersonID(r)
	var out maVuaCap
	err = authz.Run(r.Context(), h.pool, nguoi, DoiMa, func(tx pgx.Tx) error {
		var id int64
		if err := tx.QueryRow(r.Context(), capMa, banID).Scan(&id); err != nil {
			return err
		}
		return tx.QueryRow(r.Context(), docMaVuaCap, id).Scan(&out.Code, &out.DiningTableID, &out.IssuedAt)
	})
	if err != nil {
		writeErr(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, out)
}

// writeErr: lời từ chối có mã đi thẳng; lỗi của database dịch qua TÊN (ADR-082 điểm 5), tên được
// ghi lại, câu nguyên văn không tới người dùng.
func writeErr(w http.ResponseWriter, err error) {
	var e apierr.Error
	if errors.As(err, &e) {
		apierr.Write(w, e)
		return
	}
	e, name := apierr.FromDB(err)
	if e.Code == apierr.CodeInternalError {
		log.Printf("qr: lỗi hệ thống (tên từ chối %q): %v", name, err)
	}
	apierr.Write(w, e)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
