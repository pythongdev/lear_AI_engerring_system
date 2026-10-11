package menu

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

// Routes: hình yêu cầu kiểm trước quyền; trạng thái chỉ đọc sau khi đã qua authz.Run (trong service).
func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.PUT("/menu-components/:menu_component_id/base-price", h.doiGiaThanhPhan)
	r.PUT("/menu-options/:menu_option_id/surcharge", h.doiPhuThu)
	r.PUT("/menu-items/:menu_item_id/components/:menu_component_id", h.suaThanhPhan)
	r.POST("/menu-items/:menu_item_id/discontinuation", h.ngungBan)
}

type handler struct {
	svc *Service
}

func (h handler) doiGiaThanhPhan(c *gin.Context) {
	id, ok := docID(c, "menu_component_id")
	if !ok {
		return
	}
	var yc struct {
		BasePriceVnd *int64 `json:"base_price_vnd"`
		Reason       string `json:"reason"`
	}
	if !docJSON(c, &yc) {
		return
	}
	if yc.BasePriceVnd == nil || *yc.BasePriceVnd < 0 {
		saiTruong(c, "base_price_vnd")
		return
	}
	if !coLyDo(c, yc.Reason) {
		return
	}
	kq, err := h.svc.DoiGiaThanhPhan(c.Request.Context(), nguoi(c), id, *yc.BasePriceVnd, yc.Reason)
	traVe(c, err, struct {
		MenuComponentID int64 `json:"menu_component_id"`
		BasePriceVnd    int64 `json:"base_price_vnd"`
	}{kq.MenuComponentID, kq.BasePriceVnd})
}

func (h handler) doiPhuThu(c *gin.Context) {
	id, ok := docID(c, "menu_option_id")
	if !ok {
		return
	}
	var yc struct {
		SurchargeVnd *int64 `json:"surcharge_vnd"`
		Reason       string `json:"reason"`
	}
	if !docJSON(c, &yc) {
		return
	}
	if yc.SurchargeVnd == nil || *yc.SurchargeVnd < 0 {
		saiTruong(c, "surcharge_vnd")
		return
	}
	if !coLyDo(c, yc.Reason) {
		return
	}
	kq, err := h.svc.DoiPhuThu(c.Request.Context(), nguoi(c), id, *yc.SurchargeVnd, yc.Reason)
	traVe(c, err, struct {
		MenuOptionID int64 `json:"menu_option_id"`
		SurchargeVnd int64 `json:"surcharge_vnd"`
	}{kq.MenuOptionID, kq.SurchargeVnd})
}

func (h handler) suaThanhPhan(c *gin.Context) {
	monID, ok := docID(c, "menu_item_id")
	if !ok {
		return
	}
	tpID, ok := docID(c, "menu_component_id")
	if !ok {
		return
	}
	var yc struct {
		Quantity *int32 `json:"quantity"`
		Reason   string `json:"reason"`
	}
	if !docJSON(c, &yc) {
		return
	}
	if yc.Quantity == nil || *yc.Quantity < 1 {
		saiTruong(c, "quantity")
		return
	}
	if !coLyDo(c, yc.Reason) {
		return
	}
	kq, err := h.svc.SuaThanhPhan(c.Request.Context(), nguoi(c), monID, tpID, *yc.Quantity, yc.Reason)
	traVe(c, err, struct {
		MenuItemID      int64 `json:"menu_item_id"`
		MenuComponentID int64 `json:"menu_component_id"`
		Quantity        int32 `json:"quantity"`
	}{kq.MenuItemID, kq.MenuComponentID, kq.Quantity})
}

func (h handler) ngungBan(c *gin.Context) {
	id, ok := docID(c, "menu_item_id")
	if !ok {
		return
	}
	var yc struct {
		Reason string `json:"reason"`
	}
	if !docJSON(c, &yc) {
		return
	}
	if !coLyDo(c, yc.Reason) {
		return
	}
	kq, err := h.svc.NgungBan(c.Request.Context(), nguoi(c), id, yc.Reason)
	traVe(c, err, struct {
		MenuItemID     int64  `json:"menu_item_id"`
		DiscontinuedAt string `json:"discontinued_at"`
	}{kq.MenuItemID, kq.DiscontinuedAt})
}

// nguoi: không có người thì 0 — authz.Run trả unauthenticated.
func nguoi(c *gin.Context) int64 {
	id, _ := middleware.Nguoi(c)
	return id
}

func coLyDo(c *gin.Context, lyDo string) bool {
	if strings.TrimSpace(lyDo) == "" {
		saiTruong(c, "reason")
		return false
	}
	return true
}

func traVe(c *gin.Context, err error, out any) {
	if err != nil {
		writeErr(c, err)
		return
	}
	c.Writer.Header().Set("Content-Type", "application/json")
	c.Writer.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(c.Writer).Encode(out)
}

func docID(c *gin.Context, field string) (int64, bool) {
	id, err := strconv.ParseInt(c.Param(field), 10, 64)
	if err != nil || id <= 0 {
		saiTruong(c, field)
		return 0, false
	}
	return id, true
}

func docJSON(c *gin.Context, out any) bool {
	dec := json.NewDecoder(c.Request.Body)
	if err := dec.Decode(out); err != nil {
		saiTruong(c, "")
		return false
	}
	if err := dec.Decode(new(any)); err != io.EOF {
		saiTruong(c, "")
		return false
	}
	return true
}

func saiTruong(c *gin.Context, field string) {
	apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
}

func writeErr(c *gin.Context, err error) {
	var e apierr.Error
	if errors.As(err, &e) {
		apierr.Write(c.Writer, e)
		return
	}
	e, name := apierr.FromDB(err)
	if e.Code == apierr.CodeInternalError {
		log.Printf("menu: lỗi hệ thống (tên từ chối %q): %v", name, err)
	}
	apierr.Write(c.Writer, e)
}
