// Test của cửa combo cho chủ quán (P3A-06, ADR-110 · ADR-116; I-032 · I-018). Viết TRƯỚC khi có package combo —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Lớp chu_quan cả đọc (I-032 vế 6). Combo gồm ít
// nhất một món có thật, mỗi món một số phần nguyên dương; giá là MỘT con số chủ quán đặt, không cộng từ món (lời
// đóng U-092); đổi giá có lý do, có vết, và bị từ chối trong giờ bán (I-032/6, lời T-188). Ẩn chứ không xoá.
// Bán combo (hàm giá, dòng đơn, bếp, phụ thu theo món của combo) là task sau — không kiểm ở đây.
package combo_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/combo"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

type khung struct {
	ctx   context.Context
	srv   *httptest.Server
	owner *pgx.Conn
	chu   int64 // chủ quán, không đứng quầy
	quay  int64 // người thường đang đứng quầy
	loc   *time.Location
	mo    time.Duration
	dong  time.Duration
}

// gioBan đọc giờ mở và giờ đóng từ dòng "Giờ bán" của shop-facts.md §1 — không gõ lại con số.
func gioBan(t *testing.T) (mo, dong time.Duration) {
	t.Helper()
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	raw, err := os.ReadFile(filepath.Join(strings.TrimSpace(string(goc)), "master_plan", "shop-facts.md"))
	if err != nil {
		t.Fatal(err)
	}
	m := regexp.MustCompile(`(?m)^\| Giờ bán \| \*\*(\d{2}):(\d{2}) – (\d{2}):(\d{2})\*\*`).FindStringSubmatch(string(raw))
	if m == nil {
		t.Fatal("không đọc được dòng Giờ bán ở master_plan/shop-facts.md §1")
	}
	var so [4]int
	for i := range so {
		fmt.Sscanf(m[i+1], "%d", &so[i])
	}
	return time.Duration(so[0])*time.Hour + time.Duration(so[1])*time.Minute,
		time.Duration(so[2])*time.Hour + time.Duration(so[3])*time.Minute
}

// datGio đặt đồng hồ của cửa (ngayban.DongHo) vào một giờ trong ngày 2031-07-01 theo múi giờ quán.
func (k khung) datGio(t *testing.T, gio time.Duration) {
	t.Helper()
	moc := time.Date(2031, 7, 1, 0, 0, 0, 0, k.loc).Add(gio)
	goc := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil }
	t.Cleanup(func() { ngayban.DongHo = goc })
}

// coVet chạy câu dựng dữ liệu trong một giao dịch có khai người và lý do (bước 20, T-138, ADR-092).
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

func (k khung) so(t *testing.T, sql string, args ...any) int64 {
	t.Helper()
	var n int64
	if err := k.coVet(func(tx pgx.Tx) error { return tx.QueryRow(k.ctx, sql, args...).Scan(&n) }); err != nil {
		t.Fatalf("%s: %v", sql, err)
	}
	return n
}

func dung(t *testing.T) khung {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
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
	loc, err := time.LoadLocation(testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}

	r := gin.New()
	r.HandleMethodNotAllowed = true
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	combo.Routes(r, combo.NewService(pool))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)

	k := khung{ctx: ctx, srv: srv, owner: owner, loc: loc}
	k.mo, k.dong = gioBan(t)
	// Mặc định hai giờ sau giờ đóng: ngoài giờ bán, mọi cửa ghi nhận.
	k.datGio(t, k.dong+2*time.Hour)
	k.chu = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, true) RETURNING id", "test-chủ quán · "+t.Name())
	k.quay = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, false) RETURNING id", "test-người quầy · "+t.Name())
	if err := k.coVet(func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, "UPDATE shop.counter_duty SET ended_at = now() WHERE ended_at IS NULL"); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, "INSERT INTO shop.counter_duty (person_id, started_at) VALUES ($1, now())", k.quay)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	return k
}

// mon dựng một món thẳng ở database — thêm món là bước P3A-07. Món dựng ra không có thành phần nên GET /menu không
// tính giá được; khi test xong nó được cho ngừng bán để không lọt vào menu đang bán của các gói test chạy sau.
func (k khung) mon(t *testing.T, ten string) int64 {
	t.Helper()
	id := k.so(t, "INSERT INTO shop.menu_item (name) VALUES ($1) RETURNING id", ten+" · "+t.Name())
	t.Cleanup(func() {
		if err := k.coVet(func(tx pgx.Tx) error {
			_, err := tx.Exec(context.Background(), "UPDATE shop.menu_item SET discontinued_at = now() WHERE id = $1 AND discontinued_at IS NULL", id)
			return err
		}); err != nil {
			t.Errorf("không cho món test %d ngừng bán được: %v", id, err)
		}
	})
	return id
}

type traVe struct {
	status int
	body   map[string]any
}

func (r traVe) so(t *testing.T, ten string) int64 {
	t.Helper()
	f, ok := r.body[ten].(float64)
	if !ok {
		t.Fatalf("thiếu số %q trong %v", ten, r.body)
	}
	return int64(f)
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
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	if nguoi != 0 {
		req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, nguoi)})
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

func canDat(t *testing.T, r traVe, status int) {
	t.Helper()
	if r.status != status {
		t.Fatalf("muốn %d, nhận %d %v", status, r.status, r.body)
	}
}

func tuChoi(t *testing.T, r traVe, status int, code, field string) {
	t.Helper()
	if r.status != status || r.body["code"] != code || (field != "" && r.body["field"] != field) {
		t.Fatalf("muốn %d %s field=%q, nhận %d %v", status, code, field, r.status, r.body)
	}
}

type phan struct {
	mon int64
	so  int
}

func thanBody(ten string, gia any, cac ...phan) map[string]any {
	items := make([]any, 0, len(cac))
	for _, p := range cac {
		items = append(items, map[string]any{"menu_item_id": p.mon, "quantity": p.so})
	}
	return map[string]any{"name": ten, "price_vnd": gia, "items": items}
}

func (k khung) lap(t *testing.T, ten string, gia int64, cac ...phan) int64 {
	t.Helper()
	r := k.goi(t, "POST", "/menu-combos", k.chu, thanBody(ten, gia, cac...))
	canDat(t, r, http.StatusCreated)
	return r.so(t, "menu_combo_id")
}

func (k khung) doiGia(t *testing.T, id int64, nguoi int64, body any) traVe {
	t.Helper()
	return k.goi(t, "PUT", fmt.Sprintf("/menu-combos/%d/price", id), nguoi, body)
}

func (k khung) soDong(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d/%d",
		k.so(t, "SELECT count(*) FROM shop.menu_combo"),
		k.so(t, "SELECT count(*) FROM shop.menu_combo_item"),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code IN ('menu_combo', 'menu_combo_item')"))
}

func (k khung) doc(t *testing.T, q string) map[int64]map[string]any {
	t.Helper()
	r := k.goi(t, "GET", "/menu-combos"+q, k.chu, nil)
	canDat(t, r, http.StatusOK)
	ds, ok := r.body["combos"].([]any)
	if !ok {
		t.Fatalf("thiếu combos: %v", r.body)
	}
	out := map[int64]map[string]any{}
	for _, x := range ds {
		c, _ := x.(map[string]any)
		out[int64(c["menu_combo_id"].(float64))] = c
	}
	return out
}

// --- quyền: chỉ chủ quán, kể cả đọc (I-032 vế 6) -----------------------------------------------------

func TestI032_ChiChuQuanQuanLyCombo(t *testing.T) {
	k := dung(t)
	a := k.mon(t, "test-bánh cuốn thịt")
	id := k.lap(t, "test-combo đôi · "+t.Name(), 50000, phan{a, 2})
	truoc := k.soDong(t)

	cac := []struct {
		method, path string
		body         any
	}{
		{"GET", "/menu-combos", nil},
		{"POST", "/menu-combos", thanBody("test-combo khác · "+t.Name(), 30000, phan{a, 1})},
		{"PUT", fmt.Sprintf("/menu-combos/%d/price", id), map[string]any{"price_vnd": 55000, "reason": "test: đổi"}},
		{"POST", fmt.Sprintf("/menu-combos/%d/hiding", id), map[string]any{"reason": "test: ẩn"}},
	}
	for _, c := range cac {
		tuChoi(t, k.goi(t, c.method, c.path, k.quay, c.body), http.StatusForbidden, "owner_only", "")
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- combo mang một giá riêng, đọc lại món và số phần (I-032 vế 3 · 4) ----------------------------------

func TestI032_ComboMotGiaRiengDocLaiDuoc(t *testing.T) {
	k := dung(t)
	a := k.mon(t, "test-bánh cuốn thịt")
	b := k.mon(t, "test-bánh cuốn trứng")
	r := k.goi(t, "POST", "/menu-combos", k.chu, thanBody("  test-combo gia đình · "+t.Name()+"  ", 87000, phan{a, 2}, phan{b, 1}))
	canDat(t, r, http.StatusCreated)
	id := r.so(t, "menu_combo_id")
	if r.body["name"] != "test-combo gia đình · "+t.Name() || r.so(t, "price_vnd") != 87000 ||
		r.body["person_id"] != float64(k.chu) || r.body["person_name"] != "test-chủ quán · "+t.Name() ||
		r.body["hidden_at"] != nil || r.body["hidden_by_person_id"] != nil || r.body["hidden_by_name"] != nil {
		t.Fatalf("combo mới đọc sai: %v", r.body)
	}
	if s, _ := r.body["created_at"].(string); s == "" {
		t.Fatalf("combo thiếu lúc lập: %v", r.body)
	}
	kiemMon := func(c map[string]any) {
		t.Helper()
		items, ok := c["items"].([]any)
		if !ok || len(items) != 2 {
			t.Fatalf("combo phải đọc ra đúng hai món: %v", c)
		}
		muon := []struct {
			id  int64
			ten string
			so  float64
		}{{a, "test-bánh cuốn thịt · " + t.Name(), 2}, {b, "test-bánh cuốn trứng · " + t.Name(), 1}}
		for i, m := range muon {
			x, _ := items[i].(map[string]any)
			if x["menu_item_id"] != float64(m.id) || x["item_name"] != m.ten || x["quantity"] != m.so || x["discontinued"] != false {
				t.Fatalf("món thứ %d của combo đọc sai (giữ thứ tự gửi): %v", i, x)
			}
			if _, coGia := x["price_vnd"]; coGia {
				t.Fatalf("món trong combo không mang giá: %v", x)
			}
		}
	}
	kiemMon(r.body)
	c, co := k.doc(t, "")[id]
	if !co || c["price_vnd"] != float64(87000) {
		t.Fatalf("combo vừa lập không đọc lại được: %v", c)
	}
	kiemMon(c)
	if n := k.so(t, "SELECT count(*) FROM shop.menu_combo WHERE id = $1 AND price_vnd = 87000 AND person_id = $2", id, k.chu); n != 1 {
		t.Fatal("database không giữ đúng giá và người lập")
	}
	if n := k.so(t, "SELECT count(*) FROM shop.menu_combo_item WHERE menu_combo_id = $1", id); n != 2 {
		t.Fatalf("database giữ %d dòng thành phần, muốn 2", n)
	}
	// Lập combo không cần ngoài giờ bán — lời chỉ khoá đổi giá.
	k.datGio(t, k.mo+time.Hour)
	k.lap(t, "test-combo lập giữa buổi · "+t.Name(), 40000, phan{a, 1})
}

// --- lập combo sai bị từ chối, database không đổi (I-032 vế 3 · 4 · 5) -----------------------------------

func TestI032_LapComboSaiBiTuChoi(t *testing.T) {
	k := dung(t)
	a := k.mon(t, "test-bánh cuốn thịt")
	ngung := k.mon(t, "test-bánh cuốn cua")
	k.so(t, "UPDATE shop.menu_item SET discontinued_at = now() WHERE id = $1 RETURNING id", ngung)
	ten := "test-combo · " + t.Name()
	const khong = 999999999
	truoc := k.soDong(t)

	cac := []struct {
		body        any
		status      int
		code, field string
	}{
		{map[string]any{"price_vnd": 30000, "items": []any{map[string]any{"menu_item_id": a, "quantity": 1}}}, 400, "invalid_request", "name"},
		{thanBody("   ", 30000, phan{a, 1}), 400, "invalid_request", "name"},
		{map[string]any{"name": ten, "items": []any{map[string]any{"menu_item_id": a, "quantity": 1}}}, 400, "invalid_request", "price_vnd"},
		{thanBody(ten, 0, phan{a, 1}), 400, "invalid_request", "price_vnd"},
		{thanBody(ten, -1000, phan{a, 1}), 400, "invalid_request", "price_vnd"},
		{thanBody(ten, 1500.5, phan{a, 1}), 400, "invalid_request", "price_vnd"},
		{map[string]any{"name": ten, "price_vnd": 30000}, 400, "invalid_request", "items"},
		{thanBody(ten, 30000), 400, "invalid_request", "items"},
		{thanBody(ten, 30000, phan{a, 0}), 400, "invalid_request", "items[0].quantity"},
		{thanBody(ten, 30000, phan{a, 1}, phan{a, -2}), 400, "invalid_request", "items[1].quantity"},
		{thanBody(ten, 30000, phan{0, 1}), 400, "invalid_request", "items[0].menu_item_id"},
		{thanBody(ten, 30000, phan{a, 1}, phan{a, 2}), 400, "invalid_request", "items[1].menu_item_id"},
		{thanBody(ten, 30000, phan{a, 1}, phan{khong, 1}), 404, "menu_item_not_found", "items[1].menu_item_id"},
		{thanBody(ten, 30000, phan{ngung, 1}), 409, "menu_item_discontinued", "items[0].menu_item_id"},
		{"{", 400, "invalid_request", ""},
	}
	for _, c := range cac {
		tuChoi(t, k.goi(t, "POST", "/menu-combos", k.chu, c.body), c.status, c.code, c.field)
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- đổi giá có lý do, để vết giá cũ, giá mới, người sửa (I-032 vế 4 · I-018) ------------------------------

func TestI032_DoiGiaComboCoLyDoDeVet(t *testing.T) {
	k := dung(t)
	a := k.mon(t, "test-bánh cuốn thịt")
	id := k.lap(t, "test-combo đôi · "+t.Name(), 50000, phan{a, 2})
	truoc := k.soDong(t)
	tuChoi(t, k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 55000}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 55000, "reason": "  "}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 0, "reason": "test"}), http.StatusBadRequest, "invalid_request", "price_vnd")
	tuChoi(t, k.doiGia(t, id, k.chu, map[string]any{"reason": "test"}), http.StatusBadRequest, "invalid_request", "price_vnd")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r := k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 55000, "reason": " test: tăng giá đầu năm "})
	canDat(t, r, http.StatusOK)
	if r.so(t, "menu_combo_id") != id || r.so(t, "price_vnd") != 55000 {
		t.Fatalf("combo sau đổi giá đọc sai: %v", r.body)
	}
	var lyDo string
	var cu, moi, nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT reason, (before_image->>'price_vnd')::bigint, (after_image->>'price_vnd')::bigint, person_id
		FROM shop.record_revision WHERE target_table_code = 'menu_combo' AND target_row = $1 ORDER BY id DESC LIMIT 1`, id).
		Scan(&lyDo, &cu, &moi, &nguoi); err != nil {
		t.Fatalf("đổi giá không để vết: %v", err)
	}
	if lyDo != "test: tăng giá đầu năm" || cu != 50000 || moi != 55000 || nguoi != k.chu {
		t.Fatalf("vết sai: lý do %q, giá %d → %d, người %d", lyDo, cu, moi, nguoi)
	}
	if c := k.doc(t, "")[id]; c["price_vnd"] != float64(55000) {
		t.Fatalf("đọc lại giá sai: %v", c)
	}
	tuChoi(t, k.doiGia(t, 999999999, k.chu, map[string]any{"price_vnd": 1000, "reason": "test"}), http.StatusNotFound, "menu_combo_not_found", "")
}

// --- giá combo không đổi giữa buổi: hai đầu giờ bán tính là trong giờ (I-032 vế 6, lời T-188) ---------------

func TestI032_KhongDoiGiaComboTrongGioBan(t *testing.T) {
	k := dung(t)
	a := k.mon(t, "test-bánh cuốn thịt")
	id := k.lap(t, "test-combo đôi · "+t.Name(), 50000, phan{a, 2})
	truoc := k.soDong(t)
	for _, gio := range []time.Duration{k.mo, k.mo + time.Hour, k.dong} {
		k.datGio(t, gio)
		tuChoi(t, k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 60000, "reason": "test: giữa buổi"}),
			http.StatusConflict, "menu_combo_price_in_sales_hours", "")
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
	// Một phút trước giờ mở và một phút sau giờ đóng: ngoài giờ, nhận.
	k.datGio(t, k.mo-time.Minute)
	canDat(t, k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 60000, "reason": "test: trước buổi"}), http.StatusOK)
	k.datGio(t, k.dong+time.Minute)
	canDat(t, k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 65000, "reason": "test: sau buổi"}), http.StatusOK)
}

// --- ẩn chứ không xoá; combo đã ẩn đứng yên, vẫn đọc lại được (I-032 vế 6) ------------------------------

func TestI032_AnComboChuKhongXoa(t *testing.T) {
	k := dung(t)
	a := k.mon(t, "test-bánh cuốn thịt")
	id := k.lap(t, "test-combo mùa hè · "+t.Name(), 50000, phan{a, 2})
	an := fmt.Sprintf("/menu-combos/%d/hiding", id)

	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{}), http.StatusBadRequest, "invalid_request", "reason")
	// Ẩn không bị khoá theo giờ bán.
	k.datGio(t, k.mo+time.Hour)
	r := k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: hết mùa"})
	canDat(t, r, http.StatusOK)
	if r.body["hidden_by_person_id"] != float64(k.chu) || r.body["hidden_by_name"] != "test-chủ quán · "+t.Name() {
		t.Fatalf("combo vừa ẩn thiếu người ẩn: %v", r.body)
	}
	if s, _ := r.body["hidden_at"].(string); s == "" {
		t.Fatalf("combo vừa ẩn thiếu lúc ẩn: %v", r.body)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'menu_combo' AND target_row = $1 AND reason = 'test: hết mùa'", id); n != 1 {
		t.Fatalf("ẩn phải để đúng một vết mang lý do, có %d", n)
	}
	if _, co := k.doc(t, "")[id]; co {
		t.Fatal("đọc mặc định vẫn bày combo đã ẩn")
	}
	if _, co := k.doc(t, "?include_hidden=false")[id]; co {
		t.Fatal("include_hidden=false phải như đọc mặc định")
	}
	c, co := k.doc(t, "?include_hidden=true")[id]
	if !co || c["hidden_by_person_id"] != float64(k.chu) || c["price_vnd"] != float64(50000) {
		t.Fatalf("combo đã ẩn biến mất hay đọc sai khi đọc kèm ẩn: %v", c)
	}
	if items, _ := c["items"].([]any); len(items) != 1 {
		t.Fatalf("combo đã ẩn vẫn phải đọc ra món: %v", c)
	}

	k.datGio(t, k.dong+2*time.Hour)
	truoc := k.soDong(t)
	tuChoi(t, k.doiGia(t, id, k.chu, map[string]any{"price_vnd": 60000, "reason": "test"}), http.StatusConflict, "menu_combo_hidden", "")
	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: ẩn lần hai"}), http.StatusConflict, "menu_combo_hidden", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.menu_combo WHERE id = $1", id); n != 1 {
		t.Fatal("combo đã ẩn phải còn dòng")
	}
	tuChoi(t, k.goi(t, "POST", "/menu-combos/999999999/hiding", k.chu, map[string]any{"reason": "test"}), http.StatusNotFound, "menu_combo_not_found", "")
}

// --- hình sai bị từ chối trước database ------------------------------------------------------------------

func TestI032_ComboSaiHinhBiTuChoi(t *testing.T) {
	k := dung(t)
	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", "/menu-combos/abc/price", k.chu, map[string]any{"price_vnd": 1000, "reason": "test"}), http.StatusBadRequest, "invalid_request", "menu_combo_id")
	tuChoi(t, k.goi(t, "PUT", "/menu-combos/0/price", k.chu, map[string]any{"price_vnd": 1000, "reason": "test"}), http.StatusBadRequest, "invalid_request", "menu_combo_id")
	tuChoi(t, k.goi(t, "POST", "/menu-combos/abc/hiding", k.chu, map[string]any{"reason": "test"}), http.StatusBadRequest, "invalid_request", "menu_combo_id")
	tuChoi(t, k.goi(t, "PUT", "/menu-combos/1/price", k.chu, "{"), http.StatusBadRequest, "invalid_request", "")
	tuChoi(t, k.goi(t, "PUT", "/menu-combos/1/price", k.chu, map[string]any{"price_vnd": "50000", "reason": "test"}), http.StatusBadRequest, "invalid_request", "")
	tuChoi(t, k.goi(t, "GET", "/menu-combos?include_hidden=maybe", k.chu, nil), http.StatusBadRequest, "invalid_request", "include_hidden")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}
