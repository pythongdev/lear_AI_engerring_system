// Test từ chối qua cửa của mã QR (P3-05, I-023, U-062, ADR-085). Viết TRƯỚC khi có package qr —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào.
package qr_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strconv"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/db"
	"banhcuon/be/internal/dbtest"
	"banhcuon/be/internal/qr"
	"github.com/jackc/pgx/v5"
)

// xacThucTest: danh tính chỉ cho test — bản thật chờ U-075. Không file ngoài _test.go được có nó.
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
	pool, err := db.Open(ctx, dbtest.AppDSN(t), dbtest.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	owner, err := pgx.Connect(ctx, dbtest.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { owner.Close(context.Background()) })
	mux := http.NewServeMux()
	qr.Routes(mux, pool, xacThucTest{})
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	return khung{ctx: ctx, srv: srv, owner: owner}
}

func (k khung) nguoi(t *testing.T, ten string, chuQuan bool) int64 {
	t.Helper()
	var id int64
	if err := k.owner.QueryRow(k.ctx,
		"INSERT INTO shop.person (display_name, is_owner) VALUES ($1, $2) RETURNING id",
		fmt.Sprintf("%s · %s", ten, t.Name()), chuQuan).Scan(&id); err != nil {
		t.Fatal(err)
	}
	return id
}

func (k khung) ban(t *testing.T, nhan string) int64 {
	t.Helper()
	var id int64
	if err := k.owner.QueryRow(k.ctx,
		"INSERT INTO shop.dining_table (label) VALUES ($1) RETURNING id",
		fmt.Sprintf("%s · %s", nhan, t.Name())).Scan(&id); err != nil {
		t.Fatal(err)
	}
	return id
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

type traVe struct {
	status int
	body   map[string]any
}

func (k khung) goi(t *testing.T, method, path string, nguoi int64) traVe {
	t.Helper()
	out, err := k.goiTran(method, path, nguoi)
	if err != nil {
		t.Fatal(err)
	}
	t.Logf("%s %s (người %d) ⇒ %d %v", method, path, nguoi, out.status, out.body)
	return out
}

// goiTran không chạm t — gọi được từ goroutine.
func (k khung) goiTran(method, path string, nguoi int64) (traVe, error) {
	req, err := http.NewRequestWithContext(k.ctx, method, k.srv.URL+path, nil)
	if err != nil {
		return traVe{}, err
	}
	if nguoi != 0 {
		req.Header.Set("X-Test-Person-Id", strconv.FormatInt(nguoi, 10))
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return traVe{}, err
	}
	defer res.Body.Close()
	out := traVe{status: res.StatusCode, body: map[string]any{}}
	_ = json.NewDecoder(res.Body).Decode(&out.body)
	return out, nil
}

func doiMa(banID int64) string { return fmt.Sprintf("/dining-tables/%d/qr-code", banID) }

func (k khung) maHienHanh(t *testing.T, banID int64) string {
	t.Helper()
	var code string
	if err := k.owner.QueryRow(k.ctx,
		"SELECT code FROM shop.qr_code WHERE dining_table_id = $1 AND replaced_at IS NULL", banID).Scan(&code); err != nil {
		t.Fatal(err)
	}
	return code
}

func TestI023_ChiChuQuanDoiDuocMa(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	a := k.nguoi(t, "A", false)
	ban := k.ban(t, "bàn 1")
	r := k.goi(t, "POST", doiMa(ban), chu)
	if r.status != http.StatusCreated || r.body["code"] != k.maHienHanh(t, ban) {
		t.Fatal("chủ quán cấp mã: muốn 201 và mã trả về là mã hiện hành của bàn")
	}
	truoc := k.maHienHanh(t, ban)
	k.vaoQuay(t, a)
	r = k.goi(t, "POST", doiMa(ban), a)
	if r.status != http.StatusForbidden || r.body["code"] != "owner_only" {
		t.Fatal("người đứng quầy đổi mã: muốn 403 owner_only (U-062 — chỉ chủ quán)")
	}
	if sau := k.maHienHanh(t, ban); sau != truoc {
		t.Fatalf("lời từ chối mà mã vẫn đổi: %s → %s", truoc, sau)
	}
	r = k.goi(t, "POST", doiMa(ban), 0)
	if r.status != http.StatusUnauthorized || r.body["code"] != "unauthenticated" {
		t.Fatal("không người: muốn 401 unauthenticated")
	}
	var nguoiCap int64
	if err := k.owner.QueryRow(k.ctx,
		"SELECT person_id FROM shop.qr_code WHERE code = $1", truoc).Scan(&nguoiCap); err != nil {
		t.Fatal(err)
	}
	if nguoiCap != chu {
		t.Fatalf("ai đổi mã: muốn chủ quán %d, vết ghi %d", chu, nguoiCap)
	}
}

func TestI023_MaCuBiTuChoi(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	ban := k.ban(t, "bàn 2")
	k.goi(t, "POST", doiMa(ban), chu)
	cu := k.maHienHanh(t, ban)
	r := k.goi(t, "GET", "/qr-codes/"+cu, 0)
	if r.status != http.StatusOK || r.body["label"] != fmt.Sprintf("bàn 2 · %s", t.Name()) {
		t.Fatal("khách mang mã hiện hành: muốn 200 và nhãn của đúng bàn ấy")
	}
	k.goi(t, "POST", doiMa(ban), chu)
	moi := k.maHienHanh(t, ban)
	if r = k.goi(t, "GET", "/qr-codes/"+cu, 0); r.status != http.StatusNotFound || r.body["code"] != "qr_code_not_current" {
		t.Fatal("mã đã thay: muốn 404 qr_code_not_current")
	}
	if r = k.goi(t, "GET", "/qr-codes/khong-co-ma-nay", 0); r.status != http.StatusNotFound || r.body["code"] != "qr_code_not_current" {
		t.Fatal("mã không tồn tại: muốn 404 qr_code_not_current — cùng mã với mã cũ, không lộ mã nào từng có")
	}
	if r = k.goi(t, "GET", "/qr-codes/"+moi, 0); r.status != http.StatusOK {
		t.Fatal("mã mới phải dùng được ngay")
	}
}

func TestI023_KhachKhongChonDuocBan(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	ban1 := k.ban(t, "bàn 3")
	ban2 := k.ban(t, "bàn 4")
	k.goi(t, "POST", doiMa(ban1), chu)
	ma1 := k.maHienHanh(t, ban1)
	r := k.goi(t, "GET", fmt.Sprintf("/qr-codes/%s?dining_table_id=%d", ma1, ban2), 0)
	if r.status != http.StatusBadRequest || r.body["code"] != "invalid_request" || r.body["field"] != "dining_table_id" {
		t.Fatal("khách gửi kèm bàn: muốn 400 invalid_request field dining_table_id — bàn chỉ tra từ mã")
	}
}

func TestI023_BanKhongCoThiTuChoi(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	r := k.goi(t, "POST", doiMa(9_000_000_000), chu)
	if r.status != http.StatusNotFound || r.body["code"] != "dining_table_not_found" {
		t.Fatal("đổi mã cho bàn không có: muốn 404 dining_table_not_found")
	}
}

func TestI023_HaiLanDoiCungLucKhongThanhLoiHeThong(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	ban := k.ban(t, "bàn 5")
	var wg sync.WaitGroup
	statuses := make(chan traVe, 16)
	for i := 0; i < 16; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			r, err := k.goiTran("POST", doiMa(ban), chu)
			if err != nil {
				r = traVe{status: -1, body: map[string]any{"loi": err.Error()}}
			}
			statuses <- r
		}()
	}
	wg.Wait()
	close(statuses)
	thanh, xung := 0, 0
	for r := range statuses {
		switch {
		case r.status == http.StatusCreated:
			thanh++
		case r.status == http.StatusConflict && r.body["code"] == "qr_code_issue_conflict":
			xung++
		default:
			t.Fatalf("đổi mã chen nhau: chỉ được 201 hoặc 409 qr_code_issue_conflict, nhận %d %v", r.status, r.body)
		}
	}
	var hienHanh int
	if err := k.owner.QueryRow(k.ctx,
		"SELECT count(*) FROM shop.qr_code WHERE dining_table_id = $1 AND replaced_at IS NULL", ban).Scan(&hienHanh); err != nil {
		t.Fatal(err)
	}
	t.Logf("16 lần đổi chen nhau: %d thành, %d xung đột; mã hiện hành: %d", thanh, xung, hienHanh)
	if thanh == 0 || hienHanh != 1 {
		t.Fatal("phải có ít nhất một lần thành và đúng một mã hiện hành")
	}
}

// I-018 qua cửa đổi mã: từ bước 20 (T-138, ADR-092) vết ở chế độ nghiêm; lần thay mã sửa mã cũ trong
// hàm qr_code_issue, hàm tự khai lý do, nên mã cũ có đúng một vết mang người của cửa.
func TestI018_DoiMaDeLaiVetTrenMaCu(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	ban := k.ban(t, "bàn vết")
	if r := k.goi(t, "POST", doiMa(ban), chu); r.status != http.StatusCreated {
		t.Fatalf("cấp mã đầu: muốn 201, nhận %d", r.status)
	}
	var cu int64
	if err := k.owner.QueryRow(k.ctx, "SELECT id FROM shop.qr_code WHERE dining_table_id = $1 AND replaced_at IS NULL", ban).Scan(&cu); err != nil {
		t.Fatal(err)
	}
	if r := k.goi(t, "POST", doiMa(ban), chu); r.status != http.StatusCreated {
		t.Fatalf("đổi mã: muốn 201, nhận %d", r.status)
	}
	var n, nguoi int64
	var truoc, sau bool
	var lyDo string
	if err := k.owner.QueryRow(k.ctx, `SELECT count(*) OVER (), person_id, before_image ->> 'replaced_at' IS NULL,
		after_image ->> 'replaced_at' IS NOT NULL, reason
		FROM shop.record_revision WHERE target_table_code = 'qr_code' AND target_row = $1`, cu).Scan(&n, &nguoi, &truoc, &sau, &lyDo); err != nil {
		t.Fatalf("mã cũ không có vết: %v", err)
	}
	if n != 1 || nguoi != chu || !truoc || !sau || lyDo == "" {
		t.Fatalf("vết của mã cũ: %d dòng, người %d (muốn %d), trước còn hiện hành %v, sau đã thay %v, lý do %q", n, nguoi, chu, truoc, sau, lyDo)
	}
	t.Logf("đổi mã ⇒ mã cũ %d có một vết: người %d, lý do %q", cu, nguoi, lyDo)
}
