package danhmuc

import (
	"strconv"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc}
	r.GET("/menu-categories", h.doc)
	r.POST("/menu-categories", h.them)
	r.PUT("/menu-categories/:menu_category_id", h.doiTen)
	r.POST("/menu-categories/:menu_category_id/hiding", h.an)
	r.PUT("/menu-items/:menu_item_id/category", h.xepMon)
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

type yeuCau struct {
	Name   string `json:"name"`
	Reason string `json:"reason"`
}

func docYeuCau(c *gin.Context, doiTen bool) (yeuCau, bool) {
	var p yeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return p, false
	}
	p.Name = strings.TrimSpace(p.Name)
	p.Reason = strings.TrimSpace(p.Reason)
	if p.Name == "" {
		sai(c, "name")
		return p, false
	}
	if doiTen && p.Reason == "" {
		sai(c, "reason")
		return p, false
	}
	return p, true
}
func (h handler) them(c *gin.Context) {
	p, ok := docYeuCau(c, false)
	if !ok {
		return
	}
	out, e := h.svc.Them(c.Request.Context(), nguoi(c), p.Name)
	tra(c, 201, out, e)
}
func (h handler) doiTen(c *gin.Context) {
	id, ok := ma(c, "menu_category_id")
	if !ok {
		return
	}
	p, ok := docYeuCau(c, true)
	if !ok {
		return
	}
	out, e := h.svc.DoiTen(c.Request.Context(), nguoi(c), id, p.Name, p.Reason)
	tra(c, 200, out, e)
}
func (h handler) an(c *gin.Context) {
	id, ok := ma(c, "menu_category_id")
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
func (h handler) xepMon(c *gin.Context) {
	id, ok := ma(c, "menu_item_id")
	if !ok {
		return
	}
	var p struct {
		CategoryID int64  `json:"menu_category_id"`
		Reason     string `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if p.CategoryID <= 0 {
		sai(c, "menu_category_id")
		return
	}
	p.Reason = strings.TrimSpace(p.Reason)
	out, e := h.svc.XepMon(c.Request.Context(), nguoi(c), id, p.CategoryID, p.Reason)
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
