// Test từ chối qua bốn cửa sửa menu của chủ quán (P3-06, ADR-086; I-011 · I-012 · I-018,
// architecture.md §6.1 — sửa THÀNH PHẦN, không sửa giá suất). Viết TRƯỚC khi có package menu —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Số và tên ở đây là giả (test-…).
package menu_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"
	"time"

	"banhcuon/be/internal/menu"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

// xacThucTest: danh tính chỉ cho test — bản thật chờ U-075.
type xacThucTest struct{}

func (xacThucTest) PersonID(r *http.Request) (int64, bool) {
	id, err := strconv.ParseInt(r.Header.Get("X-Test-Person-Id"), 10, 64)
	return id, err == nil
}

type khung struct {
	ctx   context.Context
	srv   *httptest.Server
	owner *pgx.Conn
}

// coVet chạy câu dựng dữ liệu trong một giao dịch có khai người và lý do: từ bước 20 (T-138, ADR-092)
// database từ chối lần sửa — và lần thêm dòng con vào bản ghi đã có — mà giao dịch không khai.
func (k khung) coVet(fn func(pgx.Tx) error) error {
	return pgx.BeginFunc(k.ctx, k.owner, func(tx pgx.Tx) error {
		if _, err := tx.Exec(k.ctx, `WITH co AS (SELECT id FROM shop.person WHERE display_name = 'test-người dựng dữ liệu' ORDER BY id LIMIT 1),
			moi AS (INSERT INTO shop.person (display_name) SELECT 'test-người dựng dữ liệu' WHERE NOT EXISTS (SELECT 1 FROM co) RETURNING id)
			SELECT set_config('shop.actor_person_id', id::text, true), set_config('shop.revision_reason', 'test-dựng dữ liệu', true)
			FROM (SELECT id FROM co UNION ALL SELECT id FROM moi) p`); err != nil {
			return err
		}
		return fn(tx)
	})
}

func dung(t *testing.T) khung {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	t.Cleanup(cancel)
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	owner, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { owner.Close(context.Background()) })
	mux := http.NewServeMux()
	menu.Routes(mux, pool, xacThucTest{})
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	return khung{ctx: ctx, srv: srv, owner: owner}
}

func (k khung) id(t *testing.T, sql string, args ...any) int64 {
	t.Helper()
	var id int64
	if err := k.coVet(func(tx pgx.Tx) error { return tx.QueryRow(k.ctx, sql, args...).Scan(&id) }); err != nil {
		t.Fatalf("%s: %v", sql, err)
	}
	return id
}

func (k khung) nguoi(t *testing.T, ten string, chuQuan bool) int64 {
	t.Helper()
	return k.id(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, $2) RETURNING id",
		fmt.Sprintf("%s · %s", ten, t.Name()), chuQuan)
}

func (k khung) vaoQuay(t *testing.T, nguoi int64) {
	t.Helper()
	time.Sleep(2 * time.Millisecond)
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, "UPDATE shop.counter_duty SET ended_at = now() WHERE ended_at IS NULL")
		return err
	}); err != nil {
		t.Fatal(err)
	}
	time.Sleep(2 * time.Millisecond)
	if _, err := k.owner.Exec(k.ctx,
		"INSERT INTO shop.counter_duty (person_id, started_at) VALUES ($1, now())", nguoi); err != nil {
		t.Fatal(err)
	}
}

var soMenu int

// menuGia: một suất giả gồm hai thành phần (một nhận nhân) và một nhóm hai lựa chọn.
type menuGia struct {
	banh, gio, mon, nhom, chay, thit int64
}

func (k khung) menuGia(t *testing.T) menuGia {
	t.Helper()
	soMenu++
	ten := func(s string) string { return fmt.Sprintf("test-%s %d · %s", s, soMenu, t.Name()) }
	var m menuGia
	m.banh = k.id(t, `INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 3000, true) RETURNING id`, ten("bánh"))
	m.gio = k.id(t, `INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 9000, false) RETURNING id`, ten("giò"))
	m.mon = k.id(t, `INSERT INTO shop.menu_item (name) VALUES ($1) RETURNING id`, ten("suất"))
	k.id(t, `INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 3) RETURNING id`, m.mon, m.banh)
	k.id(t, `INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 1) RETURNING id`, m.mon, m.gio)
	m.nhom = k.id(t, `INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id`, ten("nhân"))
	m.chay = k.id(t, `INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'chay', 0) RETURNING id`, m.nhom)
	m.thit = k.id(t, `INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'thịt', 1000) RETURNING id`, m.nhom)
	k.id(t, `INSERT INTO shop.menu_item_option_group (menu_item_id, option_group_id) VALUES ($1, $2) RETURNING id`, m.mon, m.nhom)
	return m
}

type traVe struct {
	status int
	body   map[string]any
}

func (k khung) goi(t *testing.T, method, path string, nguoi int64, body any) traVe {
	t.Helper()
	var raw []byte
	switch b := body.(type) {
	case nil:
	case string:
		raw = []byte(b)
	default:
		var err error
		if raw, err = json.Marshal(b); err != nil {
			t.Fatal(err)
		}
	}
	req, err := http.NewRequestWithContext(k.ctx, method, k.srv.URL+path, bytes.NewReader(raw))
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")
	if nguoi != 0 {
		req.Header.Set("X-Test-Person-Id", strconv.FormatInt(nguoi, 10))
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	out := traVe{status: res.StatusCode, body: map[string]any{}}
	_ = json.NewDecoder(res.Body).Decode(&out.body)
	t.Logf("%s %s (người %d) ⇒ %d %v", method, path, nguoi, out.status, out.body)
	return out
}

func tuChoi(t *testing.T, r traVe, status int, code, field string) {
	t.Helper()
	if r.status != status || r.body["code"] != code || (field != "" && r.body["field"] != field) {
		t.Fatalf("muốn %d %s field=%q, nhận %d %v", status, code, field, r.status, r.body)
	}
}

// anh chụp bốn ô mà bốn cửa sửa — để chứng minh lời từ chối không đổi gì.
func (k khung) anh(t *testing.T, m menuGia) string {
	t.Helper()
	var s string
	if err := k.owner.QueryRow(k.ctx, `SELECT format('%s|%s|%s|%s',
		(SELECT base_price_vnd FROM shop.menu_component WHERE id = $1),
		(SELECT surcharge_vnd FROM shop.menu_option WHERE id = $2),
		(SELECT quantity FROM shop.menu_item_component WHERE menu_item_id = $3 AND menu_component_id = $1),
		(SELECT discontinued_at FROM shop.menu_item WHERE id = $3))`, m.banh, m.thit, m.mon).Scan(&s); err != nil {
		t.Fatal(err)
	}
	return s
}

func (k khung) soVet(t *testing.T) int64 {
	t.Helper()
	return k.id(t, "SELECT count(*) FROM shop.record_revision")
}

type cuaSua struct {
	ten, method, path string
	body              map[string]any
	bang              string // bảng của dòng bị sửa — target_table_code của vết
	dong              int64
	cot               string
	moi               string // giá trị mới của cột, đọc theo after_image ->> cot
}

func bonCua(m menuGia) []cuaSua {
	return []cuaSua{
		{"đổi giá thành phần", "PUT", fmt.Sprintf("/menu-components/%d/base-price", m.banh),
			map[string]any{"base_price_vnd": 3500, "reason": "test: chợ lên giá"}, "menu_component", m.banh, "base_price_vnd", "3500"},
		{"đổi phụ thu", "PUT", fmt.Sprintf("/menu-options/%d/surcharge", m.thit),
			map[string]any{"surcharge_vnd": 1500, "reason": "test: thịt lên giá"}, "menu_option", m.thit, "surcharge_vnd", "1500"},
		{"đổi thành phần suất", "PUT", fmt.Sprintf("/menu-items/%d/components/%d", m.mon, m.banh),
			map[string]any{"quantity": 2, "reason": "test: bớt một bánh"}, "menu_item_component", 0, "quantity", "2"},
		{"ngừng bán", "POST", fmt.Sprintf("/menu-items/%d/discontinuation", m.mon),
			map[string]any{"reason": "test: bỏ món"}, "menu_item", m.mon, "discontinued_at", ""},
	}
}

// U-062 cùng họ: chỉ chủ quán sửa menu (architecture.md §6.1, I-012 — hai ca đứng tên khác quầy).
func TestI012_ChiChuQuanSuaMenu(t *testing.T) {
	k := dung(t)
	m := k.menuGia(t)
	a := k.nguoi(t, "A", false)
	k.vaoQuay(t, a)
	truoc, vet := k.anh(t, m), k.soVet(t)
	for _, c := range bonCua(m) {
		tuChoi(t, k.goi(t, c.method, c.path, a, c.body), http.StatusForbidden, "owner_only", "")
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if sau := k.anh(t, m); sau != truoc {
		t.Fatalf("lời từ chối mà menu vẫn đổi: %s → %s", truoc, sau)
	}
	if k.soVet(t) != vet {
		t.Fatal("lời từ chối mà vẫn có vết")
	}
}

// I-018 · I-012 · I-011: mỗi lần sửa menu mang lý do, và để lại vết đọc ra cái gì · ai · lúc nào.
func TestI018_SuaMenuCoLyDoVaDeVet(t *testing.T) {
	k := dung(t)
	m := k.menuGia(t)
	chu := k.nguoi(t, "chủ quán", true)
	for _, c := range bonCua(m) {
		truoc, vet := k.anh(t, m), k.soVet(t)
		for _, lyDo := range []any{nil, "   "} {
			body := map[string]any{}
			for kk, v := range c.body {
				body[kk] = v
			}
			if lyDo == nil {
				delete(body, "reason")
			} else {
				body["reason"] = lyDo
			}
			tuChoi(t, k.goi(t, c.method, c.path, chu, body), http.StatusBadRequest, "invalid_request", "reason")
		}
		if k.anh(t, m) != truoc || k.soVet(t) != vet {
			t.Fatalf("%s: thiếu lý do mà vẫn ghi", c.ten)
		}
		r := k.goi(t, c.method, c.path, chu, c.body)
		if r.status != http.StatusOK {
			t.Fatalf("%s: muốn 200, nhận %d %v", c.ten, r.status, r.body)
		}
		dong := c.dong
		if dong == 0 {
			dong = k.id(t, "SELECT id FROM shop.menu_item_component WHERE menu_item_id = $1 AND menu_component_id = $2", m.mon, m.banh)
		}
		var nguoi int64
		var lyDo, moi string
		if err := k.owner.QueryRow(k.ctx, `SELECT person_id, reason, coalesce(after_image ->> $3, '')
			FROM shop.record_revision WHERE target_table_code = $1 AND target_row = $2
			ORDER BY id DESC LIMIT 1`, c.bang, dong, c.cot).Scan(&nguoi, &lyDo, &moi); err != nil {
			t.Fatalf("%s: không có vết: %v", c.ten, err)
		}
		t.Logf("%s: vết người=%d lý do=%q %s=%q", c.ten, nguoi, lyDo, c.cot, moi)
		if nguoi != chu || lyDo != c.body["reason"] || (c.moi != "" && moi != c.moi) || moi == "" {
			t.Fatalf("%s: vết sai — muốn người %d, lý do %q, %s=%q", c.ten, chu, c.body["reason"], c.cot, c.moi)
		}
		if k.soVet(t) != vet+1 {
			t.Fatalf("%s: muốn đúng một vết mới, có %d", c.ten, k.soVet(t)-vet)
		}
	}
}

func TestI018_GiaTriSaiKhongGhi(t *testing.T) {
	k := dung(t)
	m := k.menuGia(t)
	chu := k.nguoi(t, "chủ quán", true)
	truoc := k.anh(t, m)
	ca := []struct {
		method, path string
		body         any
		truong       string
	}{
		{"PUT", fmt.Sprintf("/menu-components/%d/base-price", m.banh), map[string]any{"base_price_vnd": -1, "reason": "test"}, "base_price_vnd"},
		{"PUT", fmt.Sprintf("/menu-components/%d/base-price", m.banh), `{"base_price_vnd": 1000.5, "reason": "test"}`, ""},
		{"PUT", fmt.Sprintf("/menu-components/%d/base-price", m.banh), map[string]any{"reason": "test"}, "base_price_vnd"},
		{"PUT", fmt.Sprintf("/menu-options/%d/surcharge", m.thit), map[string]any{"surcharge_vnd": -1, "reason": "test"}, "surcharge_vnd"},
		{"PUT", fmt.Sprintf("/menu-items/%d/components/%d", m.mon, m.banh), map[string]any{"quantity": 0, "reason": "test"}, "quantity"},
		{"PUT", fmt.Sprintf("/menu-components/%s/base-price", "abc"), map[string]any{"base_price_vnd": 1, "reason": "test"}, "menu_component_id"},
	}
	for _, c := range ca {
		tuChoi(t, k.goi(t, c.method, c.path, chu, c.body), http.StatusBadRequest, "invalid_request", c.truong)
	}
	if k.anh(t, m) != truoc {
		t.Fatal("yêu cầu sai hình mà menu vẫn đổi")
	}
}

func TestI018_KhongTimThayKhongGhi(t *testing.T) {
	k := dung(t)
	m := k.menuGia(t)
	khac := k.menuGia(t) // một suất khác: thành phần của nó không thuộc suất m
	chu := k.nguoi(t, "chủ quán", true)
	ca := []struct {
		method, path string
		body         map[string]any
		status       int
		code         string
	}{
		{"PUT", "/menu-components/9000000000/base-price", map[string]any{"base_price_vnd": 1, "reason": "test"}, 404, "menu_component_not_found"},
		{"PUT", "/menu-options/9000000000/surcharge", map[string]any{"surcharge_vnd": 1, "reason": "test"}, 404, "menu_option_not_found"},
		{"PUT", fmt.Sprintf("/menu-items/%d/components/%d", m.mon, khac.banh), map[string]any{"quantity": 2, "reason": "test"}, 404, "menu_item_component_not_found"},
		{"POST", "/menu-items/9000000000/discontinuation", map[string]any{"reason": "test"}, 404, "menu_item_not_found"},
	}
	for _, c := range ca {
		tuChoi(t, k.goi(t, c.method, c.path, chu, c.body), c.status, c.code, "")
	}
}

// Ngừng bán là một mốc, đặt một lần: lần thứ hai bị từ chối, mốc cũ giữ nguyên.
func TestI009_NgungBanHaiLan(t *testing.T) {
	k := dung(t)
	m := k.menuGia(t)
	chu := k.nguoi(t, "chủ quán", true)
	path := fmt.Sprintf("/menu-items/%d/discontinuation", m.mon)
	r := k.goi(t, "POST", path, chu, map[string]any{"reason": "test: bỏ món"})
	if r.status != http.StatusOK || r.body["menu_item_id"] != float64(m.mon) || r.body["discontinued_at"] == nil {
		t.Fatalf("ngừng bán: muốn 200 kèm menu_item_id và discontinued_at, nhận %d %v", r.status, r.body)
	}
	truoc := k.anh(t, m)
	tuChoi(t, k.goi(t, "POST", path, chu, map[string]any{"reason": "test: lần hai"}), http.StatusConflict, "menu_item_discontinued", "")
	if k.anh(t, m) != truoc {
		t.Fatal("lần ngừng thứ hai đổi mốc ngừng bán")
	}
}

// architecture.md §6.1: không đường gọi nào nhận giá của một suất — giá suất là kết quả tính ra.
func TestI013_KhongCoDuongSuaGiaSuat(t *testing.T) {
	k := dung(t)
	m := k.menuGia(t)
	chu := k.nguoi(t, "chủ quán", true)
	for _, p := range []string{"/price", "/base-price", "/unit-price"} {
		r := k.goi(t, "PUT", fmt.Sprintf("/menu-items/%d%s", m.mon, p), chu, map[string]any{"unit_price_vnd": 1, "reason": "test"})
		if r.status != http.StatusNotFound && r.status != http.StatusMethodNotAllowed {
			t.Fatalf("PUT /menu-items/{id}%s phải không tồn tại, nhận %d", p, r.status)
		}
	}
}
