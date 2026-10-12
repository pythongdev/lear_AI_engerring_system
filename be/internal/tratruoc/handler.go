package tratruoc

import (
	"net/http"
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.POST("/orders/:sales_order_id/prepayment", h.nhan)
}

type handler struct{ svc *Service }

// Mọi lời từ chối hình xảy ra trước quyền và trước database (TestQC14_HinhDuongTienTruocQuyen).
func (h handler) nhan(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("sales_order_id"), 10, 64)
	if err != nil || id <= 0 {
		apierr.WriteError(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sales_order_id"})
		return
	}
	var p PhanTien
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	nguoi, _ := middleware.Nguoi(c)
	out, err := h.svc.NhanTien(c.Request.Context(), nguoi, id, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusCreated, map[string]any{"prepayment_id": out, "sales_order_id": id})
}
