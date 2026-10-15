package khoanchi

import (
	"strconv"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/expense-categories", h.docLoai)
	r.POST("/expense-categories", h.themLoai)
	r.POST("/expenses", h.ghi)
	r.PUT("/expenses/:expense_id", h.sua)
	r.GET("/expenses", h.doc)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 { id, _ := middleware.Nguoi(c); return id }
func sai(c *gin.Context, field string) {
	apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
}
func ngayHopLe(s string) bool {
	d, err := time.Parse("2006-01-02", s)
	return err == nil && d.Year() >= 1 && d.Format("2006-01-02") == s
}
func (h handler) themLoai(c *gin.Context) {
	var p struct {
		Name         string `json:"name"`
		PaidFromTill *bool  `json:"paid_from_till"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Name = strings.TrimSpace(p.Name)
	if p.Name == "" {
		sai(c, "name")
		return
	}
	if p.PaidFromTill == nil {
		sai(c, "paid_from_till")
		return
	}
	out, err := h.svc.ThemLoai(c.Request.Context(), nguoi(c), p.Name, *p.PaidFromTill)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, out)
}
func (h handler) docLoai(c *gin.Context) {
	out, err := h.svc.DocLoai(c.Request.Context(), nguoi(c))
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, map[string]any{"expense_categories": out})
}

// Kiểm mọi hình trước quyền và database, kể cả path và bộ lọc.
func docYeuCau(c *gin.Context, sua bool) (YeuCau, bool) {
	var p YeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return p, false
	}
	if p.Amount <= 0 {
		sai(c, "amount_vnd")
		return p, false
	}
	if !ngayHopLe(p.PaidDate) {
		sai(c, "paid_date")
		return p, false
	}
	if p.CategoryID <= 0 {
		sai(c, "expense_category_id")
		return p, false
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if sua && p.Reason == "" {
		sai(c, "reason")
		return p, false
	}
	return p, true
}
func (h handler) ghi(c *gin.Context) {
	p, ok := docYeuCau(c, false)
	if !ok {
		return
	}
	out, err := h.svc.GhiKhoan(c.Request.Context(), nguoi(c), p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, out)
}
func (h handler) sua(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("expense_id"), 10, 64)
	if err != nil || id <= 0 {
		sai(c, "expense_id")
		return
	}
	p, ok := docYeuCau(c, true)
	if !ok {
		return
	}
	out, err := h.svc.SuaKhoan(c.Request.Context(), nguoi(c), id, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
func (h handler) doc(c *gin.Context) {
	loc := BoLoc{From: c.Query("from"), To: c.Query("to")}
	if !ngayHopLe(loc.From) {
		sai(c, "from")
		return
	}
	if !ngayHopLe(loc.To) || loc.From > loc.To {
		sai(c, "to")
		return
	}
	if v, ok := c.GetQuery("expense_category_id"); ok {
		id, err := strconv.ParseInt(v, 10, 64)
		if err != nil || id <= 0 {
			sai(c, "expense_category_id")
			return
		}
		loc.CategoryID = &id
	} else if _, ok := c.Request.URL.Query()["expense_category_id"]; ok {
		sai(c, "expense_category_id")
		return
	}
	if vs, ok := c.Request.URL.Query()["paid_from_till"]; ok {
		if vs[0] != "true" && vs[0] != "false" {
			sai(c, "paid_from_till")
			return
		}
		ket := vs[0] == "true"
		loc.PaidFromTill = &ket
	}
	out, err := h.svc.Doc(c.Request.Context(), nguoi(c), loc)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
