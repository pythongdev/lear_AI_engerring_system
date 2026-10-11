// Test middleware gắn người (T-151, QC-12). Viết TRƯỚC khi có middleware — Claude viết, Codex làm
// cho xanh mà không sửa điều kiện kiểm nào. Middleware chỉ gắn người đã đọc vào gin.Context; nó không
// kiểm quyền và không bao giờ từ chối: lời từ chối thuộc authz.Run, trong giao dịch của cửa (ADR-085).
package middleware_test

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func TestQC12_MiddlewareGanNguoiKhongTuChoi(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(middleware.GanNguoi(authz.ChonTen{}))
	r.GET("/thu", func(c *gin.Context) {
		id, ok := middleware.Nguoi(c)
		c.String(http.StatusOK, fmt.Sprintf("%d %t", id, ok))
	})
	cases := []struct {
		header string
		muon   string
	}{
		{"7", "7 true"},
		{"", "0 false"},
		{"abc", "0 false"},
		{"-3", "0 false"},
		{"0", "0 false"},
	}
	for _, c := range cases {
		req := httptest.NewRequest("GET", "/thu", nil)
		if c.header != "" {
			req.Header.Set(authz.HeaderNguoi, c.header)
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusOK || w.Body.String() != c.muon {
			t.Fatalf("header %q: status=%d thân=%q, muốn 200 %q", c.header, w.Code, w.Body.String(), c.muon)
		}
	}
}
