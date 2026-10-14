package nguoi

import (
	"net/http"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/people", h.danhSach)
	r.GET("/counter-duty/current", h.hienTai)
	r.POST("/counter-duty/end", h.roiQuay)
}

type handler struct{ svc *Service }

func (h handler) danhSach(c *gin.Context) {
	personID, _ := middleware.Nguoi(c)
	people, err := h.svc.DanhSach(c.Request.Context(), personID)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, struct {
		People []person `json:"people"`
	}{People: people})
}

func (h handler) hienTai(c *gin.Context) {
	result, err := h.svc.HienTai(c.Request.Context())
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, result)
}

func (h handler) roiQuay(c *gin.Context) {
	personID, _ := middleware.Nguoi(c)
	result, err := h.svc.RoiQuay(c.Request.Context(), personID)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, result)
}
