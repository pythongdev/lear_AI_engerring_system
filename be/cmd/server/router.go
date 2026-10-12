package main

import (
	"net/http"
	"strings"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ban"
	"banhcuon/be/internal/don"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/hoadon"
	"banhcuon/be/internal/ket"
	"banhcuon/be/internal/menu"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/nguoi"
	"banhcuon/be/internal/phien"
	"banhcuon/be/internal/qr"
	"banhcuon/be/internal/sanxuat"
	"banhcuon/be/internal/tratruoc"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func newRouter(pool *pgxpool.Pool, auth authz.Authenticator) *gin.Engine {
	r := gin.New()
	// Đường Gin giữ hành vi của ServeMux hôm nay (QC-12): khác phương thức ⇒ 405 kèm Allow, dấu / cuối ⇒ 404.
	r.HandleMethodNotAllowed = true
	r.RedirectTrailingSlash = false
	r.UseRawPath = true
	r.Use(middleware.GanNguoi(auth))
	menu.Routes(r, menu.NewService(pool))
	qr.Routes(r, qr.NewService(pool))
	gia.Routes(r, gia.NewService(pool))
	ban.Routes(r, ban.NewService(pool))
	phien.Routes(r, phien.NewService(pool))
	nguoi.Routes(r, nguoi.NewService(pool))
	tratruoc.Routes(r, tratruoc.NewService(pool))
	hoadon.Routes(r, hoadon.NewService(pool))
	ket.Routes(r, ket.NewService(pool))
	sanxuat.Routes(r, sanxuat.NewService(pool))
	legacy := http.NewServeMux()
	don.Routes(legacy, pool, auth)
	wrapLegacy := gin.WrapH(legacy)
	r.NoRoute(func(c *gin.Context) {
		// NoRoute đặt sẵn 404; trả về 200 trước khi handler cũ ghi thân mà không gọi WriteHeader.
		c.Status(http.StatusOK)
		wrapLegacy(c)
	})
	r.NoMethod(func(c *gin.Context) {
		if c.Request.Method != http.MethodHead {
			return
		}
		// NoMethod chỉ chuyển HEAD khi Gin tìm thấy đường GET tương ứng.
		for _, method := range strings.Split(c.Writer.Header().Get("Allow"), ",") {
			if strings.TrimSpace(method) != http.MethodGet {
				continue
			}
			c.Writer.Header().Del("Allow")
			c.Request.Method = http.MethodGet
			// Dựng context mới vì HandleContext đặt lại Writer, làm mất lớp bỏ thân.
			c.Status(http.StatusOK)
			r.ServeHTTP(headWriter{ResponseWriter: c.Writer}, c.Request)
			c.Request.Method = http.MethodHead
			return
		}
	})
	return r
}

// headWriter giữ status và header của GET, chỉ bỏ phần thân của HEAD.
type headWriter struct{ gin.ResponseWriter }

func (w headWriter) Write(b []byte) (int, error) {
	w.WriteHeaderNow()
	return len(b), nil
}

func (w headWriter) WriteString(s string) (int, error) {
	w.WriteHeaderNow()
	return len(s), nil
}
