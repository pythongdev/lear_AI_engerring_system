package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/google"
	"banhcuon/be/internal/khach"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
)

type googleVerifierFake struct {
	claims google.Claims
	err    error
	token  string
}

func (f *googleVerifierFake) Verify(_ context.Context, token string) (google.Claims, error) {
	f.token = token
	return f.claims, f.err
}
func googleRequest(r http.Handler, body string) *httptest.ResponseRecorder {
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/customer-sessions/google", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	return w
}
func TestI035_GoogleHandlerErrors(t *testing.T) {
	for _, tc := range []struct {
		name, client, code string
		status             int
	}{{"disabled", "", "google_login_disabled", 503}, {"invalid", "client", "google_token_invalid", 401}} {
		t.Run(tc.name, func(t *testing.T) {
			verifier := &googleVerifierFake{err: errors.New("invalid")}
			r := gin.New()
			khach.Routes(r, khach.NewService(nil, nil).WithGoogle(tc.client, verifier))
			w := googleRequest(r, `{"credential":"signed-token"}`)
			var out struct{ Code string }
			_ = json.Unmarshal(w.Body.Bytes(), &out)
			if w.Code != tc.status || out.Code != tc.code || w.Header().Get("Set-Cookie") != "" {
				t.Fatalf("response: %d %s %v", w.Code, w.Body, w.Header())
			}
			if tc.client != "" && verifier.token != "signed-token" {
				t.Fatal("wrong verifier input")
			}
		})
	}
}
func TestI035_GoogleHandlerCookie(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	suffix := fmt.Sprint(time.Now().UnixNano())
	verifier := &googleVerifierFake{claims: google.Claims{Sub: "http-" + suffix, Email: "http." + suffix + "@gmail.com", Name: "Lan"}}
	r := gin.New()
	khach.Routes(r, khach.NewService(pool, nil).WithGoogle("client", verifier))
	w := googleRequest(r, `{"credential":"signed-token"}`)
	var profile khach.Profile
	if err = json.Unmarshal(w.Body.Bytes(), &profile); err != nil {
		t.Fatal(err)
	}
	if w.Code != 201 || profile.AccountID == 0 || profile.DisplayName != "Lan" || verifier.token != "signed-token" {
		t.Fatalf("response: %d %s", w.Code, w.Body)
	}
	cookies := w.Result().Cookies()
	if len(cookies) != 1 {
		t.Fatal(cookies)
	}
	c := cookies[0]
	if c.Name != "banhcuon_khach" || len(c.Value) != 43 || !c.HttpOnly || !c.Secure || c.SameSite != http.SameSiteStrictMode || c.Path != "/" || c.MaxAge != 604800 {
		t.Fatalf("cookie: %+v", c)
	}
	current := httptest.NewRecorder()
	req := httptest.NewRequest("GET", "/customer-sessions/current", nil)
	req.AddCookie(c)
	r.ServeHTTP(current, req)
	if current.Code != 200 {
		t.Fatalf("session unusable: %d %s", current.Code, current.Body)
	}
}
