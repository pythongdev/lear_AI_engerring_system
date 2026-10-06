// Package menu giữ bốn cửa sửa menu của chủ quán (P3-06, I-011 · I-012 · I-018).
// Giá suất không có cửa sửa: nó là kết quả của gia.Tinh.
package menu

import (
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var DoiGiaThanhPhan = authz.Door{Code: "menu/doi_gia_thanh_phan", Need: authz.NeedOwner}
var DoiPhuThu = authz.Door{Code: "menu/doi_phu_thu", Need: authz.NeedOwner}
var SuaThanhPhan = authz.Door{Code: "menu/sua_thanh_phan", Need: authz.NeedOwner}
var NgungBan = authz.Door{Code: "menu/ngung_ban", Need: authz.NeedOwner}

//go:embed sql/doi_gia_thanh_phan/doi_gia.sql
var doiGia string

//go:embed sql/doi_phu_thu/doi_phu_thu.sql
var doiPhuThu string

//go:embed sql/sua_thanh_phan/sua_so_luong.sql
var suaSoLuong string

//go:embed sql/ngung_ban/ngung_ban.sql
var ngungBan string

// Routes: hình yêu cầu kiểm trước quyền; trạng thái chỉ đọc sau khi đã qua authz.Run.
func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	h := handler{pool: pool, auth: auth}
	mux.HandleFunc("PUT /menu-components/{menu_component_id}/base-price", h.doiGiaThanhPhan)
	mux.HandleFunc("PUT /menu-options/{menu_option_id}/surcharge", h.doiPhuThu)
	mux.HandleFunc("PUT /menu-items/{menu_item_id}/components/{menu_component_id}", h.suaThanhPhan)
	mux.HandleFunc("POST /menu-items/{menu_item_id}/discontinuation", h.ngungBan)
}

type handler struct {
	pool *pgxpool.Pool
	auth authz.Authenticator
}

func (h handler) doiGiaThanhPhan(w http.ResponseWriter, r *http.Request) {
	id, ok := docID(w, r, "menu_component_id")
	if !ok {
		return
	}
	var yc struct {
		BasePriceVnd *int64 `json:"base_price_vnd"`
		Reason       string `json:"reason"`
	}
	if !docJSON(w, r, &yc) {
		return
	}
	if yc.BasePriceVnd == nil || *yc.BasePriceVnd < 0 {
		saiTruong(w, "base_price_vnd")
		return
	}
	var out struct {
		MenuComponentID int64 `json:"menu_component_id"`
		BasePriceVnd    int64 `json:"base_price_vnd"`
	}
	h.sua(w, r, DoiGiaThanhPhan, yc.Reason, &out, func(tx pgx.Tx) error {
		if err := docDong(r.Context(), tx, "SELECT id FROM menu_component WHERE id = $1 FOR UPDATE", apierr.CodeMenuComponentNotFound, id); err != nil {
			return err
		}
		if err := khaiLyDo(r.Context(), tx, yc.Reason); err != nil {
			return err
		}
		return tx.QueryRow(r.Context(), doiGia, id, *yc.BasePriceVnd).Scan(&out.MenuComponentID, &out.BasePriceVnd)
	})
}

func (h handler) doiPhuThu(w http.ResponseWriter, r *http.Request) {
	id, ok := docID(w, r, "menu_option_id")
	if !ok {
		return
	}
	var yc struct {
		SurchargeVnd *int64 `json:"surcharge_vnd"`
		Reason       string `json:"reason"`
	}
	if !docJSON(w, r, &yc) {
		return
	}
	if yc.SurchargeVnd == nil || *yc.SurchargeVnd < 0 {
		saiTruong(w, "surcharge_vnd")
		return
	}
	var out struct {
		MenuOptionID int64 `json:"menu_option_id"`
		SurchargeVnd int64 `json:"surcharge_vnd"`
	}
	h.sua(w, r, DoiPhuThu, yc.Reason, &out, func(tx pgx.Tx) error {
		if err := docDong(r.Context(), tx, "SELECT id FROM menu_option WHERE id = $1 FOR UPDATE", apierr.CodeMenuOptionNotFound, id); err != nil {
			return err
		}
		if err := khaiLyDo(r.Context(), tx, yc.Reason); err != nil {
			return err
		}
		return tx.QueryRow(r.Context(), doiPhuThu, id, *yc.SurchargeVnd).Scan(&out.MenuOptionID, &out.SurchargeVnd)
	})
}

func (h handler) suaThanhPhan(w http.ResponseWriter, r *http.Request) {
	monID, ok := docID(w, r, "menu_item_id")
	if !ok {
		return
	}
	tpID, ok := docID(w, r, "menu_component_id")
	if !ok {
		return
	}
	var yc struct {
		Quantity *int32 `json:"quantity"`
		Reason   string `json:"reason"`
	}
	if !docJSON(w, r, &yc) {
		return
	}
	if yc.Quantity == nil || *yc.Quantity < 1 {
		saiTruong(w, "quantity")
		return
	}
	var out struct {
		MenuItemID      int64 `json:"menu_item_id"`
		MenuComponentID int64 `json:"menu_component_id"`
		Quantity        int32 `json:"quantity"`
	}
	h.sua(w, r, SuaThanhPhan, yc.Reason, &out, func(tx pgx.Tx) error {
		if err := docDong(r.Context(), tx, "SELECT id FROM menu_item WHERE id = $1", apierr.CodeMenuItemNotFound, monID); err != nil {
			return err
		}
		if err := docDong(r.Context(), tx, "SELECT id FROM menu_component WHERE id = $1", apierr.CodeMenuComponentNotFound, tpID); err != nil {
			return err
		}
		if err := docDong(r.Context(), tx, "SELECT id FROM menu_item_component WHERE menu_item_id = $1 AND menu_component_id = $2 FOR UPDATE", apierr.CodeMenuItemComponentNotFound, monID, tpID); err != nil {
			return err
		}
		if err := khaiLyDo(r.Context(), tx, yc.Reason); err != nil {
			return err
		}
		return tx.QueryRow(r.Context(), suaSoLuong, monID, tpID, *yc.Quantity).Scan(&out.MenuItemID, &out.MenuComponentID, &out.Quantity)
	})
}

func (h handler) ngungBan(w http.ResponseWriter, r *http.Request) {
	id, ok := docID(w, r, "menu_item_id")
	if !ok {
		return
	}
	var yc struct {
		Reason string `json:"reason"`
	}
	if !docJSON(w, r, &yc) {
		return
	}
	var out struct {
		MenuItemID     int64  `json:"menu_item_id"`
		DiscontinuedAt string `json:"discontinued_at"`
	}
	h.sua(w, r, NgungBan, yc.Reason, &out, func(tx pgx.Tx) error {
		var daNgung bool
		err := tx.QueryRow(r.Context(), "SELECT discontinued_at IS NOT NULL FROM menu_item WHERE id = $1 FOR UPDATE", id).Scan(&daNgung)
		if errors.Is(err, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodeMenuItemNotFound}
		}
		if err != nil {
			return err
		}
		// Đã có mốc thì không ghi đè, kể cả lần thứ hai bắt đầu trước lần thứ nhất hoàn tất.
		if daNgung {
			return apierr.Error{Code: apierr.CodeMenuItemDiscontinued}
		}
		if err := khaiLyDo(r.Context(), tx, yc.Reason); err != nil {
			return err
		}
		return tx.QueryRow(r.Context(), ngungBan, id).Scan(&out.MenuItemID, &out.DiscontinuedAt)
	})
}

func (h handler) sua(w http.ResponseWriter, r *http.Request, cua authz.Door, lyDo string, out any, fn func(pgx.Tx) error) {
	if strings.TrimSpace(lyDo) == "" {
		saiTruong(w, "reason")
		return
	}
	var nguoi int64
	if h.auth != nil {
		if id, ok := h.auth.PersonID(r); ok {
			nguoi = id
		}
	}
	if err := authz.Run(r.Context(), h.pool, nguoi, cua, fn); err != nil {
		writeErr(w, err)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(out)
}

func khaiLyDo(ctx context.Context, tx pgx.Tx, lyDo string) error {
	_, err := tx.Exec(ctx, "SELECT set_config('shop.revision_reason', $1, true)", strings.TrimSpace(lyDo))
	return err
}

func docDong(ctx context.Context, tx pgx.Tx, sql string, code apierr.Code, args ...any) error {
	var id int64
	err := tx.QueryRow(ctx, sql, args...).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.Error{Code: code}
	}
	return err
}

func docID(w http.ResponseWriter, r *http.Request, field string) (int64, bool) {
	id, err := strconv.ParseInt(r.PathValue(field), 10, 64)
	if err != nil || id <= 0 {
		saiTruong(w, field)
		return 0, false
	}
	return id, true
}

func docJSON(w http.ResponseWriter, r *http.Request, out any) bool {
	dec := json.NewDecoder(r.Body)
	if err := dec.Decode(out); err != nil {
		saiTruong(w, "")
		return false
	}
	if err := dec.Decode(new(any)); err != io.EOF {
		saiTruong(w, "")
		return false
	}
	return true
}

func saiTruong(w http.ResponseWriter, field string) {
	apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
}

func writeErr(w http.ResponseWriter, err error) {
	var e apierr.Error
	if errors.As(err, &e) {
		apierr.Write(w, e)
		return
	}
	e, name := apierr.FromDB(err)
	if e.Code == apierr.CodeInternalError {
		log.Printf("menu: lỗi hệ thống (tên từ chối %q): %v", name, err)
	}
	apierr.Write(w, e)
}
