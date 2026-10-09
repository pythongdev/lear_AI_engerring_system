package sanxuat

import (
	"encoding/json"
	"net/http"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5/pgxpool"
)

type handler struct {
	pool *pgxpool.Pool
	auth authz.Authenticator
}

func Routes(mux *http.ServeMux, pool *pgxpool.Pool, a authz.Authenticator) {
	h := handler{pool, a}
	mux.HandleFunc("POST /production-batches", h.bamMe)
	mux.HandleFunc("POST /production-batches/{id}/rollback", h.luiMe)
	mux.HandleFunc("POST /served-marks", h.raBan)
	mux.HandleFunc("POST /station-job-transfers", h.chuyen)
	mux.HandleFunc("POST /wrong-make-notes", h.ghiLamSai)
	mux.HandleFunc("POST /wrong-make-notes/{id}/cancellation", h.huyGhiLamSai)
	mux.HandleFunc("GET /production-board", h.bang)
	mux.HandleFunc("GET /station-jobs/{id}/transfer-candidates", h.ungVien)
}

func (h handler) person(r *http.Request) int64 {
	if h.auth == nil {
		return 0
	}
	id, _ := h.auth.PersonID(r)
	return id
}

// Đọc tập quầy chọn, không suy ra từ bàn hoặc mẻ; null cũng không phải một mã.
func docTap(w http.ResponseWriter, r *http.Request) ([]int64, bool) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(w, r, &raw) {
		return nil, false
	}
	var ids []int64
	err := json.Unmarshal(raw["station_job_ids"], &ids)
	seen := make(map[int64]bool)
	hop := err == nil && len(ids) > 0
	for _, id := range ids {
		if id <= 0 || seen[id] {
			hop = false
		}
		seen[id] = true
	}
	if !hop {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "station_job_ids"})
		return nil, false
	}
	return ids, true
}
