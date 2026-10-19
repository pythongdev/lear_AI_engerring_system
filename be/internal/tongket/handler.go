package tongket

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
	"time"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/sale-days/:sale_date/summary", h.doc)
}

type handler struct{ svc *Service }

func (h handler) doc(c *gin.Context) {
	ngay := c.Param("sale_date")
	d, err := time.Parse("2006-01-02", ngay)
	if err != nil || d.Year() < 1 || d.Format("2006-01-02") != ngay {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sale_date"})
		return
	}
	id, _ := middleware.Nguoi(c)
	out, err := h.svc.Doc(c.Request.Context(), id, ngay)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
