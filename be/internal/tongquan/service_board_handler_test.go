package tongquan_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"banhcuon/be/internal/tongquan"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

// T-225 (ADR-124 điểm 1): lớp quay_hoac_chu_quan — Claude viết trước khi giao.
func TestYC15_BangVanHanhQuayHoacChuQuan(t *testing.T) {
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
	var chu, quay, ngoai int64
	for _, x := range []struct {
		name  string
		owner bool
		id    *int64
	}{{"test-t225-owner", true, &chu}, {"test-t225-counter", false, &quay}, {"test-t225-outside", false, &ngoai}} {
		if err := db.QueryRow(ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ($1,$2) RETURNING id`, x.name, x.owner).Scan(x.id); err != nil {
			t.Fatal(err)
		}
	}
	duty := func(person int64) {
		t.Helper()
		err := pgx.BeginFunc(ctx, db, func(tx pgx.Tx) error {
			if _, e := tx.Exec(ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-t225-duty',true)`, fmt.Sprint(chu)); e != nil {
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
	duty(quay)
	defer duty(0)
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	tongquan.Routes(r, tongquan.NewService(pool))
	sessions := map[int64]string{chu: testhelper.Session(t, chu), quay: testhelper.Session(t, quay), ngoai: testhelper.Session(t, ngoai)}
	call := func(person int64, status int, code string) []byte {
		t.Helper()
		req := httptest.NewRequest("GET", "/service-board", nil)
		if person > 0 {
			req.AddCookie(&http.Cookie{Name: "banhcuon_phien", Value: sessions[person]})
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != status {
			t.Fatalf("người %d: %d %s", person, w.Code, w.Body.String())
		}
		if code != "" {
			var e struct{ Code string }
			if err := json.Unmarshal(w.Body.Bytes(), &e); err != nil || e.Code != code {
				t.Fatalf("lỗi: %s %v", w.Body.String(), err)
			}
		}
		return w.Body.Bytes()
	}
	call(0, 401, "unauthenticated")
	call(ngoai, 403, "not_on_counter_duty")
	for _, person := range []int64{chu, quay} {
		var out map[string]json.RawMessage
		if err := json.Unmarshal(call(person, 200, ""), &out); err != nil {
			t.Fatal(err)
		}
		for _, key := range []string{"sale_date", "read_at", "sessions", "empty_tables", "serve_history"} {
			if v, ok := out[key]; !ok || string(v) == "null" {
				t.Fatalf("thiếu %s (danh sách rỗng là []): %v", key, out)
			}
		}
	}
}
