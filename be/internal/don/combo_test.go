// Test của cửa ghi đơn khi đơn mang combo (T-196, ADR-117 điểm 2 · 5 · 7; I-034 · I-013 · I-009 · I-024). Combo trên
// đơn là MỘT dòng combo mang giá combo cùng các dòng suất con mang mức combo; tổng đơn vẫn là Σ thành tiền các dòng.
// Combo dựng trên món thật của ca §4.8 số 2 (đọc lúc chạy) — giá combo và mức là số GIẢ của test, không phải giá quán.
package don_test

import (
	"context"
	"fmt"
	"net/http"
	"testing"
	"time"

	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

const (
	giaComboThu = 7000
	mucComboThu = 1500
)

type comboThu struct {
	id, mon int64
	chon    []int64
}

// comboThat lập một combo hai suất của món ca 2, đặt mức cho lựa chọn đầu của tổ hợp ca 2; test xong thì ẩn combo.
func (c canh) comboThat(t *testing.T) comboThu {
	t.Helper()
	if len(c.mon.chonIDs) == 0 {
		t.Fatal("ca 2 của §4.8 phải mang ít nhất một lựa chọn để đặt mức")
	}
	k := comboThu{mon: c.mon.monID, chon: c.mon.chonIDs}
	if err := c.coVet(func(tx pgx.Tx) error {
		if err := tx.QueryRow(c.ctx, "INSERT INTO shop.menu_combo (name, price_vnd) VALUES ($1, $2) RETURNING id",
			"test-combo · "+t.Name(), giaComboThu).Scan(&k.id); err != nil {
			return err
		}
		var ci int64
		if err := tx.QueryRow(c.ctx, "INSERT INTO shop.menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES ($1, $2, 2) RETURNING id",
			k.id, k.mon).Scan(&ci); err != nil {
			return err
		}
		_, err := tx.Exec(c.ctx, "INSERT INTO shop.menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES ($1, $2, $3)",
			ci, k.chon[0], mucComboThu)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_ = c.coVet(func(tx pgx.Tx) error {
			_, err := tx.Exec(context.Background(), `UPDATE shop.menu_combo SET hidden_at = now(),
				hidden_by_person_id = (SELECT id FROM shop.person ORDER BY id LIMIT 1) WHERE id = $1 AND hidden_at IS NULL`, k.id)
			return err
		})
	})
	return k
}

// dong: một combo, hai suất cùng tổ hợp ca 2 tách thành hai phần tử — kèm giá gửi lên để chứng minh nó bị bỏ (I-013).
func (k comboThu) dong(tach bool) map[string]any {
	suat := func(so int) map[string]any {
		return map[string]any{"menu_item_id": k.mon, "quantity": so, "option_ids": k.chon, "unit_price_vnd": 0}
	}
	ps := []any{suat(2)}
	if tach {
		ps = []any{suat(1), suat(1)}
	}
	return map[string]any{"menu_combo_id": k.id, "quantity": 1, "portions": ps, "unit_price_vnd": 0, "line_total_vnd": 0}
}

// kiemComboTrenDon đọc database: đúng một dòng combo mang giá combo, không thành phần; suất con trỏ về nó, mỗi suất
// mang mức, ảnh chụp lựa chọn mang mức đã áp; Σ thành tiền các dòng = giá combo + hai lần mức.
func (c canh) kiemComboTrenDon(t *testing.T, don int64, k comboThu) {
	t.Helper()
	var dongCombo, giaCombo, soCon, conDungGia, tong, mucChup int64
	var coThanhPhan bool
	if err := c.owner.QueryRow(c.ctx, `SELECT l.id, l.unit_price_vnd, l.component_count IS NOT NULL,
		(SELECT count(*) FROM shop.order_line x WHERE x.parent_order_line_id = l.id),
		(SELECT count(*) FROM shop.order_line x WHERE x.parent_order_line_id = l.id AND x.unit_price_vnd = $3),
		(SELECT sum(line_total_vnd) FROM shop.order_line WHERE sales_order_id = $1),
		(SELECT coalesce(sum(p.surcharge_vnd * x.quantity), 0) FROM shop.order_line x JOIN shop.order_line_option p ON p.order_line_id = x.id
		 WHERE x.parent_order_line_id = l.id)
		FROM shop.order_line l WHERE l.sales_order_id = $1 AND l.menu_combo_id = $2`, don, k.id, mucComboThu).
		Scan(&dongCombo, &giaCombo, &coThanhPhan, &soCon, &conDungGia, &tong, &mucChup); err != nil {
		t.Fatalf("đơn %d không có đúng một dòng combo: %v", don, err)
	}
	if giaCombo != giaComboThu || coThanhPhan || soCon == 0 || conDungGia != soCon || tong != giaComboThu+2*mucComboThu ||
		mucChup != 2*mucComboThu {
		t.Fatalf("đơn %d: dòng combo giá %d (thành phần %v), %d suất con (%d mang mức), Σ dòng %d, mức đã chụp %d",
			don, giaCombo, coThanhPhan, soCon, conDungGia, tong, mucChup)
	}
}

func kiemTraVe(t *testing.T, r traLoi, k comboThu) int64 {
	t.Helper()
	if r.status != http.StatusCreated {
		t.Fatalf("muốn 201, nhận %d %v", r.status, r.body)
	}
	if r.so(t, "total_vnd") != giaComboThu+2*mucComboThu {
		t.Fatalf("tổng trả về sai: %v", r.body)
	}
	lines, _ := r.body["lines"].([]any)
	if len(lines) != 1 {
		t.Fatalf("đơn trả về phải có đúng một dòng combo, suất lồng dưới nó: %v", r.body)
	}
	d := lines[0].(map[string]any)
	if int64(d["menu_combo_id"].(float64)) != k.id || len(d["portions"].([]any)) == 0 {
		t.Fatalf("dòng combo trả về thiếu mã combo hay suất: %v", d)
	}
	return r.so(t, "sales_order_id")
}

// --- năm kênh ghi combo bằng cùng con số tính thử; giá gửi kèm bị bỏ (I-034 · I-013) ------------------------

func TestI034_GhiComboNamKenh(t *testing.T) {
	n := dungTien(t)
	k := n.comboThat(t)
	status, q := n.goi(t, "POST", "/price-quotes", 0, map[string]any{"lines": []any{k.dong(true)}})
	if status != http.StatusOK || int64(q["total_vnd"].(float64)) != giaComboThu+2*mucComboThu {
		t.Fatalf("tính thử combo sai: %d %v", status, q)
	}
	kenh := []struct {
		ten string
		goi func() traLoi
	}{
		{"staff_pos", func() traLoi { return n.datHo(t, n.quay, n.banDatHo, dauLanGui(t), k.dong(true)) }},
		{"qr_table", func() traLoi { return n.goiQR(t, n.maQR, dauLanGui(t), k.dong(true)) }},
		{"delivery", func() traLoi {
			return n.post(t, "/online-orders", 0, voiDong(lienHeGiao(), dauLanGui(t), k.dong(true)))
		}},
		{"pickup", func() traLoi {
			return n.post(t, "/online-orders", 0, voiDong(lienHeLay(), dauLanGui(t), k.dong(false)))
		}},
		{"phone_preorder", func() traLoi {
			return n.post(t, "/phone-orders", n.quay, voiDong(lienHeHotlineLay(), dauLanGui(t), k.dong(true)))
		}},
	}
	for _, x := range kenh {
		r := x.goi()
		t.Logf("%s ⇒ %d %v", x.ten, r.status, r.body)
		n.kiemComboTrenDon(t, kiemTraVe(t, r, k), k)
	}
}

// --- bếp nhận việc theo suất con, gửi lại cùng dấu, thiếu suất, đổi giá sau khi đặt (I-034 · I-024 · I-009) ----

func TestI034_ComboTrenDonBepGuiLaiGiaCu(t *testing.T) {
	n := dungTien(t)
	k := n.comboThat(t)
	ban := n.banMoi(t, "combo")
	dau := dauLanGui(t)
	don := kiemTraVe(t, n.datHo(t, n.quay, ban, dau, k.dong(true)), k)

	// Bếp: dòng combo không sinh việc; suất con sinh đúng số việc như hai suất thường của cùng món.
	var viecCombo, viecCon, viecMuon int64
	if err := n.owner.QueryRow(n.ctx, `SELECT
		(SELECT count(*) FROM shop.station_job j JOIN shop.order_line l ON l.id = j.order_line_id WHERE l.sales_order_id = $1 AND l.menu_combo_id IS NOT NULL),
		(SELECT count(*) FROM shop.station_job j JOIN shop.order_line l ON l.id = j.order_line_id WHERE l.sales_order_id = $1 AND l.parent_order_line_id IS NOT NULL),
		(SELECT coalesce(sum(l.quantity * c.quantity), 0) FROM shop.order_line l JOIN shop.order_line_component c ON c.order_line_id = l.id
		 JOIN shop.menu_component_station s ON s.menu_component_id = c.menu_component_id WHERE l.sales_order_id = $1 AND l.parent_order_line_id IS NOT NULL)`, don).
		Scan(&viecCombo, &viecCon, &viecMuon); err != nil {
		t.Fatal(err)
	}
	if viecCombo != 0 || viecCon == 0 || viecCon != viecMuon {
		t.Fatalf("việc bếp: dòng combo %d (muốn 0), suất con %d (muốn %d)", viecCombo, viecCon, viecMuon)
	}

	// Gửi lại cùng dấu, cùng nội dung ⇒ cùng đơn, không dòng mới (I-024); khác cách tách suất ⇒ xung đột.
	truoc := n.demGhi(t)
	r := n.datHo(t, n.quay, ban, dau, k.dong(true))
	if r.so(t, "sales_order_id") != don || n.demGhi(t) != truoc {
		t.Fatalf("gửi lại cùng dấu phải trả đúng đơn cũ, không ghi thêm: %v", r.body)
	}
	canMa(t, n.datHo(t, n.quay, ban, dau, k.dong(false)), http.StatusConflict, "submission_code_conflict", "")

	// Thiếu suất ⇒ từ chối cả lượt gọi, không ghi gì.
	thieu := map[string]any{"menu_combo_id": k.id, "quantity": 1,
		"portions": []any{map[string]any{"menu_item_id": k.mon, "quantity": 1, "option_ids": k.chon}}}
	canMa(t, n.datHo(t, n.quay, ban, dauLanGui(t), thieu), 422, "combo_portions_mismatch", "lines[0].portions")
	if n.demGhi(t) != truoc {
		t.Fatal("lượt gọi combo thiếu suất bị từ chối mà database vẫn đổi")
	}

	// Đổi giá combo và mức sau khi đặt ⇒ đơn cũ đứng nguyên (I-009).
	if err := n.coVet(func(tx pgx.Tx) error {
		if _, err := tx.Exec(n.ctx, "UPDATE shop.menu_combo SET price_vnd = 9999 WHERE id = $1", k.id); err != nil {
			return err
		}
		_, err := tx.Exec(n.ctx, `UPDATE shop.menu_combo_item_option_surcharge SET surcharge_vnd = 2222
			WHERE menu_combo_item_id IN (SELECT id FROM shop.menu_combo_item WHERE menu_combo_id = $1)`, k.id)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	n.kiemComboTrenDon(t, don, k)
}

// --- nhập bù một lượt giấy mang combo: giá combo và mức tại lúc bán (ADR-117 điểm 5, ADR-099) ------------------

func TestI034_NhapBuComboGiaLucBan(t *testing.T) {
	n := dungTien(t)
	k := n.comboThat(t)
	var luc time.Time
	var ngay string
	if err := n.owner.QueryRow(n.ctx, "SELECT clock_timestamp(), (clock_timestamp() AT TIME ZONE $1)::date::text",
		testhelper.ShopTZ(t)).Scan(&luc, &ngay); err != nil {
		t.Fatal(err)
	}
	if n.docSo(t, "SELECT count(*) FROM shop.paper_ledger WHERE sale_date = $1::date", ngay) == 0 {
		canDat(t, khaiGiay(t, n, n.quay, ngay, 50), http.StatusCreated)
	}
	viTri := n.docSo(t, `SELECT coalesce(max(b.paper_position), 0) + 1 FROM shop.bill b
		JOIN shop.paper_ledger l ON l.id = b.paper_ledger_id WHERE l.sale_date = $1::date`, ngay)
	if err := n.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(n.ctx, "UPDATE shop.menu_combo SET price_vnd = 9999 WHERE id = $1", k.id)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	body := map[string]any{"paper_position": viTri, "sold_at": luc.Format(time.RFC3339Nano), "kind": "takeaway",
		"items": []any{k.dong(true)}, "cash_vnd": 0, "transfer_vnd": giaComboThu + 2*mucComboThu, "debt_vnd": 0}
	for key, v := range lienHeHotlineLay() {
		body[key] = v
	}
	r := n.nhapBu(t, n.quay, ngay, body)
	canDat(t, r, http.StatusCreated)
	if r.so(t, "due_vnd") != giaComboThu+2*mucComboThu {
		t.Fatalf("nhập bù combo phải tính giá lúc bán %d, nhận %v", giaComboThu+2*mucComboThu, r.body)
	}
	n.kiemComboTrenDon(t, r.so(t, "sales_order_id"), k)
	t.Logf("nhập bù combo — giá combo lúc bán %dđ, giá hiện hành 9999đ, đơn %s", giaComboThu, fmt.Sprint(r.body["sales_order_id"]))
}
