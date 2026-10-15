// Test của hàm giá khi học combo (T-195, ADR-117 điểm 4 · 5; I-034 · I-010 · I-013 · I-009). Viết TRƯỚC khi hàm học
// combo. Giá một combo = giá combo tại mốc + với MỖI suất, tổng mức chủ quán đặt cho lựa chọn của suất ấy theo món ấy
// của combo; lựa chọn chưa đặt mức cộng 0đ (lời đóng U-096); mỗi suất chọn nhân riêng theo luật của món (lượt tám).
// Menu ở đây là menu GIẢ riêng (test-…): không một con giá nào của quán, không chạm menu thật các ca §4.8 đọc.
package gia_test

import (
	"context"
	"errors"
	"net/http"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

type menuGia struct {
	cuon, trung, ngoai               int64 // hai món của combo, một món ngoài combo
	thit, chay, thuong, nhieu        int64
	combo, ciCuon, ciTrung, mucNhieu int64
}

// dungCombo dựng: hai món giả cùng mang Nhân · Lượng nhân (Lượng nhân chỉ có khi Nhân = Thịt); combo 1 cuốn + 2 trứng
// giá 5000; mức: trứng · Nhiều = 700, cuốn · Nhiều = 300. Khi test xong: món ngừng bán, combo ẩn.
func (k khung) dungCombo(t *testing.T) menuGia {
	t.Helper()
	var m menuGia
	ten := " · " + t.Name()
	if err := k.coVet(func(tx pgx.Tx) error {
		q := func(sql string, out *int64, args ...any) {
			if err := tx.QueryRow(k.ctx, sql, args...).Scan(out); err != nil {
				t.Fatalf("%s: %v", sql, err)
			}
		}
		var banh, gNhan, gLuong int64
		q(`INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 100000, true) RETURNING id`, &banh, "test-bánh"+ten)
		for _, x := range []struct {
			ten string
			id  *int64
		}{{"test-suất cuốn", &m.cuon}, {"test-suất trứng", &m.trung}, {"test-suất ngoài", &m.ngoai}} {
			q(`INSERT INTO shop.menu_item (name) VALUES ($1) RETURNING id`, x.id, x.ten+ten)
			if _, err := tx.Exec(k.ctx, `INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 2)`, *x.id, banh); err != nil {
				return err
			}
		}
		q(`INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id`, &gNhan, "test-Nhân"+ten)
		q(`INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id`, &gLuong, "test-Lượng nhân"+ten)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Thịt', 1000) RETURNING id`, &m.thit, gNhan)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Chay', 0) RETURNING id`, &m.chay, gNhan)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Thường', 0) RETURNING id`, &m.thuong, gLuong)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Nhiều', 1000) RETURNING id`, &m.nhieu, gLuong)
		if _, err := tx.Exec(k.ctx, `INSERT INTO shop.option_group_prerequisite (option_group_id, menu_option_id) VALUES ($1, $2)`, gLuong, m.thit); err != nil {
			return err
		}
		for _, mon := range []int64{m.cuon, m.trung, m.ngoai} {
			if _, err := tx.Exec(k.ctx, `INSERT INTO shop.menu_item_option_group (menu_item_id, option_group_id) VALUES ($1, $2), ($1, $3)`, mon, gNhan, gLuong); err != nil {
				return err
			}
		}
		q(`INSERT INTO shop.menu_combo (name, price_vnd) VALUES ($1, 5000) RETURNING id`, &m.combo, "test-combo"+ten)
		q(`INSERT INTO shop.menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES ($1, $2, 1) RETURNING id`, &m.ciCuon, m.combo, m.cuon)
		q(`INSERT INTO shop.menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES ($1, $2, 2) RETURNING id`, &m.ciTrung, m.combo, m.trung)
		q(`INSERT INTO shop.menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES ($1, $2, 700) RETURNING id`, &m.mucNhieu, m.ciTrung, m.nhieu)
		var bo int64
		q(`INSERT INTO shop.menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES ($1, $2, 300) RETURNING id`, &bo, m.ciCuon, m.nhieu)
		return nil
	}); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_ = k.coVet(func(tx pgx.Tx) error {
			if _, err := tx.Exec(context.Background(), `UPDATE shop.menu_item SET discontinued_at = now() WHERE id = ANY($1) AND discontinued_at IS NULL`,
				[]int64{m.cuon, m.trung, m.ngoai}); err != nil {
				return err
			}
			_, err := tx.Exec(context.Background(), `UPDATE shop.menu_combo SET hidden_at = now(), hidden_by_person_id = (SELECT id FROM shop.person ORDER BY id LIMIT 1)
				WHERE id = $1 AND hidden_at IS NULL`, m.combo)
			return err
		})
	})
	return m
}

func suat(mon int64, so int, ids ...int64) map[string]any {
	if ids == nil {
		ids = []int64{}
	}
	return map[string]any{"menu_item_id": mon, "quantity": so, "option_ids": ids}
}

func dongCombo(combo int64, so int, cac ...map[string]any) map[string]any {
	ds := make([]any, 0, len(cac))
	for _, c := range cac {
		ds = append(ds, c)
	}
	return map[string]any{"menu_combo_id": combo, "quantity": so, "portions": ds}
}

// --- giá combo = giá combo + mức của từng suất; chưa đặt mức thì 0đ (I-034 vế 1) ---------------------------

func TestI034_GiaComboTheoTungSuat(t *testing.T) {
	k := dung(t)
	m := k.dungCombo(t)
	ca := []struct {
		ten    string
		dong   map[string]any
		kyVong int64
	}{
		{"một trứng Nhiều, một trứng Thường, cuốn Chay", dongCombo(m.combo, 1,
			suat(m.trung, 1, m.thit, m.nhieu), suat(m.trung, 1, m.thit, m.thuong), suat(m.cuon, 1, m.chay)), 5000 + 700},
		{"hai trứng Nhiều — mức cộng mỗi suất một lần", dongCombo(m.combo, 1,
			suat(m.trung, 2, m.thit, m.nhieu), suat(m.cuon, 1, m.chay)), 5000 + 2*700},
		{"cuốn Nhiều mang mức của MÓN cuốn trong combo", dongCombo(m.combo, 1,
			suat(m.trung, 2, m.chay), suat(m.cuon, 1, m.thit, m.nhieu)), 5000 + 300},
		{"Thịt chưa đặt mức ⇒ 0đ, không phải phụ thu món lẻ", dongCombo(m.combo, 1,
			suat(m.trung, 2, m.thit, m.thuong), suat(m.cuon, 1, m.thit, m.thuong)), 5000},
		{"hai combo — bốn suất trứng, hai suất cuốn", dongCombo(m.combo, 2,
			suat(m.trung, 3, m.thit, m.nhieu), suat(m.trung, 1, m.chay), suat(m.cuon, 2, m.chay)), 2*5000 + 3*700},
	}
	for _, c := range ca {
		r := tinhThu(k, t, c.dong)
		t.Logf("%s ⇒ %d %v", c.ten, r.status, r.body)
		if r.status != http.StatusOK {
			t.Fatalf("%s: muốn 200, nhận %d %v", c.ten, r.status, r.body)
		}
		if got := so(t, r.body["total_vnd"], "total_vnd"); got != c.kyVong {
			t.Fatalf("%s: tổng %d, muốn %d", c.ten, got, c.kyVong)
		}
		d := dongThu(t, r, 0)
		if so(t, d["menu_combo_id"], "menu_combo_id") != m.combo || so(t, d["line_total_vnd"], "line_total_vnd") != c.kyVong {
			t.Fatalf("%s: dòng combo sai: %v", c.ten, d)
		}
		soLuong := so(t, d["quantity"], "quantity")
		if so(t, d["unit_price_vnd"], "unit_price_vnd") != 5000 {
			t.Fatalf("%s: đơn giá dòng combo phải là giá combo, không cộng giá món: %v", c.ten, d)
		}
		ps, _ := d["portions"].([]any)
		var tongSuat int64
		for _, x := range ps {
			p := x.(map[string]any)
			don := so(t, p["unit_price_vnd"], "unit_price_vnd")
			var cong int64
			for _, o := range p["options"].([]any) {
				cong += so(t, o.(map[string]any)["surcharge_vnd"], "surcharge_vnd")
			}
			if don != cong {
				t.Fatalf("%s: đơn giá suất %d khác tổng mức đã chụp %d: %v", c.ten, don, cong, p)
			}
			if cs, _ := p["components"].([]any); len(cs) == 0 {
				t.Fatalf("%s: suất phải mang thành phần cho bếp: %v", c.ten, p)
			}
			tongSuat += so(t, p["line_total_vnd"], "line_total_vnd")
		}
		if soLuong*5000+tongSuat != c.kyVong {
			t.Fatalf("%s: giá combo × số combo + tổng suất ≠ tổng dòng", c.ten)
		}
	}
	// Giá gửi kèm bị bỏ (I-013).
	dong := dongCombo(m.combo, 1, suat(m.trung, 2, m.thit, m.nhieu), suat(m.cuon, 1, m.chay))
	dong["unit_price_vnd"], dong["price_vnd"] = 0, 0
	if r := tinhThu(k, t, dong); so(t, r.body["total_vnd"], "total_vnd") != 5000+2*700 {
		t.Fatalf("giá gửi kèm không bị bỏ: %v", r.body)
	}
	// Combo và món lẻ trong cùng một lượt: tổng cộng cả hai.
	r := tinhThu(k, t, dong, suat(m.ngoai, 1, m.chay))
	if r.status != http.StatusOK || so(t, r.body["total_vnd"], "total_vnd") != 5000+2*700+200000 {
		t.Fatalf("combo cạnh món lẻ tính sai: %v", r.body)
	}
}

// --- từ chối theo thứ tự, không sửa hộ (ADR-117 điểm 4; I-010 áp từng suất) -------------------------------

func TestI034_ComboSaiBiTuChoi(t *testing.T) {
	k := dung(t)
	m := k.dungCombo(t)
	du := []map[string]any{suat(m.trung, 2, m.chay), suat(m.cuon, 1, m.chay)}
	ca := []struct {
		ten          string
		dong         map[string]any
		status       int
		code, truong string
	}{
		{"combo không có", dongCombo(9000000000, 1, du...), 404, "menu_combo_not_found", "lines[0].menu_combo_id"},
		{"số combo 0", dongCombo(m.combo, 0, du...), 400, "invalid_request", "lines[0].quantity"},
		{"không suất nào", dongCombo(m.combo, 1), 400, "invalid_request", "lines[0].portions"},
		{"suất số lượng 0", dongCombo(m.combo, 1, suat(m.trung, 0, m.chay), suat(m.trung, 2, m.chay), suat(m.cuon, 1, m.chay)),
			400, "invalid_request", "lines[0].portions[0].quantity"},
		{"vừa món vừa combo", map[string]any{"menu_combo_id": m.combo, "menu_item_id": m.cuon, "quantity": 1, "portions": []any{du[0], du[1]}},
			400, "invalid_request", "lines[0].menu_item_id"},
		{"suất món ngoài combo", dongCombo(m.combo, 1, suat(m.trung, 2, m.chay), suat(m.cuon, 1, m.chay), suat(m.ngoai, 1, m.chay)),
			422, "combo_portions_mismatch", "lines[0].portions[2].menu_item_id"},
		{"thiếu một suất trứng", dongCombo(m.combo, 1, suat(m.trung, 1, m.chay), suat(m.cuon, 1, m.chay)),
			422, "combo_portions_mismatch", "lines[0].portions"},
		{"thừa một suất cuốn", dongCombo(m.combo, 1, suat(m.trung, 2, m.chay), suat(m.cuon, 2, m.chay)),
			422, "combo_portions_mismatch", "lines[0].portions"},
		{"Chay + Nhiều trong một suất", dongCombo(m.combo, 1, suat(m.trung, 1, m.chay), suat(m.trung, 1, m.chay, m.nhieu), suat(m.cuon, 1, m.chay)),
			422, "option_combination_invalid", "lines[0].portions[1].option_ids"},
		{"suất thiếu nhân", dongCombo(m.combo, 1, suat(m.trung, 2), suat(m.cuon, 1, m.chay)),
			422, "option_combination_invalid", "lines[0].portions[0].option_ids"},
		{"lựa chọn không có", dongCombo(m.combo, 1, suat(m.trung, 2, 9000000000), suat(m.cuon, 1, m.chay)),
			404, "menu_option_not_found", "lines[0].portions[0].option_ids"},
	}
	for _, c := range ca {
		r := tinhThu(k, t, c.dong)
		t.Logf("%s ⇒ %d %v", c.ten, r.status, r.body)
		tuChoi(t, r, c.status, c.code, c.truong)
	}
	// Món của combo ngừng bán ⇒ từ chối ở suất của món ấy.
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, `UPDATE shop.menu_item SET discontinued_at = now() WHERE id = $1`, m.cuon)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	tuChoi(t, tinhThu(k, t, dongCombo(m.combo, 1, du...)), 409, "menu_item_discontinued", "lines[0].portions[1].menu_item_id")
	// Combo đã ẩn ⇒ từ chối.
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, `UPDATE shop.menu_combo SET hidden_at = now(), hidden_by_person_id = (SELECT id FROM shop.person ORDER BY id LIMIT 1) WHERE id = $1`, m.combo)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	tuChoi(t, tinhThu(k, t, dongCombo(m.combo, 1, du...)), 409, "menu_combo_hidden", "lines[0].menu_combo_id")
}

// --- đọc tại mốc: giá combo và mức trước lần sửa (I-009, ADR-099 — nhập bù dùng giá ngày bán) ---------------

func TestI034_GiaComboTaiMoc(t *testing.T) {
	k := dung(t)
	m := k.dungCombo(t)
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	dong := []gia.DongYeuCau{{MenuComboID: m.combo, Quantity: 1, Portions: []gia.SuatYeuCau{
		{MenuItemID: m.trung, Quantity: 2, OptionIDs: []int64{m.thit, m.nhieu}},
		{MenuItemID: m.cuon, Quantity: 1, OptionIDs: []int64{m.chay}}}}}
	// Mốc lấy từ đồng hồ của database: lúc lập combo và lúc sửa đều do database ghi.
	var truoc time.Time
	if err := k.owner.QueryRow(k.ctx, "SELECT clock_timestamp()").Scan(&truoc); err != nil {
		t.Fatal(err)
	}
	if err := k.coVet(func(tx pgx.Tx) error {
		if _, err := tx.Exec(k.ctx, `UPDATE shop.menu_combo SET price_vnd = 9000 WHERE id = $1`, m.combo); err != nil {
			return err
		}
		_, err := tx.Exec(k.ctx, `UPDATE shop.menu_combo_item_option_surcharge SET surcharge_vnd = 900 WHERE id = $1`, m.mucNhieu)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	cu, err := gia.Tinh(k.ctx, pool, dong, truoc)
	if err != nil {
		t.Fatal(err)
	}
	moi, err := gia.Tinh(k.ctx, pool, dong)
	if err != nil {
		t.Fatal(err)
	}
	if cu.TotalVnd != 5000+2*700 || moi.TotalVnd != 9000+2*900 {
		t.Fatalf("giá tại mốc trước lần sửa %d (muốn %d), hiện hành %d (muốn %d)", cu.TotalVnd, 5000+2*700, moi.TotalVnd, 9000+2*900)
	}
	// Combo lập SAU mốc ⇒ chưa có tại mốc.
	_, err = gia.Tinh(k.ctx, pool, dong, truoc.Add(-time.Hour))
	var e apierr.Error
	if !errors.As(err, &e) || e.Code != apierr.CodeMenuComboNotFound {
		t.Fatalf("combo lập sau mốc phải là menu_combo_not_found, nhận %v", err)
	}
}

// --- menu bày combo đang bán: giá combo, món kèm số phần, nhóm và mức từng lựa chọn (ADR-117 điểm 5) ----------

func TestI034_MenuBayCombo(t *testing.T) {
	k := dung(t)
	m := k.dungCombo(t)
	tim := func() map[string]any {
		r := k.goi(t, "GET", "/menu", nil)
		if r.status != http.StatusOK {
			t.Fatalf("GET /menu: %d %v", r.status, r.body)
		}
		ds, ok := r.body["combos"].([]any)
		if !ok {
			t.Fatalf("menu thiếu combos: %v", r.body)
		}
		for _, x := range ds {
			c := x.(map[string]any)
			if so(t, c["menu_combo_id"], "menu_combo_id") == m.combo {
				return c
			}
		}
		return nil
	}
	c := tim()
	if c == nil || so(t, c["price_vnd"], "price_vnd") != 5000 {
		t.Fatalf("combo đang bán không có trên menu hay sai giá: %v", c)
	}
	items := c["items"].([]any)
	if len(items) != 2 {
		t.Fatalf("combo phải bày hai món: %v", items)
	}
	trung := items[1].(map[string]any)
	if so(t, trung["menu_item_id"], "menu_item_id") != m.trung || so(t, trung["quantity"], "quantity") != 2 {
		t.Fatalf("món thứ hai phải là trứng × 2 theo thứ tự lập: %v", trung)
	}
	if gs, _ := trung["option_groups"].([]any); len(gs) != 2 {
		t.Fatalf("món trong combo phải bày nhóm tuỳ chọn của nó: %v", trung)
	}
	var thay bool
	for _, x := range trung["surcharges"].([]any) {
		s := x.(map[string]any)
		if so(t, s["menu_option_id"], "menu_option_id") == m.nhieu && so(t, s["surcharge_vnd"], "surcharge_vnd") == 700 {
			thay = true
		}
	}
	if !thay {
		t.Fatalf("menu không bày mức của trứng · Nhiều: %v", trung)
	}
	// Combo có món ngừng bán hay combo đã ẩn không bày.
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, `UPDATE shop.menu_item SET discontinued_at = now() WHERE id = $1`, m.cuon)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	if c := tim(); c != nil {
		t.Fatalf("combo có món ngừng bán vẫn bày: %v", c)
	}
}
