package nhandon_test

import (
	"bufio"
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/nhandon"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/platform/realtime"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

func TestI008_LuongChuQuanVanHanhDuocTinhLaNhinThayDon(t *testing.T) {
	ctx := context.Background()
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	db, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close(ctx)
	var chu, ngoai int64
	if err := db.QueryRow(ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ('test-t308-owner',true) RETURNING id`).Scan(&chu); err != nil {
		t.Fatal(err)
	}
	if err := db.QueryRow(ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ('test-t308-outside',false) RETURNING id`).Scan(&ngoai); err != nil {
		t.Fatal(err)
	}
	broker := realtime.New(100 * time.Millisecond)
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	nhandon.Routes(r, nhandon.NewService(pool, broker))
	srv := httptest.NewServer(r)
	defer srv.Close()
	request := func(path string, person int64) *http.Request {
		t.Helper()
		req, err := http.NewRequest("GET", srv.URL+path, nil)
		if err != nil {
			t.Fatal(err)
		}
		if person != 0 {
			req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, person)})
		}
		return req
	}
	for _, tc := range []struct {
		person int64
		status int
	}{{0, 401}, {ngoai, 403}, {chu, 200}} {
		res, err := http.DefaultClient.Do(request("/counter/queue", tc.person))
		if err != nil {
			t.Fatal(err)
		}
		res.Body.Close()
		if res.StatusCode != tc.status {
			t.Fatalf("queue người %d: %d, muốn %d", tc.person, res.StatusCode, tc.status)
		}
	}
	res, err := http.DefaultClient.Do(request("/counter/events", ngoai))
	if err != nil {
		t.Fatal(err)
	}
	res.Body.Close()
	if res.StatusCode != 403 {
		t.Fatalf("luồng người ngoài quầy: %d", res.StatusCode)
	}
	if seeing, _ := broker.Seeing(); seeing {
		t.Fatal("người sai lớp được tính là nhìn thấy đơn")
	}

	res, err = http.DefaultClient.Do(request("/counter/events", chu))
	if err != nil {
		t.Fatal(err)
	}
	if res.StatusCode != 200 {
		res.Body.Close()
		t.Fatalf("luồng chủ quán: %d", res.StatusCode)
	}
	line, err := bufio.NewReader(res.Body).ReadString('\n')
	if err != nil || !strings.HasPrefix(line, "event: hello") {
		res.Body.Close()
		t.Fatalf("thiếu hello: %q %v", line, err)
	}
	if seeing, _ := broker.Seeing(); !seeing {
		res.Body.Close()
		t.Fatal("chủ quán đang xem mà quán bị coi là mù")
	}
	res.Body.Close()
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if seeing, _ := broker.Seeing(); !seeing {
			return
		}
		time.Sleep(10 * time.Millisecond)
	}
	t.Fatal("chủ quán rời trang mà luồng vẫn được tính")
}
