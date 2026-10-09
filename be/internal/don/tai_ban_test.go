// Test luồng ăn tại bàn qua cửa (P3-07, ADR-087; I-001 · I-002 · I-003 · I-006 · I-016 · I-017 ·
// I-024, và lối vào của khách QR — I-023). Viết TRƯỚC khi có cửa — Claude viết, Codex làm cho xanh
// mà không sửa điều kiện kiểm nào. Mọi lời gọi đi qua ĐƯỜNG GỌI HTTP của hợp đồng (ADR-082 điểm 2:
// quyền và giao dịch ở trong cửa); database được đọc lại bằng kết nối chủ lược đồ sau mỗi lời từ chối.
//
// Hai thứ test dựng tay bằng kết nối chủ lược đồ vì cửa của chúng thuộc lát sau, không phải vì cửa
// của lát này được phép bỏ qua: đơn tới Hoàn thành (cửa ghi đã phục vụ — P3-10) và bàn ghép vào phiên
// (cửa ghép bàn — chỗ trống có tên ở ADR-087).
package don_test

import (
	"fmt"
	"net/http"
	"sort"
	"strings"
	"sync"
	"testing"
)

// --- khung của luồng tại bàn -------------------------------------------------------------------

type traLoi struct {
	status int
	body   map[string]any
}

func (r traLoi) so(t *testing.T, key string) int64 {
	t.Helper()
	v, ok := r.body[key].(float64)
	if !ok {
		t.Fatalf("thiếu trường số %q: %d %v", key, r.status, r.body)
	}
	return int64(v)
}

func (r traLoi) chu(key string) string {
	s, _ := r.body[key].(string)
	return s
}

func (k khung) post(t *testing.T, path string, nguoi int64, body any) traLoi {
	t.Helper()
	status, out := k.goi(t, "POST", path, nguoi, body)
	return traLoi{status, out}
}

func canMa(t *testing.T, r traLoi, status int, code, field string) {
	t.Helper()
	if r.status != status || r.chu("code") != code || (field != "" && r.chu("field") != field) {
		t.Fatalf("muốn %d %s field=%q, nhận %d %v", status, code, field, r.status, r.body)
	}
}

func canDat(t *testing.T, r traLoi, status int) {
	t.Helper()
	if r.status != status {
		t.Fatalf("muốn %d, nhận %d %v", status, r.status, r.body)
	}
}

type canh struct {
	khung
	quay int64 // người đang đứng quầy
	chu  int64 // chủ quán, KHÔNG đứng quầy
	mon  caGia // một ca §4.8 hợp lệ, đọc lúc chạy
}

func dungBan(t *testing.T) canh {
	t.Helper()
	k := dung(t)
	c := canh{khung: k, mon: caSo(t, k.caCoMa(t), 2)}
	if c.mon.tuChoi {
		t.Fatal("ca 2 của §4.8 phải là một tổ hợp hợp lệ")
	}
	c.quay = k.nguoi(t, "quầy", false)
	k.vaoQuay(t, c.quay)
	c.chu = k.nguoi(t, "chủ quán", true)
	return c
}

func (c canh) banMoi(t *testing.T, ten string) int64 {
	t.Helper()
	return c.id(t, "INSERT INTO shop.dining_table (label) VALUES ($1) RETURNING id", fmt.Sprintf("%s · %s", ten, t.Name()))
}

func (c canh) dong(demVe bool) map[string]any {
	ids := c.mon.chonIDs
	if ids == nil {
		ids = []int64{}
	}
	return map[string]any{"menu_item_id": c.mon.monID, "quantity": c.mon.soSuat, "option_ids": ids, "is_takeaway": demVe}
}

// datHo: người đứng quầy đặt hộ tại bàn — POST /table-orders.
func (c canh) datHo(t *testing.T, nguoi, ban int64, dau string, dong ...map[string]any) traLoi {
	t.Helper()
	return c.post(t, "/table-orders", nguoi, map[string]any{"submission_code": dau, "dining_table_id": ban, "lines": dong})
}

// goiQR: khách quét mã của bàn — POST /qr-codes/{code}/orders, không người, không bàn.
func (c canh) goiQR(t *testing.T, ma, dau string, dong ...map[string]any) traLoi {
	t.Helper()
	return c.post(t, "/qr-codes/"+ma+"/orders", 0, map[string]any{"submission_code": dau, "lines": dong})
}

func (c canh) capMaQR(t *testing.T, ban int64) string {
	t.Helper()
	r := c.post(t, fmt.Sprintf("/dining-tables/%d/qr-code", ban), c.chu, map[string]any{})
	canDat(t, r, http.StatusCreated)
	return r.chu("code")
}

func (c canh) duyet(t *testing.T, nguoi, don int64) traLoi {
	t.Helper()
	return c.post(t, fmt.Sprintf("/orders/%d/approval", don), nguoi, map[string]any{})
}

func (c canh) tuChoi(t *testing.T, nguoi, don int64) traLoi {
	t.Helper()
	return c.post(t, fmt.Sprintf("/orders/%d/rejection", don), nguoi, map[string]any{})
}

func (c canh) tinhTien(t *testing.T, nguoi, phien int64) traLoi {
	t.Helper()
	return c.post(t, fmt.Sprintf("/table-sessions/%d/bill-request", phien), nguoi, map[string]any{})
}

func (c canh) dongPhien(t *testing.T, nguoi, phien int64, tienMat, chuyenKhoan, no int64, nguoiNo string) traLoi {
	t.Helper()
	body := map[string]any{"cash_vnd": tienMat, "transfer_vnd": chuyenKhoan, "debt_vnd": no}
	if nguoiNo != "" {
		body["debtor_name"] = nguoiNo
	}
	return c.post(t, fmt.Sprintf("/table-sessions/%d/closing", phien), nguoi, body)
}

func (c canh) donBan(t *testing.T, nguoi, ban int64) traLoi {
	t.Helper()
	return c.post(t, fmt.Sprintf("/dining-tables/%d/cleaning", ban), nguoi, map[string]any{})
}

// xong: đơn tới Hoàn thành — dựng tay; cửa ghi đã phục vụ là của P3-10.
func (c canh) xong(t *testing.T, don int64) {
	t.Helper()
	if _, err := c.owner.Exec(c.ctx, "UPDATE shop.sales_order SET status = 'completed' WHERE id = $1", don); err != nil {
		t.Fatal(err)
	}
}

// ghepTay: bàn trống nhập vào phiên đang có — dựng tay; cửa ghép bàn chưa có (ADR-087 chỗ trống).
func (c canh) ghepTay(t *testing.T, phien, ban int64) {
	t.Helper()
	c.id(t, "INSERT INTO shop.table_session_member (table_session_id, dining_table_id) VALUES ($1, $2) RETURNING id", phien, ban)
}

func (c canh) docChu(t *testing.T, sql string, args ...any) string {
	t.Helper()
	var s string
	if err := c.owner.QueryRow(c.ctx, sql, args...).Scan(&s); err != nil {
		t.Fatalf("%s: %v", sql, err)
	}
	return s
}

func (c canh) docSo(t *testing.T, sql string, args ...any) int64 {
	t.Helper()
	var n int64
	if err := c.owner.QueryRow(c.ctx, sql, args...).Scan(&n); err != nil {
		t.Fatalf("%s: %v", sql, err)
	}
	return n
}

func (c canh) trangThaiDon(t *testing.T, don int64) string {
	t.Helper()
	return c.docChu(t, "SELECT status FROM shop.sales_order WHERE id = $1", don)
}

func (c canh) trangThaiPhien(t *testing.T, phien int64) string {
	t.Helper()
	return c.docChu(t, "SELECT status FROM shop.table_session WHERE id = $1", phien)
}

// anhPhien: mọi thứ của một phiên mà lát này ghi — trạng thái, bàn (đã đóng? đã dọn?), đơn và trạng
// thái của đơn, hoá đơn. Một lời từ chối không được đổi chữ nào.
func (c canh) anhPhien(t *testing.T, phien int64) string {
	t.Helper()
	return c.docChu(t, `SELECT format('phiên %s %s | bàn %s | đơn %s | hoá đơn %s', s.id, s.status,
		(SELECT string_agg(format('%s:đóng=%s:dọn=%s', m.dining_table_id, m.session_closed, m.cleaned_at IS NOT NULL), ','
		         ORDER BY m.dining_table_id) FROM shop.table_session_member m WHERE m.table_session_id = s.id),
		(SELECT coalesce(string_agg(format('%s:%s', o.id, o.status), ',' ORDER BY o.id), '-')
		   FROM shop.sales_order o WHERE o.table_session_id = s.id),
		(SELECT coalesce(string_agg(format('%s=%s+%s+nợ %s', b.due_vnd, b.cash_vnd, b.transfer_vnd, b.debt_vnd), ','), '-')
		   FROM shop.bill b WHERE b.table_session_id = s.id))
		FROM shop.table_session s WHERE s.id = $1`, phien)
}

// soPhienChuaDong: số phiên chưa đóng mà bàn đang thuộc — I-001 đòi ≤ 1.
func (c canh) soPhienChuaDong(t *testing.T, ban int64) int64 {
	t.Helper()
	return c.docSo(t, "SELECT count(*) FROM shop.table_session_member WHERE dining_table_id = $1 AND NOT session_closed", ban)
}

func (c canh) soDongCuaBan(t *testing.T, ban int64) int64 {
	t.Helper()
	return c.docSo(t, "SELECT count(*) FROM shop.table_session_member WHERE dining_table_id = $1", ban)
}

// trangThaiBan đọc qua GET /dining-tables — trạng thái của cái bàn đọc ra từ chi tiết (I-003).
func (c canh) trangThaiBan(t *testing.T, ban int64) string {
	t.Helper()
	status, out := c.goi(t, "GET", "/dining-tables", 0, nil)
	if status != http.StatusOK {
		t.Fatalf("GET /dining-tables: %d %v", status, out)
	}
	ds, _ := out["tables"].([]any)
	for _, x := range ds {
		m, _ := x.(map[string]any)
		if id, _ := m["dining_table_id"].(float64); int64(id) == ban {
			s, _ := m["state"].(string)
			return s
		}
	}
	t.Fatalf("GET /dining-tables không có bàn %d", ban)
	return ""
}

// phienDangPhucVu: một bàn mới, một lượt đặt hộ ⇒ phiên Đang phục vụ. Trả bàn, phiên, đơn, tổng.
func (c canh) phienDangPhucVu(t *testing.T, ten string) (ban, phien, don, tong int64) {
	t.Helper()
	ban = c.banMoi(t, ten)
	r := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false))
	canDat(t, r, http.StatusCreated)
	return ban, r.so(t, "table_session_id"), r.so(t, "sales_order_id"), r.so(t, "total_vnd")
}

// --- lượt gọi đầu mở phiên; kênh quyết trạng thái đầu (I-016 · I-001) --------------------------

func TestI016_LuotGoiDauMoPhienVaKenhQuyetTrangThai(t *testing.T) {
	c := dungBan(t)
	banA := c.banMoi(t, "A")
	if s := c.trangThaiBan(t, banA); s != "empty" {
		t.Fatalf("bàn mới: muốn empty, nhận %s", s)
	}
	r := c.datHo(t, c.quay, banA, dauLanGui(t), c.dong(false))
	canDat(t, r, http.StatusCreated)
	phienA, donA := r.so(t, "table_session_id"), r.so(t, "sales_order_id")
	// P3-10 đổi có chủ ý (ADR-090 điểm 1): đơn đã xác nhận nổ ngay sang Đang thực hiện, cùng giao dịch.
	if r.chu("channel_code") != "staff_pos" || r.chu("status") != "in_progress" || r.so(t, "dining_table_id") != banA {
		t.Fatalf("đặt hộ: muốn staff_pos · in_progress · bàn %d, nhận %v", banA, r.body)
	}
	if s := c.trangThaiPhien(t, phienA); s != "serving" {
		t.Fatalf("đơn đầu đã xác nhận ⇒ phiên Đang phục vụ (§5.3), nhận %s", s)
	}
	if s := c.trangThaiBan(t, banA); s != "in_session" {
		t.Fatalf("bàn có phiên: muốn in_session, nhận %s", s)
	}
	t.Logf("đặt hộ ở bàn trống ⇒ %s", c.anhPhien(t, phienA))

	banB := c.banMoi(t, "B")
	ma := c.capMaQR(t, banB)
	q := c.goiQR(t, ma, dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	phienB, donB := q.so(t, "table_session_id"), q.so(t, "sales_order_id")
	if q.chu("channel_code") != "qr_table" || q.chu("status") != "pending_confirmation" || q.so(t, "dining_table_id") != banB {
		t.Fatalf("khách QR: muốn qr_table · pending_confirmation · bàn %d, nhận %v", banB, q.body)
	}
	if s := c.trangThaiPhien(t, phienB); s != "open" {
		t.Fatalf("đơn chờ duyệt chưa xuống bếp ⇒ phiên còn Mở, nhận %s", s)
	}
	if got := c.docSo(t, `SELECT count(*) FROM shop.sales_order o JOIN shop.qr_code q ON q.id = o.qr_code_id
		WHERE o.id = $1 AND q.code = $2 AND q.replaced_at IS NULL`, donB, ma); got != 1 {
		t.Fatal("lượt gọi QR phải mang đúng mã hiện hành đã dùng")
	}
	d := c.duyet(t, c.quay, donB)
	canDat(t, d, http.StatusOK)
	if d.chu("status") != "in_progress" || d.chu("table_session_status") != "serving" || c.trangThaiPhien(t, phienB) != "serving" {
		t.Fatalf("duyệt đơn đầu ⇒ đơn nổ sang Đang thực hiện (ADR-090), phiên Đang phục vụ; nhận %v", d.body)
	}
	t.Logf("QR ở bàn trống ⇒ phiên mở, chờ duyệt; duyệt ⇒ %s · %s", c.trangThaiDon(t, donB), c.anhPhien(t, phienB))
	if c.trangThaiDon(t, donA) != "in_progress" {
		t.Fatal("đơn A không được đổi")
	}
}

// --- I-001: hai máy bấm cùng lúc ở một bàn trống ⇒ một phiên ------------------------------------

func TestI001_LuotGoiDauChenNhauMotPhien(t *testing.T) {
	c := dungBan(t)
	ban := c.banMoi(t, "bàn")
	const n = 8
	var wg sync.WaitGroup
	ra := make([]traLoi, n)
	batDau := make(chan struct{})
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(i int, dau string) {
			defer wg.Done()
			<-batDau
			ra[i] = c.datHo(t, c.quay, ban, dau, c.dong(false))
		}(i, dauLanGui(t))
	}
	close(batDau)
	wg.Wait()
	phien := map[int64]bool{}
	for _, r := range ra {
		canDat(t, r, http.StatusCreated)
		phien[r.so(t, "table_session_id")] = true
	}
	if len(phien) != 1 || c.soPhienChuaDong(t, ban) != 1 {
		t.Fatalf("%d lượt gọi đầu chen nhau: %d phiên trả về, %d phiên chưa đóng của bàn", n, len(phien), c.soPhienChuaDong(t, ban))
	}
	for p := range phien {
		if got := c.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE table_session_id = $1", p); got != n {
			t.Fatalf("phiên %d có %d đơn, muốn %d", p, got, n)
		}
		t.Logf("%d lượt gọi đầu chen nhau ở một bàn trống ⇒ %s", n, c.anhPhien(t, p))
	}
}

// --- I-024: một lần gửi, nhiều nhất một đơn --------------------------------------------------------

func TestI024_GuiLaiCungDauBaLanMotDon(t *testing.T) {
	c := dungBan(t)
	ban := c.banMoi(t, "bàn")
	dau := dauLanGui(t)
	dau1 := c.datHo(t, c.quay, ban, dau, c.dong(false))
	canDat(t, dau1, http.StatusCreated)
	id, tong := dau1.so(t, "sales_order_id"), dau1.so(t, "total_vnd")
	for i := 2; i <= 3; i++ {
		r := c.datHo(t, c.quay, ban, dau, c.dong(false))
		canDat(t, r, http.StatusOK)
		if r.so(t, "sales_order_id") != id || r.so(t, "total_vnd") != tong || r.so(t, "table_session_id") != dau1.so(t, "table_session_id") {
			t.Fatalf("lần gửi %d trả đơn khác: %v, lần đầu %v", i, r.body, dau1.body)
		}
	}
	if got := c.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE submission_code = $1", dau); got != 1 {
		t.Fatalf("gửi ba lần cùng dấu ⇒ %d đơn", got)
	}
	// Gửi lại sau khi đơn đã đổi trạng thái vẫn nhận lại đúng đơn ấy (01-hop-dong-api.md §8).
	c.xong(t, id)
	r := c.datHo(t, c.quay, ban, dau, c.dong(false))
	canDat(t, r, http.StatusOK)
	if r.so(t, "sales_order_id") != id || r.chu("status") != "completed" {
		t.Fatalf("gửi lại sau khi đơn Hoàn thành: %v", r.body)
	}
	t.Logf("cùng dấu gửi bốn lần (201, 200, 200, 200 sau khi đơn Hoàn thành) ⇒ một đơn %d", id)
}

func TestI024_CungDauKhacNoiDungBiTuChoi(t *testing.T) {
	c := dungBan(t)
	ban, khac := c.banMoi(t, "bàn"), c.banMoi(t, "bàn khác")
	dau := dauLanGui(t)
	r := c.datHo(t, c.quay, ban, dau, c.dong(false))
	canDat(t, r, http.StatusCreated)
	id, phien := r.so(t, "sales_order_id"), r.so(t, "table_session_id")
	anh, anhDon := c.anhPhien(t, phien), c.anhDong(t, id)

	nhieuHon := c.dong(false)
	nhieuHon["quantity"] = c.mon.soSuat + 1
	for ten, thu := range map[string]traLoi{
		"số suất khác":    c.datHo(t, c.quay, ban, dau, nhieuHon),
		"dấu đem về khác": c.datHo(t, c.quay, ban, dau, c.dong(true)),
		"thêm một dòng":   c.datHo(t, c.quay, ban, dau, c.dong(false), c.dong(false)),
		"bàn khác":        c.datHo(t, c.quay, khac, dau, c.dong(false)),
	} {
		canMa(t, thu, http.StatusConflict, "submission_code_conflict", "")
		t.Logf("cùng dấu, %s ⇒ submission_code_conflict", ten)
	}
	if c.anhPhien(t, phien) != anh || c.anhDong(t, id) != anhDon || c.soDongCuaBan(t, khac) != 0 {
		t.Fatal("lời từ chối của dấu trùng mà đơn cũ hay bàn khác đã đổi")
	}
	if got := c.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE submission_code = $1", dau); got != 1 {
		t.Fatalf("dấu %s mang %d đơn", dau, got)
	}
}

// Nội dung giống hệt mà hai dấu là hai lần gửi thật — cửa không so nội dung để đoán trùng.
func TestI024_NoiDungGiongHetHaiDauLaHaiDon(t *testing.T) {
	c := dungBan(t)
	ban := c.banMoi(t, "bàn")
	a := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false))
	b := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false))
	canDat(t, a, http.StatusCreated)
	canDat(t, b, http.StatusCreated)
	if a.so(t, "sales_order_id") == b.so(t, "sales_order_id") || a.so(t, "table_session_id") != b.so(t, "table_session_id") {
		t.Fatalf("hai dấu, nội dung giống hệt: muốn hai đơn cùng một phiên, nhận %v và %v", a.body, b.body)
	}
	t.Logf("hai dấu, nội dung giống hệt ⇒ %s", c.anhPhien(t, a.so(t, "table_session_id")))
}

func TestI024_GuiLaiChenNhauMotDon(t *testing.T) {
	c := dungBan(t)
	ban := c.banMoi(t, "bàn")
	dau := dauLanGui(t)
	const n = 5
	var wg sync.WaitGroup
	ra := make([]traLoi, n)
	batDau := make(chan struct{})
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			<-batDau
			ra[i] = c.datHo(t, c.quay, ban, dau, c.dong(false))
		}(i)
	}
	close(batDau)
	wg.Wait()
	var tao int
	don := map[int64]bool{}
	for _, r := range ra {
		if r.status == http.StatusCreated {
			tao++
		} else {
			canDat(t, r, http.StatusOK)
		}
		don[r.so(t, "sales_order_id")] = true
	}
	got := c.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE submission_code = $1", dau)
	t.Logf("%d lần gửi cùng dấu chen nhau ⇒ %d lần 201, %d đơn trả về, %d đơn trong database", n, tao, len(don), got)
	if tao != 1 || len(don) != 1 || got != 1 {
		t.Fatal("gửi lại chen nhau phải ra đúng một đơn, một lần tạo")
	}
}

// --- I-002: cửa quyết lượt gọi thuộc đơn vị tính tiền nào ------------------------------------------

func TestI002_GoiThemLucChoThanhToanVaoCungPhien(t *testing.T) {
	c := dungBan(t)
	ban, phien, don1, tong1 := c.phienDangPhucVu(t, "bàn")

	// Người gọi không chọn phiên: gửi kèm một phiên ⇒ từ chối, không dùng.
	sai := c.post(t, "/table-orders", c.quay, map[string]any{"submission_code": dauLanGui(t), "dining_table_id": ban,
		"table_session_id": phien, "lines": []any{c.dong(false)}})
	canMa(t, sai, http.StatusBadRequest, "invalid_request", "table_session_id")

	c.xong(t, don1)
	tt := c.tinhTien(t, c.quay, phien)
	canDat(t, tt, http.StatusOK)
	if tt.chu("status") != "awaiting_payment" || tt.so(t, "due_vnd") != tong1 {
		t.Fatalf("tính tiền: muốn awaiting_payment · %d, nhận %v", tong1, tt.body)
	}
	them := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false))
	canDat(t, them, http.StatusCreated)
	if them.so(t, "table_session_id") != phien || c.trangThaiPhien(t, phien) != "serving" {
		t.Fatalf("gọi thêm lúc Chờ thanh toán ⇒ cùng phiên %d, phiên về Đang phục vụ; nhận %v, phiên %s",
			phien, them.body, c.trangThaiPhien(t, phien))
	}
	c.xong(t, them.so(t, "sales_order_id"))
	tt = c.tinhTien(t, c.quay, phien)
	canDat(t, tt, http.StatusOK)
	tong := tong1 + them.so(t, "total_vnd")
	dong := c.dongPhien(t, c.quay, phien, tong, 0, 0, "")
	canDat(t, dong, http.StatusCreated)
	if dong.so(t, "due_vnd") != tong || tt.so(t, "due_vnd") != tong {
		t.Fatalf("hoá đơn phải cộng cả lượt gọi thêm: muốn %d, tính tiền %d, đóng %d", tong, tt.so(t, "due_vnd"), dong.so(t, "due_vnd"))
	}
	if got := c.docSo(t, "SELECT count(*) FROM shop.bill WHERE table_session_id = $1", phien); got != 1 {
		t.Fatalf("phiên có %d hoá đơn", got)
	}
	t.Logf("gọi thêm lúc Chờ thanh toán ⇒ %s", c.anhPhien(t, phien))
}

func TestI002_BanGhepGoiVaoPhienCuaNhom(t *testing.T) {
	c := dungBan(t)
	_, phien, donA, tongA := c.phienDangPhucVu(t, "bàn A")
	banB := c.banMoi(t, "bàn B")
	c.ghepTay(t, phien, banB)
	b := c.datHo(t, c.quay, banB, dauLanGui(t), c.dong(true))
	canDat(t, b, http.StatusCreated)
	if b.so(t, "table_session_id") != phien {
		t.Fatalf("bàn ghép gọi món ⇒ vào phiên của nhóm %d, nhận %v", phien, b.body)
	}
	c.xong(t, donA)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	tong := tongA + b.so(t, "total_vnd")
	truoc := c.anhPhien(t, phien)
	canMa(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, ""), http.StatusConflict, "table_session_has_open_orders", "")
	if c.anhPhien(t, phien) != truoc {
		t.Fatal("đóng bị từ chối mà phiên đã đổi")
	}
	c.xong(t, b.so(t, "sales_order_id"))
	d := c.dongPhien(t, c.quay, phien, tong, 0, 0, "")
	canDat(t, d, http.StatusCreated)
	if d.so(t, "due_vnd") != tong {
		t.Fatalf("hoá đơn nhóm ghép: muốn %d, nhận %d", tong, d.so(t, "due_vnd"))
	}
	t.Logf("nhóm ghép: đơn của bàn B chặn đóng tới khi xong; đóng ⇒ %s", c.anhPhien(t, phien))
}

// --- I-006: suất đem về của khách ngồi bàn thuộc phiên bàn ------------------------------------------

func TestI006_SuatDemVeThuocPhienBan(t *testing.T) {
	c := dungBan(t)
	ban := c.banMoi(t, "bàn")
	donLe := c.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE table_session_id IS NULL")
	r := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false), c.dong(true))
	canDat(t, r, http.StatusCreated)
	don, phien := r.so(t, "sales_order_id"), r.so(t, "table_session_id")
	demVe := c.docChu(t, `SELECT string_agg(is_takeaway::text, ',' ORDER BY id) FROM shop.order_line WHERE sales_order_id = $1`, don)
	if demVe != "false,true" {
		t.Fatalf("hai dòng của một lượt gọi: muốn dấu đem về false,true, nhận %s", demVe)
	}
	if sau := c.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE table_session_id IS NULL"); sau != donLe {
		t.Fatalf("suất đem về sinh đơn lẻ: %d → %d", donLe, sau)
	}
	c.xong(t, don)
	tt := c.tinhTien(t, c.quay, phien)
	canDat(t, tt, http.StatusOK)
	if tt.so(t, "due_vnd") != r.so(t, "total_vnd") {
		t.Fatalf("suất đem về phải tính vào phiên: tổng lượt gọi %d, tính tiền %d", r.so(t, "total_vnd"), tt.so(t, "due_vnd"))
	}
	t.Logf("một dòng ăn tại chỗ + một dòng đem về ⇒ một đơn %d của phiên %d, dấu %s, tính tiền %d", don, phien, demVe, tt.so(t, "due_vnd"))
}

// --- I-016: chuyển ngoài bảng bị từ chối; chuyển trong bảng để lại vết --------------------------------

func TestI016_ChuyenNgoaiBangBiTuChoi(t *testing.T) {
	c := dungBan(t)
	_, phien, donQuay, _ := c.phienDangPhucVu(t, "bàn")
	anh := c.anhPhien(t, phien)
	canMa(t, c.duyet(t, c.quay, donQuay), http.StatusConflict, "order_transition_not_allowed", "")
	canMa(t, c.tuChoi(t, c.quay, donQuay), http.StatusConflict, "order_transition_not_allowed", "")
	canMa(t, c.dongPhien(t, c.quay, phien, 1, 0, 0, ""), http.StatusConflict, "table_session_transition_not_allowed", "")
	if c.anhPhien(t, phien) != anh {
		t.Fatal("lời từ chối của bảng chuyển mà phiên đã đổi")
	}
	t.Logf("Đã xác nhận → duyệt/từ chối, Đang phục vụ → Đã đóng ⇒ từ chối; %s", anh)

	banQR := c.banMoi(t, "bàn QR")
	q := c.goiQR(t, c.capMaQR(t, banQR), dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	donQR, phienQR := q.so(t, "sales_order_id"), q.so(t, "table_session_id")
	anhQR := c.anhPhien(t, phienQR)
	canMa(t, c.tinhTien(t, c.quay, phienQR), http.StatusConflict, "table_session_transition_not_allowed", "")
	canMa(t, c.dongPhien(t, c.quay, phienQR, 0, 0, 0, ""), http.StatusConflict, "table_session_transition_not_allowed", "")
	if c.anhPhien(t, phienQR) != anhQR {
		t.Fatal("phiên Mở bị đổi bởi một chuyển ngoài bảng")
	}
	tc := c.tuChoi(t, c.quay, donQR)
	canDat(t, tc, http.StatusOK)
	if tc.chu("status") != "cancelled" || c.trangThaiPhien(t, phienQR) != "open" {
		t.Fatalf("từ chối đơn chờ duyệt ⇒ Huỷ, phiên không đổi; nhận %v", tc.body)
	}
	canMa(t, c.duyet(t, c.quay, donQR), http.StatusConflict, "order_transition_not_allowed", "")
	canMa(t, c.tuChoi(t, c.quay, donQR), http.StatusConflict, "order_transition_not_allowed", "")
	if c.trangThaiDon(t, donQR) != "cancelled" {
		t.Fatal("đơn đã Huỷ bị đổi")
	}

	canMa(t, c.duyet(t, c.quay, 1<<40), http.StatusNotFound, "sales_order_not_found", "")
	canMa(t, c.tinhTien(t, c.quay, 1<<40), http.StatusNotFound, "table_session_not_found", "")
	canMa(t, c.dongPhien(t, c.quay, 1<<40, 0, 0, 0, ""), http.StatusNotFound, "table_session_not_found", "")
	t.Logf("Mở → Chờ thanh toán/Đã đóng, Huỷ → duyệt/từ chối ⇒ từ chối; %s", c.anhPhien(t, phienQR))
}

// Chuyển trạng thái do người bấm để lại vết bản trước · bản sau · người · lý do — nguyên liệu của phép
// đối chiếu I-016 (dựng lại lịch sử chuyển trạng thái từ vết).
func TestI016_ChuyenTrangThaiDeLaiVet(t *testing.T) {
	c := dungBan(t)
	ban := c.banMoi(t, "bàn")
	q := c.goiQR(t, c.capMaQR(t, ban), dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	don, phien := q.so(t, "sales_order_id"), q.so(t, "table_session_id")
	canDat(t, c.duyet(t, c.quay, don), http.StatusOK)
	c.xong(t, don)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	vet := func(bang string, id int64, tu, den string) int64 {
		return c.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = $1 AND target_row = $2
			AND before_image ->> 'status' = $3 AND after_image ->> 'status' = $4 AND person_id = $5 AND btrim(reason) <> ''`,
			bang, id, tu, den, c.quay)
	}
	for _, v := range []struct {
		bang    string
		id      int64
		tu, den string
	}{
		{"sales_order", don, "pending_confirmation", "confirmed"},
		{"table_session", phien, "open", "serving"},
		{"table_session", phien, "serving", "awaiting_payment"},
	} {
		if n := vet(v.bang, v.id, v.tu, v.den); n != 1 {
			t.Fatalf("%s %d %s → %s: %d vết mang người quầy, muốn 1", v.bang, v.id, v.tu, v.den, n)
		}
		t.Logf("vết %s %d: %s → %s, người %d", v.bang, v.id, v.tu, v.den, c.quay)
	}
}

// --- I-017: đóng phiên — chặn bởi món, không chặn bởi tiền; một giao dịch -----------------------------

func TestI017_DongPhienBiChanBoiMonChuaXong(t *testing.T) {
	c := dungBan(t)
	ban, phien, don1, tong1 := c.phienDangPhucVu(t, "bàn")
	c.xong(t, don1)
	// Một lượt gọi QR chờ duyệt cũng là món chưa xong — nó vẫn thuộc phiên (§5.2).
	q := c.goiQR(t, c.capMaQR(t, ban), dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	if q.so(t, "table_session_id") != phien {
		t.Fatalf("khách QR ở bàn đang có phiên ⇒ vào phiên ấy; nhận %v", q.body)
	}
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	truoc := c.anhPhien(t, phien)
	canMa(t, c.dongPhien(t, c.quay, phien, tong1, 0, 0, ""), http.StatusConflict, "table_session_has_open_orders", "")
	if c.anhPhien(t, phien) != truoc {
		t.Fatal("đóng bị từ chối mà phiên, bàn hay hoá đơn đã đổi")
	}
	t.Logf("còn một đơn Chờ xác nhận ⇒ table_session_has_open_orders; %s", truoc)
	canDat(t, c.tuChoi(t, c.quay, q.so(t, "sales_order_id")), http.StatusOK)
	d := c.dongPhien(t, c.quay, phien, 0, tong1, 0, "")
	canDat(t, d, http.StatusCreated)
	if d.so(t, "due_vnd") != tong1 {
		t.Fatalf("đơn Huỷ không vào hoá đơn: muốn %d, nhận %d", tong1, d.so(t, "due_vnd"))
	}
	t.Logf("từ chối đơn chờ duyệt rồi đóng ⇒ %s", c.anhPhien(t, phien))
}

func TestI017_TienChuaThuKhongChanDong(t *testing.T) {
	c := dungBan(t)
	ban, phien, don, tong := c.phienDangPhucVu(t, "bàn")
	c.xong(t, don)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	truoc := c.anhPhien(t, phien)
	canMa(t, c.dongPhien(t, c.quay, phien, tong-1, 0, 0, ""), http.StatusUnprocessableEntity, "payment_parts_mismatch", "")
	canMa(t, c.dongPhien(t, c.quay, phien, 0, 0, tong, ""), http.StatusUnprocessableEntity, "debtor_name_mismatch", "")
	canMa(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, "người không nợ"), http.StatusUnprocessableEntity, "debtor_name_mismatch", "")
	canMa(t, c.dongPhien(t, c.quay, phien, -1, tong+1, 0, ""), http.StatusBadRequest, "invalid_request", "cash_vnd")
	if c.anhPhien(t, phien) != truoc {
		t.Fatal("lời từ chối của phần tiền mà phiên đã đổi")
	}
	d := c.dongPhien(t, c.quay, phien, 0, 0, tong, "khách nợ · test")
	canDat(t, d, http.StatusCreated)
	if c.trangThaiPhien(t, phien) != "closed" || c.trangThaiBan(t, ban) != "needs_cleaning" {
		t.Fatalf("đóng kèm nợ ⇒ phiên Đã đóng, bàn cần dọn; nhận %s", c.anhPhien(t, phien))
	}
	if ai := c.docSo(t, "SELECT person_id FROM shop.bill WHERE id = $1", d.so(t, "bill_id")); ai != c.quay {
		t.Fatalf("hoá đơn mang người %d, muốn người đứng quầy %d", ai, c.quay)
	}
	t.Logf("khách chưa trả, cho nợ ⇒ phiên vẫn đóng: %s", c.anhPhien(t, phien))
}

// Cắt sau lần ghi thứ hai của cửa đóng (hoá đơn, trạng thái phiên đã ghi; dòng bàn của phiên chưa) ⇒
// không nửa nào sống. Cái kéo cắt là một trigger test gắn vào đúng một phiên, gỡ khi test xong.
func TestI017_CatGiuaLucDongKhongNuaNaoSong(t *testing.T) {
	c := dungBan(t)
	_, phien, don, tong := c.phienDangPhucVu(t, "bàn")
	c.xong(t, don)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	ham := fmt.Sprintf("test_cat_dong_phien_%d", phien)
	if _, err := c.owner.Exec(c.ctx, fmt.Sprintf(`CREATE FUNCTION shop.%s() RETURNS trigger LANGUAGE plpgsql AS $$
		BEGIN
		  IF NEW.table_session_id = %d AND NEW.session_closed THEN
		    RAISE EXCEPTION 'test: cắt giữa lúc đóng phiên';
		  END IF;
		  RETURN NEW;
		END $$`, ham, phien)); err != nil {
		t.Fatal(err)
	}
	if _, err := c.owner.Exec(c.ctx, fmt.Sprintf(`CREATE TRIGGER %s BEFORE UPDATE ON shop.table_session_member
		FOR EACH ROW EXECUTE FUNCTION shop.%s()`, ham, ham)); err != nil {
		t.Fatal(err)
	}
	goKeo := func() {
		_, _ = c.owner.Exec(c.ctx, fmt.Sprintf("DROP TRIGGER IF EXISTS %s ON shop.table_session_member", ham))
		_, _ = c.owner.Exec(c.ctx, fmt.Sprintf("DROP FUNCTION IF EXISTS shop.%s()", ham))
	}
	t.Cleanup(goKeo)
	truoc := c.anhPhien(t, phien)
	canMa(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, ""), http.StatusInternalServerError, "internal_error", "")
	if sau := c.anhPhien(t, phien); sau != truoc {
		t.Fatalf("cắt giữa lúc đóng mà một nửa sống:\n trước %s\n sau   %s", truoc, sau)
	}
	t.Logf("cắt giữa lúc đóng ⇒ 500 internal_error, database y như trước: %s", truoc)
	goKeo()
	canDat(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, ""), http.StatusCreated)
	t.Logf("gỡ kéo cắt, đóng lại ⇒ %s", c.anhPhien(t, phien))
}

// Đóng phiên và gọi thêm chen nhau ở cùng một bàn: lượt gọi hoặc vào phiên trước khi đóng (và đóng bị
// từ chối), hoặc tới sau khi đóng (và bị từ chối vì bàn cần dọn). Không bao giờ: phiên Đã đóng mà còn
// đơn chưa xong, hay hoá đơn thiếu lượt gọi.
func TestI017_DongVaGoiThemChenNhau(t *testing.T) {
	c := dungBan(t)
	var dongTruoc, goiTruoc int
	for vong := 0; vong < 8; vong++ {
		ban, phien, don, tong := c.phienDangPhucVu(t, fmt.Sprintf("bàn %d", vong))
		c.xong(t, don)
		canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
		var dong, goi traLoi
		var wg sync.WaitGroup
		batDau := make(chan struct{})
		wg.Add(2)
		go func() { defer wg.Done(); <-batDau; dong = c.dongPhien(t, c.quay, phien, tong, 0, 0, "") }()
		go func(dau string) { defer wg.Done(); <-batDau; goi = c.datHo(t, c.quay, ban, dau, c.dong(false)) }(dauLanGui(t))
		close(batDau)
		wg.Wait()
		switch {
		case dong.status == http.StatusCreated:
			canMa(t, goi, http.StatusConflict, "dining_table_needs_cleaning", "")
			dongTruoc++
		case goi.status == http.StatusCreated:
			if goi.so(t, "table_session_id") != phien {
				t.Fatalf("vòng %d: gọi thêm vào phiên khác %v", vong, goi.body)
			}
			if dong.chu("code") != "table_session_transition_not_allowed" && dong.chu("code") != "table_session_has_open_orders" {
				t.Fatalf("vòng %d: gọi thêm đã vào phiên mà đóng trả %d %v", vong, dong.status, dong.body)
			}
			goiTruoc++
		default:
			t.Fatalf("vòng %d: đóng %d %v · gọi %d %v", vong, dong.status, dong.body, goi.status, goi.body)
		}
		if lo := c.docSo(t, `SELECT count(*) FROM shop.table_session s JOIN shop.sales_order o ON o.table_session_id = s.id
			WHERE s.id = $1 AND s.status = 'closed' AND o.status NOT IN ('completed', 'cancelled')`, phien); lo != 0 {
			t.Fatalf("vòng %d: phiên Đã đóng còn %d đơn chưa xong — %s", vong, lo, c.anhPhien(t, phien))
		}
	}
	t.Logf("8 vòng đóng ⟂ gọi thêm: %d vòng đóng trước, %d vòng gọi trước; không phiên Đã đóng nào còn đơn chưa xong", dongTruoc, goiTruoc)
}

// --- I-003: bàn trống ⟺ phiên đã đóng VÀ bàn đã dọn ---------------------------------------------

func TestI003_BanTrongCanHaiDieuKien(t *testing.T) {
	c := dungBan(t)
	canhDon := c.nguoi(t, "canh và dọn", false)
	ban, phien, don, tong := c.phienDangPhucVu(t, "bàn")
	ma := c.capMaQR(t, ban)

	canMa(t, c.donBan(t, canhDon, ban), http.StatusConflict, "dining_table_not_needing_cleaning", "")
	c.xong(t, don)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	canMa(t, c.donBan(t, canhDon, ban), http.StatusConflict, "dining_table_not_needing_cleaning", "")
	if c.trangThaiBan(t, ban) != "in_session" {
		t.Fatal("bàn của phiên Chờ thanh toán vẫn không trống (§5.3)")
	}
	canDat(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, ""), http.StatusCreated)
	if s := c.trangThaiBan(t, ban); s != "needs_cleaning" {
		t.Fatalf("phiên đã đóng, chưa dọn ⇒ needs_cleaning, nhận %s", s)
	}
	canMa(t, c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false)), http.StatusConflict, "dining_table_needs_cleaning", "")
	canMa(t, c.goiQR(t, ma, dauLanGui(t), c.dong(false)), http.StatusConflict, "dining_table_needs_cleaning", "")
	if n := c.soDongCuaBan(t, ban); n != 1 {
		t.Fatalf("bàn cần dọn mà có thêm %d phiên", n-1)
	}
	canMa(t, c.donBan(t, 0, ban), http.StatusUnauthorized, "unauthenticated", "")
	canMa(t, c.donBan(t, canhDon, 1<<40), http.StatusNotFound, "dining_table_not_found", "")

	r := c.donBan(t, canhDon, ban)
	canDat(t, r, http.StatusOK)
	if r.chu("state") != "empty" || c.trangThaiBan(t, ban) != "empty" {
		t.Fatalf("dọn xong bàn đã đóng phiên ⇒ empty; nhận %v", r.body)
	}
	if n := c.docSo(t, `SELECT count(*) FROM shop.record_revision v JOIN shop.table_session_member m ON m.id = v.target_row
		WHERE v.target_table_code = 'table_session_member' AND m.table_session_id = $1 AND m.dining_table_id = $2
		  AND v.before_image ->> 'cleaned_at' IS NULL AND v.after_image ->> 'cleaned_at' IS NOT NULL AND v.person_id = $3`,
		phien, ban, canhDon); n != 1 {
		t.Fatalf("lần dọn phải để lại một vết mang người dọn, nhận %d", n)
	}
	canMa(t, c.donBan(t, canhDon, ban), http.StatusConflict, "dining_table_not_needing_cleaning", "")
	moi := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false))
	canDat(t, moi, http.StatusCreated)
	if moi.so(t, "table_session_id") == phien {
		t.Fatal("bàn đã dọn ⇒ lượt gọi mới mở phiên MỚI")
	}
	t.Logf("dọn trước khi đóng ⇒ từ chối; đóng ⇒ cần dọn, gọi món bị từ chối; dọn ⇒ trống, phiên mới %d", moi.so(t, "table_session_id"))
}

func TestI003_BanGhepDonTungBan(t *testing.T) {
	c := dungBan(t)
	canhDon := c.nguoi(t, "canh và dọn", false)
	banA, phien, don, tong := c.phienDangPhucVu(t, "bàn A")
	banB := c.banMoi(t, "bàn B")
	c.ghepTay(t, phien, banB)
	c.xong(t, don)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	canDat(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, ""), http.StatusCreated)
	canDat(t, c.donBan(t, canhDon, banA), http.StatusOK)
	a, b := c.trangThaiBan(t, banA), c.trangThaiBan(t, banB)
	if a != "empty" || b != "needs_cleaning" {
		t.Fatalf("nhóm ghép: dọn A ⇒ A empty, B needs_cleaning; nhận A %s, B %s", a, b)
	}
	canMa(t, c.datHo(t, c.quay, banB, dauLanGui(t), c.dong(false)), http.StatusConflict, "dining_table_needs_cleaning", "")
	canDat(t, c.datHo(t, c.quay, banA, dauLanGui(t), c.dong(false)), http.StatusCreated)
	t.Logf("nhóm ghép đóng chung, dọn riêng: A %s, B %s; %s", a, b, c.anhPhien(t, phien))
}

// --- Khách QR: mang mã, không mang bàn (I-023 tầng 3, 02-vai-va-quyen.md §1 câu 5) ----------------

func TestI023_KhachQRVaoPhienCuaBanQuaMaHienHanh(t *testing.T) {
	c := dungBan(t)
	ban, phien, _, _ := c.phienDangPhucVu(t, "bàn")
	ma := c.capMaQR(t, ban)
	truoc := c.anhPhien(t, phien)
	sai := c.post(t, "/qr-codes/"+ma+"/orders", 0, map[string]any{"submission_code": dauLanGui(t),
		"dining_table_id": ban, "lines": []any{c.dong(false)}})
	canMa(t, sai, http.StatusBadRequest, "invalid_request", "dining_table_id")
	canMa(t, c.goiQR(t, ma, "không-phải-uuid", c.dong(false)), http.StatusBadRequest, "invalid_request", "submission_code")
	if c.anhPhien(t, phien) != truoc {
		t.Fatal("yêu cầu sai hình mà phiên đã đổi")
	}
	q := c.goiQR(t, ma, dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	if q.so(t, "table_session_id") != phien || q.chu("status") != "pending_confirmation" {
		t.Fatalf("khách QR ở bàn đang phục vụ ⇒ vào phiên %d, chờ duyệt; nhận %v", phien, q.body)
	}
	cu := ma
	moi := c.capMaQR(t, ban)
	sau := c.anhPhien(t, phien)
	canMa(t, c.goiQR(t, cu, dauLanGui(t), c.dong(false)), http.StatusNotFound, "qr_code_not_current", "")
	if c.anhPhien(t, phien) != sau {
		t.Fatal("mã đã thay mà vẫn ghi được")
	}
	canDat(t, c.goiQR(t, moi, dauLanGui(t), c.dong(false)), http.StatusCreated)
	t.Logf("mã cũ ⇒ qr_code_not_current; mã mới vào cùng phiên: %s", c.anhPhien(t, phien))
}

// --- Quyền: mọi cửa của quầy đòi người ĐANG đứng quầy (I-012, 02-vai-va-quyen.md) ------------------

func TestI012_CuaTaiBanPhaiDungQuay(t *testing.T) {
	c := dungBan(t)
	ban, phien, don, _ := c.phienDangPhucVu(t, "bàn")
	q := c.goiQR(t, c.capMaQR(t, ban), dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	c.xong(t, don)
	truoc := c.anhPhien(t, phien)
	for _, nguoi := range []struct {
		id   int64
		code string
		st   int
	}{{c.chu, "not_on_counter_duty", http.StatusForbidden}, {0, "unauthenticated", http.StatusUnauthorized}} {
		canMa(t, c.datHo(t, nguoi.id, ban, dauLanGui(t), c.dong(false)), nguoi.st, nguoi.code, "")
		canMa(t, c.duyet(t, nguoi.id, q.so(t, "sales_order_id")), nguoi.st, nguoi.code, "")
		canMa(t, c.tuChoi(t, nguoi.id, q.so(t, "sales_order_id")), nguoi.st, nguoi.code, "")
		canMa(t, c.tinhTien(t, nguoi.id, phien), nguoi.st, nguoi.code, "")
		canMa(t, c.dongPhien(t, nguoi.id, phien, 0, 0, 0, ""), nguoi.st, nguoi.code, "")
	}
	if c.anhPhien(t, phien) != truoc {
		t.Fatal("lời từ chối của quyền mà phiên đã đổi")
	}
	t.Logf("chủ quán không đứng quầy ⇒ not_on_counter_duty, không người ⇒ unauthenticated, ở năm cửa; %s", truoc)
}

// Mọi đường gọi của lát có thật trên mux: một 404/405 KHÔNG mang mã là đường thiếu; lời từ chối có
// mã (kể cả 404 của một bản ghi không tồn tại) là đường có thật.
func TestQC12_DuongGoiCuaLuongTaiBan(t *testing.T) {
	c := dungBan(t)
	var thieu []string
	for _, p := range []struct{ method, path string }{
		{"POST", "/table-orders"}, {"POST", "/qr-codes/x/orders"}, {"POST", "/orders/1/approval"},
		{"POST", "/orders/1/rejection"}, {"POST", "/table-sessions/1/bill-request"},
		{"POST", "/table-sessions/1/closing"}, {"POST", "/dining-tables/1/cleaning"}, {"GET", "/dining-tables"},
	} {
		status, out := c.goi(t, p.method, p.path, 0, map[string]any{})
		if code, _ := out["code"].(string); code == "" && (status == http.StatusNotFound || status == http.StatusMethodNotAllowed) {
			thieu = append(thieu, p.method+" "+p.path)
		}
	}
	sort.Strings(thieu)
	if len(thieu) > 0 {
		t.Fatalf("thiếu đường gọi: %s", strings.Join(thieu, " · "))
	}
}
