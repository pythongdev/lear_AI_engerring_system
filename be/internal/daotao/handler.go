package daotao

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, s *Service) {
	h := handler{s}
	r.GET("/assigned-tasks/:assigned_task_id/guides", h.docHuongDan)
	r.POST("/assigned-tasks/:assigned_task_id/guides", h.gan)
	r.PUT("/assigned-task-guides/:assigned_task_guide_id", h.suaHuongDan)
	r.POST("/assigned-task-guides/:assigned_task_guide_id/hiding", h.anHuongDan)
	r.GET("/assigned-task-guides/:assigned_task_guide_id/file", h.tep)
	r.GET("/training-records", h.docGhiNhan)
	r.POST("/training-records", h.ghi)
	r.PUT("/training-records/:training_record_id", h.suaGhiNhan)
	r.POST("/training-records/:training_record_id/hiding", h.anGhiNhan)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 { id, _ := middleware.Nguoi(c); return id }
func sai(c *gin.Context, field string) {
	apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
}
func tra(c *gin.Context, status int, out any, e error) {
	if e != nil {
		apierr.WriteError(c.Writer, e)
		return
	}
	apierr.JSON(c.Writer, status, out)
}
func ma(c *gin.Context, field string) (int64, bool) {
	id, e := strconv.ParseInt(c.Param(field), 10, 64)
	if e != nil || id <= 0 {
		sai(c, field)
		return 0, false
	}
	return id, true
}
func kemAn(c *gin.Context) (bool, bool) {
	v, co := c.GetQueryArray("include_hidden")
	if !co {
		return false, true
	}
	if v[0] != "true" && v[0] != "false" {
		sai(c, "include_hidden")
		return false, false
	}
	return v[0] == "true", true
}
func lyDo(c *gin.Context) (string, bool) {
	var p struct {
		Reason string `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return "", false
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if p.Reason == "" {
		sai(c, "reason")
		return "", false
	}
	return p.Reason, true
}

var loaiTep = map[string]string{".jpg": "image/jpeg", ".png": "image/png", ".webp": "image/webp", ".mp4": "video/mp4", ".webm": "video/webm", ".mov": "video/quicktime"}

func nhanLoai(b []byte, kind string) string {
	mime := http.DetectContentType(b)
	if len(b) >= 12 && string(b[4:8]) == "ftyp" && string(b[8:12]) == "qt  " {
		mime = "video/quicktime"
	}
	for ext, m := range loaiTep {
		if m == mime && strings.HasPrefix(m, kind+"/") {
			return ext
		}
	}
	return ""
}
func quaCo(c *gin.Context) { apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeFileTooLarge}) }
func (h handler) gan(c *gin.Context) {
	id, ok := ma(c, "assigned_task_id")
	if !ok {
		return
	}
	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, (100<<20)+(1<<20))
	e := c.Request.ParseMultipartForm(1 << 20)
	if c.Request.MultipartForm != nil {
		defer c.Request.MultipartForm.RemoveAll()
	}
	if e != nil {
		var large *http.MaxBytesError
		if errors.As(e, &large) {
			quaCo(c)
		} else {
			sai(c, "")
		}
		return
	}
	form := c.Request.MultipartForm
	kind := ""
	if v := form.Value["kind"]; len(v) > 0 {
		kind = v[0]
	}
	if kind != "text" && kind != "image" && kind != "video" {
		sai(c, "kind")
		return
	}
	files := form.File["file"]
	if kind == "text" {
		body := ""
		if v := form.Value["body"]; len(v) > 0 {
			body = strings.TrimSpace(v[0])
		}
		if body == "" {
			sai(c, "body")
			return
		}
		if len(files) > 0 {
			sai(c, "file")
			return
		}
		out, e := h.svc.Gan(c.Request.Context(), nguoi(c), id, kind, &body, nil, "")
		tra(c, 201, out, e)
		return
	}
	if _, co := form.Value["body"]; co {
		sai(c, "body")
		return
	}
	if len(files) != 1 || files[0].Size == 0 {
		sai(c, "file")
		return
	}
	f, e := files[0].Open()
	if e != nil {
		apierr.WriteError(c.Writer, e)
		return
	}
	defer f.Close()
	var head [512]byte
	n, e := io.ReadFull(f, head[:])
	if e != nil && e != io.EOF && e != io.ErrUnexpectedEOF {
		apierr.WriteError(c.Writer, e)
		return
	}
	ext := nhanLoai(head[:n], kind)
	if ext == "" {
		sai(c, "file")
		return
	}
	max := int64(100 << 20)
	if kind == "image" {
		max = 10 << 20
	}
	if files[0].Size > max {
		quaCo(c)
		return
	}
	if _, e = f.Seek(0, io.SeekStart); e != nil {
		apierr.WriteError(c.Writer, e)
		return
	}
	out, e := h.svc.Gan(c.Request.Context(), nguoi(c), id, kind, nil, f, ext)
	tra(c, 201, out, e)
}
func (h handler) docHuongDan(c *gin.Context) {
	id, ok := ma(c, "assigned_task_id")
	if !ok {
		return
	}
	hidden, ok := kemAn(c)
	if !ok {
		return
	}
	out, e := h.svc.DocHuongDan(c.Request.Context(), nguoi(c), id, hidden)
	tra(c, 200, map[string]any{"guides": out}, e)
}
func (h handler) suaHuongDan(c *gin.Context) {
	id, ok := ma(c, "assigned_task_guide_id")
	if !ok {
		return
	}
	var p struct {
		Body   string `json:"body"`
		Reason string `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Body = strings.TrimSpace(p.Body)
	if p.Body == "" {
		sai(c, "body")
		return
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if p.Reason == "" {
		sai(c, "reason")
		return
	}
	out, e := h.svc.SuaHuongDan(c.Request.Context(), nguoi(c), id, p.Body, p.Reason)
	tra(c, 200, out, e)
}
func (h handler) anHuongDan(c *gin.Context) {
	id, ok := ma(c, "assigned_task_guide_id")
	if !ok {
		return
	}
	reason, ok := lyDo(c)
	if !ok {
		return
	}
	out, e := h.svc.AnHuongDan(c.Request.Context(), nguoi(c), id, reason)
	tra(c, 200, out, e)
}
func (h handler) tep(c *gin.Context) {
	id, ok := ma(c, "assigned_task_guide_id")
	if !ok {
		return
	}
	f, e := h.svc.Tep(c.Request.Context(), nguoi(c), id)
	if e != nil {
		apierr.WriteError(c.Writer, e)
		return
	}
	defer f.Close()
	info, e := f.Stat()
	if e != nil {
		apierr.WriteError(c.Writer, e)
		return
	}
	c.Header("Content-Type", loaiTep[filepath.Ext(f.Name())])
	http.ServeContent(c.Writer, c.Request, info.Name(), info.ModTime(), f)
}
func docYeuCau(c *gin.Context, sua bool) (p YeuCau, ok bool) {
	var raw struct {
		TraineeID json.RawMessage `json:"trainee_person_id"`
		Remark    json.RawMessage `json:"remark"`
		Rating    json.RawMessage `json:"rating"`
		Reason    json.RawMessage `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &raw) {
		return
	}
	if sua {
		if json.Unmarshal(raw.Reason, &p.Reason) != nil || strings.TrimSpace(p.Reason) == "" {
			sai(c, "reason")
			return
		}
		p.Reason = strings.TrimSpace(p.Reason)
	} else if json.Unmarshal(raw.TraineeID, &p.TraineeID) != nil || p.TraineeID <= 0 {
		sai(c, "trainee_person_id")
		return
	}
	if len(raw.Remark) > 0 && string(raw.Remark) != "null" {
		var s string
		if json.Unmarshal(raw.Remark, &s) != nil || strings.TrimSpace(s) == "" {
			sai(c, "remark")
			return
		}
		s = strings.TrimSpace(s)
		p.Remark = &s
	}
	if len(raw.Rating) > 0 && string(raw.Rating) != "null" {
		var s string
		if json.Unmarshal(raw.Rating, &s) != nil || (s != "pass" && s != "not_yet") {
			sai(c, "rating")
			return
		}
		p.Rating = &s
	}
	if p.Remark == nil && p.Rating == nil {
		sai(c, "remark")
		return
	}
	return p, true
}
func (h handler) ghi(c *gin.Context) {
	p, ok := docYeuCau(c, false)
	if !ok {
		return
	}
	out, e := h.svc.Ghi(c.Request.Context(), nguoi(c), p)
	tra(c, 201, out, e)
}
func (h handler) suaGhiNhan(c *gin.Context) {
	id, ok := ma(c, "training_record_id")
	if !ok {
		return
	}
	p, ok := docYeuCau(c, true)
	if !ok {
		return
	}
	out, e := h.svc.SuaGhiNhan(c.Request.Context(), nguoi(c), id, p)
	tra(c, 200, out, e)
}
func (h handler) anGhiNhan(c *gin.Context) {
	id, ok := ma(c, "training_record_id")
	if !ok {
		return
	}
	reason, ok := lyDo(c)
	if !ok {
		return
	}
	out, e := h.svc.AnGhiNhan(c.Request.Context(), nguoi(c), id, reason)
	tra(c, 200, out, e)
}
func (h handler) docGhiNhan(c *gin.Context) {
	var trainee int64
	if raw, co := c.GetQueryArray("trainee_person_id"); co {
		n, e := strconv.ParseInt(raw[0], 10, 64)
		if e != nil || n <= 0 {
			sai(c, "trainee_person_id")
			return
		}
		trainee = n
	}
	hidden, ok := kemAn(c)
	if !ok {
		return
	}
	out, e := h.svc.DocGhiNhan(c.Request.Context(), nguoi(c), trainee, hidden)
	tra(c, 200, map[string]any{"training_records": out}, e)
}
