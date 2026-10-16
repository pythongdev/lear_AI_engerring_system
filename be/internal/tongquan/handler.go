package tongquan

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/owner-overview", h.doc)
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
