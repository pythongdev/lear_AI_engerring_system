// Test của cửa giao việc (P3A-03, ADR-110; I-030 · I-018). Viết TRƯỚC khi có package giaoviec — Claude
// viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Lớp quay_hoac_chu_quan (I-030: chủ quán và POS
// tạo, sửa, ẩn, đánh dấu); người nhận tự đánh dấu là điều lời không nói nên không mở. Đã xong là ĐỌC RA từ
// sự kiện mới nhất, không phải cờ; ẩn không làm việc biến mất.
package giaoviec_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"banhcuon/be/internal/giaoviec"
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
	nv    int64 // người thường không đứng quầy — người nhận việc
	nv2   int64 // người thường thứ hai
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
	giaoviec.Routes(r, giaoviec.NewService(pool))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)

	k := khung{ctx: ctx, srv: srv, owner: owner}
	k.chu = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, true) RETURNING id", "test-chủ quán · "+t.Name())
	k.quay = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, false) RETURNING id", "test-người quầy · "+t.Name())
	k.nv = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, false) RETURNING id", "test-người nhận · "+t.Name())
	k.nv2 = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, false) RETURNING id", "test-người nhận hai · "+t.Name())
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

// tao giao một việc qua cửa; người tạo là nguoi.
func (k khung) tao(t *testing.T, nguoi int64, noiDung string, nhan int64) traVe {
	t.Helper()
	return k.goi(t, "POST", "/assigned-tasks", nguoi, map[string]any{"content": noiDung, "assignee_person_id": nhan, "due_at": "2026-10-25T09:30:00+07:00"})
}

func (k khung) danhDau(t *testing.T, nguoi, viec int64, dau string) traVe {
	t.Helper()
	return k.goi(t, "POST", fmt.Sprintf("/assigned-tasks/%d/marks", viec), nguoi, map[string]any{"mark": dau})
}

// trongDanhSach tìm một việc ở cửa đọc danh sách với chuỗi lọc q; trả nil nếu không có.
func (k khung) trongDanhSach(t *testing.T, q string, viec int64) map[string]any {
	t.Helper()
	r := k.goi(t, "GET", "/assigned-tasks"+q, k.chu, nil)
	canDat(t, r, http.StatusOK)
	items, ok := r.body["assigned_tasks"].([]any)
	if !ok {
		t.Fatalf("danh sách thiếu assigned_tasks: %v", r.body)
	}
	for _, x := range items {
		m, _ := x.(map[string]any)
		if id, _ := m["assigned_task_id"].(float64); int64(id) == viec {
			return m
		}
	}
	return nil
}

func (k khung) soDong(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d/%d",
		k.so(t, "SELECT count(*) FROM shop.assigned_task"),
		k.so(t, "SELECT count(*) FROM shop.assigned_task_mark"),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code IN ('assigned_task', 'assigned_task_mark')"))
}

// --- quyền: chủ quán hoặc người đang đứng quầy (I-030 vế 2) -------------------------------------------

func TestI030_ChiChuQuanHoacNguoiDungQuayLamViecGiao(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.chu, "test-rửa nồi", k.nv)
	canDat(t, r, http.StatusCreated)
	viec := r.so(t, "assigned_task_id")
	truoc := k.soDong(t)

	cac := []struct {
		method, path string
		body         any
	}{
		{"POST", "/assigned-tasks", map[string]any{"content": "test-lau bàn", "assignee_person_id": k.nv, "due_at": "2026-10-25T09:30:00+07:00"}},
		{"PUT", fmt.Sprintf("/assigned-tasks/%d", viec), map[string]any{"content": "test-rửa hai nồi", "assignee_person_id": k.nv, "reason": "test: sửa"}},
		{"POST", fmt.Sprintf("/assigned-tasks/%d/hiding", viec), map[string]any{"reason": "test: ẩn"}},
		{"POST", fmt.Sprintf("/assigned-tasks/%d/marks", viec), map[string]any{"mark": "done"}},
		{"GET", "/assigned-tasks", nil},
		{"GET", fmt.Sprintf("/assigned-tasks?assignee_person_id=%d", k.nv), nil},
		{"GET", fmt.Sprintf("/assigned-tasks/%d", viec), nil},
	}
	// Người nhận việc không đứng quầy, không là chủ quán: kể cả tự đánh dấu việc của mình cũng không (lời không mở).
	for _, c := range cac {
		tuChoi(t, k.goi(t, c.method, c.path, k.nv, c.body), http.StatusForbidden, "not_on_counter_duty", "")
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	// Người đứng quầy làm được cả bốn việc ghi; chủ quán không đứng quầy cũng vậy.
	r = k.tao(t, k.quay, "test-lau bàn", k.nv)
	canDat(t, r, http.StatusCreated)
	viec2 := r.so(t, "assigned_task_id")
	canDat(t, k.danhDau(t, k.quay, viec2, "done"), http.StatusCreated)
	canDat(t, k.danhDau(t, k.chu, viec2, "undone"), http.StatusCreated)
	canDat(t, k.goi(t, "PUT", fmt.Sprintf("/assigned-tasks/%d", viec2), k.quay,
		map[string]any{"content": "test-lau hai bàn", "assignee_person_id": k.nv, "reason": "test: thêm bàn"}), http.StatusOK)
	canDat(t, k.goi(t, "POST", fmt.Sprintf("/assigned-tasks/%d/hiding", viec2), k.quay, map[string]any{"reason": "test: giao nhầm"}), http.StatusOK)
	canDat(t, k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/%d", viec2), k.quay, nil), http.StatusOK)
}

// --- mỗi việc đủ bốn câu (I-030 vế 1) ---------------------------------------------------------------

func TestI030_ViecDocRaNoiDungNguoiNhanAiTaoLucTao(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.quay, "  test-rửa nồi nước dùng  ", k.nv)
	canDat(t, r, http.StatusCreated)
	viec := r.so(t, "assigned_task_id")
	kiem := func(m map[string]any) {
		t.Helper()
		if m["content"] != "test-rửa nồi nước dùng" ||
			m["assignee_person_id"] != float64(k.nv) || m["assignee_name"] != "test-người nhận · "+t.Name() ||
			m["person_id"] != float64(k.quay) || m["person_name"] != "test-người quầy · "+t.Name() ||
			m["done"] != false || m["hidden_at"] != nil || m["hidden_by_person_id"] != nil {
			t.Fatalf("việc đọc sai: %v", m)
		}
		if s, _ := m["created_at"].(string); s == "" {
			t.Fatalf("việc thiếu lúc tạo: %v", m)
		}
		if marks, ok := m["marks"].([]any); !ok || len(marks) != 0 {
			t.Fatalf("việc mới phải có danh sách đánh dấu rỗng: %v", m)
		}
	}
	kiem(r.body)
	d := k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/%d", viec), k.chu, nil)
	canDat(t, d, http.StatusOK)
	kiem(d.body)

	// Đọc theo người nhận: việc của người khác không lẫn vào.
	r2 := k.tao(t, k.chu, "test-đi chợ", k.nv2)
	canDat(t, r2, http.StatusCreated)
	viec2 := r2.so(t, "assigned_task_id")
	m := k.trongDanhSach(t, fmt.Sprintf("?assignee_person_id=%d", k.nv), viec)
	if m == nil {
		t.Fatalf("việc %d không có trong danh sách của người nhận", viec)
	}
	kiem(m)
	if k.trongDanhSach(t, fmt.Sprintf("?assignee_person_id=%d", k.nv), viec2) != nil {
		t.Fatalf("việc của người khác lẫn vào danh sách người nhận %d", k.nv)
	}
	if k.trongDanhSach(t, "", viec) == nil || k.trongDanhSach(t, "", viec2) == nil {
		t.Fatal("danh sách không lọc phải có cả hai việc")
	}
	if n := k.so(t, "SELECT count(*) FROM shop.assigned_task WHERE id = $1 AND person_id = $2", viec, k.quay); n != 1 {
		t.Fatal("người tạo ở database không phải người đã bấm")
	}
}

// --- đánh dấu là sự kiện, gỡ là sự kiện mới, cả hai ở lại (I-030 vế 3) ----------------------------------

func TestI030_DanhDauXongLaSuKienGoBangSuKienMoi(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.chu, "test-rửa nồi", k.nv)
	canDat(t, r, http.StatusCreated)
	viec := r.so(t, "assigned_task_id")

	// Chưa có lần xong nào thì không có gì để gỡ.
	truoc := k.soDong(t)
	tuChoi(t, k.danhDau(t, k.quay, viec, "undone"), http.StatusConflict, "assigned_task_not_done", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r = k.danhDau(t, k.quay, viec, "done")
	canDat(t, r, http.StatusCreated)
	if r.body["done"] != true {
		t.Fatalf("sau đánh dấu xong mà đọc ra chưa xong: %v", r.body)
	}
	truoc = k.soDong(t)
	tuChoi(t, k.danhDau(t, k.chu, viec, "done"), http.StatusConflict, "assigned_task_already_done", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r = k.danhDau(t, k.chu, viec, "undone")
	canDat(t, r, http.StatusCreated)
	d := k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/%d", viec), k.chu, nil)
	canDat(t, d, http.StatusOK)
	if d.body["done"] != false {
		t.Fatalf("sau bỏ đánh dấu mà đọc ra đã xong: %v", d.body)
	}
	marks, _ := d.body["marks"].([]any)
	if len(marks) != 2 {
		t.Fatalf("muốn hai sự kiện ở lại, nhận %v", d.body["marks"])
	}
	for i, muon := range []struct {
		dau   string
		nguoi int64
		ten   string
	}{{"done", k.quay, "test-người quầy · " + t.Name()}, {"undone", k.chu, "test-chủ quán · " + t.Name()}} {
		m, _ := marks[i].(map[string]any)
		if m["mark"] != muon.dau || m["person_id"] != float64(muon.nguoi) || m["person_name"] != muon.ten {
			t.Fatalf("sự kiện %d đọc sai (muốn %s bởi %d, theo thứ tự bấm): %v", i, muon.dau, muon.nguoi, m)
		}
		if s, _ := m["created_at"].(string); s == "" {
			t.Fatalf("sự kiện thiếu lúc bấm: %v", m)
		}
	}
	// Không cờ nào bị đè: database giữ đúng hai dòng sự kiện, không dòng vết sửa sự kiện nào.
	if n := k.so(t, "SELECT count(*) FROM shop.assigned_task_mark WHERE assigned_task_id = $1", viec); n != 2 {
		t.Fatalf("database giữ %d sự kiện, muốn 2", n)
	}
	// Xong lại lần nữa được: sự kiện thứ ba.
	canDat(t, k.danhDau(t, k.quay, viec, "done"), http.StatusCreated)
	if m := k.trongDanhSach(t, "", viec); m == nil || m["done"] != true {
		t.Fatalf("danh sách và chi tiết phải cùng đọc ra đã xong: %v", m)
	}
}

// --- sửa có vết (I-030 vế 4 · I-018) ------------------------------------------------------------------

func TestI030_SuaViecCoLyDoDeVet(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.chu, "test-rửa nồi", k.nv)
	canDat(t, r, http.StatusCreated)
	viec := r.so(t, "assigned_task_id")
	path := fmt.Sprintf("/assigned-tasks/%d", viec)

	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", path, k.quay, map[string]any{"content": "test-rửa hai nồi", "assignee_person_id": k.nv2}),
		http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.quay, map[string]any{"content": "test-rửa hai nồi", "assignee_person_id": k.nv2, "reason": "  "}),
		http.StatusBadRequest, "invalid_request", "reason")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r = k.goi(t, "PUT", path, k.quay, map[string]any{"content": " test-rửa hai nồi ", "assignee_person_id": k.nv2, "reason": " test: giao lại "})
	canDat(t, r, http.StatusOK)
	if r.body["content"] != "test-rửa hai nồi" || r.body["assignee_person_id"] != float64(k.nv2) ||
		r.body["person_id"] != float64(k.chu) {
		t.Fatalf("việc sau sửa đọc sai — người tạo không đổi theo người sửa: %v", r.body)
	}
	var lyDo, cuND, sauND string
	var cuNhan, sauNhan, nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT reason, before_image->>'content', after_image->>'content',
		(before_image->>'assignee_person_id')::bigint, (after_image->>'assignee_person_id')::bigint, person_id
		FROM shop.record_revision WHERE target_table_code = 'assigned_task' AND target_row = $1 ORDER BY id DESC LIMIT 1`, viec).
		Scan(&lyDo, &cuND, &sauND, &cuNhan, &sauNhan, &nguoi); err != nil {
		t.Fatalf("lần sửa không để vết: %v", err)
	}
	if lyDo != "test: giao lại" || cuND != "test-rửa nồi" || sauND != "test-rửa hai nồi" ||
		cuNhan != k.nv || sauNhan != k.nv2 || nguoi != k.quay {
		t.Fatalf("vết sai: lý do %q, nội dung %q → %q, người nhận %d → %d, người sửa %d", lyDo, cuND, sauND, cuNhan, sauNhan, nguoi)
	}
}

// --- xoá là ẩn, việc đã ẩn đọc lại được (I-030 vế 5) --------------------------------------------------

func TestI030_AnViecKhongBienMat(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.chu, "test-rửa nồi", k.nv)
	canDat(t, r, http.StatusCreated)
	viec := r.so(t, "assigned_task_id")
	canDat(t, k.danhDau(t, k.quay, viec, "done"), http.StatusCreated)
	an := fmt.Sprintf("/assigned-tasks/%d/hiding", viec)

	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{}), http.StatusBadRequest, "invalid_request", "reason")
	r = k.goi(t, "POST", an, k.quay, map[string]any{"reason": "test: giao nhầm"})
	canDat(t, r, http.StatusOK)
	if r.body["hidden_by_person_id"] != float64(k.quay) || r.body["hidden_by_name"] != "test-người quầy · "+t.Name() {
		t.Fatalf("việc vừa ẩn thiếu người ẩn: %v", r.body)
	}
	if s, _ := r.body["hidden_at"].(string); s == "" {
		t.Fatalf("việc vừa ẩn thiếu lúc ẩn: %v", r.body)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'assigned_task' AND target_row = $1 AND reason = 'test: giao nhầm'", viec); n != 1 {
		t.Fatalf("ẩn phải để đúng một vết mang lý do, có %d", n)
	}

	// Danh sách mặc định không bày việc đã ẩn; xin kèm việc đã ẩn thì có, đủ nội dung và sự kiện.
	if k.trongDanhSach(t, fmt.Sprintf("?assignee_person_id=%d", k.nv), viec) != nil {
		t.Fatal("danh sách mặc định vẫn bày việc đã ẩn")
	}
	m := k.trongDanhSach(t, fmt.Sprintf("?assignee_person_id=%d&include_hidden=true", k.nv), viec)
	if m == nil {
		t.Fatal("việc đã ẩn biến mất khỏi danh sách kèm việc ẩn")
	}
	if m["content"] != "test-rửa nồi" || m["done"] != true || m["hidden_by_person_id"] != float64(k.quay) {
		t.Fatalf("việc đã ẩn đọc lại sai: %v", m)
	}
	if marks, _ := m["marks"].([]any); len(marks) != 1 {
		t.Fatalf("việc đã ẩn mất sự kiện đánh dấu: %v", m["marks"])
	}
	d := k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/%d", viec), k.chu, nil)
	canDat(t, d, http.StatusOK)
	if d.body["hidden_by_person_id"] != float64(k.quay) {
		t.Fatalf("chi tiết việc đã ẩn đọc sai: %v", d.body)
	}

	// Việc đã ẩn không sửa, không đánh dấu, không ẩn lần nữa — mốc ẩn cũ giữ nguyên.
	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/assigned-tasks/%d", viec), k.chu,
		map[string]any{"content": "test-khác", "assignee_person_id": k.nv, "reason": "test"}), http.StatusConflict, "assigned_task_hidden", "")
	tuChoi(t, k.danhDau(t, k.chu, viec, "undone"), http.StatusConflict, "assigned_task_hidden", "")
	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: ẩn lần hai"}), http.StatusConflict, "assigned_task_hidden", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- hình sai và thứ không có bị từ chối, database không đổi ----------------------------------------

func TestI030_ViecSaiHinhBiTuChoi(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.chu, "test-rửa nồi", k.nv)
	canDat(t, r, http.StatusCreated)
	viec := r.so(t, "assigned_task_id")
	truoc := k.soDong(t)

	for _, ca := range []struct {
		body  map[string]any
		field string
	}{
		{map[string]any{"content": "   ", "assignee_person_id": k.nv}, "content"},
		{map[string]any{"assignee_person_id": k.nv}, "content"},
		{map[string]any{"content": "test-lau bàn"}, "assignee_person_id"},
		{map[string]any{"content": "test-lau bàn", "assignee_person_id": 0}, "assignee_person_id"},
		{map[string]any{"content": "test-lau bàn", "assignee_person_id": "abc"}, ""},
	} {
		tuChoi(t, k.goi(t, "POST", "/assigned-tasks", k.chu, ca.body), http.StatusBadRequest, "invalid_request", ca.field)
	}
	tuChoi(t, k.tao(t, k.chu, "test-lau bàn", 999999999), http.StatusNotFound, "person_not_found", "")

	path := fmt.Sprintf("/assigned-tasks/%d", viec)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"content": "", "assignee_person_id": k.nv, "reason": "test"}), http.StatusBadRequest, "invalid_request", "content")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"content": "test-x", "reason": "test"}), http.StatusBadRequest, "invalid_request", "assignee_person_id")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"content": "test-x", "assignee_person_id": 999999999, "reason": "test"}), http.StatusNotFound, "person_not_found", "")

	for _, dau := range []any{"finished", "", nil, 1} {
		body := map[string]any{}
		if dau != nil {
			body["mark"] = dau
		}
		r := k.goi(t, "POST", fmt.Sprintf("/assigned-tasks/%d/marks", viec), k.chu, body)
		if dau == 1 {
			tuChoi(t, r, http.StatusBadRequest, "invalid_request", "")
		} else {
			tuChoi(t, r, http.StatusBadRequest, "invalid_request", "mark")
		}
	}
	tuChoi(t, k.goi(t, "GET", "/assigned-tasks?assignee_person_id=abc", k.chu, nil), http.StatusBadRequest, "invalid_request", "assignee_person_id")
	tuChoi(t, k.goi(t, "GET", "/assigned-tasks?include_hidden=maybe", k.chu, nil), http.StatusBadRequest, "invalid_request", "include_hidden")

	const khong = 999999999
	tuChoi(t, k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/%d", khong), k.chu, nil), http.StatusNotFound, "assigned_task_not_found", "")
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/assigned-tasks/%d", khong), k.chu,
		map[string]any{"content": "test-x", "assignee_person_id": k.nv, "reason": "test"}), http.StatusNotFound, "assigned_task_not_found", "")
	tuChoi(t, k.goi(t, "POST", fmt.Sprintf("/assigned-tasks/%d/hiding", khong), k.chu, map[string]any{"reason": "test"}), http.StatusNotFound, "assigned_task_not_found", "")
	tuChoi(t, k.danhDau(t, k.chu, khong, "done"), http.StatusNotFound, "assigned_task_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}
