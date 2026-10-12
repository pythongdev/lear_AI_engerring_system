package nhandon

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
	"net/http"
)

func Routes(r *gin.Engine, s *Service) {
	h := handler{s}
	r.POST("/order-intake/pause", h.bam(TamDung))
	r.POST("/order-intake/resume", h.bam(TiepTuc))
	r.POST("/shop-blind/declaration", h.bam(BaoMu))
	r.POST("/shop-blind/reopening", h.bam(MoLai))
	r.GET("/counter/queue", h.hangCho)
	r.GET("/counter/events", h.events)
}

type handler struct{ s *Service }

func (h handler) bam(door authz.Door) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, _ := middleware.Nguoi(c)
		out, err := h.s.Bam(c.Request.Context(), id, door)
		if err != nil {
			apierr.WriteError(c.Writer, err)
			return
		}
		apierr.JSON(c.Writer, http.StatusOK, out)
	}
}
func (h handler) hangCho(c *gin.Context) {
	id, _ := middleware.Nguoi(c)
	out, err := h.s.HangCho(c.Request.Context(), id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, out)
}
func (h handler) events(c *gin.Context) {
	id, _ := middleware.Nguoi(c)
	at, blind, err := h.s.MoLuong(c.Request.Context(), id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	h.s.broker.Serve(c.Writer, c.Request, true, blind, at, h.s.Moc)
}
