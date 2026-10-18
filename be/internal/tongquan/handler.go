package tongquan

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
	"time"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/owner-overview", h.doc)
	r.PUT("/daily-minimums/:sale_date", h.dat)
}

type handler struct{ svc *Service }

func (h handler) doc(c *gin.Context) {
	id, _ := middleware.Nguoi(c)
	out, err := h.svc.Doc(c.Request.Context(), id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}

func (h handler) dat(c *gin.Context) {
	ngay := c.Param("sale_date")
	d, err := time.Parse("2006-01-02", ngay)
	if err != nil || d.Year() < 1 || d.Format("2006-01-02") != ngay {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sale_date"})
		return
	}
	var p ToiThieuInput
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if p.MinimumBanh <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "minimum_banh"})
		return
	}
	if p.MinimumWorkers <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "minimum_workers"})
		return
	}
	id, _ := middleware.Nguoi(c)
	out, err := h.svc.Dat(c.Request.Context(), id, ngay, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
