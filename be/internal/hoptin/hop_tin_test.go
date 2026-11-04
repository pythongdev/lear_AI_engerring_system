// Test bốn cửa hộp tin trạm ↔ quầy (CHAT-13, ADR-137 điểm 4 · 5 · 6 · 7; I-038). Claude viết TRƯỚC khi có package
// hoptin; Codex làm cho xanh, không sửa điều kiện kiểm. Vế tầng 1 của I-038 (bảng không khoá ngoại tới tiến độ, không
// UPDATE/DELETE) đã có ở db/tests/i038_station_message.sql; ở đây là vế tầng 3: tin riêng chỉ người gửi, người nhận
// hoặc quầy đọc được, người gửi lấy từ phiên, gửi lại không nhân bản, tín hiệu chỉ phát sau COMMIT.
//
// Hợp đồng Claude chốt trong test này (2026-11-04, trong khung ADR-137):
//   - POST /station-messages (hoptin/quay_gui, lớp quay): submission_code, recipient_person_id, work_code, body,
//     dining_table_id?, reply_to_message_id?. Tạo 201, gửi lại 200.
//   - POST /station-messages/to-counter (hoptin/gui_ve_quay, lớp nguoi_quan): như trên, không có người nhận.
//   - GET /station-messages/mine (nguoi_quan): tin gửi tới và do chính người ấy gửi.
//   - GET /station-messages/counter (quay_hoac_chu_quan): mọi tin (tin về quầy và tin quầy đã gửi).
//   - Đọc: id DESC, before_id loại trừ, limit 1–50 mặc định 20, next_before_id như customerOrders; trả read_at và
//     poll_interval_seconds = 20.
//   - Từ chối: người nhận không có, không có tài khoản hoat_dong, hoặc chính người gửi ⇒ 422 message_recipient_invalid;
//     bàn không có ⇒ 404 dining_table_not_found; tin trả lời không có hoặc người gửi không đọc được ⇒ 404
//     station_message_not_found; cùng dấu khác nội dung, hoặc dấu của người khác ⇒ 409 submission_code_conflict.
//     Thứ tự: hình → quyền → dấu gửi lại → người nhận · bàn · tin trả lời.
package hoptin_test

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
	"strings"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/hoptin"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type khung struct {
	ctx     context.Context
	srv     *httptest.Server
	owner   *pgx.Conn
	chu     int64 // chủ quán, không đứng quầy
	quay    int64 // người thường đang đứng quầy
	nv      int64 // người canh + dọn, không đứng quầy
	nv2     int64 // người thường thứ hai
	khongTK int64 // người không có tài khoản
	biKhoa  int64 // người có tài khoản đã khoá
	ban     int64
	phat    *phat
}

// phat ghi mỗi lần cửa phát tín hiệu, kèm id tin lớn nhất mà một kết nối KHÁC thấy ngay lúc ấy: thấy được tức đã COMMIT.
type phat struct {
	mu   sync.Mutex
	pool *pgxpool.Pool
	thay []int64
}

func (p *phat) ghi(time.Time) {
	var max int64
	_ = p.pool.QueryRow(context.Background(), "SELECT coalesce(max(id), 0) FROM shop.station_message").Scan(&max)
	p.mu.Lock()
	p.thay = append(p.thay, max)
	p.mu.Unlock()
}

func (p *phat) lay() []int64 {
	p.mu.Lock()
	defer p.mu.Unlock()
	return append([]int64(nil), p.thay...)
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
	nhin, err := pgxpool.New(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(nhin.Close)
	p := &phat{pool: nhin}

	r := gin.New()
	r.HandleMethodNotAllowed = true
	r.Use(func(c *gin.Context) {
		c.Request = c.Request.WithContext(postgres.WithNotifications(c.Request.Context(), p.ghi))
		c.Next()
	})
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	hoptin.Routes(r, hoptin.NewService(pool))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)

	k := khung{ctx: ctx, srv: srv, owner: owner, phat: p}
	nguoi := func(ten string, chu bool) int64 {
		return k.so(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, $2) RETURNING id", ten+" · "+t.Name(), chu)
	}
	k.chu = nguoi("test-chủ quán", true)
	k.quay = nguoi("test-người quầy", false)
	k.nv = nguoi("test-người canh dọn", false)
	k.nv2 = nguoi("test-người tráng", false)
	k.khongTK = nguoi("test-người chưa có tài khoản", false)
	k.biKhoa = nguoi("test-người bị khoá", false)
	// Session dựng tài khoản hoat_dong cho người chưa có; người nhận phải có tài khoản trước khi được gửi tới.
	for _, id := range []int64{k.chu, k.quay, k.nv, k.nv2, k.biKhoa} {
		testhelper.Session(t, id)
	}
	k.so(t, "UPDATE shop.account SET status = 'khoa' WHERE person_id = $1 RETURNING id", k.biKhoa)
	k.ban = k.so(t, "INSERT INTO shop.dining_table (label) VALUES ($1) RETURNING id", "test-bàn hộp tin · "+t.Name())
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
	raw    string
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

// tin là một tin như cửa trả; mọi trường của hợp đồng phải có mặt (null được với trường tuỳ chọn).
type tin struct {
	ID, Sender     int64
	Recipient, Ban *int64
	ReplyTo        *int64
	SenderName     string
	RecipientName  *string
	WorkCode, Body string
}

func soHoacNull(t *testing.T, m map[string]any, ten string) *int64 {
	t.Helper()
	v, co := m[ten]
	if !co {
		t.Fatalf("tin thiếu %q: %v", ten, m)
	}
	if v == nil {
		return nil
	}
	n := int64(v.(float64))
	return &n
}

func docTin(t *testing.T, m map[string]any) tin {
	t.Helper()
	for _, truong := range []string{"station_message_id", "sender_person_id", "sender_name", "recipient_name", "work_code", "body", "created_at"} {
		if _, co := m[truong]; !co {
			t.Fatalf("tin thiếu %q: %v", truong, m)
		}
	}
	out := tin{
		ID:         int64(m["station_message_id"].(float64)),
		Sender:     int64(m["sender_person_id"].(float64)),
		SenderName: m["sender_name"].(string),
		WorkCode:   m["work_code"].(string),
		Body:       m["body"].(string),
		Recipient:  soHoacNull(t, m, "recipient_person_id"),
		Ban:        soHoacNull(t, m, "dining_table_id"),
		ReplyTo:    soHoacNull(t, m, "reply_to_message_id"),
	}
	if s, ok := m["recipient_name"].(string); ok {
		out.RecipientName = &s
	}
	return out
}

type trang struct {
	Tin  []tin
	Tiep *int64
}

func docTrang(t *testing.T, r traVe) trang {
	t.Helper()
	canDat(t, r, http.StatusOK)
	if r.body["read_at"] == nil {
		t.Fatalf("thiếu read_at: %s", r.raw)
	}
	if p, _ := r.body["poll_interval_seconds"].(float64); p != 20 {
		t.Fatalf("poll_interval_seconds muốn 20, nhận %v", r.body["poll_interval_seconds"])
	}
	raw, ok := r.body["messages"].([]any)
	if !ok {
		t.Fatalf("thiếu messages: %s", r.raw)
	}
	out := trang{Tiep: soHoacNull(t, r.body, "next_before_id")}
	for _, x := range raw {
		out.Tin = append(out.Tin, docTin(t, x.(map[string]any)))
	}
	return out
}

func ids(ds []tin) []int64 {
	out := make([]int64, 0, len(ds))
	for _, d := range ds {
		out = append(out, d.ID)
	}
	return out
}

func co(ds []tin, id int64) bool {
	for _, d := range ds {
		if d.ID == id {
			return true
		}
	}
	return false
}

func (k khung) quayGui(t *testing.T, nguoi int64, body map[string]any) traVe {
	t.Helper()
	return k.goi(t, "POST", "/station-messages", nguoi, body)
}

func (k khung) veQuay(t *testing.T, nguoi int64, body map[string]any) traVe {
	t.Helper()
	return k.goi(t, "POST", "/station-messages/to-counter", nguoi, body)
}

func (k khung) soTin(t *testing.T) int64 {
	t.Helper()
	return k.so(t, "SELECT count(*) FROM shop.station_message")
}

// soTienDo đọc các ô tiến độ có thể bị chạm qua người và bàn của test: phiên bàn, việc giao, dấu việc giao, vết sửa.
// Chỉ đọc dòng gắn với dữ liệu của test này vì các package khác chạy song song trên cùng database.
func (k khung) soTienDo(t *testing.T) string {
	t.Helper()
	nguoi := []int64{k.chu, k.quay, k.nv, k.nv2}
	return fmt.Sprintf("phiên bàn %d · việc giao %d · dấu %d · vết %d",
		k.so(t, "SELECT count(*) FROM shop.table_session_member WHERE dining_table_id = $1", k.ban),
		k.so(t, "SELECT count(*) FROM shop.assigned_task WHERE assignee_person_id = ANY($1) OR person_id = ANY($1)", nguoi),
		k.so(t, "SELECT count(*) FROM shop.assigned_task_mark WHERE person_id = ANY($1)", nguoi),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE person_id = ANY($1)", nguoi))
}

// --- POS gửi tới một người; người ấy nhận mỗi tin một lần, đúng nhãn (ADR-137 điểm 4) -------------------------------

func TestI038_QuayGuiTinCanhVaDonToiCungMotNguoi(t *testing.T) {
	k := dung(t)
	truocTienDo := k.soTienDo(t)

	r := k.quayGui(t, k.quay, map[string]any{"submission_code": maGui(t), "recipient_person_id": k.nv, "work_code": "canh", "body": "test-múc 2 bát canh bàn này", "dining_table_id": k.ban})
	canDat(t, r, http.StatusCreated)
	canh := docTin(t, r.body)
	r = k.quayGui(t, k.quay, map[string]any{"submission_code": maGui(t), "recipient_person_id": k.nv, "work_code": "don_ban", "body": "test-dọn bàn này", "dining_table_id": k.ban})
	canDat(t, r, http.StatusCreated)
	don := docTin(t, r.body)

	for _, m := range []tin{canh, don} {
		if m.Sender != k.quay || m.Recipient == nil || *m.Recipient != k.nv || m.Ban == nil || *m.Ban != k.ban || m.ReplyTo != nil || m.RecipientName == nil {
			t.Fatalf("tin ghi sai người/bàn: %+v", m)
		}
	}
	if canh.WorkCode != "canh" || don.WorkCode != "don_ban" || canh.Body != "test-múc 2 bát canh bàn này" {
		t.Fatalf("nhãn hoặc nội dung sai: %+v %+v", canh, don)
	}

	// Tín hiệu: đúng một lần mỗi tin, và lúc phát kết nối khác đã thấy tin (sau COMMIT).
	if p := k.phat.lay(); len(p) != 2 || p[0] < canh.ID || p[1] < don.ID {
		t.Fatalf("tín hiệu muốn 2 lần sau COMMIT (%d, %d), nhận %v", canh.ID, don.ID, p)
	}

	// Người nhận thấy hai tin, mới nhất trước, mỗi tin một lần.
	ds := docTrang(t, k.goi(t, "GET", "/station-messages/mine", k.nv, nil))
	if len(ds.Tin) != 2 || ds.Tin[0].ID != don.ID || ds.Tin[1].ID != canh.ID || ds.Tiep != nil {
		t.Fatalf("hộp của người nhận muốn [%d %d], nhận %v (tiếp %v)", don.ID, canh.ID, ids(ds.Tin), ds.Tiep)
	}
	if ds.Tin[0].WorkCode != "don_ban" || ds.Tin[1].WorkCode != "canh" {
		t.Fatalf("nhãn ở hộp sai: %+v", ds.Tin)
	}
	// Không nhận định danh người từ tham số.
	for _, q := range []string{"person_id", "recipient_person_id"} {
		ds = docTrang(t, k.goi(t, "GET", fmt.Sprintf("/station-messages/mine?%s=%d", q, k.nv), k.nv2, nil))
		if len(ds.Tin) != 0 {
			t.Fatalf("tham số %s mở được hộp người khác: %v", q, ids(ds.Tin))
		}
	}
	// Người gửi (quầy) thấy tin mình gửi ở hộp cá nhân; quầy và chủ quán thấy ở hộp quầy.
	ds = docTrang(t, k.goi(t, "GET", "/station-messages/mine", k.quay, nil))
	if !co(ds.Tin, canh.ID) || !co(ds.Tin, don.ID) {
		t.Fatalf("người gửi không thấy tin đã gửi: %v", ids(ds.Tin))
	}
	for _, ai := range []int64{k.quay, k.chu} {
		ds = docTrang(t, k.goi(t, "GET", "/station-messages/counter", ai, nil))
		if !co(ds.Tin, canh.ID) || !co(ds.Tin, don.ID) {
			t.Fatalf("hộp quầy (người %d) thiếu tin: %v", ai, ids(ds.Tin))
		}
	}
	// Người không đứng quầy, không phải chủ quán không đọc hộp quầy.
	tuChoi(t, k.goi(t, "GET", "/station-messages/counter", k.nv, nil), http.StatusForbidden, "not_on_counter_duty", "")

	// Đọc không phát tín hiệu; gửi tin không đổi tiến độ.
	if p := k.phat.lay(); len(p) != 2 {
		t.Fatalf("cửa đọc phát tín hiệu: %v", p)
	}
	if sau := k.soTienDo(t); sau != truocTienDo {
		t.Fatalf("gửi tin mà tiến độ đổi: %s → %s", truocTienDo, sau)
	}
}

// --- Trạm gửi về quầy; chỉ tạo tin, không đụng tiến độ (ADR-137 điểm 3 · 5; I-038) ---------------------------------

func TestI038_TramGuiVeQuayChiTaoTin(t *testing.T) {
	k := dung(t)
	r := k.quayGui(t, k.quay, map[string]any{"submission_code": maGui(t), "recipient_person_id": k.nv, "work_code": "don_ban", "body": "test-dọn bàn", "dining_table_id": k.ban})
	canDat(t, r, http.StatusCreated)
	hoi := docTin(t, r.body)
	truocTienDo := k.soTienDo(t)

	// Người gửi lấy từ phiên: thân mang sender_person_id hay recipient_person_id cũng không đổi được người.
	r = k.veQuay(t, k.nv, map[string]any{"submission_code": maGui(t), "work_code": "don_ban", "body": "test-đã dọn xong", "dining_table_id": k.ban, "reply_to_message_id": hoi.ID, "sender_person_id": k.nv2, "recipient_person_id": k.nv2})
	if r.status == http.StatusBadRequest {
		tuChoi(t, r, http.StatusBadRequest, "invalid_request", "")
		r = k.veQuay(t, k.nv, map[string]any{"submission_code": maGui(t), "work_code": "don_ban", "body": "test-đã dọn xong", "dining_table_id": k.ban, "reply_to_message_id": hoi.ID})
	}
	canDat(t, r, http.StatusCreated)
	traLoi := docTin(t, r.body)
	if traLoi.Sender != k.nv || traLoi.Recipient != nil || traLoi.RecipientName != nil || traLoi.ReplyTo == nil || *traLoi.ReplyTo != hoi.ID {
		t.Fatalf("tin về quầy ghi sai người/trả lời: %+v", traLoi)
	}
	// Tráng/gấp cũng gửi được về quầy, không cần bàn.
	r = k.veQuay(t, k.nv2, map[string]any{"submission_code": maGui(t), "work_code": "trang_banh", "body": "test-hết bột"})
	canDat(t, r, http.StatusCreated)
	tuTrang := docTin(t, r.body)

	// Quầy thấy cả hai; người gửi thấy tin của mình; người thứ ba không thấy tin riêng của người khác.
	ds := docTrang(t, k.goi(t, "GET", "/station-messages/counter", k.quay, nil))
	if !co(ds.Tin, traLoi.ID) || !co(ds.Tin, tuTrang.ID) {
		t.Fatalf("quầy thiếu tin về quầy: %v", ids(ds.Tin))
	}
	ds = docTrang(t, k.goi(t, "GET", "/station-messages/mine", k.nv, nil))
	if !co(ds.Tin, traLoi.ID) || !co(ds.Tin, hoi.ID) || co(ds.Tin, tuTrang.ID) {
		t.Fatalf("hộp nv sai: %v", ids(ds.Tin))
	}
	ds = docTrang(t, k.goi(t, "GET", "/station-messages/mine", k.nv2, nil))
	if co(ds.Tin, hoi.ID) || co(ds.Tin, traLoi.ID) || !co(ds.Tin, tuTrang.ID) {
		t.Fatalf("nv2 đọc được tin riêng của nv: %v", ids(ds.Tin))
	}

	// Trả lời một tin mình không đọc được, hoặc tin không có ⇒ không có tin ấy; không ghi dòng.
	truocTin := k.soTin(t)
	tuChoi(t, k.veQuay(t, k.nv2, map[string]any{"submission_code": maGui(t), "work_code": "khac", "body": "test-dòm", "reply_to_message_id": hoi.ID}), http.StatusNotFound, "station_message_not_found", "")
	tuChoi(t, k.veQuay(t, k.nv, map[string]any{"submission_code": maGui(t), "work_code": "khac", "body": "test-không có", "reply_to_message_id": tuTrang.ID + 1000000}), http.StatusNotFound, "station_message_not_found", "")
	if k.soTin(t) != truocTin {
		t.Fatal("lời từ chối vẫn ghi tin")
	}

	if sau := k.soTienDo(t); sau != truocTienDo {
		t.Fatalf("tin về quầy mà tiến độ đổi: %s → %s", truocTienDo, sau)
	}
}

// --- Người nhận phải có tài khoản hoat_dong (ADR-137 điểm 4); hình sai bị từ chối trước quyền --------------------

func TestI038_NguoiNhanKhongHopLeVaHinhSai(t *testing.T) {
	k := dung(t)
	truocTin := k.soTin(t)
	gui := func(nguoi int64, them map[string]any) traVe {
		body := map[string]any{"submission_code": maGui(t), "recipient_person_id": k.nv, "work_code": "canh", "body": "test-nội dung"}
		for a, b := range them {
			if b == nil {
				delete(body, a)
			} else {
				body[a] = b
			}
		}
		return k.quayGui(t, nguoi, body)
	}

	for ten, nhan := range map[string]int64{"không tài khoản": k.khongTK, "bị khoá": k.biKhoa, "không có người": k.biKhoa + 1000000, "chính mình": k.quay} {
		r := gui(k.quay, map[string]any{"recipient_person_id": nhan})
		if r.status != http.StatusUnprocessableEntity || r.body["code"] != "message_recipient_invalid" {
			t.Fatalf("người nhận %s: muốn 422 message_recipient_invalid, nhận %d %s", ten, r.status, r.raw)
		}
	}
	tuChoi(t, gui(k.quay, map[string]any{"dining_table_id": k.ban + 1000000}), http.StatusNotFound, "dining_table_not_found", "")
	tuChoi(t, gui(k.quay, map[string]any{"reply_to_message_id": int64(9_000_000_000)}), http.StatusNotFound, "station_message_not_found", "")

	// Hình sai: invalid_request với field, xét trước quyền (người không đứng quầy cũng nhận lỗi hình).
	sai := []struct {
		them  map[string]any
		field string
	}{
		{map[string]any{"submission_code": nil}, "submission_code"},
		{map[string]any{"submission_code": "khong-phai-uuid"}, "submission_code"},
		{map[string]any{"submission_code": strings.ToUpper(maGui(t))}, "submission_code"},
		{map[string]any{"recipient_person_id": nil}, "recipient_person_id"},
		{map[string]any{"recipient_person_id": 0}, "recipient_person_id"},
		{map[string]any{"work_code": "nau_an"}, "work_code"},
		{map[string]any{"work_code": nil}, "work_code"},
		{map[string]any{"body": "   "}, "body"},
		{map[string]any{"body": nil}, "body"},
		{map[string]any{"body": strings.Repeat("ă", 501)}, "body"},
		{map[string]any{"dining_table_id": 0}, "dining_table_id"},
		{map[string]any{"reply_to_message_id": 0}, "reply_to_message_id"},
	}
	for _, s := range sai {
		tuChoi(t, gui(k.nv, s.them), http.StatusBadRequest, "invalid_request", s.field)
	}
	tuChoi(t, k.goi(t, "POST", "/station-messages", k.quay, "{không phải json"), http.StatusBadRequest, "invalid_request", "")
	tuChoi(t, k.veQuay(t, k.nv, map[string]any{"submission_code": maGui(t), "work_code": "khac", "body": ""}), http.StatusBadRequest, "invalid_request", "body")

	// Đúng hình mà không đứng quầy ⇒ từ chối quyền ở cửa gửi tới người.
	tuChoi(t, gui(k.nv, nil), http.StatusForbidden, "not_on_counter_duty", "")
	tuChoi(t, gui(k.chu, nil), http.StatusForbidden, "not_on_counter_duty", "")

	if k.soTin(t) != truocTin {
		t.Fatal("lời từ chối vẫn ghi tin")
	}
	if p := k.phat.lay(); len(p) != 0 {
		t.Fatalf("lời từ chối phát tín hiệu: %v", p)
	}

	// Biên: đúng 500 ký tự là nhận; khoảng trắng hai đầu giữ nguyên từng byte.
	r := gui(k.quay, map[string]any{"body": strings.Repeat("ă", 500)})
	canDat(t, r, http.StatusCreated)
	r = gui(k.quay, map[string]any{"body": "  test-có khoảng trắng  "})
	canDat(t, r, http.StatusCreated)
	if b := docTin(t, r.body).Body; b != "  test-có khoảng trắng  " {
		t.Fatalf("nội dung bị đổi: %q", b)
	}
}

// --- Gửi lại an toàn (ADR-137 điểm 6) --------------------------------------------------------------------------------

func TestI038_GuiLaiKhongNhanBanTin(t *testing.T) {
	k := dung(t)
	ma := maGui(t)
	than := map[string]any{"submission_code": ma, "recipient_person_id": k.nv, "work_code": "canh", "body": "test-múc canh", "dining_table_id": k.ban}
	r := k.quayGui(t, k.quay, than)
	canDat(t, r, http.StatusCreated)
	dau := docTin(t, r.body)
	truocTin := k.soTin(t)

	// Cùng người, cùng dấu, cùng nội dung ⇒ 200, đúng tin cũ, không thêm dòng.
	r = k.quayGui(t, k.quay, than)
	canDat(t, r, http.StatusOK)
	if lai := docTin(t, r.body); lai.ID != dau.ID || lai.Body != dau.Body {
		t.Fatalf("gửi lại muốn tin %d, nhận %+v", dau.ID, lai)
	}
	if k.soTin(t) != truocTin {
		t.Fatal("gửi lại thêm dòng")
	}
	ds := docTrang(t, k.goi(t, "GET", "/station-messages/mine", k.nv, nil))
	if len(ds.Tin) != 1 || ds.Tin[0].ID != dau.ID {
		t.Fatalf("người nhận thấy tin nhân bản: %v", ids(ds.Tin))
	}

	// Cùng dấu khác nội dung ⇒ 409, tin cũ giữ nguyên.
	khac := map[string]any{"submission_code": ma, "recipient_person_id": k.nv, "work_code": "canh", "body": "test-múc canh KHÁC", "dining_table_id": k.ban}
	tuChoi(t, k.quayGui(t, k.quay, khac), http.StatusConflict, "submission_code_conflict", "")
	// Dấu của người khác ⇒ 409, không lộ tin của người ấy.
	r = k.veQuay(t, k.nv2, map[string]any{"submission_code": ma, "work_code": "canh", "body": "test-múc canh"})
	tuChoi(t, r, http.StatusConflict, "submission_code_conflict", "")
	if strings.Contains(r.raw, "test-múc canh") || strings.Contains(r.raw, "station_message_id") {
		t.Fatalf("lời từ chối lộ tin của người khác: %s", r.raw)
	}
	if k.soTin(t) != truocTin {
		t.Fatal("dấu trùng vẫn thêm dòng")
	}

	// Quyền xét trước dấu: rời quầy rồi gửi lại cùng dấu vẫn bị từ chối.
	k.so(t, "UPDATE shop.counter_duty SET ended_at = now() WHERE person_id = $1 AND ended_at IS NULL RETURNING person_id", k.quay)
	tuChoi(t, k.quayGui(t, k.quay, than), http.StatusForbidden, "not_on_counter_duty", "")
}

// --- Chia trang hai đường đọc ------------------------------------------------------------------------------------

func TestI038_ChiaTrangHaiDuongDocTheoBeforeID(t *testing.T) {
	k := dung(t)
	var gui []int64
	for i := 0; i < 3; i++ {
		r := k.quayGui(t, k.quay, map[string]any{"submission_code": maGui(t), "recipient_person_id": k.nv, "work_code": "khac", "body": fmt.Sprintf("test-tin %d", i)})
		canDat(t, r, http.StatusCreated)
		gui = append(gui, r.so(t, "station_message_id"))
	}
	for _, duong := range []struct {
		path  string
		nguoi int64
	}{{"/station-messages/mine", k.nv}, {"/station-messages/counter", k.quay}} {
		p := docTrang(t, k.goi(t, "GET", duong.path+"?limit=2", duong.nguoi, nil))
		if len(p.Tin) != 2 || p.Tin[0].ID != gui[2] || p.Tin[1].ID != gui[1] || p.Tiep == nil || *p.Tiep != gui[1] {
			t.Fatalf("%s trang 1 sai: %v tiếp %v (gửi %v)", duong.path, ids(p.Tin), p.Tiep, gui)
		}
		p = docTrang(t, k.goi(t, "GET", fmt.Sprintf("%s?limit=2&before_id=%d", duong.path, *p.Tiep), duong.nguoi, nil))
		if len(p.Tin) == 0 || p.Tin[0].ID != gui[0] {
			t.Fatalf("%s trang 2 sai: %v", duong.path, ids(p.Tin))
		}
		for _, q := range []struct{ q, field string }{{"limit=0", "limit"}, {"limit=51", "limit"}, {"limit=abc", "limit"}, {"before_id=0", "before_id"}, {"before_id=x", "before_id"}} {
			tuChoi(t, k.goi(t, "GET", duong.path+"?"+q.q, duong.nguoi, nil), http.StatusBadRequest, "invalid_request", q.field)
		}
	}
	// Hộp cá nhân hết tin cũ hơn ⇒ next_before_id null.
	p := docTrang(t, k.goi(t, "GET", "/station-messages/mine?limit=3", k.nv, nil))
	if len(p.Tin) != 3 || p.Tiep != nil {
		t.Fatalf("hết tin mà còn trang tiếp: %v tiếp %v", ids(p.Tin), p.Tiep)
	}
	p = docTrang(t, k.goi(t, "GET", "/station-messages/mine", k.nv, nil))
	if len(p.Tin) != 3 {
		t.Fatalf("mặc định phải trả đủ 3 tin (limit 20): %v", ids(p.Tin))
	}
}

// --- Khách và người không phiên bị từ chối ở cả bốn cửa (ADR-137 điểm 5) -------------------------------------------

func TestI038_KhongPhienVaCookieKhachBiTuChoiOCaBonCua(t *testing.T) {
	k := dung(t)
	tokenKhach := phienKhach(t, k)
	cua := []struct {
		method, path string
		body         any
	}{
		{"POST", "/station-messages", map[string]any{"submission_code": maGui(t), "recipient_person_id": k.nv, "work_code": "khac", "body": "test-khách"}},
		{"POST", "/station-messages/to-counter", map[string]any{"submission_code": maGui(t), "work_code": "khac", "body": "test-khách"}},
		{"GET", "/station-messages/mine", nil},
		{"GET", "/station-messages/counter", nil},
	}
	truocTin := k.soTin(t)
	for _, c := range cua {
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
		tuChoi(t, k.goiVoi(t, c.method, c.path, c.body, func(req *http.Request) {
			req.AddCookie(&http.Cookie{Name: authz.CookieKhach, Value: tokenKhach})
		}), http.StatusUnauthorized, "unauthenticated", "")
	}
	if k.soTin(t) != truocTin {
		t.Fatal("khách hoặc không phiên ghi được tin")
	}
}

// phienKhach dựng một phiên khách còn hiệu lực bằng dòng thật (cùng cách test CHAT-34).
func phienKhach(t *testing.T, k khung) string {
	t.Helper()
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	token := base64.RawURLEncoding.EncodeToString(b)
	h := sha256.Sum256([]byte(token))
	email := fmt.Sprintf("test-khach-hoptin-%d@example.test", time.Now().UnixNano())
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
