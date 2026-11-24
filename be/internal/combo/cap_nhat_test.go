package combo_test

import (
	"fmt"
	"net/http"
	"testing"
	"time"

	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

func TestI032_CapNhatComboGiuDongCuVaQuyen(t *testing.T) {
	k := dung(t)
	a := k.mon(t, "test-món A")
	b := k.mon(t, "test-món B")
	c := k.mon(t, "test-món C")
	id := k.lap(t, "test-combo cũ · "+t.Name(), 50000, phan{a, 2}, phan{b, 1})
	for _, mon := range []int64{a, b, c} {
		thanhPhan := k.so(t, "INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 10000, false) RETURNING id", fmt.Sprintf("thành phần %d · %s", mon, t.Name()))
		if err := k.coVet(func(tx pgx.Tx) error {
			_, err := tx.Exec(k.ctx, "INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 1)", mon, thanhPhan)
			return err
		}); err != nil {
			t.Fatal(err)
		}
	}
	mocCu := time.Now()
	time.Sleep(10 * time.Millisecond)
	path := fmt.Sprintf("/menu-combos/%d", id)
	body := map[string]any{"name": "test-combo mới · " + t.Name(), "price_vnd": 60000,
		"items":  []map[string]any{{"menu_item_id": a, "quantity": 3}, {"menu_item_id": c, "quantity": 1}},
		"reason": "đổi thực đơn"}
	tuChoi(t, k.goi(t, "PUT", path, k.quay, body), http.StatusForbidden, "owner_only", "")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"name": "mới", "price_vnd": 60000,
		"items": []map[string]any{{"menu_item_id": a, "quantity": 1}, {"menu_item_id": a, "quantity": 2}}, "reason": "test"}),
		http.StatusBadRequest, "invalid_request", "items[1].menu_item_id")
	before := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_row=$1 AND target_table_code='menu_combo'", id)
	k.datGio(t, k.mo+time.Hour)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, body), http.StatusConflict, "menu_combo_update_in_sales_hours", "")
	// Từ chối phải giữ cả tên, giá, thành phần và vết.
	if n := k.so(t, "SELECT count(*) FROM shop.menu_combo WHERE id=$1 AND name=$2 AND price_vnd=50000", id, "test-combo cũ · "+t.Name()); n != 1 {
		t.Fatal("trong giờ đã đổi combo")
	}
	if n := k.so(t, "SELECT count(*) FROM shop.menu_combo_item WHERE menu_combo_id=$1 AND retired_at IS NULL AND ((menu_item_id=$2 AND quantity=2) OR (menu_item_id=$3 AND quantity=1))", id, a, b); n != 2 {
		t.Fatal("trong giờ đã đổi thành phần")
	}
	if n := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_row=$1 AND target_table_code='menu_combo'", id); n != before {
		t.Fatal("từ chối sinh vết")
	}
	k.datGio(t, k.dong+time.Hour)
	out := k.goi(t, "PUT", path, k.chu, body)
	canDat(t, out, http.StatusOK)
	if out.body["name"] != body["name"] || out.so(t, "price_vnd") != 60000 {
		t.Fatalf("combo sau sửa: %v", out.body)
	}
	items, ok := out.body["items"].([]any)
	if !ok || len(items) != 2 || items[0].(map[string]any)["quantity"] != float64(3) ||
		items[1].(map[string]any)["menu_item_id"] != float64(c) {
		t.Fatalf("thành phần sau sửa: %v", out.body["items"])
	}
	doc := k.goi(t, "GET", "/menu-combos", k.chu, nil)
	canDat(t, doc, http.StatusOK)
	found := false
	for _, raw := range doc.body["combos"].([]any) {
		current := raw.(map[string]any)
		if current["menu_combo_id"] != float64(id) {
			continue
		}
		found = true
		for _, rawItem := range current["items"].([]any) {
			if rawItem.(map[string]any)["menu_item_id"] == float64(b) {
				t.Fatal("đọc combo còn món đã rút")
			}
		}
	}
	if !found {
		t.Fatal("đọc thiếu combo vừa sửa")
	}
	if n := k.so(t, `SELECT count(*) FROM shop.menu_combo_item WHERE menu_combo_id=$1 AND menu_item_id=$2 AND retired_at IS NOT NULL`, id, b); n != 1 {
		t.Fatalf("món rút phải còn dòng lịch sử: %d", n)
	}
	if n := k.so(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_combo_item' AND reason='đổi thực đơn' AND person_id=$1 AND target_row IN (SELECT id FROM shop.menu_combo_item WHERE menu_combo_id=$2)`, k.chu, id); n < 2 {
		t.Fatalf("thiếu vết đổi số phần và rút món: %d", n)
	}
	if n := k.so(t, `SELECT count(*) FROM shop.record_revision
		WHERE target_table_code='menu_combo' AND target_row=$1 AND reason='đổi thực đơn' AND person_id=$2
		AND before_image ? 'menu_combo_item'
		AND jsonb_array_length(after_image->'menu_combo_item') = jsonb_array_length(before_image->'menu_combo_item') + 1`, id, k.chu); n != 1 {
		t.Fatalf("thiếu vết thêm món vào combo đã có: %d", n)
	}
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	quote := func(at ...time.Time) (gia.KetQua, error) {
		phan := []gia.SuatYeuCau{{MenuItemID: a, Quantity: 3}, {MenuItemID: c, Quantity: 1}}
		if len(at) > 0 {
			phan = []gia.SuatYeuCau{{MenuItemID: a, Quantity: 2}, {MenuItemID: b, Quantity: 1}}
		}
		return gia.Tinh(k.ctx, pool, []gia.DongYeuCau{{MenuComboID: id, Quantity: 1, Portions: phan}}, at...)
	}
	giaCu, err := quote(mocCu)
	if err != nil {
		t.Fatalf("báo giá tại mốc cũ: %v", err)
	}
	if giaCu.TotalVnd != 50000 || giaCu.Lines[0].ItemName != "test-combo cũ · "+t.Name() || len(giaCu.Lines[0].Portions) != 2 || giaCu.Lines[0].Portions[1].MenuItemID != b {
		t.Fatalf("giá/ thành phần cũ không giữ: %+v", giaCu)
	}
	giaMoi, err := quote()
	if err != nil {
		t.Fatalf("báo giá mới: %v", err)
	}
	if giaMoi.TotalVnd != 60000 || giaMoi.Lines[0].ItemName != body["name"] || len(giaMoi.Lines[0].Portions) != 2 || giaMoi.Lines[0].Portions[1].MenuItemID != c {
		t.Fatalf("giá/ thành phần mới sai: %+v", giaMoi)
	}
	// Thêm lại món đã rút tạo dòng mới, không làm sống lại phụ thu hoặc vết cũ.
	body["items"] = []map[string]any{{"menu_item_id": a, "quantity": 3}, {"menu_item_id": b, "quantity": 1}}
	canDat(t, k.goi(t, "PUT", path, k.chu, body), http.StatusOK)
	if n := k.so(t, `SELECT count(*) FROM shop.menu_combo_item WHERE menu_combo_id=$1 AND menu_item_id=$2`, id, b); n != 2 {
		t.Fatalf("món thêm lại phải có dòng mới: %d", n)
	}
	canDat(t, k.goi(t, "POST", path+"/hiding", k.chu, map[string]any{"reason": "ẩn sau sửa"}), http.StatusOK)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, body), http.StatusConflict, "menu_combo_hidden", "")
}
