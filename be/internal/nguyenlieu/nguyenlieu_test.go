// Test của cửa sổ nguyên liệu (P3A-02, ADR-110; I-025 · I-026 · I-018). Viết TRƯỚC khi có package
// nguyenlieu — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Máy chép con số người gõ,
// không tự tính lượng dùng (§8.4); tổng và hiệu số là phép cộng, phép trừ của backend, cộng dồn từ ngày
// mua, không đặt lại (I-026). Con số trên dây là CHUỖI thập phân, đọc ra không số 0 thừa. Ngày dùng ở đây
// thuộc tháng 5/2033; đồng hồ của quán đặt về 2033-06-30 để các ngày ấy là ngày đã qua.
package nguyenlieu_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/nguyenlieu"
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

	loc, err := time.LoadLocation(testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	moc := time.Date(2033, 6, 30, 9, 0, 0, 0, loc)
	goc := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil }
	t.Cleanup(func() { ngayban.DongHo = goc })

	r := gin.New()
	r.HandleMethodNotAllowed = true
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	nguyenlieu.Routes(r, nguyenlieu.NewService(pool))
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

// thu thêm một thứ vào danh mục qua cửa; donVi rỗng thì không gửi đơn vị.
func (k khung) thu(t *testing.T, ten, donVi string) int64 {
	t.Helper()
	body := map[string]any{"name": ten + " · " + t.Name()}
	if donVi != "" {
		body["purchase_unit"] = donVi
	}
	r := k.goi(t, "POST", "/supply-items", k.chu, body)
	canDat(t, r, http.StatusCreated)
	return r.so(t, "supply_item_id")
}

func (k khung) ghi(t *testing.T, thu int64, ngay, loai, so string) traVe {
	t.Helper()
	return k.goi(t, "POST", "/supply-day-entries", k.chu,
		map[string]any{"supply_item_id": thu, "entry_date": ngay, "kind": loai, "measure": so})
}

// tong đọc ba con số của một thứ ở danh sách và ở trang chi tiết; hai chỗ phải nói cùng một đáp số.
func (k khung) tong(t *testing.T, thu int64) (mua, dung, hieu string) {
	t.Helper()
	r := k.goi(t, "GET", fmt.Sprintf("/supply-items/%d", thu), k.chu, nil)
	canDat(t, r, http.StatusOK)
	mua, _ = r.body["purchased_total"].(string)
	dung, _ = r.body["used_total"].(string)
	hieu, _ = r.body["balance"].(string)
	ds := k.goi(t, "GET", "/supply-items", k.chu, nil)
	canDat(t, ds, http.StatusOK)
	items, _ := ds.body["supply_items"].([]any)
	for _, x := range items {
		m, _ := x.(map[string]any)
		if id, _ := m["supply_item_id"].(float64); int64(id) == thu {
			if m["purchased_total"] != mua || m["used_total"] != dung || m["balance"] != hieu {
				t.Fatalf("danh sách và chi tiết nói hai đáp số cho thứ %d: %v ≠ %s/%s/%s", thu, m, mua, dung, hieu)
			}
			return
		}
	}
	t.Fatalf("thứ %d không có trong danh sách", thu)
	return
}

func (k khung) soDong(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d/%d",
		k.so(t, "SELECT count(*) FROM shop.supply_item"),
		k.so(t, "SELECT count(*) FROM shop.supply_day_entry"),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code IN ('supply_item', 'supply_day_entry')"))
}

// --- quyền: chủ quán (kế hoạch AD_BE §4 — §8.4 chủ quán tự nhập số liệu) ----------------------------

func TestI025_ChiChuQuanGhiVaDocSoNguyenLieu(t *testing.T) {
	k := dung(t)
	gao := k.thu(t, "test-gạo", "")
	r := k.ghi(t, gao, "2033-05-01", "purchased", "10")
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "supply_day_entry_id")
	truoc := k.soDong(t)

	for _, c := range []struct {
		method, path string
		body         any
	}{
		{"POST", "/supply-items", map[string]any{"name": "test-quất · " + t.Name()}},
		{"PUT", fmt.Sprintf("/supply-items/%d/purchase-unit", gao), map[string]any{"purchase_unit": "kg"}},
		{"POST", "/supply-day-entries", map[string]any{"supply_item_id": gao, "entry_date": "2033-05-01", "kind": "used", "measure": "3"}},
		{"PUT", fmt.Sprintf("/supply-day-entries/%d", con), map[string]any{"measure": "11", "reason": "test: sửa"}},
		{"GET", "/supply-items", nil},
		{"GET", fmt.Sprintf("/supply-items/%d", gao), nil},
	} {
		tuChoi(t, k.goi(t, c.method, c.path, k.quay, c.body), http.StatusForbidden, "owner_only", "")
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- mỗi con số đọc ra ai · ngày nào · lúc nào (I-025 vế 1) ---------------------------------------------

func TestI025_ConSoDocRaNguoiNhapNgayVaLucGo(t *testing.T) {
	k := dung(t)
	gao := k.thu(t, "test-gạo", "")
	r := k.ghi(t, gao, "2033-05-02", "purchased", "10")
	canDat(t, r, http.StatusCreated)
	if r.so(t, "supply_item_id") != gao || r.body["entry_date"] != "2033-05-02" || r.body["kind"] != "purchased" ||
		r.body["measure"] != "10" || r.so(t, "person_id") != k.chu || r.body["person_name"] != "test-chủ quán · "+t.Name() {
		t.Fatalf("con số vừa ghi đọc sai: %v", r.body)
	}
	if s, _ := r.body["created_at"].(string); s == "" {
		t.Fatalf("con số thiếu lúc gõ: %v", r.body)
	}
	canDat(t, k.ghi(t, gao, "2033-05-02", "used", "7"), http.StatusCreated)

	d := k.goi(t, "GET", fmt.Sprintf("/supply-items/%d", gao), k.chu, nil)
	canDat(t, d, http.StatusOK)
	if d.body["purchase_unit"] != nil {
		t.Fatalf("thứ chưa có đơn vị mà đọc ra %v — phải trống (null)", d.body["purchase_unit"])
	}
	entries, _ := d.body["entries"].([]any)
	if len(entries) != 2 {
		t.Fatalf("muốn 2 con số, nhận %v", d.body)
	}
	for _, e := range entries {
		m, _ := e.(map[string]any)
		if m["entry_date"] != "2033-05-02" || m["person_name"] != "test-chủ quán · "+t.Name() {
			t.Fatalf("con số đọc lại sai: %v", m)
		}
	}
}

// --- tổng là phép cộng, hiệu số là phép trừ, không đặt lại (I-026) ------------------------------------

func TestI026_TongVaHieuSoLaPhepCongCacConSoNgay(t *testing.T) {
	k := dung(t)
	gao := k.thu(t, "test-gạo", "kg")
	var dung2 int64
	for _, c := range []struct{ ngay, mua, dung string }{
		{"2033-05-03", "10", "4"}, {"2033-05-04", "0", "3"}, {"2033-05-05", "5", "6"},
	} {
		canDat(t, k.ghi(t, gao, c.ngay, "purchased", c.mua), http.StatusCreated)
		r := k.ghi(t, gao, c.ngay, "used", c.dung)
		canDat(t, r, http.StatusCreated)
		if c.ngay == "2033-05-04" {
			dung2 = r.so(t, "supply_day_entry_id")
		}
	}
	// Ngày thứ ba mua thêm mà hai tổng không đặt lại.
	if mua, dung, hieu := k.tong(t, gao); mua != "15" || dung != "13" || hieu != "2" {
		t.Fatalf("ba ngày: muốn 15/13/2, nhận %s/%s/%s", mua, dung, hieu)
	}

	// Sửa con số đã dùng ngày thứ hai 3 → 5: tổng theo, không ai sửa con số tổng.
	path := fmt.Sprintf("/supply-day-entries/%d", dung2)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"measure": "5"}), http.StatusBadRequest, "invalid_request", "reason")
	r := k.goi(t, "PUT", path, k.chu, map[string]any{"measure": "5", "reason": " test: đếm lại bao gạo "})
	canDat(t, r, http.StatusOK)
	if r.body["measure"] != "5" {
		t.Fatalf("con số sau sửa: %v", r.body)
	}
	if mua, dung, hieu := k.tong(t, gao); mua != "15" || dung != "15" || hieu != "0" {
		t.Fatalf("sau sửa: muốn 15/15/0, nhận %s/%s/%s", mua, dung, hieu)
	}
	var lyDo, cu, sau string
	var nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT reason, before_image->>'entered_measure', after_image->>'entered_measure', person_id
		FROM shop.record_revision WHERE target_table_code = 'supply_day_entry' AND target_row = $1 ORDER BY id DESC LIMIT 1`, dung2).
		Scan(&lyDo, &cu, &sau, &nguoi); err != nil {
		t.Fatalf("lần sửa không để vết: %v", err)
	}
	if lyDo != "test: đếm lại bao gạo" || cu != "3" || sau != "5" || nguoi != k.chu {
		t.Fatalf("vết sai: lý do %q, trước %s, sau %s, người %d", lyDo, cu, sau, nguoi)
	}

	// Đã dùng vượt tổng đã nhập: nhận, hiệu số âm, máy không kết luận (I-026 kịch bản biên).
	canDat(t, k.ghi(t, gao, "2033-05-06", "used", "4"), http.StatusCreated)
	if _, _, hieu := k.tong(t, gao); hieu != "-4" {
		t.Fatalf("đã dùng vượt: muốn hiệu số -4, nhận %s", hieu)
	}

	// Con số có phần lẻ cộng đúng, đọc ra không số 0 thừa.
	mam := k.thu(t, "test-nước mắm", "lít")
	canDat(t, k.ghi(t, mam, "2033-05-03", "purchased", "1.5"), http.StatusCreated)
	canDat(t, k.ghi(t, mam, "2033-05-04", "purchased", "0.250"), http.StatusCreated)
	canDat(t, k.ghi(t, mam, "2033-05-04", "used", "0.75"), http.StatusCreated)
	if mua, dung, hieu := k.tong(t, mam); mua != "1.75" || dung != "0.75" || hieu != "1" {
		t.Fatalf("số lẻ: muốn 1.75/0.75/1, nhận %s/%s/%s", mua, dung, hieu)
	}
	// Thứ chưa có con số nào: ba con số là 0, không phải trống.
	quat := k.thu(t, "test-quất", "")
	if mua, dung, hieu := k.tong(t, quat); mua != "0" || dung != "0" || hieu != "0" {
		t.Fatalf("thứ chưa có con số: muốn 0/0/0, nhận %s/%s/%s", mua, dung, hieu)
	}
}

func TestI026_MotThuMotNgayMotDapSo(t *testing.T) {
	k := dung(t)
	gao := k.thu(t, "test-gạo", "")
	canDat(t, k.ghi(t, gao, "2033-05-07", "purchased", "10"), http.StatusCreated)
	truoc := k.soDong(t)
	tuChoi(t, k.ghi(t, gao, "2033-05-07", "purchased", "2"), http.StatusConflict, "supply_day_entry_already_recorded", "")
	tuChoi(t, k.goi(t, "POST", "/supply-items", k.chu, map[string]any{"name": "test-gạo · " + t.Name()}), http.StatusConflict, "supply_item_name_taken", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- hình sai bị từ chối trước database --------------------------------------------------------------

func TestI025_SoNguyenLieuSaiHinhBiTuChoi(t *testing.T) {
	k := dung(t)
	gao := k.thu(t, "test-gạo", "")
	r := k.ghi(t, gao, "2033-05-08", "purchased", "10")
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "supply_day_entry_id")
	truoc := k.soDong(t)

	for _, ca := range []struct {
		body  map[string]any
		field string
	}{
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "wasted", "measure": "1"}, "kind"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "measure": "1"}, "kind"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "used", "measure": "-1"}, "measure"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "used", "measure": "abc"}, "measure"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "used", "measure": "1e3"}, "measure"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "used", "measure": "NaN"}, "measure"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "used", "measure": ""}, "measure"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "used", "measure": 5}, "measure"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-05-09", "kind": "used"}, "measure"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-02-30", "kind": "used", "measure": "1"}, "entry_date"},
		{map[string]any{"supply_item_id": gao, "kind": "used", "measure": "1"}, "entry_date"},
		{map[string]any{"supply_item_id": gao, "entry_date": "2033-07-01", "kind": "used", "measure": "1"}, "entry_date"}, // sau hôm nay của quán
		{map[string]any{"entry_date": "2033-05-09", "kind": "used", "measure": "1"}, "supply_item_id"},
	} {
		tuChoi(t, k.goi(t, "POST", "/supply-day-entries", k.chu, ca.body), http.StatusBadRequest, "invalid_request", ca.field)
	}
	tuChoi(t, k.ghi(t, 999999999, "2033-05-09", "used", "1"), http.StatusNotFound, "supply_item_not_found", "")
	tuChoi(t, k.goi(t, "GET", "/supply-items/999999999", k.chu, nil), http.StatusNotFound, "supply_item_not_found", "")

	tuChoi(t, k.goi(t, "POST", "/supply-items", k.chu, map[string]any{"name": "  "}), http.StatusBadRequest, "invalid_request", "name")
	tuChoi(t, k.goi(t, "POST", "/supply-items", k.chu, map[string]any{"name": "test-hành · " + t.Name(), "purchase_unit": " "}), http.StatusBadRequest, "invalid_request", "purchase_unit")

	path := fmt.Sprintf("/supply-day-entries/%d", con)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"measure": "9", "reason": "\t"}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"measure": "-9", "reason": "test"}), http.StatusBadRequest, "invalid_request", "measure")
	tuChoi(t, k.goi(t, "PUT", "/supply-day-entries/999999999", k.chu, map[string]any{"measure": "9", "reason": "test"}), http.StatusNotFound, "supply_day_entry_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- đơn vị đặt một lần cho thứ chưa có (I-026 điều kiện biên: không quy đổi) --------------------------

func TestI026_DonViDatMotLanChoThuChuaCo(t *testing.T) {
	k := dung(t)
	gao := k.thu(t, "test-gạo", "")
	path := fmt.Sprintf("/supply-items/%d/purchase-unit", gao)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"purchase_unit": "  "}), http.StatusBadRequest, "invalid_request", "purchase_unit")
	r := k.goi(t, "PUT", path, k.chu, map[string]any{"purchase_unit": " kg "})
	canDat(t, r, http.StatusOK)
	if r.body["purchase_unit"] != "kg" {
		t.Fatalf("đơn vị sau khi đặt: %v", r.body)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'supply_item' AND target_row = $1", gao); n != 1 {
		t.Fatalf("đặt đơn vị phải để đúng một vết, có %d", n)
	}
	// Đổi đơn vị đã có làm hai con số của một thứ ghi theo hai đơn vị — vế hiệu số của I-026 hỏng.
	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"purchase_unit": "bao"}), http.StatusConflict, "supply_item_unit_already_set", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
	mam := k.thu(t, "test-nước mắm", "lít")
	truoc = k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/supply-items/%d/purchase-unit", mam), k.chu, map[string]any{"purchase_unit": "chai"}), http.StatusConflict, "supply_item_unit_already_set", "")
	tuChoi(t, k.goi(t, "PUT", "/supply-items/999999999/purchase-unit", k.chu, map[string]any{"purchase_unit": "kg"}), http.StatusNotFound, "supply_item_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}
