package taikhoan

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc}
	r.POST("/accounts", h.register)
	r.POST("/sessions", h.login)
	r.GET("/sessions/current", h.current)
	r.POST("/sessions/current/end", h.logout)
	r.POST("/accounts/current/password", h.changePassword)
	r.POST("/password-reset-requests", h.requestReset)
	r.POST("/password-resets", h.reset)
	r.GET("/accounts", h.list)
	r.POST("/accounts/:account_id/approval", h.approve)
	r.POST("/accounts/:account_id/rejection", h.reject)
	r.POST("/accounts/:account_id/lock", h.lock)
	r.POST("/accounts/:account_id/unlock", h.unlock)
}

type handler struct{ s *Service }

func cookie(c *gin.Context) string { v, _ := c.Cookie(CookiePhien); return v }
func setCookie(c *gin.Context, value string, age int) {
	http.SetCookie(c.Writer, &http.Cookie{Name: CookiePhien, Value: value, Path: "/", HttpOnly: true, Secure: true, SameSite: http.SameSiteStrictMode, MaxAge: age})
}
func result(c *gin.Context, status int, v any, err error) {
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, status, v)
}
func ok(c *gin.Context, err error) { result(c, 200, map[string]string{"status": "ok"}, err) }
func (h handler) register(c *gin.Context) {
	var in ChuQuanMoi
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, err := h.s.register(c.Request.Context(), in, false)
	result(c, 201, out, err)
}
func (h handler) login(c *gin.Context) {
	var in struct {
		Username  string `json:"username"`
		Password  string `json:"password"`
		AtCounter bool   `json:"at_counter"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, token, err := h.s.login(c.Request.Context(), in.Username, in.Password, in.AtCounter)
	if err == nil {
		setCookie(c, token, 7*24*60*60)
	}
	result(c, 201, out, err)
}
func (h handler) current(c *gin.Context) {
	id, _ := middleware.Nguoi(c)
	out, err := h.s.current(c.Request.Context(), id, cookie(c))
	result(c, 200, out, err)
}
func (h handler) logout(c *gin.Context) {
	id, _ := middleware.Nguoi(c)
	err := h.s.logout(c.Request.Context(), id, cookie(c))
	if err == nil {
		setCookie(c, "", -1)
	}
	ok(c, err)
}
func (h handler) changePassword(c *gin.Context) {
	var in struct {
		Current string `json:"current_password"`
		Next    string `json:"new_password"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	id, _ := middleware.Nguoi(c)
	err := h.s.changePassword(c.Request.Context(), id, cookie(c), in.Current, in.Next)
	if err == nil {
		setCookie(c, "", -1)
	}
	ok(c, err)
}
func (h handler) requestReset(c *gin.Context) {
	var in struct {
		Email string `json:"email"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	err := h.s.requestReset(c.Request.Context(), in.Email)
	if err != nil { // Cùng câu kể cả lỗi lưu/gửi; không tiết lộ tài khoản.
		c.Error(err)
	}
	result(c, 202, map[string]string{"status": "ok"}, nil)
}
func (h handler) reset(c *gin.Context) {
	var in struct {
		Token    string `json:"token"`
		Password string `json:"new_password"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	ok(c, h.s.reset(c.Request.Context(), in.Token, in.Password))
}
func (h handler) list(c *gin.Context) {
	id, _ := middleware.Nguoi(c)
	rows, err := h.s.list(c.Request.Context(), id, c.Query("status"))
	result(c, 200, struct {
		Accounts []Account `json:"accounts"`
	}{rows}, err)
}
func (h handler) approve(c *gin.Context) { h.decide(c, "approval") }
func (h handler) reject(c *gin.Context)  { h.decide(c, "rejection") }
func (h handler) lock(c *gin.Context)    { h.decide(c, "lock") }
func (h handler) unlock(c *gin.Context)  { h.decide(c, "unlock") }
func (h handler) decide(c *gin.Context, action string) {
	id, err := strconv.ParseInt(c.Param("account_id"), 10, 64)
	if err != nil || id <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest})
		return
	}
	var in struct {
		Role     string `json:"role_code"`
		PersonID int64  `json:"person_id"`
		Password string `json:"temporary_password"`
	}
	if action == "approval" || action == "unlock" {
		if !apierr.ReadJSON(c.Writer, c.Request, &in) {
			return
		}
	}
	person, _ := middleware.Nguoi(c)
	out, err := h.s.decide(c.Request.Context(), person, id, action, in.Role, in.PersonID, in.Password, cookie(c))
	result(c, 200, out, err)
}
