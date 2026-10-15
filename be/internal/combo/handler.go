package combo

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"strconv"
	"strings"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc}
	r.GET("/menu-combos", h.doc)
	r.POST("/menu-combos", h.them)
	r.PUT("/menu-combos/:menu_combo_id/price", h.doiGia)
	r.POST("/menu-combos/:menu_combo_id/hiding", h.an)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 { id, _ := middleware.Nguoi(c); return id }
func sai(c *gin.Context, field string) {
	apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
}
func tra(c *gin.Context, status int, out any, err error) {
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, status, out)
}
func ma(c *gin.Context, field string) (int64, bool) {
	id, e := strconv.ParseInt(c.Param(field), 10, 64)
	if e != nil || id <= 0 {
		sai(c, field)
		return 0, false
	}
	return id, true
}

// Đọc giá riêng để số lẻ mang field=price_vnd, còn sai kiểu JSON là invalid_request.
func docGia(c *gin.Context, raw json.RawMessage) (int64, bool) {
	if len(raw) == 0 || string(raw) == "null" {
		sai(c, "price_vnd")
		return 0, false
	}
	if raw[0] == '"' {
		sai(c, "")
		return 0, false
	}
	var n json.Number
	if e := json.Unmarshal(raw, &n); e != nil {
		sai(c, "")
		return 0, false
	}
	gia, e := n.Int64()
	if e != nil || gia <= 0 {
		sai(c, "price_vnd")
		return 0, false
	}
	return gia, true
}
func (h handler) them(c *gin.Context) {
	var p struct {
		Name  string          `json:"name"`
		Price json.RawMessage `json:"price_vnd"`
		Items []ThanhPhan     `json:"items"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Name = strings.TrimSpace(p.Name)
	if p.Name == "" {
		sai(c, "name")
		return
	}
	gia, ok := docGia(c, p.Price)
	if !ok {
		return
	}
	if len(p.Items) == 0 {
		sai(c, "items")
		return
	}
	seen := map[int64]bool{}
	for i, item := range p.Items {
		if item.MenuItemID <= 0 {
			sai(c, fmt.Sprintf("items[%d].menu_item_id", i))
			return
		}
		if item.Quantity <= 0 {
			sai(c, fmt.Sprintf("items[%d].quantity", i))
			return
		}
		if seen[item.MenuItemID] {
			sai(c, fmt.Sprintf("items[%d].menu_item_id", i))
			return
		}
		seen[item.MenuItemID] = true
	}
	out, e := h.svc.Them(c.Request.Context(), nguoi(c), p.Name, gia, p.Items)
	tra(c, 201, out, e)
}
func (h handler) doiGia(c *gin.Context) {
	id, ok := ma(c, "menu_combo_id")
	if !ok {
		return
	}
	var p struct {
		Price  json.RawMessage `json:"price_vnd"`
		Reason string          `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	gia, ok := docGia(c, p.Price)
	if !ok {
		return
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if p.Reason == "" {
		sai(c, "reason")
		return
	}
	out, e := h.svc.DoiGia(c.Request.Context(), nguoi(c), id, gia, p.Reason)
	tra(c, 200, out, e)
}
func (h handler) an(c *gin.Context) {
	id, ok := ma(c, "menu_combo_id")
	if !ok {
		return
	}
	var p struct {
		Reason string `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if p.Reason == "" {
		sai(c, "reason")
		return
	}
	out, e := h.svc.An(c.Request.Context(), nguoi(c), id, p.Reason)
	tra(c, 200, out, e)
}
func (h handler) doc(c *gin.Context) {
	kemAn := false
	if raw, co := c.GetQueryArray("include_hidden"); co {
		if raw[0] != "true" && raw[0] != "false" {
			sai(c, "include_hidden")
			return
		}
		kemAn = raw[0] == "true"
	}
	out, e := h.svc.Doc(c.Request.Context(), nguoi(c), kemAn)
	tra(c, 200, out, e)
}
