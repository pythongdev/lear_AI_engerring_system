package khach

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

func Routes(r *gin.Engine, s *Service) {
	h := handler{s}
	r.POST("/customer-email-verifications", h.verify)
	r.POST("/customer-accounts/current/email-verification", h.resend)
	r.POST("/customer-accounts", h.register)
	r.POST("/customer-sessions", h.login)
	r.POST("/customer-sessions/google", h.google)
	r.GET("/customer-sessions/current", h.current)
	r.POST("/customer-sessions/current/end", h.logout)
	r.PUT("/customer-accounts/current/delivery-profile", h.delivery)
	r.GET("/customer-accounts/current/orders", h.history)
	r.PUT("/customer-accounts/current/password", h.password)
	r.POST("/customer-password-reset-requests", h.requestReset)
	r.POST("/customer-password-resets", h.reset)
}

type handler struct{ s *Service }

func result(c *gin.Context, status int, out any, e error) {
	if e != nil {
		apierr.WriteError(c.Writer, e)
		return
	}
	apierr.JSON(c.Writer, status, out)
}
func ok(c *gin.Context, e error)   { result(c, 200, map[string]string{"status": "ok"}, e) }
func cookie(c *gin.Context) string { return authz.CustomerToken(c.Request) }
func setCookie(c *gin.Context, t string, age int) {
	http.SetCookie(c.Writer, &http.Cookie{Name: authz.CookieKhach, Value: t, Path: "/", MaxAge: age, HttpOnly: true, Secure: true, SameSite: http.SameSiteStrictMode})
}
func (h handler) register(c *gin.Context) {
	var in Registration
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, t, e := h.s.register(c.Request.Context(), in)
	if e == nil {
		setCookie(c, t, 604800)
	}
	result(c, 201, out, e)
}
func (h handler) login(c *gin.Context) {
	var in struct {
		Identifier string `json:"identifier"`
		Password   string `json:"password"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, t, e := h.s.login(c.Request.Context(), in.Identifier, in.Password)
	if e == nil {
		setCookie(c, t, 604800)
	}
	result(c, 201, out, e)
}
func (h handler) current(c *gin.Context) {
	out, e := h.s.current(c.Request.Context(), cookie(c))
	result(c, 200, out, e)
}
func (h handler) logout(c *gin.Context) {
	e := h.s.logout(c.Request.Context(), cookie(c))
	if e == nil {
		setCookie(c, "", -1)
	}
	ok(c, e)
}
func (h handler) delivery(c *gin.Context) {
	var in struct {
		Name    *string `json:"delivery_name"`
		Phone   *string `json:"delivery_phone"`
		Address *string `json:"delivery_address"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	for _, f := range []struct {
		name  string
		value *string
	}{{"delivery_name", in.Name}, {"delivery_phone", in.Phone}, {"delivery_address", in.Address}} {
		if f.value == nil {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: f.name})
			return
		}
	}
	ok(c, h.s.delivery(c.Request.Context(), cookie(c), Delivery{*in.Name, *in.Phone, *in.Address}))
}
func (h handler) password(c *gin.Context) {
	var in struct {
		Current string `json:"current_password"`
		Next    string `json:"new_password"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	ok(c, h.s.changePassword(c.Request.Context(), cookie(c), in.Current, in.Next))
}
func (h handler) requestReset(c *gin.Context) {
	var in struct {
		Email string `json:"email"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	if e := h.s.requestReset(c.Request.Context(), in.Email); e != nil {
		_ = c.Error(e)
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
func (h handler) history(c *gin.Context) {
	var before int64
	limit := int64(20)
	for _, p := range []struct {
		name string
		dest *int64
		max  int64
	}{{"before_id", &before, 1<<63 - 1}, {"limit", &limit, 50}} {
		if raw, has := c.GetQuery(p.name); has {
			v, e := strconv.ParseInt(raw, 10, 64)
			if e != nil || v < 1 || v > p.max {
				apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: p.name})
				return
			}
			*p.dest = v
		} else if _, has = c.Request.URL.Query()[p.name]; has {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: p.name})
			return
		}
	}
	out, e := h.s.history(c.Request.Context(), cookie(c), before, int32(limit))
	result(c, 200, out, e)
}

func (h handler) google(c *gin.Context) {
	var in struct {
		Credential string `json:"credential"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, token, err := h.s.loginGoogle(c.Request.Context(), in.Credential)
	if err == nil {
		setCookie(c, token, 604800)
	}
	result(c, 201, out, err)
}

func (h handler) verify(c *gin.Context) {
	var in struct {
		Token string `json:"token"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &in) {
		return
	}
	out, err := h.s.verify(c.Request.Context(), in.Token)
	result(c, 200, out, err)
}
func (h handler) resend(c *gin.Context) {
	result(c, 202, map[string]string{"status": "ok"}, h.s.resend(c.Request.Context(), cookie(c)))
}
