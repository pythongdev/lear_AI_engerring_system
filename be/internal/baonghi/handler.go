package baonghi

import (
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc}
	r.POST("/leave-notices", h.bao)
	r.POST("/leave-notices/:leave_notice_id/cancel", h.huy)
	r.POST("/leave-notices/:leave_notice_id/acknowledge", h.daBiet)
	r.GET("/leave-notices/mine", h.cuaToi)
	r.GET("/leave-notices", h.theoKhoang)
}

type handler struct{ svc *Service }

func (h handler) bao(c *gin.Context) {
	var p YeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	personID, _ := middleware.Nguoi(c)
	out, replay, err := h.svc.Bao(c.Request.Context(), personID, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	status := 201
	if replay {
		status = 200
	}
	apierr.JSON(c.Writer, status, out)
}
func (h handler) huy(c *gin.Context)    { h.ghiDau(c, false) }
func (h handler) daBiet(c *gin.Context) { h.ghiDau(c, true) }
func (h handler) ghiDau(c *gin.Context, acknowledge bool) {
	id, err := strconv.ParseInt(c.Param("leave_notice_id"), 10, 64)
	if err != nil || id <= 0 {
		apierr.WriteError(c.Writer, invalid("leave_notice_id"))
		return
	}
	personID, _ := middleware.Nguoi(c)
	out, err := h.svc.GhiDau(c.Request.Context(), personID, id, acknowledge)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
func (h handler) cuaToi(c *gin.Context) {
	var before int64
	limit := int64(20)
	for _, p := range []struct {
		name string
		dest *int64
		max  int64
	}{
		{"before_id", &before, 1<<63 - 1}, {"limit", &limit, 50},
	} {
		if raw, has := c.Request.URL.Query()[p.name]; has {
			v, err := strconv.ParseInt(raw[0], 10, 64)
			if err != nil || v < 1 || v > p.max {
				apierr.WriteError(c.Writer, invalid(p.name))
				return
			}
			*p.dest = v
		}
	}
	personID, _ := middleware.Nguoi(c)
	out, err := h.svc.CuaToi(c.Request.Context(), personID, before, int32(limit))
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
func (h handler) theoKhoang(c *gin.Context) {
	personID, _ := middleware.Nguoi(c)
	out, err := h.svc.TheoKhoang(c.Request.Context(), personID, c.Query("from"), c.Query("to"))
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
