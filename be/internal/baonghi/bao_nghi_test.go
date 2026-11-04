// Test năm đường báo nghỉ (CHAT-31, ADR-138 điểm 3 · 6; I-039). Claude viết TRƯỚC khi có package baonghi; Codex làm
// cho xanh, không sửa điều kiện kiểm. Vế tầng 1 của I-039 (trigger, khoá, chặn tick hai chiều) đã có ở
// db/tests/i039_leave_notice.sql; ở đây là vế tầng 3: người luôn lấy từ phiên (không ghi hộ), đúng người huỷ và ghi
// đã biết, đọc đúng phạm vi, gửi lại không nhân đôi, không chạm chấm công hay tiền.
//
// Hợp đồng Claude chốt trong test này (2026-11-04, trong khung ADR-138):
//   - POST /leave-notices (baonghi/bao, lớp nguoi_quan): thân submission_code (SubmissionCode), leave_date
//     (YYYY-MM-DD). Người nghỉ là người của phiên (cột mặc định actor_person_id()). Tạo 201, gửi lại 200.
//   - POST /leave-notices/{leave_notice_id}/cancel (baonghi/huy, lớp nguoi_quan): không thân. Chủ quán huỷ mọi báo
//     nghỉ, lúc nào cũng được; người khác chỉ huỷ báo nghỉ của chính mình khi ngày lịch Việt Nam còn trước leave_date.
//   - POST /leave-notices/{leave_notice_id}/acknowledge (baonghi/da_biet, lớp chu_quan): không thân.
//   - GET /leave-notices/mine (nguoi_quan): báo nghỉ của người của phiên, kể cả đã huỷ; id DESC, before_id loại trừ,
//     limit 1–50 mặc định 20, next_before_id như GET /station-messages/mine.
//   - GET /leave-notices?from=YYYY-MM-DD&to=YYYY-MM-DD (chu_quan): mọi báo nghỉ có leave_date trong [from, to], kể cả
//     đã huỷ; leave_date ASC rồi id ASC; from ≤ to, to − from ≤ 92 ngày; không chia trang.
//   - Mỗi dòng (cửa ghi trả cùng hình): leave_notice_id, person_id, person_name, leave_date, notice_kind, created_at,
//     acknowledged_at, acknowledged_by_person_id, cancelled_at, cancelled_by_person_id (null khi chưa có), can_cancel.
//     notice_kind = bao_truoc khi leave_date − ngày lịch Asia/Ho_Chi_Minh của created_at ≥ 3, còn lại dot_xuat
//     (ADR-138 điểm 2, backend suy, không cất). can_cancel tính cho người đang đọc: chưa huỷ và (người đọc là chủ quán,
//     hoặc là người nghỉ và hôm nay còn trước leave_date). Đường đọc trả thêm read_at (now() của database).
//   - Thứ tự xét: hình (400 invalid_request + field) → quyền → dấu gửi lại → luật → ghi.
//   - Gửi lại: cùng người, cùng dấu, cùng leave_date ⇒ 200 đúng dòng ấy ở trạng thái hiện tại (kể cả đã huỷ, kể cả
//     ngày đã qua); cùng dấu khác leave_date ⇒ 409 submission_code_conflict. Dấu là duy nhất THEO NGƯỜI: người khác
//     dùng cùng dấu là một báo nghỉ mới của họ. Tranh chấp khoá dấu chạy lại cả giao dịch (tối đa bốn lần), §8.
//   - Từ chối: leave_date trước hôm nay ⇒ 422 leave_date_in_past; đã có báo nghỉ còn hiệu lực ngày ấy ⇒ 409
//     leave_notice_day_taken; ngày ấy đã có ô có đi làm còn hiệu lực ⇒ 409 leave_day_attendance_ticked; báo nghỉ không có,
//     hoặc người huỷ không phải chủ quán mà không phải người nghỉ ⇒ 404 leave_notice_not_found; người nghỉ huỷ khi hôm nay
//     đã tới leave_date ⇒ 422 leave_notice_cancel_closed; không phải chủ quán ở lớp chu_quan ⇒ 403 owner_only.
//   - Huỷ dòng đã huỷ, ghi đã biết dòng đã có dấu đã biết ⇒ 200 dòng hiện tại, dấu cũ giữ nguyên, không ghi. Ghi đã biết
//     một dòng đã huỷ được (dấu đã biết chỉ là đã xem).
//   - Huỷ và đã biết khai lý do vết cố định do backend đặt (không nhận từ thân): vết ghi đúng người của phiên.
//   - Không phiên hoặc chỉ cookie khách ⇒ 401 unauthenticated ở cả năm đường.
package baonghi_test

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sort"
	"strings"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/baonghi"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

type khung struct {
	ctx    context.Context
	srv    *httptest.Server
	owner  *pgx.Conn
	chu    int64 // chủ quán
	nv     int64 // người làm
	nv2    int64 // người làm thứ hai
	homNay time.Time
}

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

func (k khung) chuoi(t *testing.T, sql string, args ...any) string {
	t.Helper()
	var s string
	if err := k.coVet(func(tx pgx.Tx) error { return tx.QueryRow(k.ctx, sql, args...).Scan(&s) }); err != nil {
		t.Fatalf("%s: %v", sql, err)
	}
	return s
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
	baonghi.Routes(r, baonghi.NewService(pool))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)

	k := khung{ctx: ctx, srv: srv, owner: owner}
	nguoi := func(ten string, chu bool) int64 {
		return k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, $2) RETURNING id", ten+" · "+t.Name(), chu)
	}
	k.chu = nguoi("test-chủ quán", true)
	k.nv = nguoi("test-người làm", false)
	k.nv2 = nguoi("test-người làm hai", false)
	for _, id := range []int64{k.chu, k.nv, k.nv2} {
		testhelper.Session(t, id)
	}
	hn, err := time.Parse("2006-01-02", k.chuoi(t, "SELECT ((now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date)::text"))
	if err != nil {
		t.Fatal(err)
	}
	k.homNay = hn
	return k
}

// ngay trả ngày lịch Việt Nam hôm nay cộng n ngày, dạng YYYY-MM-DD.
func (k khung) ngay(n int) string { return k.homNay.AddDate(0, 0, n).Format("2006-01-02") }

type traVe struct {
	status int
	raw    string
	body   map[string]any
}

func (k khung) goiVoi(t *testing.T, method, path string, body any, gan func(*http.Request)) traVe {
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
	gan(req)
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	var buf bytes.Buffer
	_, _ = buf.ReadFrom(res.Body)
	out := traVe{status: res.StatusCode, raw: buf.String(), body: map[string]any{}}
	_ = json.Unmarshal(buf.Bytes(), &out.body)
	t.Logf("%s %s ⇒ %d %s", method, path, out.status, out.raw)
	return out
}

func (k khung) goi(t *testing.T, method, path string, nguoi int64, body any) traVe {
	t.Helper()
	return k.goiVoi(t, method, path, body, func(req *http.Request) {
		if nguoi != 0 {
			req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, nguoi)})
		}
	})
}

func canDat(t *testing.T, r traVe, status int) {
	t.Helper()
	if r.status != status {
		t.Fatalf("muốn %d, nhận %d %s", status, r.status, r.raw)
	}
}

func tuChoi(t *testing.T, r traVe, status int, code, field string) {
	t.Helper()
	if r.status != status || r.body["code"] != code || (field != "" && r.body["field"] != field) {
		t.Fatalf("muốn %d %s field=%q, nhận %d %s", status, code, field, r.status, r.raw)
	}
}

func maGui(t *testing.T) string {
	t.Helper()
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	b[6] = b[6]&0x0f | 0x40
	b[8] = b[8]&0x3f | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}

// nghi là một dòng báo nghỉ như cửa trả; mọi trường của hợp đồng phải có mặt (null được với trường tuỳ chọn).
type nghi struct {
	ID, Person      int64
	PersonName      string
	Ngay, Loai      string
	BietLuc, HuyLuc *string
	BietBoi, HuyBoi *int64
	HuyDuoc         bool
}

func soHoacNull(t *testing.T, m map[string]any, ten string) *int64 {
	t.Helper()
	v, co := m[ten]
	if !co {
		t.Fatalf("dòng thiếu %q: %v", ten, m)
	}
	if v == nil {
		return nil
	}
	n := int64(v.(float64))
	return &n
}

func chuHoacNull(t *testing.T, m map[string]any, ten string) *string {
	t.Helper()
	v, co := m[ten]
	if !co {
		t.Fatalf("dòng thiếu %q: %v", ten, m)
	}
	if v == nil {
		return nil
	}
	s := v.(string)
	return &s
}

func docNghi(t *testing.T, m map[string]any) nghi {
	t.Helper()
	for _, truong := range []string{"leave_notice_id", "person_id", "person_name", "leave_date", "notice_kind", "created_at", "can_cancel"} {
		if v, co := m[truong]; !co || v == nil {
			t.Fatalf("dòng thiếu %q: %v", truong, m)
		}
	}
	return nghi{
		ID:         int64(m["leave_notice_id"].(float64)),
		Person:     int64(m["person_id"].(float64)),
		PersonName: m["person_name"].(string),
		Ngay:       m["leave_date"].(string),
		Loai:       m["notice_kind"].(string),
		BietLuc:    chuHoacNull(t, m, "acknowledged_at"),
		BietBoi:    soHoacNull(t, m, "acknowledged_by_person_id"),
		HuyLuc:     chuHoacNull(t, m, "cancelled_at"),
		HuyBoi:     soHoacNull(t, m, "cancelled_by_person_id"),
		HuyDuoc:    m["can_cancel"].(bool),
	}
}

type trang struct {
	Dong []nghi
	Tiep *int64
}

func docTrang(t *testing.T, r traVe, coTiep bool) trang {
	t.Helper()
	canDat(t, r, http.StatusOK)
	if r.body["read_at"] == nil {
		t.Fatalf("thiếu read_at: %s", r.raw)
	}
	raw, ok := r.body["leave_notices"].([]any)
	if !ok {
		t.Fatalf("thiếu leave_notices: %s", r.raw)
	}
	out := trang{}
	if coTiep {
		out.Tiep = soHoacNull(t, r.body, "next_before_id")
	}
	for _, x := range raw {
		out.Dong = append(out.Dong, docNghi(t, x.(map[string]any)))
	}
	return out
}

func ids(ds []nghi) []int64 {
	out := make([]int64, 0, len(ds))
	for _, d := range ds {
		out = append(out, d.ID)
	}
	return out
}

func tim(ds []nghi, id int64) (nghi, bool) {
	for _, d := range ds {
		if d.ID == id {
			return d, true
		}
	}
	return nghi{}, false
}

func (k khung) bao(t *testing.T, nguoi int64, ma, ngay string) traVe {
	t.Helper()
	return k.goi(t, "POST", "/leave-notices", nguoi, map[string]any{"submission_code": ma, "leave_date": ngay})
}

func (k khung) baoMoi(t *testing.T, nguoi int64, ngay string) nghi {
	t.Helper()
	r := k.bao(t, nguoi, maGui(t), ngay)
	canDat(t, r, http.StatusCreated)
	return docNghi(t, r.body)
}

func (k khung) huy(t *testing.T, nguoi, id int64) traVe {
	t.Helper()
	return k.goi(t, "POST", fmt.Sprintf("/leave-notices/%d/cancel", id), nguoi, nil)
}

func (k khung) daBiet(t *testing.T, nguoi, id int64) traVe {
	t.Helper()
	return k.goi(t, "POST", fmt.Sprintf("/leave-notices/%d/acknowledge", id), nguoi, nil)
}

func (k khung) soDong(t *testing.T) int64 {
	t.Helper()
	return k.so(t, "SELECT count(*) FROM shop.leave_notice WHERE person_id = ANY($1)", []int64{k.chu, k.nv, k.nv2})
}

// dauVet đọc nguyên trạng thái các bảng báo nghỉ không được chạm: ô chấm công, ứng lương, thưởng lễ của người trong
// test (ADR-138 điểm 5; I-039). Chỉ đọc dòng gắn với người của test vì các package khác chạy song song.
func (k khung) dauVet(t *testing.T) string {
	t.Helper()
	nguoi := []int64{k.chu, k.nv, k.nv2}
	return k.chuoi(t, `SELECT concat_ws(' · ',
		(SELECT coalesce(string_agg(to_jsonb(a)::text, ',' ORDER BY a.id), '') FROM shop.attendance_day a WHERE a.worker_person_id = ANY($1)),
		(SELECT coalesce(string_agg(to_jsonb(s)::text, ',' ORDER BY s.id), '') FROM shop.staff_advance s WHERE s.worker_person_id = ANY($1)),
		(SELECT coalesce(string_agg(to_jsonb(h)::text, ',' ORDER BY h.id), '') FROM shop.holiday_bonus h WHERE h.worker_person_id = ANY($1)))`, nguoi)
}

// tick ghi một ô có đi làm còn hiệu lực bằng owner (chưa có cửa tick ở backend).
func (k khung) tick(t *testing.T, nguoi int64, ngay string) int64 {
	t.Helper()
	return k.so(t, "INSERT INTO shop.attendance_day (worker_person_id, work_date) VALUES ($1, $2::date) RETURNING id", nguoi, ngay)
}

// --- Báo nghỉ cho chính mình; loại báo trước / đột xuất do backend suy (ADR-138 điểm 1 · 2 · 6) ---------------------

func TestI039_BaoNghiChoChinhMinhVaLoaiDoBackendSuy(t *testing.T) {
	k := dung(t)
	truocVet := k.dauVet(t)

	cases := []struct {
		them int
		loai string
	}{{3, "bao_truoc"}, {10, "bao_truoc"}, {2, "dot_xuat"}, {1, "dot_xuat"}, {0, "dot_xuat"}}

	for _, c := range cases {
		d := k.baoMoi(t, k.nv, k.ngay(c.them))
		if d.Person != k.nv || d.Ngay != k.ngay(c.them) || d.Loai != c.loai {
			t.Fatalf("hôm nay + %d: muốn người %d ngày %s loại %s, nhận %+v", c.them, k.nv, k.ngay(c.them), c.loai, d)
		}
		if d.BietLuc != nil || d.BietBoi != nil || d.HuyLuc != nil || d.HuyBoi != nil || d.PersonName == "" {
			t.Fatalf("dòng mới mang dấu hoặc thiếu tên: %+v", d)
		}
		// Ngày hôm nay: người nghỉ không còn huỷ được; các ngày sau còn huỷ được.
		if d.HuyDuoc != (c.them > 0) {
			t.Fatalf("hôm nay + %d: can_cancel muốn %v, nhận %v", c.them, c.them > 0, d.HuyDuoc)
		}

	}

	// Không ghi hộ: thân mang person_id của người khác cũng không đổi người nghỉ.
	r := k.goi(t, "POST", "/leave-notices", k.nv, map[string]any{"submission_code": maGui(t), "leave_date": k.ngay(20), "person_id": k.nv2})
	if r.status == http.StatusBadRequest {
		tuChoi(t, r, http.StatusBadRequest, "invalid_request", "")
	} else {
		canDat(t, r, http.StatusCreated)
		if d := docNghi(t, r.body); d.Person != k.nv {
			t.Fatalf("thân đổi được người nghỉ: %+v", d)
		}
	}
	if n := k.so(t, "SELECT count(*) FROM shop.leave_notice WHERE person_id = $1", k.nv2); n != 0 {
		t.Fatalf("ghi hộ được báo nghỉ cho người khác: %d dòng", n)
	}

	// Ngày đã qua ⇒ 422; đã có báo nghỉ còn hiệu lực ngày ấy ⇒ 409; không ghi dòng.
	truoc := k.soDong(t)
	tuChoi(t, k.bao(t, k.nv, maGui(t), k.ngay(-1)), http.StatusUnprocessableEntity, "leave_date_in_past", "")
	tuChoi(t, k.bao(t, k.nv, maGui(t), k.ngay(3)), http.StatusConflict, "leave_notice_day_taken", "")
	if k.soDong(t) != truoc {
		t.Fatal("lời từ chối vẫn ghi dòng")
	}
	// Người khác báo cùng ngày là việc của họ.
	k.baoMoi(t, k.nv2, k.ngay(3))

	// Chủ quán cũng báo nghỉ cho chính mình được (lớp nguoi_quan).
	if d := k.baoMoi(t, k.chu, k.ngay(5)); d.Person != k.chu {
		t.Fatalf("chủ quán báo nghỉ ghi sai người: %+v", d)
	}

	if sau := k.dauVet(t); sau != truocVet {
		t.Fatalf("báo nghỉ chạm chấm công hoặc tiền: %s → %s", truocVet, sau)
	}
}

// --- Chặn hai chiều với ô có đi làm (ADR-138 điểm 4; I-039) ----------------------------------------------------------

func TestI039_NgayDaTickThiKhongBaoNghi(t *testing.T) {
	k := dung(t)
	k.tick(t, k.nv, k.ngay(4))
	truocVet := k.dauVet(t)
	truoc := k.soDong(t)
	tuChoi(t, k.bao(t, k.nv, maGui(t), k.ngay(4)), http.StatusConflict, "leave_day_attendance_ticked", "")
	if k.soDong(t) != truoc || k.dauVet(t) != truocVet {
		t.Fatal("lời từ chối vẫn ghi hoặc đổi ô chấm công")
	}
	// Ngày khác vẫn báo được.
	k.baoMoi(t, k.nv, k.ngay(5))
}

// --- Gửi lại an toàn; dấu duy nhất theo người (ADR-138 điểm 1 · 6; §8) ----------------------------------------------

func TestI039_GuiLaiKhongNhanDoi(t *testing.T) {
	k := dung(t)
	ma := maGui(t)
	r := k.bao(t, k.nv, ma, k.ngay(6))
	canDat(t, r, http.StatusCreated)
	dau := docNghi(t, r.body)
	truoc := k.soDong(t)

	r = k.bao(t, k.nv, ma, k.ngay(6))
	canDat(t, r, http.StatusOK)
	if lai := docNghi(t, r.body); lai.ID != dau.ID {
		t.Fatalf("gửi lại muốn dòng %d, nhận %+v", dau.ID, lai)
	}
	// Cùng dấu khác ngày ⇒ 409, không thêm dòng.
	tuChoi(t, k.bao(t, k.nv, ma, k.ngay(7)), http.StatusConflict, "submission_code_conflict", "")
	if k.soDong(t) != truoc {
		t.Fatal("gửi lại thêm dòng")
	}
	// Người khác dùng cùng dấu: báo nghỉ mới của họ.
	r = k.bao(t, k.nv2, ma, k.ngay(6))
	canDat(t, r, http.StatusCreated)
	if d := docNghi(t, r.body); d.Person != k.nv2 || d.ID == dau.ID {
		t.Fatalf("dấu của người khác lẫn dòng: %+v", d)
	}

	// Đã huỷ rồi gửi lại cùng dấu ⇒ 200 dòng ấy ở trạng thái hiện tại, không sinh dòng mới.
	canDat(t, k.huy(t, k.nv, dau.ID), http.StatusOK)
	r = k.bao(t, k.nv, ma, k.ngay(6))
	canDat(t, r, http.StatusOK)
	if lai := docNghi(t, r.body); lai.ID != dau.ID || lai.HuyLuc == nil || lai.HuyBoi == nil || *lai.HuyBoi != k.nv {
		t.Fatalf("gửi lại sau huỷ muốn dòng %d đã huỷ, nhận %+v", dau.ID, lai)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.leave_notice WHERE person_id = $1", k.nv); n != 1 {
		t.Fatalf("gửi lại sau huỷ sinh dòng: %d", n)
	}

	// Hai lần gửi song song cùng dấu: một 201, một 200, một dòng.
	ma2 := maGui(t)
	var wg sync.WaitGroup
	st := make([]int, 2)
	for i := range st {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			st[i] = k.bao(t, k.nv, ma2, k.ngay(8)).status
		}(i)
	}
	wg.Wait()
	sort.Ints(st)
	if st[0] != http.StatusOK || st[1] != http.StatusCreated {
		t.Fatalf("song song cùng dấu muốn [200 201], nhận %v", st)
	}
	// Hai lần gửi song song khác dấu cùng ngày: một 201, một 409 leave_notice_day_taken.
	kq := make([]traVe, 2)
	for i := range kq {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			kq[i] = k.bao(t, k.nv, maGui(t), k.ngay(9))
		}(i)
	}
	wg.Wait()
	sort.Slice(kq, func(a, b int) bool { return kq[a].status < kq[b].status })
	if kq[0].status != http.StatusCreated || kq[1].status != http.StatusConflict || kq[1].body["code"] != "leave_notice_day_taken" {
		t.Fatalf("song song khác dấu cùng ngày muốn 201 + 409 leave_notice_day_taken, nhận %d %s / %d %s", kq[0].status, kq[0].raw, kq[1].status, kq[1].raw)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.leave_notice WHERE person_id = $1 AND leave_date IN ($2::date, $3::date)", k.nv, k.ngay(8), k.ngay(9)); n != 2 {
		t.Fatalf("song song sinh %d dòng, muốn 2", n)
	}
}

// --- Huỷ: chủ quán lúc nào cũng được, người nghỉ tới hết ngày trước (ADR-138 điểm 3) --------------------------------

func TestI039_HuyDungNguoiDungHan(t *testing.T) {
	k := dung(t)
	mai := k.baoMoi(t, k.nv, k.ngay(1))
	homNay := k.baoMoi(t, k.nv, k.ngay(0))
	xa := k.baoMoi(t, k.nv, k.ngay(12))

	// Người khác (không phải chủ quán) không thấy, không huỷ được báo nghỉ của nv; không có dòng ⇒ cùng lời 404.
	tuChoi(t, k.huy(t, k.nv2, mai.ID), http.StatusNotFound, "leave_notice_not_found", "")
	tuChoi(t, k.huy(t, k.nv, xa.ID+1000000), http.StatusNotFound, "leave_notice_not_found", "")
	// Người nghỉ huỷ ngày hôm nay ⇒ đã hết hạn.
	tuChoi(t, k.huy(t, k.nv, homNay.ID), http.StatusUnprocessableEntity, "leave_notice_cancel_closed", "")
	if n := k.so(t, "SELECT count(*) FROM shop.leave_notice WHERE id = ANY($1) AND cancelled_at IS NOT NULL", []int64{mai.ID, homNay.ID}); n != 0 {
		t.Fatalf("lời từ chối vẫn huỷ %d dòng", n)
	}

	// Người nghỉ huỷ ngày mai: được, dấu huỷ là người của phiên, có vết đúng người.
	r := k.huy(t, k.nv, mai.ID)
	canDat(t, r, http.StatusOK)
	d := docNghi(t, r.body)
	if d.ID != mai.ID || d.HuyLuc == nil || d.HuyBoi == nil || *d.HuyBoi != k.nv || d.HuyDuoc {
		t.Fatalf("huỷ ghi sai: %+v", d)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'leave_notice' AND target_row = $1 AND person_id = $2 AND btrim(reason) <> ''", mai.ID, k.nv); n != 1 {
		t.Fatalf("huỷ muốn đúng một vết của người huỷ, nhận %d", n)
	}
	// Huỷ lại dòng đã huỷ ⇒ 200 dòng hiện tại, dấu cũ giữ nguyên, kể cả khi chủ quán huỷ lại.
	luc := *d.HuyLuc
	for _, ai := range []int64{k.nv, k.chu} {
		r = k.huy(t, ai, mai.ID)
		canDat(t, r, http.StatusOK)
		if lai := docNghi(t, r.body); lai.HuyLuc == nil || *lai.HuyLuc != luc || *lai.HuyBoi != k.nv {
			t.Fatalf("huỷ lại đổi dấu: %+v", lai)
		}
	}
	// Huỷ xong thì báo lại ngày ấy được (dòng mới).
	k.baoMoi(t, k.nv, k.ngay(1))

	// Chủ quán huỷ ngày hôm nay của người khác: được.
	r = k.huy(t, k.chu, homNay.ID)
	canDat(t, r, http.StatusOK)
	if d := docNghi(t, r.body); d.HuyBoi == nil || *d.HuyBoi != k.chu {
		t.Fatalf("chủ quán huỷ ghi sai người: %+v", d)
	}
	// Huỷ báo nghỉ thì ô có đi làm ngày ấy tick lại được (database; không có cửa tick).
	k.tick(t, k.nv, k.ngay(0))

	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'leave_notice' AND target_row = $1", mai.ID); n != 1 {
		t.Fatalf("huỷ lại vẫn ghi vết: %d", n)
	}
}

// --- Đã biết: chỉ chủ quán, một lần (ADR-138 điểm 3 · 6) ------------------------------------------------------------

func TestI039_DaBietChiChuQuanMotLan(t *testing.T) {
	k := dung(t)
	truocVet := k.dauVet(t)
	d := k.baoMoi(t, k.nv, k.ngay(4))
	huy := k.baoMoi(t, k.nv, k.ngay(5))
	canDat(t, k.huy(t, k.nv, huy.ID), http.StatusOK)

	tuChoi(t, k.daBiet(t, k.nv, d.ID), http.StatusForbidden, "owner_only", "")
	tuChoi(t, k.daBiet(t, k.nv2, d.ID), http.StatusForbidden, "owner_only", "")
	tuChoi(t, k.daBiet(t, k.chu, d.ID+1000000), http.StatusNotFound, "leave_notice_not_found", "")

	r := k.daBiet(t, k.chu, d.ID)
	canDat(t, r, http.StatusOK)
	biet := docNghi(t, r.body)
	if biet.BietLuc == nil || biet.BietBoi == nil || *biet.BietBoi != k.chu || biet.HuyLuc != nil {
		t.Fatalf("đã biết ghi sai: %+v", biet)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'leave_notice' AND target_row = $1 AND person_id = $2 AND btrim(reason) <> ''", d.ID, k.chu); n != 1 {
		t.Fatalf("đã biết muốn đúng một vết của chủ quán, nhận %d", n)
	}
	// Ghi lại ⇒ 200, dấu cũ giữ nguyên, không vết thêm.
	r = k.daBiet(t, k.chu, d.ID)
	canDat(t, r, http.StatusOK)
	if lai := docNghi(t, r.body); lai.BietLuc == nil || *lai.BietLuc != *biet.BietLuc {
		t.Fatalf("ghi lại đã biết đổi dấu: %+v", lai)
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'leave_notice' AND target_row = $1", d.ID); n != 1 {
		t.Fatalf("ghi lại đã biết vẫn ghi vết: %d", n)
	}
	// Dòng đã huỷ vẫn ghi đã biết được.
	r = k.daBiet(t, k.chu, huy.ID)
	canDat(t, r, http.StatusOK)
	if x := docNghi(t, r.body); x.BietLuc == nil || x.HuyLuc == nil {
		t.Fatalf("đã biết dòng đã huỷ sai: %+v", x)
	}
	// Đã biết không đổi quyền huỷ của người nghỉ.
	r = k.huy(t, k.nv, d.ID)
	canDat(t, r, http.StatusOK)

	if sau := k.dauVet(t); sau != truocVet {
		t.Fatalf("đã biết chạm chấm công hoặc tiền: %s → %s", truocVet, sau)
	}
}

// --- Đọc đúng phạm vi ------------------------------------------------------------------------------------------------

func TestI039_DocDungPhamVi(t *testing.T) {
	k := dung(t)
	a := k.baoMoi(t, k.nv, k.ngay(3))
	b := k.baoMoi(t, k.nv, k.ngay(1))
	c := k.baoMoi(t, k.nv, k.ngay(0))
	x := k.baoMoi(t, k.nv2, k.ngay(2))
	canDat(t, k.huy(t, k.nv, b.ID), http.StatusOK)

	// Của tôi: chỉ dòng của người của phiên, kể cả đã huỷ, id DESC; tham số không mở được dòng người khác.
	p := docTrang(t, k.goi(t, "GET", "/leave-notices/mine", k.nv, nil), true)
	if got := ids(p.Dong); len(got) != 3 || got[0] != c.ID || got[1] != b.ID || got[2] != a.ID || p.Tiep != nil {
		t.Fatalf("của tôi muốn [%d %d %d], nhận %v tiếp %v", c.ID, b.ID, a.ID, got, p.Tiep)
	}
	if d, _ := tim(p.Dong, a.ID); !d.HuyDuoc || d.Loai != "bao_truoc" {
		t.Fatalf("dòng a muốn còn huỷ được, báo trước: %+v", d)
	}
	if d, _ := tim(p.Dong, b.ID); d.HuyDuoc || d.HuyLuc == nil {
		t.Fatalf("dòng đã huỷ muốn can_cancel false: %+v", d)
	}
	if d, _ := tim(p.Dong, c.ID); d.HuyDuoc {
		t.Fatalf("dòng hôm nay muốn can_cancel false với người nghỉ: %+v", d)
	}
	for _, q := range []string{"person_id", "worker_person_id"} {
		p = docTrang(t, k.goi(t, "GET", fmt.Sprintf("/leave-notices/mine?%s=%d", q, k.nv), k.nv2, nil), true)
		if len(p.Dong) != 1 || p.Dong[0].ID != x.ID {
			t.Fatalf("tham số %s mở được dòng người khác: %v", q, ids(p.Dong))
		}
	}

	// Chia trang của tôi.
	p = docTrang(t, k.goi(t, "GET", "/leave-notices/mine?limit=2", k.nv, nil), true)
	if len(p.Dong) != 2 || p.Tiep == nil || *p.Tiep != b.ID {
		t.Fatalf("trang 1 sai: %v tiếp %v", ids(p.Dong), p.Tiep)
	}
	p = docTrang(t, k.goi(t, "GET", fmt.Sprintf("/leave-notices/mine?limit=2&before_id=%d", b.ID), k.nv, nil), true)
	if len(p.Dong) != 1 || p.Dong[0].ID != a.ID || p.Tiep != nil {
		t.Fatalf("trang 2 sai: %v tiếp %v", ids(p.Dong), p.Tiep)
	}

	// Chủ quán đọc theo khoảng ngày: mọi người, kể cả đã huỷ, leave_date ASC rồi id ASC; can_cancel tính cho chủ quán.
	duong := fmt.Sprintf("/leave-notices?from=%s&to=%s", k.ngay(0), k.ngay(3))
	tuChoi(t, k.goi(t, "GET", duong, k.nv, nil), http.StatusForbidden, "owner_only", "")
	p = docTrang(t, k.goi(t, "GET", duong, k.chu, nil), false)
	var cuaTest []nghi
	for _, d := range p.Dong {
		if d.Person == k.nv || d.Person == k.nv2 {
			cuaTest = append(cuaTest, d)
		}
	}
	if got := ids(cuaTest); len(got) != 4 || got[0] != c.ID || got[1] != b.ID || got[2] != x.ID || got[3] != a.ID {
		t.Fatalf("khoảng ngày muốn [%d %d %d %d], nhận %v", c.ID, b.ID, x.ID, a.ID, got)
	}
	for _, d := range cuaTest {
		if d.HuyDuoc != (d.HuyLuc == nil) || d.PersonName == "" {
			t.Fatalf("can_cancel của chủ quán sai: %+v", d)
		}
	}
	for i := 1; i < len(p.Dong); i++ {
		if p.Dong[i-1].Ngay > p.Dong[i].Ngay || (p.Dong[i-1].Ngay == p.Dong[i].Ngay && p.Dong[i-1].ID > p.Dong[i].ID) {
			t.Fatalf("khoảng ngày không theo leave_date, id: %v", ids(p.Dong))
		}
		if p.Dong[i].Ngay < k.ngay(0) || p.Dong[i].Ngay > k.ngay(3) {
			t.Fatalf("dòng ngoài khoảng: %+v", p.Dong[i])
		}
	}
	p = docTrang(t, k.goi(t, "GET", fmt.Sprintf("/leave-notices?from=%s&to=%s", k.ngay(1), k.ngay(1)), k.chu, nil), false)
	if _, co := tim(p.Dong, b.ID); !co {
		t.Fatalf("khoảng một ngày thiếu dòng đã huỷ: %v", ids(p.Dong))
	}
	if _, co := tim(p.Dong, a.ID); co {
		t.Fatalf("khoảng một ngày lẫn ngày khác: %v", ids(p.Dong))
	}
}

// --- Hình sai bị từ chối trước quyền ---------------------------------------------------------------------------------

func TestI039_HinhSai(t *testing.T) {
	k := dung(t)
	truoc := k.soDong(t)
	for _, s := range []struct {
		body  map[string]any
		field string
	}{
		{map[string]any{"leave_date": k.ngay(4)}, "submission_code"},
		{map[string]any{"submission_code": "khong-phai-uuid", "leave_date": k.ngay(4)}, "submission_code"},
		{map[string]any{"submission_code": strings.ToUpper(maGui(t)), "leave_date": k.ngay(4)}, "submission_code"},
		{map[string]any{"submission_code": maGui(t)}, "leave_date"},
		{map[string]any{"submission_code": maGui(t), "leave_date": ""}, "leave_date"},
		{map[string]any{"submission_code": maGui(t), "leave_date": "2026-13-01"}, "leave_date"},
		{map[string]any{"submission_code": maGui(t), "leave_date": "2026-02-30"}, "leave_date"},
		{map[string]any{"submission_code": maGui(t), "leave_date": "2026-11-4"}, "leave_date"},
		{map[string]any{"submission_code": maGui(t), "leave_date": "04/11/2026"}, "leave_date"},
		{map[string]any{"submission_code": maGui(t), "leave_date": k.ngay(4) + "T00:00:00Z"}, "leave_date"},
		{map[string]any{"submission_code": maGui(t), "leave_date": 20261104}, "leave_date"},
	} {
		tuChoi(t, k.goi(t, "POST", "/leave-notices", k.nv, s.body), http.StatusBadRequest, "invalid_request", s.field)
	}
	tuChoi(t, k.goi(t, "POST", "/leave-notices", k.nv, "{không phải json"), http.StatusBadRequest, "invalid_request", "")

	// Mã trên đường dẫn: sai hình ⇒ 400 trước quyền (người không phải chủ quán cũng nhận lỗi hình ở acknowledge).
	for _, id := range []string{"0", "-1", "abc"} {
		tuChoi(t, k.goi(t, "POST", "/leave-notices/"+id+"/cancel", k.nv, nil), http.StatusBadRequest, "invalid_request", "leave_notice_id")
		tuChoi(t, k.goi(t, "POST", "/leave-notices/"+id+"/acknowledge", k.nv, nil), http.StatusBadRequest, "invalid_request", "leave_notice_id")
	}

	// Đọc của tôi: limit, before_id.
	for _, q := range []struct{ q, field string }{{"limit=0", "limit"}, {"limit=51", "limit"}, {"limit=abc", "limit"}, {"before_id=0", "before_id"}, {"before_id=x", "before_id"}} {
		tuChoi(t, k.goi(t, "GET", "/leave-notices/mine?"+q.q, k.nv, nil), http.StatusBadRequest, "invalid_request", q.field)
	}
	// Đọc theo khoảng: from, to bắt buộc, đúng hình, from ≤ to, to − from ≤ 92 ngày; xét trước quyền.
	for _, q := range []struct{ q, field string }{
		{"to=" + k.ngay(1), "from"},
		{"from=" + k.ngay(1), "to"},
		{"from=hom-nay&to=" + k.ngay(1), "from"},
		{"from=" + k.ngay(1) + "&to=2026-02-30", "to"},
		{"from=" + k.ngay(2) + "&to=" + k.ngay(1), "to"},
		{"from=" + k.ngay(0) + "&to=" + k.ngay(93), "to"},
	} {
		tuChoi(t, k.goi(t, "GET", "/leave-notices?"+q.q, k.nv, nil), http.StatusBadRequest, "invalid_request", q.field)
	}
	// Biên: đúng 92 ngày là nhận.
	docTrang(t, k.goi(t, "GET", fmt.Sprintf("/leave-notices?from=%s&to=%s", k.ngay(0), k.ngay(92)), k.chu, nil), false)

	if k.soDong(t) != truoc {
		t.Fatal("lời từ chối vẫn ghi dòng")
	}
}

// --- Khách và người không phiên bị từ chối ở cả năm đường -----------------------------------------------------------

func TestI039_KhongPhienVaCookieKhachBiTuChoi(t *testing.T) {
	k := dung(t)
	d := k.baoMoi(t, k.nv, k.ngay(6))
	tokenKhach := phienKhach(t, k)
	cua := []struct {
		method, path string
		body         any
	}{
		{"POST", "/leave-notices", map[string]any{"submission_code": maGui(t), "leave_date": k.ngay(7)}},
		{"POST", fmt.Sprintf("/leave-notices/%d/cancel", d.ID), nil},
		{"POST", fmt.Sprintf("/leave-notices/%d/acknowledge", d.ID), nil},
		{"GET", "/leave-notices/mine", nil},
		{"GET", fmt.Sprintf("/leave-notices?from=%s&to=%s", k.ngay(0), k.ngay(7)), nil},
	}
	truoc := k.soDong(t)
	for _, c := range cua {
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
		tuChoi(t, k.goiVoi(t, c.method, c.path, c.body, func(req *http.Request) {
			req.AddCookie(&http.Cookie{Name: authz.CookieKhach, Value: tokenKhach})
		}), http.StatusUnauthorized, "unauthenticated", "")
	}
	if k.soDong(t) != truoc {
		t.Fatal("khách hoặc không phiên ghi được báo nghỉ")
	}
	if n := k.so(t, "SELECT count(*) FROM shop.leave_notice WHERE id = $1 AND (cancelled_at IS NOT NULL OR acknowledged_at IS NOT NULL)", d.ID); n != 0 {
		t.Fatal("khách hoặc không phiên huỷ hay ghi đã biết được")
	}
}

// phienKhach dựng một phiên khách còn hiệu lực bằng dòng thật (cùng cách test CHAT-13, CHAT-34).
func phienKhach(t *testing.T, k khung) string {
	t.Helper()
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	token := base64.RawURLEncoding.EncodeToString(b)
	h := sha256.Sum256([]byte(token))
	email := fmt.Sprintf("test-khach-baonghi-%d@example.test", time.Now().UnixNano())
	if err := k.coVet(func(tx pgx.Tx) error {
		var a int64
		if err := tx.QueryRow(k.ctx, `INSERT INTO shop.customer_account (email, display_name) VALUES ($1, 'test-khách') RETURNING id`, email).Scan(&a); err != nil {
			return err
		}
		_, err := tx.Exec(k.ctx, `INSERT INTO shop.customer_session (customer_account_id, token_hash, expires_at) VALUES ($1, $2, now() + interval '1 day')`, a, h[:])
		return err
	}); err != nil {
		t.Fatal(err)
	}
	return token
}
