// Test của cửa danh mục món (P3A-05, ADR-110 · ADR-115; I-032 · I-018). Viết TRƯỚC khi có package danhmuc —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Lớp chu_quan cả đọc (I-032 vế 6: chủ quán tự
// quản lý menu). Một món thuộc nhiều nhất một danh mục; món chưa xếp vẫn là món. Danh mục ẩn chứ không xoá, ẩn
// được cả khi còn món — món của nó đọc ra ở nhóm chưa xếp (ADR-115). Combo là P3A-06, không kiểm ở đây.
package danhmuc_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"banhcuon/be/internal/danhmuc"
	"banhcuon/be/internal/middleware"
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

	r := gin.New()
	r.HandleMethodNotAllowed = true
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	danhmuc.Routes(r, danhmuc.NewService(pool))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)

	k := khung{ctx: ctx, srv: srv, owner: owner}
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

// mon dựng một món thẳng ở database — thêm món là bước P3A-07, không phải thứ được kiểm ở đây. Món dựng ra không
// có thành phần nên GET /menu không tính giá được; khi test xong nó được cho ngừng bán để không lọt vào menu đang
// bán của các gói test chạy sau trên cùng database.
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

func (k khung) them(t *testing.T, ten string) int64 {
	t.Helper()
	r := k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{"name": ten})
	canDat(t, r, http.StatusCreated)
	return r.so(t, "menu_category_id")
}

func (k khung) xep(t *testing.T, mon, danhMuc int64, lyDo string) traVe {
	t.Helper()
	body := map[string]any{"menu_category_id": danhMuc}
	if lyDo != "" {
		body["reason"] = lyDo
	}
	return k.goi(t, "PUT", fmt.Sprintf("/menu-items/%d/category", mon), k.chu, body)
}

func (k khung) soDong(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d/%d",
		k.so(t, "SELECT count(*) FROM shop.menu_category"),
		k.so(t, "SELECT count(*) FROM shop.menu_item_category"),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code IN ('menu_category', 'menu_item_category')"))
}

// cho là nơi mỗi món đọc ra: id danh mục, 0 nếu ở nhóm chưa xếp. Hỏng test nếu một món đứng hai chỗ.
type cho struct {
	danhMuc map[int64]map[string]any // danh mục theo id
	mon     map[int64]int64
	monTho  map[int64]map[string]any
}

func (k khung) doc(t *testing.T, q string) cho {
	t.Helper()
	r := k.goi(t, "GET", "/menu-categories"+q, k.chu, nil)
	canDat(t, r, http.StatusOK)
	out := cho{danhMuc: map[int64]map[string]any{}, mon: map[int64]int64{}, monTho: map[int64]map[string]any{}}
	dat := func(items any, dm int64) {
		ds, ok := items.([]any)
		if !ok {
			t.Fatalf("thiếu mảng món: %v", items)
		}
		for _, x := range ds {
			m, _ := x.(map[string]any)
			id := int64(m["menu_item_id"].(float64))
			if cu, co := out.mon[id]; co {
				t.Fatalf("món %d đứng hai chỗ: %d và %d", id, cu, dm)
			}
			out.mon[id] = dm
			out.monTho[id] = m
		}
	}
	cats, ok := r.body["categories"].([]any)
	if !ok {
		t.Fatalf("thiếu categories: %v", r.body)
	}
	for _, x := range cats {
		c, _ := x.(map[string]any)
		id := int64(c["menu_category_id"].(float64))
		out.danhMuc[id] = c
		dat(c["items"], id)
	}
	dat(r.body["uncategorized_items"], 0)
	return out
}

// --- quyền: chỉ chủ quán, kể cả đọc (I-032 vế 6) -----------------------------------------------------

func TestI032_ChiChuQuanDatDanhMuc(t *testing.T) {
	k := dung(t)
	dm := k.them(t, "test-bánh cuốn · "+t.Name())
	mon := k.mon(t, "test-bánh cuốn trứng")
	truoc := k.soDong(t)

	cac := []struct {
		method, path string
		body         any
	}{
		{"GET", "/menu-categories", nil},
		{"POST", "/menu-categories", map[string]any{"name": "test-đồ uống · " + t.Name()}},
		{"PUT", fmt.Sprintf("/menu-categories/%d", dm), map[string]any{"name": "test-bánh · " + t.Name(), "reason": "test: đổi"}},
		{"POST", fmt.Sprintf("/menu-categories/%d/hiding", dm), map[string]any{"reason": "test: ẩn"}},
		{"PUT", fmt.Sprintf("/menu-items/%d/category", mon), map[string]any{"menu_category_id": dm}},
	}
	// Người đang đứng quầy không là chủ quán: không đọc, không ghi.
	for _, c := range cac {
		tuChoi(t, k.goi(t, c.method, c.path, k.quay, c.body), http.StatusForbidden, "owner_only", "")
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- danh mục đọc ra kèm món, mỗi món đúng một chỗ (I-032 vế 1 · 2) ------------------------------------

func TestI032_DanhMucGomMonMoiMonMotCho(t *testing.T) {
	k := dung(t)
	r := k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{"name": "  test-bánh cuốn · " + t.Name() + "  "})
	canDat(t, r, http.StatusCreated)
	dm := r.so(t, "menu_category_id")
	if r.body["name"] != "test-bánh cuốn · "+t.Name() || r.body["person_id"] != float64(k.chu) ||
		r.body["person_name"] != "test-chủ quán · "+t.Name() || r.body["hidden_at"] != nil || r.body["hidden_by_person_id"] != nil {
		t.Fatalf("danh mục mới đọc sai: %v", r.body)
	}
	if s, _ := r.body["created_at"].(string); s == "" {
		t.Fatalf("danh mục thiếu lúc lập: %v", r.body)
	}
	if items, ok := r.body["items"].([]any); !ok || len(items) != 0 {
		t.Fatalf("danh mục mới phải có danh sách món rỗng: %v", r.body)
	}

	mons := []int64{k.mon(t, "test-bánh cuốn thịt"), k.mon(t, "test-bánh cuốn trứng"), k.mon(t, "test-bánh cuốn chay")}
	le := k.mon(t, "test-trà đá")
	for _, m := range mons {
		x := k.xep(t, m, dm, "")
		canDat(t, x, http.StatusOK)
		if x.so(t, "menu_category_id") != dm {
			t.Fatalf("xếp món phải trả danh mục đích: %v", x.body)
		}
	}
	c := k.doc(t, "")
	for _, m := range mons {
		if c.mon[m] != dm {
			t.Fatalf("món %d phải nằm trong danh mục %d, đọc ra ở %d", m, dm, c.mon[m])
		}
	}
	if dmLe, co := c.mon[le]; !co || dmLe != 0 {
		t.Fatalf("món chưa xếp phải đọc ra ở uncategorized_items: %v", c.monTho[le])
	}
	if c.monTho[le]["item_name"] != "test-trà đá · "+t.Name() || c.monTho[le]["discontinued"] != false {
		t.Fatalf("món chưa xếp đọc sai: %v", c.monTho[le])
	}
	if n := k.so(t, "SELECT count(*) FROM shop.menu_item_category WHERE menu_category_id = $1 AND person_id = $2", dm, k.chu); n != 3 {
		t.Fatalf("database giữ %d dòng xếp mang người xếp là chủ quán, muốn 3", n)
	}
}

// --- tên một lần trong danh mục còn dùng; ẩn rồi nhường tên (I-032 vế 1) ----------------------------------

func TestI032_TenDanhMucConDungKhongTrung(t *testing.T) {
	k := dung(t)
	ten := "test-đồ uống · " + t.Name()
	dm := k.them(t, ten)
	tuChoi(t, k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{"name": ten}), http.StatusConflict, "menu_category_name_taken", "")
	khac := k.them(t, "test-món thêm · "+t.Name())
	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{"name": ten}), http.StatusConflict, "menu_category_name_taken", "")
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/menu-categories/%d", khac), k.chu, map[string]any{"name": ten, "reason": "test: trùng"}),
		http.StatusConflict, "menu_category_name_taken", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
	canDat(t, k.goi(t, "POST", fmt.Sprintf("/menu-categories/%d/hiding", dm), k.chu, map[string]any{"reason": "test: bỏ nhóm"}), http.StatusOK)
	canDat(t, k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{"name": ten}), http.StatusCreated)
}

// --- đổi tên có lý do để vết (I-032 · I-018) -----------------------------------------------------------

func TestI032_DoiTenCoLyDoDeVet(t *testing.T) {
	k := dung(t)
	dm := k.them(t, "test-bánh · "+t.Name())
	path := fmt.Sprintf("/menu-categories/%d", dm)
	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"name": "test-bánh cuốn · " + t.Name()}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"name": "test-bánh cuốn · " + t.Name(), "reason": "  "}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"name": "  ", "reason": "test"}), http.StatusBadRequest, "invalid_request", "name")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r := k.goi(t, "PUT", path, k.chu, map[string]any{"name": " test-bánh cuốn · " + t.Name() + " ", "reason": " test: tên rõ hơn "})
	canDat(t, r, http.StatusOK)
	if r.body["name"] != "test-bánh cuốn · "+t.Name() || r.so(t, "menu_category_id") != dm {
		t.Fatalf("danh mục sau đổi tên đọc sai: %v", r.body)
	}
	var lyDo, cu, moi string
	var nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT reason, before_image->>'name', after_image->>'name', person_id
		FROM shop.record_revision WHERE target_table_code = 'menu_category' AND target_row = $1 ORDER BY id DESC LIMIT 1`, dm).
		Scan(&lyDo, &cu, &moi, &nguoi); err != nil {
		t.Fatalf("đổi tên không để vết: %v", err)
	}
	if lyDo != "test: tên rõ hơn" || cu != "test-bánh · "+t.Name() || moi != "test-bánh cuốn · "+t.Name() || nguoi != k.chu {
		t.Fatalf("vết sai: lý do %q, tên %q → %q, người %d", lyDo, cu, moi, nguoi)
	}

	const khong = 999999999
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/menu-categories/%d", khong), k.chu, map[string]any{"name": "test-x", "reason": "test"}),
		http.StatusNotFound, "menu_category_not_found", "")
	tuChoi(t, k.goi(t, "POST", fmt.Sprintf("/menu-categories/%d/hiding", khong), k.chu, map[string]any{"reason": "test"}),
		http.StatusNotFound, "menu_category_not_found", "")
}

// --- ẩn chứ không xoá; ẩn được khi còn món, món về nhóm chưa xếp (I-032 vế 6 · ADR-115) -------------------

func TestI032_AnDanhMucConMonMonVeChuaXep(t *testing.T) {
	k := dung(t)
	dm := k.them(t, "test-món theo mùa · "+t.Name())
	mon := k.mon(t, "test-bánh cuốn tôm")
	canDat(t, k.xep(t, mon, dm, ""), http.StatusOK)
	an := fmt.Sprintf("/menu-categories/%d/hiding", dm)

	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{}), http.StatusBadRequest, "invalid_request", "reason")
	r := k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: hết mùa"})
	canDat(t, r, http.StatusOK)
	if r.body["hidden_by_person_id"] != float64(k.chu) || r.body["hidden_by_name"] != "test-chủ quán · "+t.Name() {
		t.Fatalf("danh mục vừa ẩn thiếu người ẩn: %v", r.body)
	}
	if s, _ := r.body["hidden_at"].(string); s == "" {
		t.Fatalf("danh mục vừa ẩn thiếu lúc ẩn: %v", r.body)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'menu_category' AND target_row = $1 AND reason = 'test: hết mùa'", dm); n != 1 {
		t.Fatalf("ẩn phải để đúng một vết mang lý do, có %d", n)
	}

	// Đọc mặc định: danh mục vắng, món của nó ở nhóm chưa xếp. Kèm danh mục ẩn: món nằm lại trong nó.
	c := k.doc(t, "")
	if _, co := c.danhMuc[dm]; co {
		t.Fatal("đọc mặc định vẫn bày danh mục đã ẩn")
	}
	if dmMon, co := c.mon[mon]; !co || dmMon != 0 {
		t.Fatalf("món của danh mục đã ẩn phải đọc ra ở nhóm chưa xếp, đọc ra ở %d", dmMon)
	}
	c = k.doc(t, "?include_hidden=true")
	if d, co := c.danhMuc[dm]; !co || d["hidden_by_person_id"] != float64(k.chu) {
		t.Fatalf("danh mục đã ẩn biến mất khỏi đọc kèm ẩn: %v", d)
	}
	if c.mon[mon] != dm {
		t.Fatalf("đọc kèm ẩn: món phải nằm trong danh mục đã ẩn, đọc ra ở %d", c.mon[mon])
	}
	if c = k.doc(t, "?include_hidden=false"); c.mon[mon] != 0 {
		t.Fatal("include_hidden=false phải như đọc mặc định")
	}

	// Danh mục đã ẩn không đổi tên, không ẩn lần nữa, không nhận món — mốc ẩn cũ giữ nguyên.
	mon2 := k.mon(t, "test-bánh cuốn nấm")
	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/menu-categories/%d", dm), k.chu, map[string]any{"name": "test-khác · " + t.Name(), "reason": "test"}),
		http.StatusConflict, "menu_category_hidden", "")
	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: ẩn lần hai"}), http.StatusConflict, "menu_category_hidden", "")
	tuChoi(t, k.xep(t, mon2, dm, ""), http.StatusConflict, "menu_category_hidden", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.menu_category WHERE id = $1", dm); n != 1 {
		t.Fatal("danh mục đã ẩn phải còn dòng")
	}

	// Món của danh mục đã ẩn chuyển sang danh mục còn dùng được, có lý do.
	moi := k.them(t, "test-bánh cuốn · "+t.Name())
	canDat(t, k.xep(t, mon, moi, "test: dời nhóm"), http.StatusOK)
	if c = k.doc(t, ""); c.mon[mon] != moi {
		t.Fatalf("món chuyển khỏi danh mục đã ẩn đọc sai: %d", c.mon[mon])
	}
}

// --- xếp và chuyển món: nhiều nhất một danh mục có thật, chuyển có vết (I-032 vế 2 · I-018) -----------------

func TestI032_XepVaChuyenMon(t *testing.T) {
	k := dung(t)
	a := k.them(t, "test-bánh cuốn · "+t.Name())
	b := k.them(t, "test-món ăn kèm · "+t.Name())
	mon := k.mon(t, "test-chả quế")
	const khong = 999999999

	truoc := k.soDong(t)
	tuChoi(t, k.xep(t, khong, a, ""), http.StatusNotFound, "menu_item_not_found", "")
	tuChoi(t, k.xep(t, mon, khong, ""), http.StatusNotFound, "menu_category_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	canDat(t, k.xep(t, mon, a, ""), http.StatusOK)
	truoc = k.soDong(t)
	tuChoi(t, k.xep(t, mon, a, "test: xếp lại"), http.StatusConflict, "menu_item_already_in_category", "")
	tuChoi(t, k.xep(t, mon, b, ""), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.xep(t, mon, b, "   "), http.StatusBadRequest, "invalid_request", "reason")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r := k.xep(t, mon, b, " test: chả là món kèm ")
	canDat(t, r, http.StatusOK)
	if r.so(t, "menu_category_id") != b {
		t.Fatalf("chuyển món phải trả danh mục đích: %v", r.body)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.menu_item_category WHERE menu_item_id = $1", mon); n != 1 {
		t.Fatalf("món giữ %d dòng xếp, muốn đúng 1", n)
	}
	var lyDo string
	var cu, moi, nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT v.reason, (v.before_image->>'menu_category_id')::bigint, (v.after_image->>'menu_category_id')::bigint, v.person_id
		FROM shop.record_revision v JOIN shop.menu_item_category x ON x.id = v.target_row
		WHERE v.target_table_code = 'menu_item_category' AND x.menu_item_id = $1 ORDER BY v.id DESC LIMIT 1`, mon).
		Scan(&lyDo, &cu, &moi, &nguoi); err != nil {
		t.Fatalf("chuyển món không để vết: %v", err)
	}
	if lyDo != "test: chả là món kèm" || cu != a || moi != b || nguoi != k.chu {
		t.Fatalf("vết sai: lý do %q, danh mục %d → %d, người %d", lyDo, cu, moi, nguoi)
	}
	c := k.doc(t, "")
	if c.mon[mon] != b {
		t.Fatalf("món sau chuyển đọc ra ở %d, muốn %d", c.mon[mon], b)
	}
	if items, _ := c.danhMuc[a]["items"].([]any); len(items) != 0 {
		t.Fatalf("danh mục cũ vẫn giữ món: %v", items)
	}
}

// --- món đã ngừng bán vẫn là món, xếp được (I-032 vế 2) ----------------------------------------------------

func TestI032_MonNgungBanVanXepDuoc(t *testing.T) {
	k := dung(t)
	dm := k.them(t, "test-bánh cuốn · "+t.Name())
	mon := k.mon(t, "test-bánh cuốn cua")
	k.so(t, "UPDATE shop.menu_item SET discontinued_at = now() WHERE id = $1 RETURNING id", mon)
	canDat(t, k.xep(t, mon, dm, ""), http.StatusOK)
	c := k.doc(t, "")
	if c.mon[mon] != dm || c.monTho[mon]["discontinued"] != true {
		t.Fatalf("món ngừng bán đọc sai: ở %d, %v", c.mon[mon], c.monTho[mon])
	}
}

// --- hình sai bị từ chối trước database ------------------------------------------------------------------

func TestI032_DanhMucSaiHinhBiTuChoi(t *testing.T) {
	k := dung(t)
	dm := k.them(t, "test-bánh cuốn · "+t.Name())
	mon := k.mon(t, "test-bánh cuốn thịt")
	truoc := k.soDong(t)

	tuChoi(t, k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{}), http.StatusBadRequest, "invalid_request", "name")
	tuChoi(t, k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{"name": "   "}), http.StatusBadRequest, "invalid_request", "name")
	tuChoi(t, k.goi(t, "POST", "/menu-categories", k.chu, map[string]any{"name": 5}), http.StatusBadRequest, "invalid_request", "")
	tuChoi(t, k.goi(t, "POST", "/menu-categories", k.chu, "{"), http.StatusBadRequest, "invalid_request", "")
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/menu-items/%d/category", mon), k.chu, map[string]any{}), http.StatusBadRequest, "invalid_request", "menu_category_id")
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/menu-items/%d/category", mon), k.chu, map[string]any{"menu_category_id": 0}), http.StatusBadRequest, "invalid_request", "menu_category_id")
	tuChoi(t, k.goi(t, "PUT", "/menu-items/abc/category", k.chu, map[string]any{"menu_category_id": dm}), http.StatusBadRequest, "invalid_request", "menu_item_id")
	tuChoi(t, k.goi(t, "PUT", "/menu-categories/0", k.chu, map[string]any{"name": "test-x", "reason": "test"}), http.StatusBadRequest, "invalid_request", "menu_category_id")
	tuChoi(t, k.goi(t, "POST", "/menu-categories/abc/hiding", k.chu, map[string]any{"reason": "test"}), http.StatusBadRequest, "invalid_request", "menu_category_id")
	tuChoi(t, k.goi(t, "GET", "/menu-categories?include_hidden=maybe", k.chu, nil), http.StatusBadRequest, "invalid_request", "include_hidden")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}
