package nguyenlieu

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
	"regexp"
	"strconv"
	"strings"
	"time"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/supply-items", h.doc)
	r.POST("/supply-items", h.them)
	r.PUT("/supply-items/:supply_item_id/purchase-unit", h.dat)
	r.GET("/supply-items/:supply_item_id", h.chiTiet)
	r.POST("/supply-day-entries", h.ghi)
	r.PUT("/supply-day-entries/:supply_day_entry_id", h.sua)
}

type handler struct{ svc *Service }

var measurePattern = regexp.MustCompile(`^(0|[1-9][0-9]{0,8})(\.[0-9]{1,3})?$`)

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
	id, err := strconv.ParseInt(c.Param(field), 10, 64)
	if err != nil || id <= 0 {
		sai(c, field)
		return 0, false
	}
	return id, true
}
func (h handler) them(c *gin.Context) {
	var p struct {
		Name         string  `json:"name"`
		PurchaseUnit *string `json:"purchase_unit"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Name = strings.TrimSpace(p.Name)
	if p.Name == "" {
		sai(c, "name")
		return
	}
	unit := ""
	if p.PurchaseUnit != nil {
		unit = strings.TrimSpace(*p.PurchaseUnit)
		if unit == "" {
			sai(c, "purchase_unit")
			return
		}
	}
	out, err := h.svc.Them(c.Request.Context(), nguoi(c), p.Name, unit)
	tra(c, 201, out, err)
}
func (h handler) dat(c *gin.Context) {
	id, ok := ma(c, "supply_item_id")
	if !ok {
		return
	}
	var p struct {
		PurchaseUnit string `json:"purchase_unit"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.PurchaseUnit = strings.TrimSpace(p.PurchaseUnit)
	if p.PurchaseUnit == "" {
		sai(c, "purchase_unit")
		return
	}
	out, err := h.svc.Dat(c.Request.Context(), nguoi(c), id, p.PurchaseUnit)
	tra(c, 200, out, err)
}
func docYeuCau(c *gin.Context, sua bool) (YeuCau, bool) {
	var p YeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return p, false
	}
	if !measurePattern.MatchString(p.Measure) {
		sai(c, "measure")
		return p, false
	}
	if sua {
		p.Reason = strings.TrimSpace(p.Reason)
		if p.Reason == "" {
			sai(c, "reason")
			return p, false
		}
	} else {
		if p.ItemID <= 0 {
			sai(c, "supply_item_id")
			return p, false
		}
		d, err := time.Parse("2006-01-02", p.EntryDate)
		if err != nil || d.Year() < 1 || d.Format("2006-01-02") != p.EntryDate {
			sai(c, "entry_date")
			return p, false
		}
		if p.Kind != "purchased" && p.Kind != "used" {
			sai(c, "kind")
			return p, false
		}
	}
	return p, true
}
func (h handler) ghi(c *gin.Context) {
	p, ok := docYeuCau(c, false)
	if !ok {
		return
	}
	out, err := h.svc.Ghi(c.Request.Context(), nguoi(c), p)
	tra(c, 201, out, err)
}
func (h handler) sua(c *gin.Context) {
	id, ok := ma(c, "supply_day_entry_id")
	if !ok {
		return
	}
	p, ok := docYeuCau(c, true)
	if !ok {
		return
	}
	out, err := h.svc.Sua(c.Request.Context(), nguoi(c), id, p)
	tra(c, 200, out, err)
}
func (h handler) doc(c *gin.Context) {
	out, err := h.svc.Doc(c.Request.Context(), nguoi(c))
	tra(c, 200, map[string]any{"supply_items": out}, err)
}
func (h handler) chiTiet(c *gin.Context) {
	id, ok := ma(c, "supply_item_id")
	if !ok {
		return
	}
	out, err := h.svc.DocChiTiet(c.Request.Context(), nguoi(c), id)
	tra(c, 200, out, err)
}
