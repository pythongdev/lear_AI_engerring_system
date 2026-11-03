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
	r.PUT("/expense-categories/:expense_category_id", h.suaLoai)
	r.DELETE("/expense-categories/:expense_category_id", h.xoaLoai)
	r.POST("/expense-items", h.themCon)
	r.PUT("/expense-items/:expense_item_id", h.suaCon)
	r.DELETE("/expense-items/:expense_item_id", h.xoaCon)
	r.DELETE("/expenses/:expense_id", h.xoaKhoan)
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
	if p.ItemID != nil && *p.ItemID <= 0 {
		sai(c, "expense_item_id")
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

func readID(c *gin.Context, key string) (int64, bool) {
	id, err := strconv.ParseInt(c.Param(key), 10, 64)
	if err != nil || id <= 0 {
		sai(c, key)
		return 0, false
	}
	return id, true
}

type catalogRequest struct {
	Name       string `json:"name"`
	Reason     string `json:"reason"`
	CategoryID int64  `json:"expense_category_id"`
}

func readCatalog(c *gin.Context, rename, create bool) (p catalogRequest, ok bool) {
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Name = strings.TrimSpace(p.Name)
	p.Reason = strings.TrimSpace(p.Reason)
	if (rename || create) && p.Name == "" {
		sai(c, "name")
		return
	}
	if !create && p.Reason == "" {
		sai(c, "reason")
		return
	}
	if create && p.CategoryID <= 0 {
		sai(c, "expense_category_id")
		return
	}
	return p, true
}
func respondCatalog(c *gin.Context, out any, err error, status int) {
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	if status == 204 {
		c.Status(204)
		return
	}
	apierr.JSON(c.Writer, status, out)
}
func (h handler) suaLoai(c *gin.Context) {
	id, ok := readID(c, "expense_category_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, true, false)
	if !ok {
		return
	}
	out, err := h.svc.DoiTenLoai(c.Request.Context(), nguoi(c), id, p.Name, p.Reason)
	respondCatalog(c, out, err, 200)
}
func (h handler) xoaLoai(c *gin.Context) {
	id, ok := readID(c, "expense_category_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, false, false)
	if !ok {
		return
	}
	err := h.svc.XoaLoaiChi(c.Request.Context(), nguoi(c), id, p.Reason)
	respondCatalog(c, nil, err, 204)
}
func (h handler) themCon(c *gin.Context) {
	p, ok := readCatalog(c, false, true)
	if !ok {
		return
	}
	out, err := h.svc.TaoKhoanCon(c.Request.Context(), nguoi(c), p.CategoryID, p.Name)
	respondCatalog(c, out, err, 201)
}
func (h handler) suaCon(c *gin.Context) {
	id, ok := readID(c, "expense_item_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, true, false)
	if !ok {
		return
	}
	out, err := h.svc.DoiTenKhoanCon(c.Request.Context(), nguoi(c), id, p.Name, p.Reason)
	respondCatalog(c, out, err, 200)
}
func (h handler) xoaCon(c *gin.Context) {
	id, ok := readID(c, "expense_item_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, false, false)
	if !ok {
		return
	}
	err := h.svc.XoaCon(c.Request.Context(), nguoi(c), id, p.Reason)
	respondCatalog(c, nil, err, 204)
}
func (h handler) xoaKhoan(c *gin.Context) {
	id, ok := readID(c, "expense_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, false, false)
	if !ok {
		return
	}
	err := h.svc.XoaKhoan(c.Request.Context(), nguoi(c), id, p.Reason)
	respondCatalog(c, nil, err, 204)
}
