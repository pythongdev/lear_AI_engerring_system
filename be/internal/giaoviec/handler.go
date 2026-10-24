package giaoviec

import (
	"encoding/json"
	"strconv"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc}
	r.GET("/assigned-tasks", h.doc)
	r.POST("/assigned-tasks", h.tao)
	r.GET("/assigned-tasks/:assigned_task_id", h.chiTiet)
	r.PUT("/assigned-tasks/:assigned_task_id", h.sua)
	r.POST("/assigned-tasks/:assigned_task_id/hiding", h.an)
	r.POST("/assigned-tasks/:assigned_task_id/marks", h.danhDau)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 { id, _ := middleware.Nguoi(c); return id }
func sai(c *gin.Context, field string) {
	apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
}
func tra(c *gin.Context, status int, out any, err error) {
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, status, out)
}
func ma(c *gin.Context, field string) (int64, bool) {
	id, err := strconv.ParseInt(c.Param(field), 10, 64)
	if err != nil || id <= 0 {
		sai(c, field)
		return 0, false
	}
	return id, true
}

func docYeuCau(c *gin.Context, sua bool) (YeuCau, bool) {
	var body struct {
		Content    string          `json:"content"`
		AssigneeID int64           `json:"assignee_person_id"`
		Reason     string          `json:"reason"`
		DueAt      json.RawMessage `json:"due_at"`
	}
	var p YeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &body) {
		return p, false
	}
	p.Content, p.AssigneeID, p.Reason = body.Content, body.AssigneeID, body.Reason
	p.Content = strings.TrimSpace(p.Content)
	if p.Content == "" {
		sai(c, "content")
		return p, false
	}
	if p.AssigneeID <= 0 {
		sai(c, "assignee_person_id")
		return p, false
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if sua && p.Reason == "" {
		sai(c, "reason")
		return p, false
	}
	if !sua || len(body.DueAt) > 0 {
		var raw string
		if json.Unmarshal(body.DueAt, &raw) != nil || raw == "" {
			sai(c, "due_at")
			return p, false
		}
		due, err := time.Parse(time.RFC3339Nano, raw)
		if err != nil || due.IsZero() || due.Year() < 1 || due.Year() > 9999 {
			sai(c, "due_at")
			return p, false
		}
		p.DueAt = &due
	}
	return p, true
}
func (h handler) tao(c *gin.Context) {
	p, ok := docYeuCau(c, false)
	if !ok {
		return
	}
	out, e := h.svc.Tao(c.Request.Context(), nguoi(c), p)
	tra(c, 201, out, e)
}
func (h handler) sua(c *gin.Context) {
	id, ok := ma(c, "assigned_task_id")
	if !ok {
		return
	}
	p, ok := docYeuCau(c, true)
	if !ok {
		return
	}
	out, e := h.svc.Sua(c.Request.Context(), nguoi(c), id, p)
	tra(c, 200, out, e)
}
func (h handler) an(c *gin.Context) {
	id, ok := ma(c, "assigned_task_id")
	if !ok {
		return
	}
	var p struct {
		Reason string `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if p.Reason == "" {
		sai(c, "reason")
		return
	}
	out, e := h.svc.An(c.Request.Context(), nguoi(c), id, p.Reason)
	tra(c, 200, out, e)
}
func (h handler) danhDau(c *gin.Context) {
	id, ok := ma(c, "assigned_task_id")
	if !ok {
		return
	}
	var p struct {
		Mark string `json:"mark"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if p.Mark != "done" && p.Mark != "undone" {
		sai(c, "mark")
		return
	}
	out, e := h.svc.DanhDau(c.Request.Context(), nguoi(c), id, p.Mark)
	tra(c, 201, out, e)
}
func (h handler) chiTiet(c *gin.Context) {
	id, ok := ma(c, "assigned_task_id")
	if !ok {
		return
	}
	out, e := h.svc.ChiTiet(c.Request.Context(), nguoi(c), id)
	tra(c, 200, out, e)
}
func (h handler) doc(c *gin.Context) {
	var nhan int64
	if raw, co := c.GetQueryArray("assignee_person_id"); co {
		n, e := strconv.ParseInt(raw[0], 10, 64)
		if e != nil || n <= 0 {
			sai(c, "assignee_person_id")
			return
		}
		nhan = n
	}
	kemAn := false
	if raw, co := c.GetQueryArray("include_hidden"); co {
		if raw[0] != "true" && raw[0] != "false" {
			sai(c, "include_hidden")
			return
		}
		kemAn = raw[0] == "true"
	}
	out, e := h.svc.Doc(c.Request.Context(), nguoi(c), nhan, kemAn)
	tra(c, 200, map[string]any{"assigned_tasks": out}, e)
}
