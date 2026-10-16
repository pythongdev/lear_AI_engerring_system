package tongquan_test

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"
	"time"

	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"banhcuon/be/internal/tongquan"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

// Chạy qua be-check với PostgreSQL thật; không bỏ qua khi thiếu DB.
func TestYC16_TongQuanChiChuQuanVaNgayBan(t *testing.T) {
	ctx := context.Background()
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	owner, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer owner.Close(ctx)
	var chu, nhanvien int64
	if err = owner.QueryRow(ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ('test-tổng quan chủ',true) RETURNING id`).Scan(&chu); err != nil {
		t.Fatal(err)
	}
	if err = owner.QueryRow(ctx, `INSERT INTO shop.person(display_name) VALUES ('test-tổng quan nhân viên') RETURNING id`).Scan(&nhanvien); err != nil {
		t.Fatal(err)
	}
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	tongquan.Routes(r, tongquan.NewService(pool))
	get := func(person int64) *httptest.ResponseRecorder {
		req := httptest.NewRequest("GET", "/owner-overview", nil)
		if person > 0 {
			req.AddCookie(&http.Cookie{Name: "banhcuon_phien", Value: testhelper.Session(t, person)})
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		return w
	}
	for _, tc := range []struct {
		person int64
		status int
		code   string
	}{{0, 401, "unauthenticated"}, {nhanvien, 403, "owner_only"}} {
		w := get(tc.person)
		var out struct{ Code string }
		if e := json.Unmarshal(w.Body.Bytes(), &out); e != nil {
			t.Fatal(e)
		}
		if w.Code != tc.status || out.Code != tc.code {
			t.Fatalf("quyền: %d %s", w.Code, w.Body.String())
		}
	}
	// Người đang trực quầy cũng bị từ chối; đóng khoảng test khi xong.
	var duty int64
	err = pgx.BeginFunc(ctx, owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-tổng quan',true)`, strconv.FormatInt(chu, 10)); e != nil {
			return e
		}
		if _, e := tx.Exec(ctx, `UPDATE shop.counter_duty SET ended_at=now() WHERE ended_at IS NULL`); e != nil {
			return e
		}
		return tx.QueryRow(ctx, `INSERT INTO shop.counter_duty(person_id,started_at) VALUES ($1,now()) RETURNING id`, nhanvien).Scan(&duty)
	})
	if err != nil {
		t.Fatal(err)
	}
	defer func() {
		e := pgx.BeginFunc(ctx, owner, func(tx pgx.Tx) error {
			if _, e := tx.Exec(ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-khép trực tổng quan',true)`, strconv.FormatInt(chu, 10)); e != nil {
				return e
			}
			_, e := tx.Exec(ctx, `UPDATE shop.counter_duty SET ended_at=now() WHERE id=$1 AND ended_at IS NULL`, duty)
			return e
		})
		if e != nil {
			t.Error(e)
		}
	}()
	w := get(nhanvien)
	if w.Code != 403 {
		t.Fatalf("POS đọc được: %d %s", w.Code, w.Body.String())
	}
	// Mốc sát nửa đêm quán: ngày máy UTC vẫn là 14, ngày bán đã sang 15.
	cu := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) {
		return time.Date(2026, 10, 14, 17, 0, 0, 0, time.UTC), nil
	}
	defer func() { ngayban.DongHo = cu }()
	w = get(chu)
	var out struct {
		SaleDate         string                  `json:"sale_date"`
		ProvisionalSales struct{ Status string } `json:"provisional_sales"`
	}
	if err = json.Unmarshal(w.Body.Bytes(), &out); err != nil {
		t.Fatal(err)
	}
	if w.Code != 200 || out.SaleDate != "2026-10-15" || out.ProvisionalSales.Status != "unavailable" {
		t.Fatalf("ngày bán/quyền chủ: %d %s", w.Code, w.Body.String())
	}
}
