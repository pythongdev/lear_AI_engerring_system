package tongquan_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strconv"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/nguyenlieu"
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
	// Nhân viên không trực cũng không được nhập tối thiểu.
	req := httptest.NewRequest("PUT", "/daily-minimums/2087-02-01", strings.NewReader(`{"minimum_banh":100,"minimum_workers":2}`))
	req.Header.Set("Content-Type", "application/json")
	req.AddCookie(&http.Cookie{Name: "banhcuon_phien", Value: testhelper.Session(t, nhanvien)})
	denied := httptest.NewRecorder()
	r.ServeHTTP(denied, req)
	if denied.Code != 403 || !strings.Contains(denied.Body.String(), `"owner_only"`) {
		t.Fatalf("nhân viên ghi được: %d %s", denied.Code, denied.Body.String())
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

	put := func(person int64, day, body string) *httptest.ResponseRecorder {
		req := httptest.NewRequest("PUT", "/daily-minimums/"+day, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
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
		w := put(tc.person, "2087-02-01", `{"minimum_banh":100,"minimum_workers":2}`)
		var out struct{ Code string }
		_ = json.Unmarshal(w.Body.Bytes(), &out)
		if w.Code != tc.status || out.Code != tc.code {
			t.Fatalf("quyền ghi: %d %s", w.Code, w.Body.String())
		}
	}
	for _, body := range []string{`{}`, `{"minimum_banh":0,"minimum_workers":1}`, `{"minimum_banh":1,"minimum_workers":-1}`, `{"minimum_banh":1.5,"minimum_workers":1}`, `{"minimum_banh":2147483648,"minimum_workers":1}`} {
		if w := put(chu, "2087-02-01", body); w.Code != 400 {
			t.Fatalf("hình sai được nhận: %d %s", w.Code, w.Body.String())
		}
	}
	if w := put(chu, "2087-02-30", `{"minimum_banh":1,"minimum_workers":1}`); w.Code != 400 {
		t.Fatal("ngày sai được nhận")
	}
	for _, body := range []string{`{"minimum_banh":100,"minimum_workers":2}`, `{"minimum_banh":120,"minimum_workers":3}`} {
		w := put(chu, "2087-02-01", body)
		var out tongquan.ToiThieu
		if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
			t.Fatal(err)
		}
		if w.Code != 200 || out.SaleDate != "2087-02-01" || out.PersonID <= 0 || out.CreatedAt.IsZero() {
			t.Fatalf("ghi: %d %s", w.Code, w.Body.String())
		}
	}
	var n int
	if err := owner.QueryRow(ctx, `SELECT count(*) FROM shop.daily_minimum WHERE sale_date='2087-02-01' AND minimum_banh=120 AND minimum_workers=3`).Scan(&n); err != nil || n != 1 {
		t.Fatalf("upsert: %d %v", n, err)
	}
	if err := owner.QueryRow(ctx, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='daily_minimum' AND person_id=$1 AND before_image->>'minimum_banh'='100' AND after_image->>'minimum_banh'='120'`, chu).Scan(&n); err != nil || n < 1 {
		t.Fatalf("vết cửa: %d %v", n, err)
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
		SalesProgress    struct {
			Status      string
			Reason      string
			MinimumBanh *int32 `json:"minimum_banh"`
		} `json:"sales_progress"`
		Shortages struct {
			Workers struct {
				Reason         string
				MinimumWorkers *int32 `json:"minimum_workers"`
			} `json:"workers"`
		} `json:"shortages"`
	}
	if err = json.Unmarshal(w.Body.Bytes(), &out); err != nil {
		t.Fatal(err)
	}
	if w.Code != 200 || out.SaleDate != "2026-10-15" || out.ProvisionalSales.Status != "available" {
		t.Fatalf("ngày bán/quyền chủ: %d %s", w.Code, w.Body.String())
	}
	if out.SalesProgress.Status != "unavailable" || out.SalesProgress.Reason != "daily_minimum_missing" || out.Shortages.Workers.Reason != "workers_present_missing" {
		t.Fatalf("hình chưa có: %s", w.Body.String())
	}
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) {
		return time.Date(2087, 2, 1, 0, 0, 0, 0, time.UTC), nil
	}
	w = get(chu)
	if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
		t.Fatal(err)
	}
	if w.Code != 200 || out.SalesProgress.Status != "available" || out.SalesProgress.MinimumBanh == nil || *out.SalesProgress.MinimumBanh != 120 || out.Shortages.Workers.MinimumWorkers == nil || *out.Shortages.Workers.MinimumWorkers != 3 {
		t.Fatalf("tối thiểu qua GET: %d %s", w.Code, w.Body.String())
	}

}

// Hai cửa đọc phải trả cùng các dòng kho, không kéo sổ ngày vào tổng quan.
func TestQC14_TongQuanNguyenLieuBangSupplyStockKhongCoSoNgay(t *testing.T) {
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
	var chu int64
	if err := owner.QueryRow(ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ('test-tổng quan kho',true) RETURNING id`).Scan(&chu); err != nil {
		t.Fatal(err)
	}
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	tongquan.Routes(r, tongquan.NewService(pool))
	nguyenlieu.Routes(r, nguyenlieu.NewService(pool))
	session := testhelper.Session(t, chu)
	call := func(method, path, body string, status int) []byte {
		t.Helper()
		req := httptest.NewRequest(method, path, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "banhcuon_phien", Value: session})
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != status {
			t.Fatalf("%s %s: %d %s", method, path, w.Code, w.Body.String())
		}
		return w.Body.Bytes()
	}
	var item nguyenlieu.Thu
	if err := json.Unmarshal(call("POST", "/supply-items", fmt.Sprintf(`{"name":"test-tổng quan kho-%d","purchase_unit":"kg"}`, chu), 201), &item); err != nil {
		t.Fatal(err)
	}
	for _, entry := range []struct{ kind, measure string }{{"purchased", "10"}, {"used", "3"}} {
		call("POST", "/supply-day-entries", fmt.Sprintf(`{"supply_item_id":%d,"entry_date":"2020-01-01","kind":%q,"measure":%q}`, item.ID, entry.kind, entry.measure), 201)
	}
	var overview struct {
		Shortages struct {
			Supplies struct{ Items []map[string]any }
		}
	}
	if err := json.Unmarshal(call("GET", "/owner-overview", "", 200), &overview); err != nil {
		t.Fatal(err)
	}
	var stock struct {
		Items []map[string]any `json:"supply_items"`
	}
	if err := json.Unmarshal(call("GET", "/supply-stock", "", 200), &stock); err != nil {
		t.Fatal(err)
	}
	fields := []string{"supply_item_id", "name", "purchase_unit", "purchased_total", "used_total", "balance", "reminder_ratio", "latest_purchase_date", "latest_purchase_measure", "reminder_status", "check_reminder"}
	found := false
	for _, row := range overview.Shortages.Supplies.Items {
		if _, ok := row["entries"]; ok {
			t.Fatalf("tổng quan mang sổ ngày: %v", row)
		}
		if len(row) != len(fields) {
			t.Fatalf("sai số trường: %v", row)
		}
		for _, field := range fields {
			if _, ok := row[field]; !ok {
				t.Fatalf("thiếu %s: %v", field, row)
			}
		}
		if row["supply_item_id"] == float64(item.ID) {
			found = true
		}
	}
	if !found {
		t.Fatal("thiếu nguyên liệu có hai dòng sổ ngày")
	}
	if !reflect.DeepEqual(overview.Shortages.Supplies.Items, stock.Items) {
		t.Fatalf("tổng quan khác kho: overview=%v stock=%v", overview.Shortages.Supplies.Items, stock.Items)
	}
}
