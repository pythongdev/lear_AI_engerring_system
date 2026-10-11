package main

import (
	"net/http"

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
	r.Use(middleware.GanNguoi(auth))
	legacy := http.NewServeMux()
	ban.Routes(legacy, pool, auth)
	don.Routes(legacy, pool, auth)
	gia.Routes(legacy, pool)
	hoadon.Routes(legacy, pool, auth)
	ket.Routes(legacy, pool, auth)
	menu.Routes(legacy, pool, auth)
	nguoi.Routes(legacy, pool, auth)
	phien.Routes(legacy, pool, auth)
	qr.Routes(legacy, pool, auth)
	sanxuat.Routes(legacy, pool, auth)
	tratruoc.Routes(legacy, pool, auth)
	wrapLegacy := gin.WrapH(legacy)
	r.NoRoute(func(c *gin.Context) {
		// NoRoute đặt sẵn 404; trả về 200 trước khi handler cũ ghi thân mà không gọi WriteHeader.
		c.Status(http.StatusOK)
		wrapLegacy(c)
	})
	return r
}
