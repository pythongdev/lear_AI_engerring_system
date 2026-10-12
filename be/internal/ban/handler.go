package ban

import (
	"net/http"
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/dining-tables", h.danhSach)
	r.POST("/dining-tables/:dining_table_id/cleaning", h.daDon)
}

type handler struct{ svc *Service }

func (h handler) danhSach(c *gin.Context) {
	tables, err := h.svc.DanhSach(c.Request.Context())
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, struct {
		Tables []Ban `json:"tables"`
	}{Tables: tables})
}

func (h handler) daDon(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("dining_table_id"), 10, 64)
	if err != nil || id <= 0 {
		apierr.WriteError(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
		return
	}
	nguoi, _ := middleware.Nguoi(c)
	b, err := h.svc.DaDon(c.Request.Context(), nguoi, id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"dining_table_id": id, "state": b.State})
}
