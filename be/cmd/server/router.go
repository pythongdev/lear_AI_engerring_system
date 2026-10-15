package main

import (
	"banhcuon/be/internal/taikhoan"
	"net/http"
	"os"
	"strings"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ban"
	"banhcuon/be/internal/don"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/giaoviec"
	"banhcuon/be/internal/hoadon"
	"banhcuon/be/internal/ket"
	"banhcuon/be/internal/khoanchi"
	"banhcuon/be/internal/menu"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/nguoi"
	"banhcuon/be/internal/nguyenlieu"
	"banhcuon/be/internal/nhandon"
	"banhcuon/be/internal/phien"
	"banhcuon/be/internal/platform/realtime"
	"banhcuon/be/internal/qr"
	"banhcuon/be/internal/sanxuat"
	"banhcuon/be/internal/tratruoc"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func newRouter(pool *pgxpool.Pool, auth authz.Authenticator) *gin.Engine {
	return routerWithRealtime(pool, auth, realtime.New(0))
}

func routerWithRealtime(pool *pgxpool.Pool, auth authz.Authenticator, b *realtime.Broker) *gin.Engine {
	r := gin.New()
	r.Use(middleware.CungNguon(os.Getenv("BANHCUON_ORIGIN")))
	r.Use(middleware.Realtime(b))
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
	taikhoan.Routes(r, taikhoan.NewService(pool, taikhoan.SMTPFromEnv()))
	tratruoc.Routes(r, tratruoc.NewService(pool))
	hoadon.Routes(r, hoadon.NewService(pool))
	ket.Routes(r, ket.NewService(pool))
	khoanchi.Routes(r, khoanchi.NewService(pool))
	nguyenlieu.Routes(r, nguyenlieu.NewService(pool))
	giaoviec.Routes(r, giaoviec.NewService(pool))
	sanxuat.Routes(r, sanxuat.NewService(pool).WithRealtime(b))
	don.Routes(r, don.NewService(pool, b))
	nhandon.Routes(r, nhandon.NewService(pool, b))
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
			c.Request = c.Request.WithContext(realtime.HeadContext(c.Request.Context()))
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
