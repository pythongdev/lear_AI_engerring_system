package main

import (
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"bufio"
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

func main() {
	username := flag.String("username", "", "Tên đăng nhập")
	email := flag.String("email", "", "Địa chỉ nhận thư")
	display := flag.String("display-name", "", "Tên hiển thị")
	flag.Parse()
	if *username == "" || *email == "" || *display == "" {
		log.Fatal("cần username, email, display-name; mật khẩu lấy một dòng từ stdin")
	}
	password, err := bufio.NewReader(io.LimitReader(os.Stdin, 65536)).ReadString('\n')
	if err != nil && err != io.EOF {
		log.Fatal(err)
	}
	password = strings.TrimSuffix(strings.TrimSuffix(password, "\n"), "\r")
	dsn := os.Getenv("BANHCUON_DATABASE_URL")
	if dsn == "" {
		log.Fatal("thiếu BANHCUON_DATABASE_URL")
	}
	ctx := context.Background()
	pool, err := postgres.Open(ctx, dsn, os.Getenv("BANHCUON_SHOP_TZ"))
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()
	out, err := taikhoan.KhoiTaoChuQuan(ctx, pool, taikhoan.ChuQuanMoi{Username: *username, Email: *email, DisplayName: *display, Password: password})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("account_id=%d person_id=%d status=%s\n", out.AccountID, out.PersonID, out.Status)
}
