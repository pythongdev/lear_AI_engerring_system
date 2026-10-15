// Test của cửa khoản chi (P3A-01, ADR-110; I-029 · I-021 · I-018). Viết TRƯỚC khi có package khoanchi —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Chỉ chủ quán ghi, sửa và đọc khoản
// chi (lời đóng U-095, 2026-10-15). Khoản của loại trả TỪ KÉT trừ vào két của ngày người ghi khai
// (U-072) — cửa đọc két của backend và bộ đối chiếu phải ra cùng con số. Ngày dùng ở đây thuộc tháng
// 5–6/2033, không test nào khác chạm; đồng hồ của quán đặt về 2033-06-30 để các ngày ấy là ngày đã qua.
package khoanchi_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os/exec"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/ket"
	"banhcuon/be/internal/khoanchi"
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
	khoanchi.Routes(r, khoanchi.NewService(pool))
	ket.Routes(r, ket.NewService(pool))
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

// loai tạo một loại chi qua cửa, tên riêng của test.
func (k khung) loai(t *testing.T, ten string, tuKet bool) int64 {
	t.Helper()
	r := k.goi(t, "POST", "/expense-categories", k.chu, map[string]any{"name": ten + " · " + t.Name(), "paid_from_till": tuKet})
	canDat(t, r, http.StatusCreated)
	if r.body["paid_from_till"] != tuKet {
		t.Fatalf("loại mới mang nguồn %v, muốn %v", r.body["paid_from_till"], tuKet)
	}
	return r.so(t, "expense_category_id")
}

func (k khung) ghi(t *testing.T, loai, tien int64, ngay string) traVe {
	t.Helper()
	return k.goi(t, "POST", "/expenses", k.chu, map[string]any{"expense_category_id": loai, "amount_vnd": tien, "paid_date": ngay})
}

// soDong đếm khoản chi, loại chi và vết của hai bảng — để chứng minh một lời từ chối không ghi gì.
func (k khung) soDong(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d/%d",
		k.so(t, "SELECT count(*) FROM shop.expense"),
		k.so(t, "SELECT count(*) FROM shop.expense_category"),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code IN ('expense', 'expense_category')"))
}

// --- quyền: chỉ chủ quán (lời đóng U-095) ----------------------------------------------------------

func TestI029_ChiChuQuanGhiSuaVaDocKhoanChi(t *testing.T) {
	k := dung(t)
	dien := k.loai(t, "test-điện", true)
	r := k.ghi(t, dien, 120000, "2033-05-02")
	canDat(t, r, http.StatusCreated)
	khoan := r.so(t, "expense_id")
	truoc := k.soDong(t)

	cua := []struct {
		method, path string
		body         any
	}{
		{"POST", "/expense-categories", map[string]any{"name": "test-nước · " + t.Name(), "paid_from_till": true}},
		{"POST", "/expenses", map[string]any{"expense_category_id": dien, "amount_vnd": 5000, "paid_date": "2033-05-02"}},
		{"PUT", fmt.Sprintf("/expenses/%d", khoan), map[string]any{"expense_category_id": dien, "amount_vnd": 1000, "paid_date": "2033-05-02", "reason": "test: sửa"}},
		{"GET", "/expense-categories", nil},
		{"GET", "/expenses?from=2033-05-01&to=2033-05-31", nil},
	}
	for _, c := range cua {
		// Người đứng quầy không phải chủ quán: kể cả khoản trả từ két, quầy không ghi (U-095).
		tuChoi(t, k.goi(t, c.method, c.path, k.quay, c.body), http.StatusForbidden, "owner_only", "")
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- ghi và đọc đủ bốn câu ---------------------------------------------------------------------------

func TestI029_KhoanChiDocRaLoaiSoTienNgayVaNguoiGhi(t *testing.T) {
	k := dung(t)
	dien := k.loai(t, "test-điện", true)
	mkt := k.loai(t, "test-marketing", false)

	a := k.ghi(t, dien, 350000, "2033-05-03")
	canDat(t, a, http.StatusCreated)
	if a.so(t, "amount_vnd") != 350000 || a.body["paid_date"] != "2033-05-03" || a.so(t, "person_id") != k.chu ||
		a.so(t, "expense_category_id") != dien || a.body["paid_from_till"] != true {
		t.Fatalf("khoản vừa ghi đọc sai: %v", a.body)
	}
	canDat(t, k.ghi(t, dien, 50000, "2033-05-20"), http.StatusCreated)
	canDat(t, k.ghi(t, mkt, 200000, "2033-05-10"), http.StatusCreated)
	canDat(t, k.ghi(t, dien, 999000, "2033-06-01"), http.StatusCreated) // ngoài khoảng tháng 5

	// Đọc theo khoảng ngày và loại: đủ bốn câu, tổng là phép cộng của backend (ADR-086).
	r := k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-05-01&to=2033-05-31&expense_category_id=%d", dien), k.chu, nil)
	canDat(t, r, http.StatusOK)
	ds, _ := r.body["expenses"].([]any)
	if len(ds) != 2 || r.so(t, "total_vnd") != 400000 {
		t.Fatalf("điện tháng 5: muốn 2 khoản, tổng 400000; nhận %v", r.body)
	}
	dau, _ := ds[0].(map[string]any)
	ten, _ := dau["category_name"].(string)
	nguoi, _ := dau["person_name"].(string)
	if dau["paid_date"] != "2033-05-03" || !strings.HasPrefix(ten, "test-điện") || nguoi != "test-chủ quán · "+t.Name() {
		t.Fatalf("khoản đầu (theo ngày khai) đọc sai: %v", dau)
	}
	if s, _ := dau["created_at"].(string); s == "" {
		t.Fatalf("khoản thiếu lúc ghi: %v", dau)
	}

	// Đọc theo nguồn: tiền riêng của tháng 5 trong hai loại của test là đúng khoản marketing.
	r = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-05-01&to=2033-05-31&expense_category_id=%d&paid_from_till=false", mkt), k.chu, nil)
	canDat(t, r, http.StatusOK)
	if ds, _ := r.body["expenses"].([]any); len(ds) != 1 || r.so(t, "total_vnd") != 200000 {
		t.Fatalf("marketing tháng 5: muốn 1 khoản 200000; nhận %v", r.body)
	}
	r = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-05-01&to=2033-05-31&expense_category_id=%d&paid_from_till=true", mkt), k.chu, nil)
	canDat(t, r, http.StatusOK)
	if ds, _ := r.body["expenses"].([]any); len(ds) != 0 || r.so(t, "total_vnd") != 0 {
		t.Fatalf("marketing không trả từ két mà lọc két ra khoản: %v", r.body)
	}

	// Danh sách loại có loại mới cùng nguồn của nó.
	r = k.goi(t, "GET", "/expense-categories", k.chu, nil)
	canDat(t, r, http.StatusOK)
	thay := 0
	cs, _ := r.body["expense_categories"].([]any)
	for _, c := range cs {
		m, _ := c.(map[string]any)
		id, _ := m["expense_category_id"].(float64)
		if (int64(id) == dien && m["paid_from_till"] == true) || (int64(id) == mkt && m["paid_from_till"] == false) {
			thay++
		}
	}
	if thay != 2 {
		t.Fatalf("danh sách loại thiếu loại của test hoặc sai nguồn: %v", r.body)
	}
}

// --- loại mới phải khai nguồn (I-029 vế 4, ADR-074) ----------------------------------------------------

func TestI029_LoaiChiMoiPhaiKhaiNguonVaTenRieng(t *testing.T) {
	k := dung(t)
	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "POST", "/expense-categories", k.chu, map[string]any{"name": "test-gas · " + t.Name()}), http.StatusBadRequest, "invalid_request", "paid_from_till")
	tuChoi(t, k.goi(t, "POST", "/expense-categories", k.chu, map[string]any{"name": "test-gas · " + t.Name(), "paid_from_till": nil}), http.StatusBadRequest, "invalid_request", "paid_from_till")
	tuChoi(t, k.goi(t, "POST", "/expense-categories", k.chu, map[string]any{"name": " \t ", "paid_from_till": true}), http.StatusBadRequest, "invalid_request", "name")
	tuChoi(t, k.goi(t, "POST", "/expense-categories", k.chu, map[string]any{"paid_from_till": true}), http.StatusBadRequest, "invalid_request", "name")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối hình mà database vẫn đổi: %s → %s", truoc, sau)
	}
	k.loai(t, "test-gas", true)
	tuChoi(t, k.goi(t, "POST", "/expense-categories", k.chu, map[string]any{"name": "test-gas · " + t.Name(), "paid_from_till": false}), http.StatusConflict, "expense_category_name_taken", "")
}

func TestI029_KhoanChiSaiHinhBiTuChoi(t *testing.T) {
	k := dung(t)
	dien := k.loai(t, "test-điện", true)
	truoc := k.soDong(t)
	for _, ca := range []struct {
		body  map[string]any
		field string
	}{
		{map[string]any{"expense_category_id": dien, "amount_vnd": 0, "paid_date": "2033-05-04"}, "amount_vnd"},
		{map[string]any{"expense_category_id": dien, "amount_vnd": -1000, "paid_date": "2033-05-04"}, "amount_vnd"},
		{map[string]any{"expense_category_id": dien, "paid_date": "2033-05-04"}, "amount_vnd"},
		{map[string]any{"expense_category_id": dien, "amount_vnd": 1000}, "paid_date"},
		{map[string]any{"expense_category_id": dien, "amount_vnd": 1000, "paid_date": "2033-02-30"}, "paid_date"},
		{map[string]any{"expense_category_id": dien, "amount_vnd": 1000, "paid_date": "2033-07-01"}, "paid_date"}, // sau hôm nay của quán
		{map[string]any{"amount_vnd": 1000, "paid_date": "2033-05-04"}, "expense_category_id"},
	} {
		tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, ca.body), http.StatusBadRequest, "invalid_request", ca.field)
	}
	tuChoi(t, k.ghi(t, 999999999, 1000, "2033-05-04"), http.StatusNotFound, "expense_category_not_found", "")
	for _, q := range []string{"/expenses?to=2033-05-31", "/expenses?from=2033-05-01", "/expenses?from=2033-05-31&to=2033-05-01", "/expenses?from=2033-5-1&to=2033-05-31"} {
		tuChoi(t, k.goi(t, "GET", q, k.chu, nil), http.StatusBadRequest, "invalid_request", "")
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- sửa có lý do, để lại vết (I-018) --------------------------------------------------------------------

func TestI029_SuaKhoanChiCoLyDoDeLaiBanTruocBanSau(t *testing.T) {
	k := dung(t)
	dien := k.loai(t, "test-điện", true)
	r := k.ghi(t, dien, 120000, "2033-05-05")
	canDat(t, r, http.StatusCreated)
	khoan := r.so(t, "expense_id")
	path := fmt.Sprintf("/expenses/%d", khoan)
	moi := map[string]any{"expense_category_id": dien, "amount_vnd": 125000, "paid_date": "2033-05-06"}

	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, moi), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"expense_category_id": dien, "amount_vnd": 125000, "paid_date": "2033-05-06", "reason": "  "}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", "/expenses/999999999", k.chu, map[string]any{"expense_category_id": dien, "amount_vnd": 1, "paid_date": "2033-05-06", "reason": "test"}), http.StatusNotFound, "expense_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	moi["reason"] = "  test: gõ nhầm số trên hoá đơn điện  "
	r = k.goi(t, "PUT", path, k.chu, moi)
	canDat(t, r, http.StatusOK)
	if r.so(t, "amount_vnd") != 125000 || r.body["paid_date"] != "2033-05-06" || r.so(t, "person_id") != k.chu {
		t.Fatalf("khoản sau sửa đọc sai: %v", r.body)
	}
	var lyDo, cu, sau string
	var nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT reason, before_image->>'amount_vnd', after_image->>'amount_vnd', person_id
		FROM shop.record_revision WHERE target_table_code = 'expense' AND target_row = $1 ORDER BY id DESC LIMIT 1`, khoan).
		Scan(&lyDo, &cu, &sau, &nguoi); err != nil {
		t.Fatalf("lần sửa không để vết: %v", err)
	}
	if lyDo != "test: gõ nhầm số trên hoá đơn điện" || cu != "120000" || sau != "125000" || nguoi != k.chu {
		t.Fatalf("vết sai: lý do %q, trước %s, sau %s, người %d", lyDo, cu, sau, nguoi)
	}
}

// --- khoản trả từ két trừ vào két của ngày khai (I-021, U-072) -----------------------------------------

// ngayKet dựng tiền đầu két và số đếm của một ngày bằng kết nối chủ lược đồ (cửa của chúng thuộc P3-09).
func (k khung) ngayKet(t *testing.T, ngay string, dauKet, dem int64, daKy bool) {
	t.Helper()
	if err := k.coVet(func(tx pgx.Tx) error {
		if _, err := tx.Exec(k.ctx, `WITH f AS (INSERT INTO shop.opening_float (sale_date) VALUES ($1::date) RETURNING id)
			INSERT INTO shop.opening_float_line (opening_float_id, denomination_vnd, amount_vnd) SELECT id, 1000, $2 FROM f`, ngay, dauKet); err != nil {
			return err
		}
		if _, err := tx.Exec(k.ctx, `WITH c AS (INSERT INTO shop.cash_count (sale_date) VALUES ($1::date) RETURNING id)
			INSERT INTO shop.cash_count_line (cash_count_id, denomination_vnd, amount_vnd) SELECT id, 1000, $2 FROM c`, ngay, dem); err != nil {
			return err
		}
		if daKy {
			_, err := tx.Exec(k.ctx, "INSERT INTO shop.reconciled_day (sale_date) VALUES ($1::date)", ngay)
			return err
		}
		return nil
	}); err != nil {
		t.Fatal(err)
	}
}

func (k khung) vePhai(t *testing.T, ngay string) int64 {
	t.Helper()
	r := k.goi(t, "GET", "/sale-days/"+ngay+"/cash-reconciliation", k.chu, nil)
	canDat(t, r, http.StatusOK)
	return r.so(t, "expected_vnd")
}

// vePhaiDoiChieu: vế phải của két theo BỘ ĐỐI CHIẾU — prelude của scripts/reconcile.sh, hàm pg_temp.ket_ngay.
func (k khung) vePhaiDoiChieu(t *testing.T, ngay string) int64 {
	t.Helper()
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command("./scripts/reconcile.sh", "--emit-prelude")
	cmd.Dir = strings.TrimSpace(string(goc))
	prelude, err := cmd.Output()
	if err != nil {
		t.Fatalf("reconcile.sh --emit-prelude: %v", err)
	}
	conn, err := pgx.Connect(k.ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(context.Background())
	if _, err := conn.Exec(k.ctx, "SET search_path TO shop, public"); err != nil {
		t.Fatal(err)
	}
	if _, err := conn.Exec(k.ctx, string(prelude)); err != nil {
		t.Fatalf("nạp prelude của bộ đối chiếu: %v", err)
	}
	var v int64
	if err := conn.QueryRow(k.ctx, "SELECT ve_phai FROM pg_temp.ket_ngay($1) WHERE ngay = $2::date", testhelper.ShopTZ(t), ngay).Scan(&v); err != nil {
		t.Fatalf("ket_ngay ngày %s: %v", ngay, err)
	}
	return v
}

func TestI021_KhoanChiTuKetTruVaoKetCuaNgayKhai(t *testing.T) {
	k := dung(t)
	const D, D2 = "2033-06-10", "2033-06-11"
	k.ngayKet(t, D, 500000, 450000, false)
	k.ngayKet(t, D2, 500000, 500000, false)
	dien := k.loai(t, "test-điện", true)
	mkt := k.loai(t, "test-marketing", false)
	if v := k.vePhai(t, D); v != 0 {
		t.Fatalf("ngày %s chưa có giao dịch nào mà vế phải %d", D, v)
	}

	r := k.ghi(t, dien, 50000, D)
	canDat(t, r, http.StatusCreated)
	khoan := r.so(t, "expense_id")
	if v, dc := k.vePhai(t, D), k.vePhaiDoiChieu(t, D); v != -50000 || dc != -50000 {
		t.Fatalf("điện 50000 trả từ két ngày %s: cửa đọc két nói %d, bộ đối chiếu %d; muốn cả hai -50000", D, v, dc)
	}
	// Tiền riêng không rời két (U-093): vế phải đứng nguyên.
	canDat(t, k.ghi(t, mkt, 30000, D), http.StatusCreated)
	if v := k.vePhai(t, D); v != -50000 {
		t.Fatalf("marketing tiền riêng làm két đổi: vế phải %d", v)
	}
	// Đếm 450000 − đầu két 500000 − vế phải (−50000) = lệch 0.
	if g := k.goi(t, "GET", "/sale-days/"+D+"/cash-reconciliation", k.chu, nil); g.so(t, "gap_vnd") != 0 {
		t.Fatalf("két ngày %s: muốn lệch 0, nhận %v", D, g.body)
	}

	// Sửa ngày khai: khoản rời ngày D sang D2, két của D trở về 0, của D2 nhận khoản.
	canDat(t, k.goi(t, "PUT", fmt.Sprintf("/expenses/%d", khoan), k.chu,
		map[string]any{"expense_category_id": dien, "amount_vnd": 50000, "paid_date": D2, "reason": "test: khai nhầm ngày"}), http.StatusOK)
	if v, v2 := k.vePhai(t, D), k.vePhai(t, D2); v != 0 || v2 != -50000 {
		t.Fatalf("sau khi dời ngày khai: vế phải %s = %d, %s = %d; muốn 0 và -50000", D, v, D2, v2)
	}
	if dc := k.vePhaiDoiChieu(t, D2); dc != -50000 {
		t.Fatalf("bộ đối chiếu ngày %s: %d, muốn -50000", D2, dc)
	}
}

func TestI021_KhoanChiTuKetVaoNgayDaDoiSoatBiTuChoi(t *testing.T) {
	k := dung(t)
	const R, D = "2033-06-12", "2033-06-13"
	k.ngayKet(t, R, 500000, 500000, true)
	dien := k.loai(t, "test-điện", true)
	mkt := k.loai(t, "test-marketing", false)

	truoc := k.soDong(t)
	tuChoi(t, k.ghi(t, dien, 50000, R), http.StatusConflict, "sale_day_reconciled", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
	// Khoản tiền riêng không chạm két của ngày đã ký: nhận.
	canDat(t, k.ghi(t, mkt, 30000, R), http.StatusCreated)

	// Dời một khoản từ két VÀO ngày đã ký cũng là ghi vào két ấy: từ chối, khoản đứng nguyên.
	r := k.ghi(t, dien, 40000, D)
	canDat(t, r, http.StatusCreated)
	khoan := r.so(t, "expense_id")
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/expenses/%d", khoan), k.chu,
		map[string]any{"expense_category_id": dien, "amount_vnd": 40000, "paid_date": R, "reason": "test: dời vào ngày đã ký"}), http.StatusConflict, "sale_day_reconciled", "")
	// Đổi một khoản tiền riêng của ngày đã ký sang loại trả từ két cũng chạm két ấy: từ chối.
	r = k.ghi(t, mkt, 10000, R)
	canDat(t, r, http.StatusCreated)
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/expenses/%d", r.so(t, "expense_id")), k.chu,
		map[string]any{"expense_category_id": dien, "amount_vnd": 10000, "paid_date": R, "reason": "test: đổi sang loại từ két"}), http.StatusConflict, "sale_day_reconciled", "")
	if n := k.so(t, "SELECT count(*) FROM shop.expense e JOIN shop.expense_category c ON c.id = e.expense_category_id WHERE e.paid_date = $1::date AND c.paid_from_till", R); n != 0 {
		t.Fatalf("ngày đã ký %s có %d khoản trả từ két", R, n)
	}
}
