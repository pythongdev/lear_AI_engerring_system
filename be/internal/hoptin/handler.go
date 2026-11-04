package hoptin

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
	"strconv"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc}
	r.POST("/station-messages", h.quayGui)
	r.POST("/station-messages/to-counter", h.guiVeQuay)
	r.GET("/station-messages/mine", h.cuaToi)
	r.GET("/station-messages/counter", h.cuaQuay)
}

type handler struct{ svc *Service }

func (h handler) quayGui(c *gin.Context)   { h.gui(c, false) }
func (h handler) guiVeQuay(c *gin.Context) { h.gui(c, true) }
func (h handler) cuaToi(c *gin.Context)    { h.doc(c, false) }
func (h handler) cuaQuay(c *gin.Context)   { h.doc(c, true) }
func (h handler) gui(c *gin.Context, toCounter bool) {
	var p YeuCau
	// Cửa về quầy không nhận người nhận, kể cả khi trường lạ có kiểu sai.
	if toCounter {
		var body struct {
			SubmissionCode string `json:"submission_code"`
			WorkCode       string `json:"work_code"`
			Body           string `json:"body"`
			DiningTableID  *int64 `json:"dining_table_id"`
			ReplyToID      *int64 `json:"reply_to_message_id"`
		}
		if !apierr.ReadJSON(c.Writer, c.Request, &body) {
			return
		}
		p = YeuCau{SubmissionCode: body.SubmissionCode, WorkCode: body.WorkCode, Body: body.Body, DiningTableID: body.DiningTableID, ReplyToID: body.ReplyToID}
	} else if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	personID, _ := middleware.Nguoi(c)
	out, replay, err := h.svc.Gui(c.Request.Context(), personID, p, toCounter)
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
func (h handler) doc(c *gin.Context, counter bool) {
	var before int64
	limit := int64(20)
	for _, p := range []struct {
		name string
		dest *int64
		max  int64
	}{{"before_id", &before, 1<<63 - 1}, {"limit", &limit, 50}} {
		if raw, has := c.Request.URL.Query()[p.name]; has {
			v, err := strconv.ParseInt(raw[0], 10, 64)
			if err != nil || v < 1 || v > p.max {
				apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: p.name})
				return
			}
			*p.dest = v
		}
	}
	personID, _ := middleware.Nguoi(c)
	out, err := h.svc.Doc(c.Request.Context(), personID, before, int32(limit), counter)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
