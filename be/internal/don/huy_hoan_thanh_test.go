// Huỷ đơn đã Hoàn thành (T-147, ADR-090 Sửa đổi 2026-10-10; shop-facts.md §6.19 — lời U-027).
// Chủ quán: "có thể huỷ được, để POS quyết định trong thực tế". Cửa huỷ chỉ đổi trạng thái đơn và để vết;
// tiền đi đường hoàn của P3-09 do quầy quyết từng ca — cửa huỷ không tự hoàn, không đụng hoá đơn.
package don_test

import (
	"net/http"
	"strings"
	"testing"
)

// chiTien: demTien bỏ con số cuối (đơn Hoàn thành) — huỷ đơn được đổi trạng thái, không được đổi bảng tiền nào.
func chiTien(dem string) string { return dem[:strings.LastIndex(dem, " · ")] }

func TestI004_HuyDonHoanThanhGanBanRutKhoiTienCuaPhien(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 25)
	ban, phien, don, _ := n.phienDangPhucVu(t, banTien())
	r := n.datHo(t, n.quay, ban, dauLanGui(t), n.dong(false))
	canDat(t, r, http.StatusCreated)
	con, tongCon := r.so(t, "sales_order_id"), r.so(t, "total_vnd")
	n.phucVuHet(t, n.quay, don)
	n.phucVuHet(t, n.quay, con)
	if s := n.trangThaiDon(t, don); s != "completed" {
		t.Fatalf("phục vụ hết đơn gắn bàn ⇒ Hoàn thành, nhận %s", s)
	}
	daRa := len(n.viecCua(t, don, "served"))
	k := n.khoaCua(t, n.viecCua(t, don, "served")[0])
	cuaDon := int64(0) // đơn vị đã ra bàn của đơn sắp huỷ, đúng khoá k
	for _, v := range n.viecCua(t, don, "served") {
		if n.khoaCua(t, v) == k {
			cuaDon++
		}
	}
	truoc := phanCua(n.bang(t, ""), k, ban, 0)
	if truoc.daRaBan < cuaDon || cuaDon == 0 {
		t.Fatalf("trước khi huỷ bàn phải có phần đã ra bàn của đơn: %+v, của đơn %d", truoc, cuaDon)
	}

	h := n.huyDon(t, n.quay, don)
	canDat(t, h, http.StatusOK)
	if h.chu("status") != "cancelled" || n.trangThaiDon(t, don) != "cancelled" {
		t.Fatalf("huỷ đơn Hoàn thành: %v", h.body)
	}
	if c := n.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'sales_order' AND target_row = $1
		AND before_image ->> 'status' = 'completed' AND after_image ->> 'status' = 'cancelled' AND person_id = $2`, don, n.quay); c != 1 {
		t.Fatal("Hoàn thành → Huỷ phải để vết mang người quầy")
	}
	// Bánh đã tới tay khách: đơn vị ở lại Đã ra bàn (QD-50), nhưng đơn huỷ không còn phần trên bảng (F-044).
	if got := len(n.viecCua(t, don, "served")); got != daRa {
		t.Fatalf("huỷ không đổi đơn vị việc trạm: trước %d đã ra bàn, sau %d", daRa, got)
	}
	if p := phanCua(n.bang(t, ""), k, ban, 0); p.daRaBan != truoc.daRaBan-cuaDon || p.goi != truoc.goi-cuaDon {
		t.Fatalf("đơn huỷ còn tính trên bảng nhu cầu: trước %+v, sau %+v, của đơn %d", truoc, p, cuaDon)
	}
	// Phiên chưa thu: tiền phải trả chỉ còn đơn chưa huỷ.
	tt := n.tinhTien(t, n.quay, phien)
	canDat(t, tt, http.StatusOK)
	if due := tt.so(t, "due_vnd"); due != tongCon {
		t.Fatalf("tiền của phiên sau khi huỷ một đơn Hoàn thành: muốn %d, nhận %d", tongCon, due)
	}
	canMa(t, n.huyDon(t, n.quay, don), http.StatusConflict, "order_transition_not_allowed", "")
	t.Logf("đơn %d Hoàn thành ⇒ Huỷ; %d đơn vị ở lại đã ra bàn; phiên %d còn phải trả %d", don, daRa, phien, tongCon)
}

func TestI014_HuyDonLeDaThuGiuHoaDonHoanDoQuayQuyet(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 26)
	d, tong := n.donLay(t)
	n.phucVuHet(t, n.quay, d)
	r := n.traoTaiQuay(t, n.quay, d, thu(tong, 0))
	canDat(t, r, http.StatusCreated)
	hd := r.so(t, "bill_id")
	anh := n.anhHoaDon(t, hd)
	tienTruoc := n.demTien(t)

	// Người không đứng quầy, kể cả chủ quán, không huỷ được (lớp quay — ADR-090 điểm 9 · 02-vai-va-quyen.md).
	if s := n.huyDon(t, n.chu, d).status; s == http.StatusOK {
		t.Fatal("chủ quán không đứng quầy không được huỷ đơn")
	}
	canDat(t, n.huyDon(t, n.quay, d), http.StatusOK)
	if s := n.trangThaiDon(t, d); s != "cancelled" {
		t.Fatalf("đơn lẻ đã thu sau khi huỷ: %s", s)
	}
	// Cửa huỷ không tự hoàn tiền, không đụng hoá đơn: tiền là việc quầy quyết qua cửa hoàn (§6.4 · §6.19).
	if a := n.anhHoaDon(t, hd); a != anh {
		t.Fatalf("huỷ đơn đổi hoá đơn: %s → %s", anh, a)
	}
	if sau := n.demTien(t); chiTien(sau) != chiTien(tienTruoc) {
		t.Fatalf("huỷ đơn Hoàn thành đổi bảng tiền: %s → %s", tienTruoc, sau)
	}
	canDat(t, n.hoan(t, n.quay, hd, tong, "cash", "cash", "khách trả lại, huỷ đơn"), http.StatusCreated)
	if c := n.docSo(t, `SELECT count(*) FROM shop.refund WHERE bill_id = $1 AND amount_vnd = $2`, hd, tong); c != 1 {
		t.Fatal("hoá đơn của đơn đã huỷ vẫn nhận hoàn qua cửa hoàn")
	}
	t.Logf("đơn lẻ %d đã thu ⇒ huỷ, hoá đơn %d giữ nguyên, hoàn %d qua cửa hoàn", d, hd, tong)
}
