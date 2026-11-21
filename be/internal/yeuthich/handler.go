package yeuthich

import (
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc}
	r.GET("/customer-accounts/current/favourites", h.read)
	r.POST("/customer-accounts/current/favourites", h.createLine)
	r.PUT("/customer-accounts/current/favourites/:favourite_line_id", h.updateLine)
	r.POST("/customer-accounts/current/favourites/:favourite_line_id/removal", h.removeLine)
	r.POST("/customer-accounts/current/favourite-sets", h.createSet)
	r.PUT("/customer-accounts/current/favourite-sets/:favourite_set_id", h.updateSet)
	r.POST("/customer-accounts/current/favourite-sets/:favourite_set_id/removal", h.removeSet)
}

type handler struct{ s *Service }

func result(c *gin.Context, out any, err error) {
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}

func readID(c *gin.Context, field string) (int64, bool) {
	id, err := strconv.ParseInt(c.Param(field), 10, 64)
	if err != nil || id < 1 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
		return 0, false
	}
	return id, true
}

func (h handler) read(c *gin.Context) {
	out, err := h.s.read(c.Request.Context(), authz.CustomerToken(c.Request))
	result(c, out, err)
}

func (h handler) createLine(c *gin.Context) { h.saveLine(c, 0) }
func (h handler) updateLine(c *gin.Context) {
	if id, ok := readID(c, "favourite_line_id"); ok {
		h.saveLine(c, id)
	}
}
func (h handler) saveLine(c *gin.Context, id int64) {
	var in FavouriteLineInput
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, err := h.s.saveLine(c.Request.Context(), authz.CustomerToken(c.Request), id, in)
	result(c, out, err)
}
func (h handler) removeLine(c *gin.Context) {
	if id, ok := readID(c, "favourite_line_id"); ok {
		err := h.s.removeLine(c.Request.Context(), authz.CustomerToken(c.Request), id)
		result(c, map[string]string{"status": "ok"}, err)
	}
}

func (h handler) createSet(c *gin.Context) {
	var in FavouriteSetInput
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, err := h.s.saveSet(c.Request.Context(), authz.CustomerToken(c.Request), 0, in)
	result(c, out, err)
}
func (h handler) updateSet(c *gin.Context) {
	id, ok := readID(c, "favourite_set_id")
	if !ok {
		return
	}
	var in struct {
		Name  string               `json:"name"`
		Lines []FavouriteLineInput `json:"lines"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, err := h.s.saveSet(c.Request.Context(), authz.CustomerToken(c.Request), id,
		FavouriteSetInput{Name: in.Name, Lines: in.Lines})
	result(c, out, err)
}
func (h handler) removeSet(c *gin.Context) {
	if id, ok := readID(c, "favourite_set_id"); ok {
		err := h.s.removeSet(c.Request.Context(), authz.CustomerToken(c.Request), id)
		result(c, map[string]string{"status": "ok"}, err)
	}
}
