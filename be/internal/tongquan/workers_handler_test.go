package tongquan_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
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

func TestYC15_WorkersPresentQuyenLichSuNgayBanVaTongQuan(t *testing.T) {
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
	var chu, nv int64
	if err := db.QueryRow(ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ('test-workers-owner',true) RETURNING id`).Scan(&chu); err != nil {
		t.Fatal(err)
	}
	if err := db.QueryRow(ctx, `INSERT INTO shop.person(display_name) VALUES ('test-workers-counter') RETURNING id`).Scan(&nv); err != nil {
		t.Fatal(err)
	}
	duty := func(person int64) {
		t.Helper()
		err := pgx.BeginFunc(ctx, db, func(tx pgx.Tx) error {
			if _, e := tx.Exec(ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-workers-duty',true)`, fmt.Sprint(chu)); e != nil {
				return e
			}
			if _, e := tx.Exec(ctx, `UPDATE shop.counter_duty SET ended_at=now() WHERE ended_at IS NULL`); e != nil {
				return e
			}
			if person > 0 {
				_, e := tx.Exec(ctx, `INSERT INTO shop.counter_duty(person_id,started_at) VALUES ($1,now())`, person)
				return e
			}
			return nil
		})
		if err != nil {
			t.Fatal(err)
		}
	}
	duty(0)
	defer duty(0)
	old := ngayban.DongHo
	// 23:59 UTC: quy ngày tại quán sang ngày sau, ngoài giờ bán.
	clock := time.Date(2086, 4, 1, 23, 59, 0, 0, time.UTC)
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return clock, nil }
	defer func() { ngayban.DongHo = old }()
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	tongquan.Routes(r, tongquan.NewService(pool))
	sessions := map[int64]string{chu: testhelper.Session(t, chu), nv: testhelper.Session(t, nv)}
	call := func(person int64, method, path, body string, status int, code string) []byte {
		t.Helper()
		req := httptest.NewRequest(method, path, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		if person > 0 {
			req.AddCookie(&http.Cookie{Name: "banhcuon_phien", Value: sessions[person]})
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != status {
			t.Fatalf("%s %s: %d %s", method, path, w.Code, w.Body.String())
		}
		if code != "" {
			var e struct{ Code string }
			if err := json.Unmarshal(w.Body.Bytes(), &e); err != nil || e.Code != code {
				t.Fatalf("lỗi: %s %v", w.Body.String(), err)
			}
		}
		return w.Body.Bytes()
	}
	for _, tc := range []struct {
		person int64
		status int
		code   string
	}{{0, 401, "unauthenticated"}, {nv, 403, "not_on_counter_duty"}, {chu, 403, "not_on_counter_duty"}} {
		call(tc.person, "POST", "/workers-present-declarations", `{"worker_count":3}`, tc.status, tc.code)
	}
	call(0, "GET", "/workers-present", "", 401, "unauthenticated")
	call(nv, "GET", "/workers-present", "", 403, "not_on_counter_duty")
	read := func(person int64) tongquan.NguoiDangLam {
		t.Helper()
		var out tongquan.NguoiDangLam
		if err := json.Unmarshal(call(person, "GET", "/workers-present", "", 200, ""), &out); err != nil {
			t.Fatal(err)
		}
		return out
	}
	overview := func() tongquan.TongQuan {
		t.Helper()
		var out tongquan.TongQuan
		if err := json.Unmarshal(call(chu, "GET", "/owner-overview", "", 200, ""), &out); err != nil {
			t.Fatal(err)
		}
		return out
	}
	if out := read(chu); out.SaleDate != "2086-04-02" || out.Declaration != nil {
		t.Fatalf("chưa khai: %+v", out)
	}
	if out := overview(); out.WorkersPresent.Reason != "workers_present_missing" || out.Shortages.Workers.Reason != "workers_present_missing" {
		t.Fatalf("chưa khai: %+v", out)
	}
	call(chu, "PUT", "/daily-minimums/2086-04-02", `{"minimum_banh":100,"minimum_workers":4}`, 200, "")
	if out := overview(); out.Shortages.Workers.MinimumWorkers == nil || *out.Shortages.Workers.MinimumWorkers != 4 || out.Shortages.Workers.Reason != "workers_present_missing" {
		t.Fatalf("có tối thiểu, chưa khai: %+v", out)
	}
	duty(nv)
	declare := func(person int64, count int32) tongquan.KhaiNguoi {
		t.Helper()
		var out tongquan.KhaiNguoi
		if err := json.Unmarshal(call(person, "POST", "/workers-present-declarations", fmt.Sprintf(`{"worker_count":%d}`, count), 201, ""), &out); err != nil {
			t.Fatal(err)
		}
		if out.ID <= 0 || out.PersonID != person || out.WorkerCount != count || out.SaleDate != "2086-04-02" || out.DeclaredAt.IsZero() || out.PersonName == "" {
			t.Fatalf("khai: %+v", out)
		}
		return out
	}
	first := declare(nv, 3)
	if first.PersonName != "test-workers-counter" {
		t.Fatalf("sai tên: %+v", first)
	}
	if out := read(nv); out.Declaration == nil || out.Declaration.ID != first.ID {
		t.Fatalf("đọc POS: %+v", out)
	}
	out := overview()
	if out.WorkersPresent.Status != "available" || out.WorkersPresent.WorkerCount == nil || *out.WorkersPresent.WorkerCount != 3 || out.Shortages.Workers.Status != "available" || out.Shortages.Workers.Short == nil || !*out.Shortages.Workers.Short || out.Shortages.Workers.MissingWorkers == nil || *out.Shortages.Workers.MissingWorkers != 1 {
		t.Fatalf("thiếu một người: %+v", out)
	}
	duty(chu)
	second := declare(chu, 5)
	if second.ID == first.ID || second.PersonName != "test-workers-owner" {
		t.Fatalf("khai lại: %+v", second)
	}
	if out := read(chu); out.Declaration == nil || *out.Declaration != second {
		t.Fatalf("lần mới nhất: %+v", out)
	}
	out = overview()
	if out.WorkersPresent.WorkerCount == nil || *out.WorkersPresent.WorkerCount != 5 || out.WorkersPresent.PersonID == nil || *out.WorkersPresent.PersonID != chu || out.Shortages.Workers.Short == nil || *out.Shortages.Workers.Short || out.Shortages.Workers.MissingWorkers == nil || *out.Shortages.Workers.MissingWorkers != 0 {
		t.Fatalf("đủ người: %+v", out)
	}
	var n int
	if err := db.QueryRow(ctx, `SELECT count(*) FROM shop.workers_present_declaration WHERE sale_date='2086-04-02' AND ((id=$1 AND person_id=$2 AND worker_count=3) OR (id=$3 AND person_id=$4 AND worker_count=5))`, first.ID, nv, second.ID, chu).Scan(&n); err != nil || n != 2 {
		t.Fatalf("dòng đã ghi: n=%d err=%v", n, err)
	}
	clock = clock.AddDate(0, 0, 1)
	if got := read(chu); got.Declaration != nil || got.SaleDate != "2086-04-03" {
		t.Fatalf("lấy ngày trước: %+v", got)
	}
	out = overview()
	if out.WorkersPresent.Reason != "workers_present_missing" || out.Shortages.Workers.Reason != "workers_present_missing" {
		t.Fatalf("tổng quan lấy ngày trước: %+v", out)
	}
	call(chu, "POST", "/workers-present-declarations", `{"worker_count":2}`, 201, "")
	out = overview()
	if out.WorkersPresent.Status != "available" || out.Shortages.Workers.Status != "unavailable" || out.Shortages.Workers.Reason != "daily_minimum_missing" {
		t.Fatalf("thiếu tối thiểu: %+v", out)
	}
}
