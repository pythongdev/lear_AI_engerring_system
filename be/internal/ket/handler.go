package ket

import (
	"net/http"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.POST("/opening-floats", h.khai)
	r.POST("/cash-counts", h.dem)
	r.POST("/sale-days/:sale_date/reconciliation", h.ky)
	r.GET("/sale-days/:sale_date/cash-reconciliation", h.doc)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 {
	id, _ := middleware.Nguoi(c)
	return id
}

func (h handler) khai(c *gin.Context) { h.ghiSo(c, false, "opening_float_id") }
func (h handler) dem(c *gin.Context)  { h.ghiSo(c, true, "cash_count_id") }

// Mọi lời từ chối hình xảy ra trước quyền và trước database (TestQC14_HinhDuongTienTruocQuyen).
func (h handler) ghiSo(c *gin.Context, dem bool, key string) {
	var p YeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	total, err := p.Kiem()
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	id, ngay, err := h.svc.GhiSo(c.Request.Context(), nguoi(c), dem, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, map[string]any{key: id, "sale_date": ngay, "total_vnd": total})
}

func docNgay(c *gin.Context) (string, bool) {
	s := c.Param("sale_date")
	d, err := time.Parse("2006-01-02", s)
	if err != nil || d.Year() < 1 || d.Format("2006-01-02") != s {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sale_date"})
		return "", false
	}
	return s, true
}

func (h handler) doc(c *gin.Context) {
	ngay, ok := docNgay(c)
	if !ok {
		return
	}
	s, err := h.svc.DocSo(c.Request.Context(), ngay)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, s)
}

func (h handler) ky(c *gin.Context) {
	ngay, ok := docNgay(c)
	if !ok {
		return
	}
	var p struct {
		GapExplanation *string `json:"gap_explanation"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	var explanation *string
	if p.GapExplanation != nil {
		trimmed := strings.TrimSpace(*p.GapExplanation)
		if trimmed != "" {
			explanation = &trimmed
		}
	}
	id, gap, err := h.svc.KyNgay(c.Request.Context(), nguoi(c), ngay, explanation)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusCreated, map[string]any{"reconciled_day_id": id, "sale_date": ngay, "gap_vnd": gap, "gap_explanation": explanation})
}
