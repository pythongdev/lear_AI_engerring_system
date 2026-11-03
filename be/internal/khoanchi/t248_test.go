package khoanchi_test

import (
	"fmt"
	"net/http"
	"os"
	"strings"
	"testing"
)

func TestI029_KhoanConDoiTenXoaMemVaTong(t *testing.T) {
	k := dung(t)
	category := k.loai(t, "test-T248-category", true)
	other := k.loai(t, "test-T248-other", false)
	itemResponse := k.goi(t, "POST", "/expense-items", k.chu, map[string]any{"expense_category_id": category, "name": "Bột gạo"})
	canDat(t, itemResponse, 201)
	item := itemResponse.so(t, "expense_item_id")
	create := map[string]any{"expense_category_id": category, "expense_item_id": item, "amount_vnd": 70000, "paid_date": "2033-05-21"}
	tuChoi(t, k.goi(t, "POST", "/expenses", k.quay, create), 403, "owner_only", "")
	create["expense_category_id"] = other
	tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, create), 404, "expense_item_not_found", "")
	create["expense_category_id"] = category
	entryResponse := k.goi(t, "POST", "/expenses", k.chu, create)
	canDat(t, entryResponse, 201)
	entry := entryResponse.so(t, "expense_id")
	reason := map[string]any{"reason": "Ghi nhầm"}
	// Khoản tồn tại ở ngày khác vẫn chặn xoá danh mục/khoản con.
	tuChoi(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-items/%d", item), k.chu, reason), 409, "expense_item_in_use", "")
	tuChoi(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-categories/%d", category), k.chu, reason), 409, "expense_category_in_use", "")
	rename := map[string]any{"name": "Bột gạo mới", "reason": "Sửa tên"}
	canDat(t, k.goi(t, "PUT", fmt.Sprintf("/expense-items/%d", item), k.chu, rename), 200)
	list := k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-05-01&to=2033-05-31&expense_category_id=%d", category), k.chu, nil)
	canDat(t, list, 200)
	if list.so(t, "total_vnd") != 70000 {
		t.Fatal(list.body)
	}
	totals := list.body["item_totals"].([]any)
	if len(totals) != 1 || totals[0].(map[string]any)["total_vnd"] != float64(70000) || totals[0].(map[string]any)["last_paid_date"] != "2033-05-21" {
		t.Fatal(totals)
	}
	expenses := list.body["expenses"].([]any)
	if expenses[0].(map[string]any)["item_name"] != "Bột gạo mới" {
		t.Fatal(expenses)
	}
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expenses/%d", entry), k.chu, reason), 204)
	if k.so(t, "SELECT count(*) FROM shop.expense WHERE id=$1 AND deleted_at IS NOT NULL", entry) != 1 {
		t.Fatal("mất hàng hoặc dấu xoá")
	}
	if k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code='expense' AND target_row=$1 AND reason='Ghi nhầm' AND after_image->>'deleted_at' IS NOT NULL", entry) != 1 {
		t.Fatal("thiếu vết xoá")
	}
	list = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-05-01&to=2033-05-31&expense_category_id=%d", category), k.chu, nil)
	if list.so(t, "total_vnd") != 0 || len(list.body["expenses"].([]any)) != 0 {
		t.Fatal(list.body)
	}
	create["reason"] = "Sửa sau xoá"
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/expenses/%d", entry), k.chu, create), 404, "expense_not_found", "")
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-items/%d", item), k.chu, reason), 204)
	tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, create), 404, "expense_item_not_found", "")
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-categories/%d", category), k.chu, reason), 204)
	tuChoi(t, k.goi(t, "POST", "/expense-items", k.chu, map[string]any{"expense_category_id": category, "name": "Tên mới"}), 404, "expense_category_not_found", "")
}
func TestI021_XoaKhoanBoKhoiKetVaChanNgayDaKy(t *testing.T) {
	k := dung(t)
	const day = "2033-05-22"
	k.ngayKet(t, day, 500000, 500000, false)
	category := k.loai(t, "test-T248-till", true)
	entry := k.ghi(t, category, 50000, day).so(t, "expense_id")
	if k.vePhai(t, day) != -50000 || k.vePhaiDoiChieu(t, day) != -50000 {
		t.Fatal("thiếu khoản chi trong két")
	}
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expenses/%d", entry), k.chu, map[string]any{"reason": "Ghi nhầm"}), 204)
	if k.vePhai(t, day) != 0 || k.vePhaiDoiChieu(t, day) != 0 {
		t.Fatal("khoản đã xoá vẫn nằm trong két")
	}
	const signed = "2033-05-23"
	tillEntry := k.ghi(t, category, 1000, signed).so(t, "expense_id")
	private := k.loai(t, "test-T248-private", false)
	privateEntry := k.ghi(t, private, 2000, signed).so(t, "expense_id")
	k.ngayKet(t, signed, 500000, 499000, true)
	for _, id := range []int64{tillEntry, privateEntry} {
		tuChoi(t, k.goi(t, "DELETE", fmt.Sprintf("/expenses/%d", id), k.chu, map[string]any{"reason": "Muốn xoá"}), http.StatusConflict, "sale_day_reconciled", "")
		if k.so(t, "SELECT count(*) FROM shop.expense WHERE id=$1 AND deleted_at IS NULL", id) != 1 {
			t.Fatal("lời từ chối vẫn xoá")
		}
	}
}

func TestI029_XoaMucRongGiuVetKhoanConVaChanLui(t *testing.T) {
	k := dung(t)
	category := k.loai(t, "test-T248-empty-category", false)
	response := k.goi(t, "POST", "/expense-items", k.chu, map[string]any{"expense_category_id": category, "name": "Khoản con chưa ghi"})
	canDat(t, response, 201)
	item := response.so(t, "expense_item_id")
	// Không cấp các cửa quản trị mới cho người thường.
	for _, req := range []struct {
		method, path string
		body         any
	}{
		{"PUT", fmt.Sprintf("/expense-categories/%d", category), map[string]any{"name": "Khác", "reason": "Sửa"}},
		{"DELETE", fmt.Sprintf("/expense-categories/%d", category), map[string]any{"reason": "Xoá"}},
		{"POST", "/expense-items", map[string]any{"name": "Khác", "expense_category_id": category}},
		{"PUT", fmt.Sprintf("/expense-items/%d", item), map[string]any{"name": "Khác", "reason": "Sửa"}},
		{"DELETE", fmt.Sprintf("/expense-items/%d", item), map[string]any{"reason": "Xoá"}},
	} {
		tuChoi(t, k.goi(t, req.method, req.path, k.quay, req.body), 403, "owner_only", "")
	}
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-categories/%d", category), k.chu, map[string]any{"reason": "Không dùng mục"}), 204)
	if k.so(t, "SELECT count(*) FROM shop.expense_item WHERE id=$1 AND deleted_at IS NOT NULL", item) != 1 {
		t.Fatal("mục rỗng không xoá mềm khoản con")
	}
	if k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code='expense_item' AND target_row=$1 AND reason='Không dùng mục'", item) != 1 {
		t.Fatal("thiếu vết khoản con khi xoá mục")
	}
	source, err := os.ReadFile("../../../db/migrations/20261024140000_khoan_chi_chi_tiet.down.sql")
	if err != nil {
		t.Fatal(err)
	}
	tx, err := k.owner.Begin(k.ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(k.ctx)
	if _, err = tx.Exec(k.ctx, "SET LOCAL search_path = shop, public"); err != nil {
		t.Fatal(err)
	}
	if _, err = tx.Exec(k.ctx, string(source)); err == nil || !strings.Contains(err.Error(), "cannot remove expense item or deletion history") {
		t.Fatalf("lùi không được làm mất lịch sử: %v", err)
	}
}
