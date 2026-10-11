package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"github.com/gin-gonic/gin"
)

func main() {
	dsn := os.Getenv("BANHCUON_DATABASE_URL")
	if dsn == "" {
		log.Fatal("thiếu BANHCUON_DATABASE_URL")
	}
	tz := os.Getenv("BANHCUON_SHOP_TZ")
	if tz == "" {
		log.Fatal("thiếu BANHCUON_SHOP_TZ")
	}
	addr := os.Getenv("BANHCUON_ADDR")
	if addr == "" {
		addr = ":8080"
	}
	gin.SetMode(gin.ReleaseMode)
	pool, err := postgres.Open(context.Background(), dsn, tz)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()
	server := http.Server{Addr: addr, Handler: newRouter(pool, authz.ChonTen{})}
	log.Fatal(server.ListenAndServe())
}
