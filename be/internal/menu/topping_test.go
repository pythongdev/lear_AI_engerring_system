package menu_test

// T-210 — topping: chủ quán thêm lựa chọn vào nhóm có sẵn, tích nhóm nó mở, ẩn · bật lại (master_plan/shop-facts.md §8.9
// *QUẢN LÝ TOPPING*). Claude viết cùng lượt dựng cửa (2026-10-19). Giá đọc qua gia.Tinh — hàm tính giá duy nhất (I-013) — trên cùng database.

import (
	"errors"
	"fmt"
	"testing"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
)

func tinhThu(t *testing.T, k khung, mon int64, chon ...int64) (int64, apierr.Code) {
	t.Helper()
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	if chon == nil {
		chon = []int64{}
	}
	q, err := gia.Tinh(k.ctx, pool, []gia.DongYeuCau{{MenuItemID: mon, Quantity: 1, OptionIDs: chon}})
	var e apierr.Error
	if errors.As(err, &e) {
		return 0, e.Code
	}
	if err != nil {
		t.Fatal(err)
	}
	return q.TotalVnd, ""
}

func TestI010_ThemLuaChonVaoNhomCoSan(t *testing.T) {
	k := dung(t)
	chu, thuong := k.nguoi(t, "chủ", true), k.nguoi(t, "thường", false)
	m := k.menuGia(t)
	// Nhóm thứ hai chỉ mở khi chọn "thịt" — hình của Lượng nhân (luật 3 §4.6).
	luong := k.id(t, `INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id`, "test-lượng · "+t.Name())
	nhieu := k.id(t, `INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'nhiều', 1000) RETURNING id`, luong)
	k.id(t, `INSERT INTO shop.menu_item_option_group (menu_item_id, option_group_id) VALUES ($1, $2) RETURNING id`, m.mon, luong)
	k.id(t, `INSERT INTO shop.option_group_prerequisite (option_group_id, menu_option_id) VALUES ($1, $2) RETURNING id`, luong, m.thit)

	path := fmt.Sprintf("/option-groups/%d/options", m.nhom)
	tuChoi(t, k.goi(t, "POST", path, thuong, map[string]any{"name": "nấm", "surcharge_vnd": 1000}), 403, "owner_only", "")
	tuChoi(t, k.goi(t, "POST", "/option-groups/9000000000/options", chu, map[string]any{"name": "nấm", "surcharge_vnd": 1000}), 404, "option_group_not_found", "")
	tuChoi(t, k.goi(t, "POST", path, chu, map[string]any{"name": " ", "surcharge_vnd": 1000}), 400, "invalid_request", "name")
	tuChoi(t, k.goi(t, "POST", path, chu, map[string]any{"name": "nấm", "surcharge_vnd": -1}), 400, "invalid_request", "surcharge_vnd")
	tuChoi(t, k.goi(t, "POST", path, chu, map[string]any{"name": "nấm", "surcharge_vnd": 1000, "enables_option_group_ids": []int64{m.nhom}}), 400, "invalid_request", "enables_option_group_ids")
	tuChoi(t, k.goi(t, "POST", path, chu, map[string]any{"name": "thịt", "surcharge_vnd": 1000}), 409, "menu_option_name_taken", "")

	r := k.goi(t, "POST", path, chu, map[string]any{"name": "nấm", "surcharge_vnd": 1000, "enables_option_group_ids": []int64{luong}})
	if r.status != 201 || r.body["name"] != "nấm" || r.body["surcharge_vnd"] != float64(1000) {
		t.Fatalf("thêm lựa chọn: %v", r)
	}
	nam := int64(r.body["menu_option_id"].(float64))
	// Ba phần nhận nhân (3 cái bánh) × (1.000 nấm + 1.000 nhiều) + giá gốc 3×3.000 + 9.000 = 24.000.
	if gia, ma := tinhThu(t, k, m.mon, nam, nhieu); ma != "" || gia != 24000 {
		t.Fatalf("nấm + nhiều: muốn 24000, nhận %d %s", gia, ma)
	}
	if _, ma := tinhThu(t, k, m.mon, nam); ma != apierr.CodeOptionCombinationInvalid {
		t.Fatalf("nấm mở nhóm lượng mà không chọn lượng: muốn option_combination_invalid, nhận %s", ma)
	}
	// Không tích nhóm lượng: lựa chọn ấy như "chay" — chọn kèm lượng bị từ chối.
	r = k.goi(t, "POST", path, chu, map[string]any{"name": "chay nấm", "surcharge_vnd": 0})
	if r.status != 201 {
		t.Fatalf("thêm lựa chọn không tích: %v", r)
	}
	chayNam := int64(r.body["menu_option_id"].(float64))
	if gia, ma := tinhThu(t, k, m.mon, chayNam); ma != "" || gia != 18000 {
		t.Fatalf("chay nấm: muốn 18000, nhận %d %s", gia, ma)
	}
	if _, ma := tinhThu(t, k, m.mon, chayNam, nhieu); ma != apierr.CodeOptionCombinationInvalid {
		t.Fatalf("chay nấm + nhiều: muốn option_combination_invalid, nhận %s", ma)
	}
	d := k.goi(t, "GET", "/option-groups", chu, nil)
	if d.status != 200 {
		t.Fatalf("GET /option-groups: %v", d)
	}
	// T-211: mỗi nhóm nói món nào mang nó — nhóm nhân và nhóm lượng của test đều chỉ do món giả mang.
	for _, raw := range d.body["option_groups"].([]any) {
		g := raw.(map[string]any)
		gid := int64(g["option_group_id"].(float64))
		if gid != m.nhom && gid != luong {
			continue
		}
		mon, _ := g["menu_item_ids"].([]any)
		if len(mon) != 1 || int64(mon[0].(float64)) != m.mon {
			t.Fatalf("nhóm %d: muốn menu_item_ids [%d], nhận %v", gid, m.mon, g["menu_item_ids"])
		}
	}
	tuChoi(t, k.goi(t, "GET", "/option-groups", thuong, nil), 403, "owner_only", "")
}

func TestI010_AnVaBatLaiLuaChon(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ", true)
	m := k.menuGia(t)
	an := fmt.Sprintf("/menu-options/%d/hiding", m.thit)
	bat := fmt.Sprintf("/menu-options/%d/unhiding", m.thit)
	tuChoi(t, k.goi(t, "POST", an, chu, map[string]any{"reason": " "}), 400, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "POST", bat, chu, map[string]any{"reason": "test"}), 409, "menu_option_not_hidden", "")
	tuChoi(t, k.goi(t, "POST", "/menu-options/9000000000/hiding", chu, map[string]any{"reason": "test"}), 404, "menu_option_not_found", "")
	if gia, ma := tinhThu(t, k, m.mon, m.thit); ma != "" || gia != 21000 {
		t.Fatalf("trước khi ẩn: muốn 21000, nhận %d %s", gia, ma)
	}
	if r := k.goi(t, "POST", an, chu, map[string]any{"reason": "test hết thịt"}); r.status != 200 {
		t.Fatalf("ẩn: %v", r)
	}
	if n := k.id(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_option' AND target_row=$1
		AND person_id=$2 AND reason='test hết thịt' AND after_image->>'hidden_at' IS NOT NULL`, m.thit, chu); n != 1 {
		t.Fatalf("ẩn phải để một vết đủ người và lý do, nhận %d", n)
	}
	if _, ma := tinhThu(t, k, m.mon, m.thit); ma != apierr.CodeMenuOptionHidden {
		t.Fatalf("lựa chọn đã ẩn: muốn menu_option_hidden, nhận %s", ma)
	}
	tuChoi(t, k.goi(t, "POST", an, chu, map[string]any{"reason": "test"}), 409, "menu_option_hidden", "")
	if coTrenMenu(t, k, m.mon, m.thit) {
		t.Fatal("GET /menu còn bày lựa chọn đã ẩn")
	}
	if r := k.goi(t, "POST", bat, chu, map[string]any{"reason": "test có thịt lại"}); r.status != 200 {
		t.Fatalf("bật lại: %v", r)
	}
	if !coTrenMenu(t, k, m.mon, m.thit) {
		t.Fatal("bật lại mà GET /menu không bày lựa chọn")
	}
	if gia, ma := tinhThu(t, k, m.mon, m.thit); ma != "" || gia != 21000 {
		t.Fatalf("sau khi bật lại: muốn 21000, nhận %d %s", gia, ma)
	}
	// Lựa chọn mặc định không ẩn được (§8.9, cách đọc của phiên).
	k.id(t, `UPDATE shop.menu_option SET is_default = true WHERE id = $1 RETURNING id`, m.chay)
	tuChoi(t, k.goi(t, "POST", fmt.Sprintf("/menu-options/%d/hiding", m.chay), chu, map[string]any{"reason": "test"}), 409, "menu_option_is_default", "")
	// Trả cờ về: database test dùng chung, và TestI010_MenuChoBietMacDinhDeChonSan đọc mặc định của mọi nhóm trên menu.
	k.id(t, `UPDATE shop.menu_option SET is_default = false WHERE id = $1 RETURNING id`, m.chay)
}

// coTrenMenu: đường đọc của GET /menu (gia.Service.DocMenu) có bày lựa chọn ấy cho món ấy không.
func coTrenMenu(t *testing.T, k khung, mon, luaChon int64) bool {
	t.Helper()
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	m, err := gia.NewService(pool).DocMenu(k.ctx)
	if err != nil {
		t.Fatal(err)
	}
	for _, it := range m.Items {
		if it.MenuItemID != mon {
			continue
		}
		for _, g := range it.OptionGroups {
			for _, o := range g.Options {
				if o.MenuOptionID == luaChon {
					return true
				}
			}
		}
	}
	return false
}
