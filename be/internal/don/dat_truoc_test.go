// Test qua cửa của đơn đặt trước qua điện thoại theo giờ nhắc (T-142, U-077; I-004 · I-016 · I-012).
// Viết TRƯỚC khi có cửa — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào.
// Luật của owner (shop-facts.md §5.2 điểm 5, chủ quán 2026-10-09): đơn đặt trước KHÔNG làm ngay lúc nhận;
// máy nhắc POS và bếp hai lần, trước giờ khách cần hàng 20 phút và 10 phút, và bếp làm lúc ấy; không ai
// phải bấm cho đơn xuống bếp. Cách dựng (ADR-091, suy ra của phiên): lần nhắc đầu là lúc đơn nổ việc trạm;
// máy POS tự gọi cửa nhả đơn hẹn theo nhịp đồng hồ — người đứng quầy không bấm gì.
package don_test

import (
	"fmt"
	"net/http"
	"sync"
	"testing"
	"time"
)

// nhaHen: máy POS gọi cửa nhả đơn hẹn tới lần nhắc đầu (POST /preorder-releases).
func (n ngoai) nhaHen(t *testing.T, nguoi int64) traLoi {
	t.Helper()
	return n.post(t, "/preorder-releases", nguoi, map[string]any{})
}

// nhaRa: các mã đơn mà một lần nhả trả về.
func nhaRa(t *testing.T, r traLoi) []int64 {
	t.Helper()
	ds, ok := r.body["released_order_ids"].([]any)
	if !ok {
		t.Fatalf("lần nhả không trả released_order_ids: %v", r.body)
	}
	var out []int64
	for _, x := range ds {
		f, _ := x.(float64)
		out = append(out, int64(f))
	}
	return out
}

func coMa(ds []int64, id int64) int {
	n := 0
	for _, x := range ds {
		if x == id {
			n++
		}
	}
	return n
}

// gioCanCua: giờ khách cần hàng của một đơn, đọc từ database.
func (n ngoai) gioCanCua(t *testing.T, don int64) time.Time {
	t.Helper()
	var moc time.Time
	if err := n.owner.QueryRow(n.ctx, "SELECT customer_needed_at FROM shop.sales_order WHERE id = $1", don).Scan(&moc); err != nil {
		t.Fatal(err)
	}
	return moc
}

// denGioLam: đồng hồ tới lần nhắc đầu của đơn (giờ khách cần trừ 20 phút) và máy POS gọi cửa nhả — sau
// đó đơn đã nổ, Đang thực hiện.
func (n ngoai) denGioLam(t *testing.T, don int64) {
	t.Helper()
	datDongHo(t, n.gioCanCua(t, don).Add(-20*time.Minute))
	r := n.nhaHen(t, n.quay)
	canDat(t, r, http.StatusOK)
	if s := n.trangThaiDon(t, don); s != "in_progress" {
		t.Fatalf("đơn hẹn %d tới lần nhắc đầu: %s, muốn in_progress", don, s)
	}
}

// nhacCua: dòng của một đơn trong danh sách nhắc (GET /preorder-reminders), hoặc nil khi vắng.
func (n ngoai) nhacCua(t *testing.T, don int64) map[string]any {
	t.Helper()
	status, out := n.goi(t, "GET", "/preorder-reminders", n.quay, nil)
	if status != http.StatusOK {
		t.Fatalf("GET /preorder-reminders: %d %v", status, out)
	}
	ds, _ := out["preorders"].([]any)
	for _, x := range ds {
		m, _ := x.(map[string]any)
		if id, _ := m["sales_order_id"].(float64); int64(id) == don {
			return m
		}
	}
	return nil
}

func nhacDaToi(t *testing.T, m map[string]any) string {
	t.Helper()
	ds, ok := m["due_reminders"].([]any)
	if !ok {
		t.Fatalf("dòng nhắc thiếu due_reminders: %v", m)
	}
	s := ""
	for _, x := range ds {
		f, _ := x.(float64)
		s += fmt.Sprintf("[%d]", int64(f))
	}
	if s == "" {
		return "-"
	}
	return s
}

// datHen: một đơn hotline cần hàng lúc `can`, nhận lúc `nhan`.
func (n ngoai) datHen(t *testing.T, nhan, can time.Time) int64 {
	t.Helper()
	datDongHo(t, nhan)
	lienHe := lienHeHotlineLay()
	lienHe["customer_needed_at"] = can.Format(time.RFC3339)
	r := n.hotline(t, n.quay, dauLanGui(t), lienHe)
	canDat(t, r, http.StatusCreated)
	return r.so(t, "sales_order_id")
}

// canLucHen: 10 giờ sáng (giờ mở + 4 giờ) của một ngày 25…29/1/2031 — không test nào khác của gói dùng
// những ngày ấy, và mọi lần nhận đơn của file này (sớm nhất 3 giờ trước) đều trong giờ bán.
func (n ngoai) canLucHen(ngay int) time.Time { return n.luc(ngay, n.gioMo+4*time.Hour) }

func TestI004_DatTruocKhongNoLucNhan(t *testing.T) {
	n := dungNgoai(t)
	can := n.canLucHen(25)
	don := n.datHen(t, can.Add(-3*time.Hour), can)

	if s := n.trangThaiDon(t, don); s != "confirmed" {
		t.Fatalf("đơn đặt trước lúc nhận: %s, muốn confirmed — không làm ngay (U-077)", s)
	}
	if co := n.soViecCo(t, don); co != "-" {
		t.Fatalf("đơn đặt trước chưa tới giờ nhắc đã có việc trạm: %s", co)
	}
	m := n.nhacCua(t, don)
	if m == nil {
		t.Fatal("đơn hẹn phải nằm trong danh sách nhắc ngay từ lúc nhận")
	}
	if got := nhacDaToi(t, m); got != "-" || m["status"] != "confirmed" {
		t.Fatalf("ba giờ trước giờ cần: nhắc đã tới %s, trạng thái %v — muốn chưa lần nào", got, m["status"])
	}
	moc, _ := m["remind_at"].([]any)
	if len(moc) != 2 {
		t.Fatalf("hai mốc nhắc, nhận %v", m["remind_at"])
	}
	for i, phut := range []int{20, 10} {
		s, _ := moc[i].(string)
		got, err := time.Parse(time.RFC3339, s)
		if err != nil || !got.Equal(can.Add(-time.Duration(phut)*time.Minute)) {
			t.Fatalf("mốc nhắc %d phút: %q, muốn %s", phut, s, can.Add(-time.Duration(phut)*time.Minute).Format(time.RFC3339))
		}
	}
	t.Logf("đơn hẹn %d nhận lúc %s, cần lúc %s ⇒ confirmed, 0 việc; nhắc lúc %v",
		don, can.Add(-3*time.Hour).Format("15:04"), can.Format("15:04"), m["remind_at"])
}

func TestI004_DatTruocNoDungLanNhacDau(t *testing.T) {
	n := dungNgoai(t)
	can := n.canLucHen(26)
	don := n.datHen(t, can.Add(-2*time.Hour), can)

	// 21 phút trước giờ cần: chưa tới lần nhắc đầu ⇒ lần nhả không chạm đơn này.
	datDongHo(t, can.Add(-21*time.Minute))
	r := n.nhaHen(t, n.quay)
	canDat(t, r, http.StatusOK)
	if coMa(nhaRa(t, r), don) != 0 || n.trangThaiDon(t, don) != "confirmed" || n.soViecCo(t, don) != "-" {
		t.Fatalf("21 phút trước giờ cần mà đơn đã nổ: %v, %s", r.body, n.trangThaiDon(t, don))
	}

	// Đúng 20 phút trước: nổ đủ việc, Đang thực hiện, vết mang người của máy POS.
	datDongHo(t, can.Add(-20*time.Minute))
	r = n.nhaHen(t, n.quay)
	canDat(t, r, http.StatusOK)
	if coMa(nhaRa(t, r), don) != 1 {
		t.Fatalf("lần nhắc đầu phải nhả đúng một lần đơn %d: %v", don, r.body)
	}
	if s := n.trangThaiDon(t, don); s != "in_progress" {
		t.Fatalf("sau lần nhắc đầu: %s, muốn in_progress", s)
	}
	if muon, co := n.soViecMuon(t, don), n.soViecCo(t, don); muon != co {
		t.Fatalf("nổ đơn hẹn sai:\n muốn %s\n có   %s", muon, co)
	}
	if v := n.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'sales_order' AND target_row = $1
		AND before_image ->> 'status' = 'confirmed' AND after_image ->> 'status' = 'in_progress' AND person_id = $2`, don, n.quay); v != 1 {
		t.Fatalf("Đã xác nhận → Đang thực hiện của đơn hẹn: %d vết mang người quầy, muốn 1", v)
	}
	if got := nhacDaToi(t, n.nhacCua(t, don)); got != "[20]" {
		t.Fatalf("đúng lần nhắc đầu: nhắc đã tới %s, muốn [20]", got)
	}

	// Lần nhả thứ hai không nổ lần hai.
	viec := n.soViecCo(t, don)
	r = n.nhaHen(t, n.quay)
	canDat(t, r, http.StatusOK)
	if coMa(nhaRa(t, r), don) != 0 || n.soViecCo(t, don) != viec {
		t.Fatalf("nhả lần hai nổ lại: %v, %s → %s", r.body, viec, n.soViecCo(t, don))
	}

	// Lần nhắc thứ hai: 10 phút trước — chỉ là nhắc, không đổi gì.
	datDongHo(t, can.Add(-10*time.Minute))
	if got := nhacDaToi(t, n.nhacCua(t, don)); got != "[20][10]" {
		t.Fatalf("10 phút trước giờ cần: nhắc đã tới %s, muốn [20][10]", got)
	}
	if n.soViecCo(t, don) != viec {
		t.Fatal("lần nhắc thứ hai không được ghi gì")
	}

	// Xong đơn thì không còn trong danh sách nhắc.
	n.phucVuHet(t, n.quay, don)
	tong := n.docSo(t, "SELECT sum(line_total_vnd) FROM shop.order_line WHERE sales_order_id = $1", don)
	canDat(t, n.post(t, fmt.Sprintf("/orders/%d/handover", don), n.quay, map[string]any{"cash_vnd": tong, "transfer_vnd": 0}), http.StatusCreated)
	if m := n.nhacCua(t, don); m != nil {
		t.Fatalf("đơn đã hoàn thành vẫn bị nhắc: %v", m)
	}
	t.Logf("đơn hẹn %d: 21 phút trước ⇒ chưa; 20 phút ⇒ nổ %s; nhả lại ⇒ không nổ lần hai; 10 phút ⇒ nhắc lần hai", don, viec)
}

// Nhận đơn khi chỉ còn chưa tới 20 phút: lần nhắc đầu đã qua ⇒ làm ngay (suy ra của phiên, ADR-091).
func TestI004_DatTruocNhanSatGioThiLamNgay(t *testing.T) {
	n := dungNgoai(t)
	can := n.canLucHen(27)
	for _, truoc := range []time.Duration{20 * time.Minute, 5 * time.Minute} {
		don := n.datHen(t, can.Add(-truoc), can)
		if s := n.trangThaiDon(t, don); s != "in_progress" {
			t.Fatalf("nhận %s trước giờ cần: %s, muốn in_progress (lần nhắc đầu đã tới)", truoc, s)
		}
		if muon, co := n.soViecMuon(t, don), n.soViecCo(t, don); muon != co {
			t.Fatalf("nhận sát giờ nổ sai:\n muốn %s\n có   %s", muon, co)
		}
		t.Logf("nhận %s trước giờ cần ⇒ in_progress ngay, %s", truoc, n.soViecCo(t, don))
	}
}

func TestI012_CuaNhaHenPhaiDungQuay(t *testing.T) {
	n := dungNgoai(t)
	can := n.canLucHen(28)
	don := n.datHen(t, can.Add(-time.Hour), can)
	datDongHo(t, can.Add(-15*time.Minute))
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)
	canMa(t, n.nhaHen(t, 0), http.StatusUnauthorized, "unauthenticated", "")
	canMa(t, n.nhaHen(t, khac), http.StatusForbidden, "not_on_counter_duty", "")
	if s := n.trangThaiDon(t, don); s != "confirmed" || n.soViecCo(t, don) != "-" {
		t.Fatalf("lời từ chối quyền mà đơn đã nổ: %s", s)
	}
}

// Năm máy cùng gọi nhả một lúc: mỗi đơn nổ đúng một lần (khoá đơn trước khi xét trạng thái).
func TestI004_HaiLanNhaChenNhauNoMotLan(t *testing.T) {
	n := dungNgoai(t)
	can := n.canLucHen(29)
	don := n.datHen(t, can.Add(-time.Hour), can)
	datDongHo(t, can.Add(-20*time.Minute))
	const chenNhau = 5
	var wg sync.WaitGroup
	var mu sync.Mutex
	lan, loi := 0, []string{}
	for i := 0; i < chenNhau; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			status, out := n.goi(t, "POST", "/preorder-releases", n.quay, map[string]any{})
			mu.Lock()
			defer mu.Unlock()
			if status != http.StatusOK {
				loi = append(loi, fmt.Sprint(status, out))
				return
			}
			ds, _ := out["released_order_ids"].([]any)
			for _, x := range ds {
				if f, _ := x.(float64); int64(f) == don {
					lan++
				}
			}
		}()
	}
	wg.Wait()
	if len(loi) > 0 || lan != 1 {
		t.Fatalf("%d lần nhả chen nhau: đơn %d nhả %d lần, lỗi %v — muốn đúng 1, không lỗi", chenNhau, don, lan, loi)
	}
	if muon, co := n.soViecMuon(t, don), n.soViecCo(t, don); muon != co {
		t.Fatalf("nhả chen nhau nổ sai:\n muốn %s\n có   %s", muon, co)
	}
}

// Luật chỉ nói về phone_preorder: đơn khách tự đặt tới lấy (pickup) vẫn nổ lúc duyệt.
func TestI004_DonTuLayCuaKhachVanNoLucDuyet(t *testing.T) {
	n := dungNgoai(t)
	r := n.web(t, dauLanGui(t), lienHeLay())
	canDat(t, r, http.StatusCreated)
	don := r.so(t, "sales_order_id")
	canDat(t, n.duyet(t, n.quay, don), http.StatusOK)
	if s := n.trangThaiDon(t, don); s != "in_progress" {
		t.Fatalf("đơn tới lấy của khách sau khi duyệt: %s, muốn in_progress", s)
	}
}
