package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"

	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/troly"
	"github.com/gin-gonic/gin"
)

func docBoGioBan(getenv func(string) string) (bool, error) {
	switch getenv("BANHCUON_DEV_BO_GIO_BAN") {
	case "", "0":
		return false, nil
	case "1":
		origin := getenv("BANHCUON_ORIGIN")
		u, err := url.Parse(origin)
		if err != nil || u.Scheme != "http" || u.User != nil || (u.Hostname() != "localhost" && u.Hostname() != "127.0.0.1") {
			return false, fmt.Errorf("BANHCUON_DEV_BO_GIO_BAN=1 chỉ dùng với BANHCUON_ORIGIN là http://localhost hoặc http://127.0.0.1")
		}
		return true, nil
	default:
		return false, fmt.Errorf("BANHCUON_DEV_BO_GIO_BAN chỉ nhận giá trị rỗng, 0 hoặc 1")
	}
}

func main() {
	chat, err := troly.DocCauHinh(os.Getenv)
	if err != nil {
		log.Fatal(err)
	}
	boGioBan, err := docBoGioBan(os.Getenv)
	if err != nil {
		log.Fatal(err)
	}
	if boGioBan {
		log.Print("CẢNH BÁO: máy dev đang bỏ kiểm tra giờ bán khi nhận đơn")
	}
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
	if os.Getenv("BANHCUON_ORIGIN") == "" {
		log.Fatal("thiếu BANHCUON_ORIGIN")
	}
	if os.Getenv("BANHCUON_FILE_DIR") == "" {
		log.Fatal("thiếu BANHCUON_FILE_DIR")
	}
	gin.SetMode(gin.ReleaseMode)
	pool, err := postgres.Open(context.Background(), dsn, tz)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()
	server := http.Server{Addr: addr, Handler: newRouterWithBoGioBan(pool, taikhoan.NewAuthenticator(pool), boGioBan, chat)}
	log.Fatal(server.ListenAndServe())
}
