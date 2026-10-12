package phien

import (
	"net/http"
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.POST("/table-sessions/:table_session_id/bill-request", h.tinhTien)
}

type handler struct{ svc *Service }

func (h handler) tinhTien(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("table_session_id"), 10, 64)
	if err != nil || id <= 0 {
		apierr.WriteError(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "table_session_id"})
		return
	}
	nguoi, _ := middleware.Nguoi(c)
	due, err := h.svc.TinhTien(c.Request.Context(), nguoi, id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"table_session_id": id, "status": "awaiting_payment", "due_vnd": due})
}
