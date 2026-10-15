// Test của cửa đào tạo (P3A-04, ADR-110; I-031 · I-018 · ADR-107). Viết TRƯỚC khi có package daotao — Claude
// viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Lớp quay_hoac_chu_quan (I-031: chủ quán hoặc POS
// ghi). Hướng dẫn gắn đúng một việc giao; ảnh · video là tệp trong kho tệp trên máy chạy hệ thống, database chỉ
// cất khoá tệp (ADR-107). Ghi nhận đứng trên một người, mọi lần ghi ở lại, đọc theo lúc ghi.
package daotao_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"banhcuon/be/internal/daotao"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

// Đầu tệp đủ để nhận loại bằng nội dung, không bằng tên hay Content-Type người gửi khai.
var (
	tepPNG = append([]byte("\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR"), bytes.Repeat([]byte{7}, 64)...)
	tepMP4 = append([]byte("\x00\x00\x00\x18ftypmp42\x00\x00\x00\x00mp42isom"), bytes.Repeat([]byte{9}, 64)...)
	tepMOV = append([]byte("\x00\x00\x00\x14ftypqt  \x00\x00\x02\x00qt  "), bytes.Repeat([]byte{5}, 64)...)
)

type khung struct {
	ctx   context.Context
	srv   *httptest.Server
	owner *pgx.Conn
	kho   string
	chu   int64 // chủ quán, không đứng quầy
	quay  int64 // người thường đang đứng quầy
	nv    int64 // người thường không đứng quầy — người học việc
	nv2   int64
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

	kho := t.TempDir()
	r := gin.New()
	r.HandleMethodNotAllowed = true
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	daotao.Routes(r, daotao.NewService(pool, kho))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)

	k := khung{ctx: ctx, srv: srv, owner: owner, kho: kho}
	k.chu = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, true) RETURNING id", "test-chủ quán · "+t.Name())
	k.quay = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, false) RETURNING id", "test-người quầy · "+t.Name())
	k.nv = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, false) RETURNING id", "test-người học · "+t.Name())
	k.nv2 = k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, false) RETURNING id", "test-người học hai · "+t.Name())
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

// viec dựng một việc giao thẳng ở database — cửa giao việc là bước P3A-03, không phải thứ được kiểm ở đây.
func (k khung) viec(t *testing.T, noiDung string) int64 {
	t.Helper()
	return k.so(t, "INSERT INTO shop.assigned_task (content, assignee_person_id) VALUES ($1, $2) RETURNING id", noiDung+" · "+t.Name(), k.nv)
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

func (k khung) lam(t *testing.T, req *http.Request, nguoi int64) traVe {
	t.Helper()
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
	t.Logf("%s %s (người %d) ⇒ %d %v", req.Method, req.URL.Path, nguoi, out.status, out.body)
	return out
}

func (k khung) goi(t *testing.T, method, path string, nguoi int64, body any) traVe {
	t.Helper()
	var raw []byte
	if body != nil {
		var err error
		if raw, err = json.Marshal(body); err != nil {
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
	return k.lam(t, req, nguoi)
}

// gan gửi một mẩu hướng dẫn dạng multipart/form-data: trường chữ kind, body; tệp ở phần file.
func (k khung) gan(t *testing.T, nguoi, viec int64, truong map[string]string, tep []byte) traVe {
	t.Helper()
	var buf bytes.Buffer
	w := multipart.NewWriter(&buf)
	for ten, gt := range truong {
		if err := w.WriteField(ten, gt); err != nil {
			t.Fatal(err)
		}
	}
	if tep != nil {
		p, err := w.CreateFormFile("file", "tep-tu-may")
		if err != nil {
			t.Fatal(err)
		}
		if _, err := p.Write(tep); err != nil {
			t.Fatal(err)
		}
	}
	if err := w.Close(); err != nil {
		t.Fatal(err)
	}
	req, err := http.NewRequestWithContext(k.ctx, "POST", fmt.Sprintf("%s/assigned-tasks/%d/guides", k.srv.URL, viec), &buf)
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", w.FormDataContentType())
	return k.lam(t, req, nguoi)
}

// tai đọc tệp của một mẩu hướng dẫn: mã trạng thái, Content-Type và thân.
func (k khung) tai(t *testing.T, nguoi, huongDan int64) (int, string, []byte) {
	t.Helper()
	req, err := http.NewRequestWithContext(k.ctx, "GET", fmt.Sprintf("%s/assigned-task-guides/%d/file", k.srv.URL, huongDan), nil)
	if err != nil {
		t.Fatal(err)
	}
	if nguoi != 0 {
		req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, nguoi)})
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	b, _ := io.ReadAll(res.Body)
	return res.StatusCode, res.Header.Get("Content-Type"), b
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

// soTep đếm tệp thường trong kho, mọi tầng thư mục.
func (k khung) soTep(t *testing.T) int {
	t.Helper()
	n := 0
	if err := filepath.WalkDir(k.kho, func(_ string, d fs.DirEntry, err error) error {
		if err == nil && d.Type().IsRegular() {
			n++
		}
		return err
	}); err != nil {
		t.Fatal(err)
	}
	return n
}

func (k khung) soDong(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d/%d/%d",
		k.so(t, "SELECT count(*) FROM shop.assigned_task_guide"),
		k.so(t, "SELECT count(*) FROM shop.training_record"),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code IN ('assigned_task_guide', 'training_record')"),
		k.soTep(t))
}

func (k khung) danhSach(t *testing.T, path, khoa string) []map[string]any {
	t.Helper()
	r := k.goi(t, "GET", path, k.chu, nil)
	canDat(t, r, http.StatusOK)
	items, ok := r.body[khoa].([]any)
	if !ok {
		t.Fatalf("thiếu %s: %v", khoa, r.body)
	}
	out := make([]map[string]any, 0, len(items))
	for _, x := range items {
		m, _ := x.(map[string]any)
		out = append(out, m)
	}
	return out
}

// --- quyền: chủ quán hoặc người đang đứng quầy (I-031 vế 3) -------------------------------------------

func TestI031_ChiChuQuanHoacNguoiDungQuayLamDaoTao(t *testing.T) {
	k := dung(t)
	viec := k.viec(t, "test-rửa nồi")
	r := k.gan(t, k.chu, viec, map[string]string{"kind": "text", "body": "test-ngâm nồi nước nóng trước"}, nil)
	canDat(t, r, http.StatusCreated)
	hd := r.so(t, "assigned_task_guide_id")
	r = k.gan(t, k.chu, viec, map[string]string{"kind": "image"}, tepPNG)
	canDat(t, r, http.StatusCreated)
	anh := r.so(t, "assigned_task_guide_id")
	r = k.goi(t, "POST", "/training-records", k.chu, map[string]any{"trainee_person_id": k.nv, "rating": "not_yet"})
	canDat(t, r, http.StatusCreated)
	gn := r.so(t, "training_record_id")
	truoc := k.soDong(t)

	for _, nguoi := range []struct {
		id     int64
		status int
		code   string
	}{{k.nv, http.StatusForbidden, "not_on_counter_duty"}, {0, http.StatusUnauthorized, "unauthenticated"}} {
		tuChoi(t, k.gan(t, nguoi.id, viec, map[string]string{"kind": "text", "body": "test-khác"}, nil), nguoi.status, nguoi.code, "")
		for _, c := range []struct {
			method, path string
			body         any
		}{
			{"GET", fmt.Sprintf("/assigned-tasks/%d/guides", viec), nil},
			{"PUT", fmt.Sprintf("/assigned-task-guides/%d", hd), map[string]any{"body": "test-khác", "reason": "test"}},
			{"POST", fmt.Sprintf("/assigned-task-guides/%d/hiding", hd), map[string]any{"reason": "test"}},
			{"POST", "/training-records", map[string]any{"trainee_person_id": k.nv, "rating": "pass"}},
			{"PUT", fmt.Sprintf("/training-records/%d", gn), map[string]any{"rating": "pass", "reason": "test"}},
			{"POST", fmt.Sprintf("/training-records/%d/hiding", gn), map[string]any{"reason": "test"}},
			{"GET", "/training-records", nil},
			{"GET", fmt.Sprintf("/training-records?trainee_person_id=%d", k.nv), nil},
		} {
			tuChoi(t, k.goi(t, c.method, c.path, nguoi.id, c.body), nguoi.status, nguoi.code, "")
		}
		if status, _, _ := k.tai(t, nguoi.id, anh); status != nguoi.status {
			t.Fatalf("tải tệp: người %d muốn %d, nhận %d", nguoi.id, nguoi.status, status)
		}
	}
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database hay kho tệp vẫn đổi: %s → %s", truoc, sau)
	}

	// Người đứng quầy làm được; người ghi là người đã bấm.
	r = k.gan(t, k.quay, viec, map[string]string{"kind": "text", "body": "test-cọ đáy nồi"}, nil)
	canDat(t, r, http.StatusCreated)
	if r.body["person_id"] != float64(k.quay) {
		t.Fatalf("người gắn hướng dẫn sai: %v", r.body)
	}
	r = k.goi(t, "POST", "/training-records", k.quay, map[string]any{"trainee_person_id": k.nv, "remark": "test-còn chậm"})
	canDat(t, r, http.StatusCreated)
	if r.body["person_id"] != float64(k.quay) {
		t.Fatalf("người ghi nhận sai: %v", r.body)
	}
	if status, _, _ := k.tai(t, k.quay, anh); status != http.StatusOK {
		t.Fatalf("người đứng quầy không tải được tệp: %d", status)
	}
}

// --- hướng dẫn gắn đúng một việc; ảnh · video là tệp trong kho, database cất khoá (I-031 vế 1 · 2) ----

func TestI031_HuongDanGanDungMotViecTepNamTrongKho(t *testing.T) {
	k := dung(t)
	viec := k.viec(t, "test-rửa nồi")
	khac := k.viec(t, "test-lau bàn")

	r := k.gan(t, k.quay, viec, map[string]string{"kind": "text", "body": "  test-ngâm nồi nước nóng  "}, nil)
	canDat(t, r, http.StatusCreated)
	chu := r.so(t, "assigned_task_guide_id")
	if r.body["kind"] != "text" || r.body["body"] != "test-ngâm nồi nước nóng" || r.body["assigned_task_id"] != float64(viec) ||
		r.body["person_name"] != "test-người quầy · "+t.Name() || r.body["hidden_at"] != nil {
		t.Fatalf("hướng dẫn chữ đọc sai: %v", r.body)
	}
	if s, _ := r.body["created_at"].(string); s == "" {
		t.Fatalf("hướng dẫn thiếu lúc gắn: %v", r.body)
	}

	tep := map[int64]struct {
		kieu, loai string
		noi        []byte
	}{}
	for _, c := range []struct {
		kind, loai string
		noi        []byte
	}{{"image", "image/png", tepPNG}, {"video", "video/mp4", tepMP4}, {"video", "video/quicktime", tepMOV}} {
		r := k.gan(t, k.chu, viec, map[string]string{"kind": c.kind}, c.noi)
		canDat(t, r, http.StatusCreated)
		if r.body["kind"] != c.kind || r.body["body"] != nil {
			t.Fatalf("hướng dẫn %s đọc sai: %v", c.kind, r.body)
		}
		tep[r.so(t, "assigned_task_guide_id")] = struct {
			kieu, loai string
			noi        []byte
		}{c.kind, c.loai, c.noi}
	}
	if n := k.soTep(t); n != 3 {
		t.Fatalf("kho phải có đúng 3 tệp, có %d", n)
	}
	for id, c := range tep {
		status, loai, noi := k.tai(t, k.chu, id)
		if status != http.StatusOK || loai != c.loai || !bytes.Equal(noi, c.noi) {
			t.Fatalf("tệp %d: muốn 200 %s và đúng nội dung, nhận %d %s (%d byte)", id, c.loai, status, loai, len(noi))
		}
		// Database cất khoá tệp ngắn, không nội dung tệp (ADR-107 điểm 2); khoá trỏ tới một tệp có trong kho.
		var khoa string
		if err := k.owner.QueryRow(k.ctx, "SELECT file_code FROM shop.assigned_task_guide WHERE id = $1", id).Scan(&khoa); err != nil {
			t.Fatal(err)
		}
		if b, err := os.ReadFile(filepath.Join(k.kho, filepath.FromSlash(khoa))); err != nil || !bytes.Equal(b, c.noi) {
			t.Fatalf("khoá tệp %q không trỏ tới tệp đúng trong kho: %v", khoa, err)
		}
	}

	ds := k.danhSach(t, fmt.Sprintf("/assigned-tasks/%d/guides", viec), "guides")
	if len(ds) != 4 || ds[0]["assigned_task_guide_id"] != float64(chu) {
		t.Fatalf("muốn 4 mẩu theo thứ tự gắn, mẩu chữ đầu tiên: %v", ds)
	}
	if ds := k.danhSach(t, fmt.Sprintf("/assigned-tasks/%d/guides", khac), "guides"); len(ds) != 0 {
		t.Fatalf("việc khác không được mang hướng dẫn của việc này: %v", ds)
	}
	// Mẩu chữ không có tệp.
	if status, _, _ := k.tai(t, k.chu, chu); status != http.StatusNotFound {
		t.Fatalf("mẩu chữ không có tệp, muốn 404, nhận %d", status)
	}
}

// --- tệp sai bị từ chối trước database, kho không giữ tệp mồ côi ---------------------------------------

func TestI031_HuongDanSaiHinhBiTuChoiKhoKhongDoi(t *testing.T) {
	k := dung(t)
	viec := k.viec(t, "test-rửa nồi")
	truoc := k.soDong(t)

	for _, ca := range []struct {
		truong map[string]string
		tep    []byte
		field  string
	}{
		{map[string]string{"kind": "audio"}, tepPNG, "kind"},
		{map[string]string{}, tepPNG, "kind"},
		{map[string]string{"kind": "text"}, nil, "body"},
		{map[string]string{"kind": "text", "body": "   "}, nil, "body"},
		{map[string]string{"kind": "text", "body": "test-x"}, tepPNG, "file"},
		{map[string]string{"kind": "image"}, nil, "file"},
		{map[string]string{"kind": "image", "body": "test-x"}, tepPNG, "body"},
		{map[string]string{"kind": "image"}, []byte("chỉ là chữ, không phải ảnh"), "file"},
		{map[string]string{"kind": "image"}, tepMP4, "file"},
		{map[string]string{"kind": "video"}, tepPNG, "file"},
		{map[string]string{"kind": "video"}, []byte{}, "file"},
	} {
		tuChoi(t, k.gan(t, k.chu, viec, ca.truong, ca.tep), http.StatusBadRequest, "invalid_request", ca.field)
	}
	// Ảnh quá 10 MiB.
	lon := append(append([]byte{}, tepPNG...), make([]byte, 10<<20)...)
	tuChoi(t, k.gan(t, k.chu, viec, map[string]string{"kind": "image"}, lon), http.StatusRequestEntityTooLarge, "file_too_large", "")

	// Việc không có, việc đã ẩn: lời từ chối đến từ giao dịch, sau khi đã nhận tệp — tệp không được ở lại kho.
	tuChoi(t, k.gan(t, k.chu, 999999999, map[string]string{"kind": "image"}, tepPNG), http.StatusNotFound, "assigned_task_not_found", "")
	an := k.viec(t, "test-việc đã ẩn")
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, "UPDATE shop.assigned_task SET hidden_at = now(), hidden_by_person_id = $2 WHERE id = $1", an, k.chu)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	truoc = k.soDong(t)
	tuChoi(t, k.gan(t, k.chu, an, map[string]string{"kind": "image"}, tepPNG), http.StatusConflict, "assigned_task_hidden", "")
	tuChoi(t, k.gan(t, k.chu, an, map[string]string{"kind": "text", "body": "test-x"}, nil), http.StatusConflict, "assigned_task_hidden", "")
	tuChoi(t, k.goi(t, "GET", "/assigned-tasks/999999999/guides", k.chu, nil), http.StatusNotFound, "assigned_task_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database hay kho tệp vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- sửa và ẩn hướng dẫn có vết; mẩu đã ẩn đọc lại được (I-031 vế 5) ------------------------------------

func TestI031_SuaVaAnHuongDanCoVet(t *testing.T) {
	k := dung(t)
	viec := k.viec(t, "test-rửa nồi")
	r := k.gan(t, k.chu, viec, map[string]string{"kind": "text", "body": "test-ngâm nồi"}, nil)
	canDat(t, r, http.StatusCreated)
	chu := r.so(t, "assigned_task_guide_id")
	r = k.gan(t, k.chu, viec, map[string]string{"kind": "image"}, tepPNG)
	canDat(t, r, http.StatusCreated)
	anh := r.so(t, "assigned_task_guide_id")
	path := fmt.Sprintf("/assigned-task-guides/%d", chu)

	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", path, k.quay, map[string]any{"body": "test-ngâm nồi nước nóng"}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.quay, map[string]any{"body": " ", "reason": "test"}), http.StatusBadRequest, "invalid_request", "body")
	// Mẩu ảnh không có chữ để sửa; đổi ảnh là ẩn mẩu cũ rồi gắn mẩu mới.
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/assigned-task-guides/%d", anh), k.quay, map[string]any{"body": "test-x", "reason": "test"}),
		http.StatusConflict, "assigned_task_guide_not_text", "")
	tuChoi(t, k.goi(t, "PUT", "/assigned-task-guides/999999999", k.quay, map[string]any{"body": "test-x", "reason": "test"}),
		http.StatusNotFound, "assigned_task_guide_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r = k.goi(t, "PUT", path, k.quay, map[string]any{"body": " test-ngâm nồi nước nóng ", "reason": " test: rõ hơn "})
	canDat(t, r, http.StatusOK)
	if r.body["body"] != "test-ngâm nồi nước nóng" || r.body["person_id"] != float64(k.chu) {
		t.Fatalf("hướng dẫn sau sửa đọc sai — người gắn không đổi theo người sửa: %v", r.body)
	}
	var lyDo, cu, moi string
	var nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT reason, before_image->>'body', after_image->>'body', person_id
		FROM shop.record_revision WHERE target_table_code = 'assigned_task_guide' AND target_row = $1 ORDER BY id DESC LIMIT 1`, chu).
		Scan(&lyDo, &cu, &moi, &nguoi); err != nil {
		t.Fatalf("lần sửa không để vết: %v", err)
	}
	if lyDo != "test: rõ hơn" || cu != "test-ngâm nồi" || moi != "test-ngâm nồi nước nóng" || nguoi != k.quay {
		t.Fatalf("vết sai: lý do %q, %q → %q, người %d", lyDo, cu, moi, nguoi)
	}

	an := fmt.Sprintf("/assigned-task-guides/%d/hiding", anh)
	tuChoi(t, k.goi(t, "POST", an, k.quay, map[string]any{}), http.StatusBadRequest, "invalid_request", "reason")
	r = k.goi(t, "POST", an, k.quay, map[string]any{"reason": "test: ảnh mờ"})
	canDat(t, r, http.StatusOK)
	if r.body["hidden_by_person_id"] != float64(k.quay) || r.body["hidden_by_name"] != "test-người quầy · "+t.Name() {
		t.Fatalf("mẩu vừa ẩn thiếu người ẩn: %v", r.body)
	}
	if ds := k.danhSach(t, fmt.Sprintf("/assigned-tasks/%d/guides", viec), "guides"); len(ds) != 1 {
		t.Fatalf("danh sách mặc định vẫn bày mẩu đã ẩn: %v", ds)
	}
	if ds := k.danhSach(t, fmt.Sprintf("/assigned-tasks/%d/guides?include_hidden=true", viec), "guides"); len(ds) != 2 {
		t.Fatalf("mẩu đã ẩn biến mất khỏi danh sách kèm mẩu ẩn: %v", ds)
	}
	// Mẩu đã ẩn đọc lại được, kể cả tệp; tệp không bị xoá khỏi kho.
	if status, _, noi := k.tai(t, k.chu, anh); status != http.StatusOK || !bytes.Equal(noi, tepPNG) {
		t.Fatalf("tệp của mẩu đã ẩn không đọc lại được: %d", status)
	}
	canDat(t, k.goi(t, "POST", fmt.Sprintf("/assigned-task-guides/%d/hiding", chu), k.chu, map[string]any{"reason": "test: ẩn chữ"}), http.StatusOK)
	truoc = k.soDong(t)
	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: lần hai"}), http.StatusConflict, "assigned_task_guide_hidden", "")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"body": "test-y", "reason": "test"}), http.StatusConflict, "assigned_task_guide_hidden", "")
	tuChoi(t, k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/%d/guides?include_hidden=maybe", viec), k.chu, nil), http.StatusBadRequest, "invalid_request", "include_hidden")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- tệp đã mất: khoá vẫn hợp lệ, chữ vẫn đọc được (ADR-107 hệ quả) ---------------------------------------

func TestI031_TepMatVanDocDuocDanhSach(t *testing.T) {
	k := dung(t)
	viec := k.viec(t, "test-rửa nồi")
	r := k.gan(t, k.chu, viec, map[string]string{"kind": "image"}, tepPNG)
	canDat(t, r, http.StatusCreated)
	anh := r.so(t, "assigned_task_guide_id")
	var khoa string
	if err := k.owner.QueryRow(k.ctx, "SELECT file_code FROM shop.assigned_task_guide WHERE id = $1", anh).Scan(&khoa); err != nil {
		t.Fatal(err)
	}
	if err := os.Remove(filepath.Join(k.kho, filepath.FromSlash(khoa))); err != nil {
		t.Fatal(err)
	}
	req, _ := http.NewRequestWithContext(k.ctx, "GET", fmt.Sprintf("%s/assigned-task-guides/%d/file", k.srv.URL, anh), nil)
	tuChoi(t, k.lam(t, req, k.chu), http.StatusNotFound, "assigned_task_guide_file_missing", "")
	req, _ = http.NewRequestWithContext(k.ctx, "GET", k.srv.URL+"/assigned-task-guides/999999999/file", nil)
	tuChoi(t, k.lam(t, req, k.chu), http.StatusNotFound, "assigned_task_guide_not_found", "")
	if ds := k.danhSach(t, fmt.Sprintf("/assigned-tasks/%d/guides", viec), "guides"); len(ds) != 1 {
		t.Fatalf("tệp mất làm danh sách hỏng: %v", ds)
	}
}

// --- ghi nhận về một người, đạt · chưa, mọi lần ở lại theo lúc ghi (I-031 vế 3 · 4) ---------------------

func TestI031_GhiNhanDatChuaVeMotNguoiTheoLucGhi(t *testing.T) {
	k := dung(t)
	r := k.goi(t, "POST", "/training-records", k.quay, map[string]any{"trainee_person_id": k.nv, "rating": "not_yet", "remark": "  test-tráng bánh còn dày  "})
	canDat(t, r, http.StatusCreated)
	mot := r.so(t, "training_record_id")
	if r.body["trainee_person_id"] != float64(k.nv) || r.body["trainee_name"] != "test-người học · "+t.Name() ||
		r.body["rating"] != "not_yet" || r.body["remark"] != "test-tráng bánh còn dày" ||
		r.body["person_id"] != float64(k.quay) || r.body["person_name"] != "test-người quầy · "+t.Name() || r.body["hidden_at"] != nil {
		t.Fatalf("ghi nhận đọc sai: %v", r.body)
	}
	if s, _ := r.body["created_at"].(string); s == "" {
		t.Fatalf("ghi nhận thiếu lúc ghi: %v", r.body)
	}
	r = k.goi(t, "POST", "/training-records", k.chu, map[string]any{"trainee_person_id": k.nv, "rating": "pass"})
	canDat(t, r, http.StatusCreated)
	hai := r.so(t, "training_record_id")
	if r.body["remark"] != nil {
		t.Fatalf("ghi nhận không nhận xét phải đọc ra remark null: %v", r.body)
	}
	r = k.goi(t, "POST", "/training-records", k.chu, map[string]any{"trainee_person_id": k.nv2, "remark": "test-chỉ nhận xét"})
	canDat(t, r, http.StatusCreated)
	khac := r.so(t, "training_record_id")
	if r.body["rating"] != nil {
		t.Fatalf("ghi nhận không đánh giá phải đọc ra rating null: %v", r.body)
	}

	ds := k.danhSach(t, fmt.Sprintf("/training-records?trainee_person_id=%d", k.nv), "training_records")
	if len(ds) != 2 || ds[0]["training_record_id"] != float64(mot) || ds[1]["training_record_id"] != float64(hai) {
		t.Fatalf("muốn hai ghi nhận theo lúc ghi (chưa rồi đạt), không lẫn người khác: %v", ds)
	}
	thay := false
	for _, m := range k.danhSach(t, "/training-records", "training_records") {
		if m["training_record_id"] == float64(khac) {
			thay = true
		}
	}
	if !thay {
		t.Fatal("danh sách không lọc thiếu ghi nhận của người khác")
	}
}

func TestI031_GhiNhanSaiHinhBiTuChoi(t *testing.T) {
	k := dung(t)
	truoc := k.soDong(t)
	for _, ca := range []struct {
		body  map[string]any
		field string
	}{
		{map[string]any{"trainee_person_id": k.nv}, "remark"},
		{map[string]any{"trainee_person_id": k.nv, "remark": nil, "rating": nil}, "remark"},
		{map[string]any{"trainee_person_id": k.nv, "remark": "   "}, "remark"},
		{map[string]any{"trainee_person_id": k.nv, "rating": "good"}, "rating"},
		{map[string]any{"trainee_person_id": k.nv, "rating": ""}, "rating"},
		{map[string]any{"trainee_person_id": k.nv, "rating": 8}, "rating"},
		{map[string]any{"rating": "pass"}, "trainee_person_id"},
		{map[string]any{"trainee_person_id": 0, "rating": "pass"}, "trainee_person_id"},
	} {
		tuChoi(t, k.goi(t, "POST", "/training-records", k.chu, ca.body), http.StatusBadRequest, "invalid_request", ca.field)
	}
	tuChoi(t, k.goi(t, "POST", "/training-records", k.chu, map[string]any{"trainee_person_id": 999999999, "rating": "pass"}), http.StatusNotFound, "person_not_found", "")
	tuChoi(t, k.goi(t, "GET", "/training-records?trainee_person_id=abc", k.chu, nil), http.StatusBadRequest, "invalid_request", "trainee_person_id")
	tuChoi(t, k.goi(t, "GET", "/training-records?include_hidden=maybe", k.chu, nil), http.StatusBadRequest, "invalid_request", "include_hidden")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- sửa và ẩn ghi nhận có vết; ghi nhận đã ẩn đọc lại được (I-031 vế 5) --------------------------------

func TestI031_SuaVaAnGhiNhanCoVet(t *testing.T) {
	k := dung(t)
	r := k.goi(t, "POST", "/training-records", k.quay, map[string]any{"trainee_person_id": k.nv, "rating": "not_yet", "remark": "test-còn chậm"})
	canDat(t, r, http.StatusCreated)
	gn := r.so(t, "training_record_id")
	path := fmt.Sprintf("/training-records/%d", gn)

	truoc := k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"rating": "pass", "remark": "test-đã nhanh"}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"reason": "test"}), http.StatusBadRequest, "invalid_request", "remark")
	tuChoi(t, k.goi(t, "PUT", "/training-records/999999999", k.chu, map[string]any{"rating": "pass", "reason": "test"}), http.StatusNotFound, "training_record_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	// Sửa thay cả hai trường: remark vắng nghĩa là không còn nhận xét.
	r = k.goi(t, "PUT", path, k.chu, map[string]any{"rating": "pass", "reason": " test: ghi nhầm mức "})
	canDat(t, r, http.StatusOK)
	if r.body["rating"] != "pass" || r.body["remark"] != nil || r.body["person_id"] != float64(k.quay) {
		t.Fatalf("ghi nhận sau sửa đọc sai — người ghi không đổi theo người sửa: %v", r.body)
	}
	var lyDo, cu, moi string
	var nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT reason, before_image->>'rating_code', after_image->>'rating_code', person_id
		FROM shop.record_revision WHERE target_table_code = 'training_record' AND target_row = $1 ORDER BY id DESC LIMIT 1`, gn).
		Scan(&lyDo, &cu, &moi, &nguoi); err != nil {
		t.Fatalf("lần sửa không để vết: %v", err)
	}
	if lyDo != "test: ghi nhầm mức" || cu != "not_yet" || moi != "pass" || nguoi != k.chu {
		t.Fatalf("vết sai: lý do %q, %q → %q, người %d", lyDo, cu, moi, nguoi)
	}

	an := fmt.Sprintf("/training-records/%d/hiding", gn)
	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{"reason": ""}), http.StatusBadRequest, "invalid_request", "reason")
	r = k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: ghi nhầm người"})
	canDat(t, r, http.StatusOK)
	if r.body["hidden_by_person_id"] != float64(k.chu) || r.body["hidden_by_name"] != "test-chủ quán · "+t.Name() {
		t.Fatalf("ghi nhận vừa ẩn thiếu người ẩn: %v", r.body)
	}
	if ds := k.danhSach(t, fmt.Sprintf("/training-records?trainee_person_id=%d", k.nv), "training_records"); len(ds) != 0 {
		t.Fatalf("danh sách mặc định vẫn bày ghi nhận đã ẩn: %v", ds)
	}
	ds := k.danhSach(t, fmt.Sprintf("/training-records?trainee_person_id=%d&include_hidden=true", k.nv), "training_records")
	if len(ds) != 1 || ds[0]["rating"] != "pass" || ds[0]["hidden_by_person_id"] != float64(k.chu) {
		t.Fatalf("ghi nhận đã ẩn đọc lại sai: %v", ds)
	}
	truoc = k.soDong(t)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"rating": "not_yet", "reason": "test"}), http.StatusConflict, "training_record_hidden", "")
	tuChoi(t, k.goi(t, "POST", an, k.chu, map[string]any{"reason": "test: lần hai"}), http.StatusConflict, "training_record_hidden", "")
	tuChoi(t, k.goi(t, "POST", "/training-records/999999999/hiding", k.chu, map[string]any{"reason": "test"}), http.StatusNotFound, "training_record_not_found", "")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}
