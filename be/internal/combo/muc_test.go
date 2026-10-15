// Test của cửa đặt mức phụ thu trong combo (T-194, ADR-117 điểm 1 · 6; I-034 vế 3 · I-018). Viết TRƯỚC khi có cửa —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Chủ quán đặt, cho từng món của một combo, mức của
// mỗi lựa chọn (lời lượt bảy, shop-facts.md §8.9); mức khoá như giá combo — chỉ đổi ngoài giờ bán, có lý do, có vết
// (lượt tám vế 4). Lựa chọn chưa đặt mức thì không có dòng (cộng 0đ là việc của hàm giá, T-195).
package combo_test

import (
	"fmt"
	"net/http"
	"testing"
	"time"
)

type nhomNhan struct {
	mon                       int64
	thit, chay, thuong, nhieu int64
	la                        int64 // lựa chọn của một nhóm món không mang
}

// monCoNhan dựng một món mang hai nhóm Nhân · Lượng nhân, và một nhóm lạ món không mang.
func (k khung) monCoNhan(t *testing.T, ten string) nhomNhan {
	t.Helper()
	n := nhomNhan{mon: k.mon(t, ten)}
	g := func(ten string) int64 {
		return k.so(t, "INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id", ten+" · "+t.Name())
	}
	o := func(g int64, ten string) int64 {
		return k.so(t, "INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, $2, 0) RETURNING id", g, ten)
	}
	gNhan, gLuong, gLa := g(ten+" test-Nhân"), g(ten+" test-Lượng nhân"), g(ten+" test-Nhóm lạ")
	n.thit, n.chay = o(gNhan, "test-Thịt"), o(gNhan, "test-Chay")
	n.thuong, n.nhieu = o(gLuong, "test-Thường"), o(gLuong, "test-Nhiều")
	n.la = o(gLa, "test-Lạ")
	k.so(t, "INSERT INTO shop.menu_item_option_group (menu_item_id, option_group_id) VALUES ($1, $2), ($1, $3) RETURNING 1", n.mon, gNhan, gLuong)
	return n
}

type muc struct {
	mon, luaChon int64
	vnd          any
}

func thanMuc(lyDo any, cac ...muc) map[string]any {
	ds := make([]any, 0, len(cac))
	for _, m := range cac {
		ds = append(ds, map[string]any{"menu_item_id": m.mon, "menu_option_id": m.luaChon, "surcharge_vnd": m.vnd})
	}
	out := map[string]any{"surcharges": ds}
	if lyDo != nil {
		out["reason"] = lyDo
	}
	return out
}

func (k khung) datMuc(t *testing.T, id, nguoi int64, body any) traVe {
	t.Helper()
	return k.goi(t, "PUT", fmt.Sprintf("/menu-combos/%d/surcharges", id), nguoi, body)
}

func (k khung) soMuc(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d",
		k.so(t, "SELECT count(*) FROM shop.menu_combo_item_option_surcharge"),
		k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'menu_combo_item_option_surcharge'"))
}

// mucDoc đọc mức của một món trong combo từ thân MenuCombo: menu_option_id → surcharge_vnd.
func mucDoc(t *testing.T, c map[string]any, mon int64) map[int64]float64 {
	t.Helper()
	items, _ := c["items"].([]any)
	for _, x := range items {
		it, _ := x.(map[string]any)
		if it["menu_item_id"] != float64(mon) {
			continue
		}
		ds, ok := it["surcharges"].([]any)
		if !ok {
			t.Fatalf("món %d của combo thiếu danh sách surcharges: %v", mon, it)
		}
		out := map[int64]float64{}
		for _, y := range ds {
			s, _ := y.(map[string]any)
			if s["option_name"] == nil || s["option_group_name"] == nil {
				t.Fatalf("mức thiếu tên lựa chọn hay tên nhóm: %v", s)
			}
			out[int64(s["menu_option_id"].(float64))] = s["surcharge_vnd"].(float64)
		}
		return out
	}
	t.Fatalf("combo không có món %d: %v", mon, c)
	return nil
}

// --- quyền: chỉ chủ quán ----------------------------------------------------------------------------------

func TestI034_ChiChuQuanDatMucCombo(t *testing.T) {
	k := dung(t)
	tr := k.monCoNhan(t, "test-suất trứng")
	id := k.lap(t, "test-combo · "+t.Name(), 50000, phan{tr.mon, 2})
	truoc := k.soMuc(t)
	body := thanMuc("test: đặt mức", muc{tr.mon, tr.nhieu, 3000})
	tuChoi(t, k.datMuc(t, id, k.quay, body), http.StatusForbidden, "owner_only", "")
	tuChoi(t, k.datMuc(t, id, 0, body), http.StatusUnauthorized, "unauthenticated", "")
	if sau := k.soMuc(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- đặt mức theo món của combo, đọc lại, đổi có vết (I-034 vế 3 · I-018) ---------------------------------

func TestI034_DatMucTheoMonCuaCombo(t *testing.T) {
	k := dung(t)
	cu := k.monCoNhan(t, "test-suất cuốn")
	tr := k.monCoNhan(t, "test-suất trứng")
	id := k.lap(t, "test-combo · "+t.Name(), 50000, phan{cu.mon, 1}, phan{tr.mon, 2})

	r := k.datMuc(t, id, k.chu, thanMuc(" test: đặt mức đầu ", muc{tr.mon, tr.nhieu, 3000}, muc{cu.mon, cu.nhieu, 2000}, muc{tr.mon, tr.thit, 0}))
	canDat(t, r, http.StatusOK)
	if r.so(t, "menu_combo_id") != id || r.so(t, "price_vnd") != 50000 {
		t.Fatalf("đặt mức trả combo sai: %v", r.body)
	}
	if m := mucDoc(t, r.body, tr.mon); len(m) != 2 || m[tr.nhieu] != 3000 || m[tr.thit] != 0 {
		t.Fatalf("mức của món trứng đọc sai (muốn Nhiều 3000, Thịt 0): %v", m)
	}
	if m := mucDoc(t, r.body, cu.mon); len(m) != 1 || m[cu.nhieu] != 2000 {
		t.Fatalf("mức của món cuốn đọc sai — mức là của TỪNG món trong combo: %v", m)
	}
	// Đọc lại qua GET /menu-combos.
	if m := mucDoc(t, k.doc(t, "")[id], tr.mon); m[tr.nhieu] != 3000 {
		t.Fatalf("GET /menu-combos không trả mức đã đặt: %v", m)
	}
	if n := k.so(t, `SELECT count(*) FROM shop.menu_combo_item_option_surcharge s JOIN shop.menu_combo_item ci ON ci.id = s.menu_combo_item_id
		WHERE ci.menu_combo_id = $1 AND s.person_id = $2`, id, k.chu); n != 3 {
		t.Fatalf("database giữ %d mức mang người đặt là chủ quán, muốn 3", n)
	}

	// Đổi một mức: có vết mức cũ, mức mới, lý do, người; mức không nhắc tới đứng nguyên.
	canDat(t, k.datMuc(t, id, k.chu, thanMuc("test: tăng mức", muc{tr.mon, tr.nhieu, 4000})), http.StatusOK)
	var lyDo string
	var truocV, sauV, nguoi int64
	if err := k.owner.QueryRow(k.ctx, `SELECT r.reason, (r.before_image->>'surcharge_vnd')::bigint, (r.after_image->>'surcharge_vnd')::bigint, r.person_id
		FROM shop.record_revision r JOIN shop.menu_combo_item_option_surcharge s ON s.id = r.target_row
		JOIN shop.menu_combo_item ci ON ci.id = s.menu_combo_item_id
		WHERE r.target_table_code = 'menu_combo_item_option_surcharge' AND ci.menu_combo_id = $1 AND s.menu_option_id = $2
		ORDER BY r.id DESC LIMIT 1`, id, tr.nhieu).Scan(&lyDo, &truocV, &sauV, &nguoi); err != nil {
		t.Fatalf("đổi mức không để vết: %v", err)
	}
	if lyDo != "test: tăng mức" || truocV != 3000 || sauV != 4000 || nguoi != k.chu {
		t.Fatalf("vết sai: lý do %q, mức %d → %d, người %d", lyDo, truocV, sauV, nguoi)
	}
	c := k.doc(t, "")[id]
	if m := mucDoc(t, c, tr.mon); m[tr.nhieu] != 4000 || m[tr.thit] != 0 {
		t.Fatalf("đọc lại sau khi đổi sai: %v", m)
	}
	if m := mucDoc(t, c, cu.mon); m[cu.nhieu] != 2000 {
		t.Fatalf("mức không nhắc tới bị đổi: %v", m)
	}
	// Combo chưa đặt mức nào vẫn đọc ra danh sách rỗng, không thiếu trường.
	id2 := k.lap(t, "test-combo trơn · "+t.Name(), 30000, phan{cu.mon, 1})
	if m := mucDoc(t, k.doc(t, "")[id2], cu.mon); len(m) != 0 {
		t.Fatalf("combo chưa đặt mức phải đọc ra danh sách rỗng: %v", m)
	}
}

// --- sai bị từ chối, database không đổi -------------------------------------------------------------------

func TestI034_DatMucSaiBiTuChoi(t *testing.T) {
	k := dung(t)
	tr := k.monCoNhan(t, "test-suất trứng")
	ngoai := k.monCoNhan(t, "test-suất ngoài combo")
	id := k.lap(t, "test-combo · "+t.Name(), 50000, phan{tr.mon, 2})
	const khong = 999999999
	truoc := k.soMuc(t)

	cac := []struct {
		body        any
		status      int
		code, field string
	}{
		// Hình — trước quyền và database (QC-14).
		{thanMuc(nil, muc{tr.mon, tr.nhieu, 1000}), 400, "invalid_request", "reason"},
		{thanMuc("  ", muc{tr.mon, tr.nhieu, 1000}), 400, "invalid_request", "reason"},
		{map[string]any{"reason": "test"}, 400, "invalid_request", "surcharges"},
		{thanMuc("test"), 400, "invalid_request", "surcharges"},
		{thanMuc("test", muc{0, tr.nhieu, 1000}), 400, "invalid_request", "surcharges[0].menu_item_id"},
		{thanMuc("test", muc{tr.mon, 0, 1000}), 400, "invalid_request", "surcharges[0].menu_option_id"},
		{thanMuc("test", muc{tr.mon, tr.nhieu, -1}), 400, "invalid_request", "surcharges[0].surcharge_vnd"},
		{thanMuc("test", muc{tr.mon, tr.nhieu, 1000.5}), 400, "invalid_request", "surcharges[0].surcharge_vnd"},
		{thanMuc("test", muc{tr.mon, tr.nhieu, nil}), 400, "invalid_request", "surcharges[0].surcharge_vnd"},
		{thanMuc("test", muc{tr.mon, tr.nhieu, 1000}, muc{tr.mon, tr.nhieu, 2000}), 400, "invalid_request", "surcharges[1].menu_option_id"},
		{"{", 400, "invalid_request", ""},
		// Miền — trong giao dịch, theo thứ tự phần tử.
		{thanMuc("test", muc{tr.mon, tr.nhieu, 1000}, muc{ngoai.mon, ngoai.nhieu, 1000}), 404, "menu_combo_item_not_found", "surcharges[1].menu_item_id"},
		{thanMuc("test", muc{tr.mon, khong, 1000}), 404, "menu_option_not_found", "surcharges[0].menu_option_id"},
		{thanMuc("test", muc{tr.mon, tr.la, 1000}), 422, "option_combination_invalid", "surcharges[0].menu_option_id"},
		{thanMuc("test", muc{tr.mon, ngoai.nhieu, 1000}), 422, "option_combination_invalid", "surcharges[0].menu_option_id"},
	}
	for _, c := range cac {
		tuChoi(t, k.datMuc(t, id, k.chu, c.body), c.status, c.code, c.field)
	}
	tuChoi(t, k.datMuc(t, khong, k.chu, thanMuc("test", muc{tr.mon, tr.nhieu, 1000})), http.StatusNotFound, "menu_combo_not_found", "")
	tuChoi(t, k.goi(t, "PUT", "/menu-combos/abc/surcharges", k.chu, thanMuc("test", muc{tr.mon, tr.nhieu, 1000})), http.StatusBadRequest, "invalid_request", "menu_combo_id")
	tuChoi(t, k.goi(t, "PUT", "/menu-combos/0/surcharges", k.chu, thanMuc("test", muc{tr.mon, tr.nhieu, 1000})), http.StatusBadRequest, "invalid_request", "menu_combo_id")
	if sau := k.soMuc(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	// Combo đã ẩn đứng yên.
	canDat(t, k.goi(t, "POST", fmt.Sprintf("/menu-combos/%d/hiding", id), k.chu, map[string]any{"reason": "test: ẩn"}), http.StatusOK)
	tuChoi(t, k.datMuc(t, id, k.chu, thanMuc("test", muc{tr.mon, tr.nhieu, 1000})), http.StatusConflict, "menu_combo_hidden", "")
	if sau := k.soMuc(t); sau != truoc {
		t.Fatalf("combo đã ẩn mà mức vẫn đổi: %s → %s", truoc, sau)
	}
}

// --- mức khoá như giá combo: hai đầu giờ bán tính là trong giờ (lượt tám vế 4) -----------------------------

func TestI034_KhongDoiMucComboTrongGioBan(t *testing.T) {
	k := dung(t)
	tr := k.monCoNhan(t, "test-suất trứng")
	id := k.lap(t, "test-combo · "+t.Name(), 50000, phan{tr.mon, 2})
	truoc := k.soMuc(t)
	for _, gio := range []time.Duration{k.mo, k.mo + time.Hour, k.dong} {
		k.datGio(t, gio)
		tuChoi(t, k.datMuc(t, id, k.chu, thanMuc("test: giữa buổi", muc{tr.mon, tr.nhieu, 1000})),
			http.StatusConflict, "menu_combo_surcharge_in_sales_hours", "")
	}
	if sau := k.soMuc(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}
	k.datGio(t, k.mo-time.Minute)
	canDat(t, k.datMuc(t, id, k.chu, thanMuc("test: trước buổi", muc{tr.mon, tr.nhieu, 1000})), http.StatusOK)
	k.datGio(t, k.dong+time.Minute)
	canDat(t, k.datMuc(t, id, k.chu, thanMuc("test: sau buổi", muc{tr.mon, tr.nhieu, 1500})), http.StatusOK)
}
