package tongket_test

import (
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strconv"
	"strings"
	"testing"

	"banhcuon/be/internal/ket"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/nguyenlieu"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"banhcuon/be/internal/tongket"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

//go:embed testdata/http.sql
var httpFixture string

func TestQC14_SummaryQuyenHinhSoGiayVaNhacKiemTra(t *testing.T) {
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
	var chu, worker int64
	if err = owner.QueryRow(ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ('test-p3a10-http-owner',true) RETURNING id`).Scan(&chu); err != nil {
		t.Fatal(err)
	}
	if err = owner.QueryRow(ctx, `INSERT INTO shop.person(display_name) VALUES ('test-p3a10-http-worker') RETURNING id`).Scan(&worker); err != nil {
		t.Fatal(err)
	}
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	tongket.Routes(r, tongket.NewService(pool))
	nguyenlieu.Routes(r, nguyenlieu.NewService(pool))
	sessions := map[int64]string{chu: testhelper.Session(t, chu), worker: testhelper.Session(t, worker)}
	call := func(person int64, method, path, body string) *httptest.ResponseRecorder {
		t.Helper()
		req := httptest.NewRequest(method, path, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		if person > 0 {
			req.AddCookie(&http.Cookie{Name: "banhcuon_phien", Value: sessions[person]})
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		return w
	}
	for _, tc := range []struct {
		person int64
		status int
		code   string
	}{{0, 401, "unauthenticated"}, {worker, 403, "owner_only"}} {
		w := call(tc.person, "GET", "/sale-days/2185-01-01/summary", "")
		if w.Code != tc.status || !strings.Contains(w.Body.String(), `"code":"`+tc.code+`"`) {
			t.Fatalf("quyền: %d %s", w.Code, w.Body.String())
		}
	}
	var duty int64
	err = pgx.BeginFunc(ctx, owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-p3a10-duty',true)`, strconv.FormatInt(chu, 10)); e != nil {
			return e
		}
		if _, e := tx.Exec(ctx, `UPDATE shop.counter_duty SET ended_at=greatest(now(),started_at+interval '1 second') WHERE ended_at IS NULL`); e != nil {
			return e
		}
		return tx.QueryRow(ctx, `INSERT INTO shop.counter_duty(person_id,started_at) VALUES ($1,now()) RETURNING id`, worker).Scan(&duty)
	})
	if err != nil {
		t.Fatal(err)
	}
	defer func() {
		e := pgx.BeginFunc(ctx, owner, func(tx pgx.Tx) error {
			if _, e := tx.Exec(ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-p3a10-close-duty',true)`, strconv.FormatInt(chu, 10)); e != nil {
				return e
			}
			_, e := tx.Exec(ctx, `UPDATE shop.counter_duty SET ended_at=now() WHERE id=$1`, duty)
			return e
		})
		if e != nil {
			t.Error(e)
		}
	}()
	w := call(worker, "GET", "/sale-days/2185-01-01/summary", "")
	if w.Code != 403 || !strings.Contains(w.Body.String(), `"owner_only"`) {
		t.Fatalf("POS: %d %s", w.Code, w.Body.String())
	}
	for _, person := range []int64{0, worker, chu} {
		w = call(person, "GET", "/sale-days/2026-02-30/summary", "")
		if w.Code != 400 || !strings.Contains(w.Body.String(), `"field":"sale_date"`) {
			t.Fatalf("hình trước quyền: %d %s", w.Code, w.Body.String())
		}
	}
	read := func(day string) tongket.Summary {
		t.Helper()
		w := call(chu, "GET", "/sale-days/"+day+"/summary", "")
		if w.Code != 200 {
			t.Fatalf("summary: %d %s", w.Code, w.Body.String())
		}
		var out tongket.Summary
		if e := json.Unmarshal(w.Body.Bytes(), &out); e != nil {
			t.Fatal(e)
		}
		var top map[string]json.RawMessage
		if e := json.Unmarshal(w.Body.Bytes(), &top); e != nil {
			t.Fatal(e)
		}
		if len(top) != 4 {
			t.Fatalf("cần bốn mục: %s", w.Body.String())
		}
		var rev map[string]json.RawMessage
		if e := json.Unmarshal(top["revenue"], &rev); e != nil {
			t.Fatal(e)
		}
		for _, key := range []string{"table_session_vnd", "standalone_vnd", "refunds_vnd", "total_vnd", "reconciliation_status", "paper_entries_pending"} {
			if _, ok := rev[key]; !ok {
				t.Fatalf("thiếu %s", key)
			}
		}
		return out
	}
	empty := read("2185-01-01")
	if empty.Revenue != (tongket.Revenue{}) || empty.BestSellers.Items == nil || len(empty.BestSellers.Items) != 0 || empty.BestSellers.Combos == nil || len(empty.BestSellers.Combos) != 0 || empty.Staff == nil || len(empty.Staff) != 0 || empty.SupplyReminders.Items == nil {
		t.Fatalf("ngày trống: %+v", empty)
	}
	// Nhắc nguyên liệu là ảnh hiện tại, có thể có dữ liệu của package khác trong be-check.
	if empty.SupplyReminders.ReadAt.IsZero() {
		t.Fatal("thiếu read_at")
	}
	err = pgx.BeginFunc(ctx, owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(ctx, `SET LOCAL search_path=shop,public`); e != nil {
			return e
		}
		_, e := tx.Exec(ctx, httpFixture)
		return e
	})
	if err != nil {
		t.Fatal(err)
	}
	pending := read("2185-01-02")
	if pending.Revenue.PaperEntriesPending != 2 || pending.Revenue.ReconciliationStatus != nil || pending.Revenue.TotalVnd != 100 {
		t.Fatalf("chưa đếm két vẫn phải còn 2: %+v", pending.Revenue)
	}
	if _, err = ket.NewService(pool).DocSo(ctx, "2185-01-02"); err == nil {
		t.Fatal("DocSo phải giữ hành vi thiếu số đếm")
	}
	for day, want := range map[string]string{"2185-02-01": "reconciled", "2185-02-02": "reopened"} {
		out := read(day)
		old, e := ket.NewService(pool).DocSo(ctx, day)
		if e != nil {
			t.Fatal(e)
		}
		if out.Revenue.ReconciliationStatus == nil || *out.Revenue.ReconciliationStatus != want || !reflect.DeepEqual(out.Revenue.ReconciliationStatus, old.Status) || out.Revenue.PaperEntriesPending != old.PaperEntriesPending {
			t.Fatalf("trạng thái khác DocSo: %+v %+v", out.Revenue, old)
		}
	}
	// Dựng nguyên liệu cần kiểm qua chính cửa hiện có.
	w = call(chu, "POST", "/supply-items", fmt.Sprintf(`{"name":"test-p3a10-reminder-%d","purchase_unit":"kg"}`, chu))
	if w.Code != 201 {
		t.Fatalf("tạo nguyên liệu: %d %s", w.Code, w.Body.String())
	}
	var item nguyenlieu.Thu
	if err = json.Unmarshal(w.Body.Bytes(), &item); err != nil {
		t.Fatal(err)
	}
	for _, entry := range []struct{ kind, measure string }{{"purchased", "10"}, {"used", "9"}} {
		w = call(chu, "POST", "/supply-day-entries", fmt.Sprintf(`{"supply_item_id":%d,"entry_date":"2020-01-01","kind":%q,"measure":%q}`, item.ID, entry.kind, entry.measure))
		if w.Code != 201 {
			t.Fatalf("ghi nguyên liệu: %d %s", w.Code, w.Body.String())
		}
	}
	out := read("2185-01-01")
	w = call(chu, "GET", "/supply-check-reminders", "")
	if w.Code != 200 {
		t.Fatalf("nhắc: %d %s", w.Code, w.Body.String())
	}
	var reminders nguyenlieu.NhacKiemTra
	if err = json.Unmarshal(w.Body.Bytes(), &reminders); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(out.SupplyReminders.Items, reminders.Items) || out.SupplyReminders.ReadAt.IsZero() || reminders.ReadAt.IsZero() {
		t.Fatalf("khác tập: %+v %+v", out.SupplyReminders, reminders)
	}
	found := false
	for _, v := range reminders.Items {
		if v.ID == item.ID {
			found = true
		}
	}
	if !found {
		t.Fatal("fixture phải có thứ cần kiểm")
	}
}
