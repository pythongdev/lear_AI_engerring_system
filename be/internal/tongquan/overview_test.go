package tongquan

import (
	"encoding/json"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/nguyenlieu"
)

// P3A-09: test viết trước thân triển khai. Không cộng những đơn vị khác nhau thành một số suất.
func TestQC14_BayMucVaPhanRaBan(t *testing.T) {
	board := json.RawMessage(`{"read_at":"2026-10-15T01:00:00Z","rows":[
 {"station_code":"trang_banh","menu_component_id":1,"component_name":"bánh","filling_option_ids":[2],"parts":[{"dining_table_id":1,"served":2,"missing":3},{"dining_table_id":2,"served":1,"missing":4},{"sales_order_id":9,"served":40,"missing":50}]},
 {"station_code":"canh","menu_component_id":3,"component_name":"canh","filling_option_ids":[],"parts":[{"dining_table_id":1,"served":1,"missing":0}]}]}`)
	supplies := []nguyenlieu.ChiTiet{{Thu: nguyenlieu.Thu{ID: 1, PurchasedTotal: "10", UsedTotal: "3", Balance: "7"}, Entries: []nguyenlieu.ConSo{{EntryDate: "2026-10-14", Kind: "purchased"}}}}
	out, err := lap("2026-10-15", time.Date(2026, 10, 15, 1, 0, 0, 0, time.UTC), board, supplies)
	if err != nil {
		t.Fatal(err)
	}
	if len(out.ServedPortions.Rows) != 2 || out.ServedPortions.Rows[0].Quantity != 3 || out.MissingPortions.Rows[0].Quantity != 7 {
		t.Fatalf("sai phần tại bàn: %+v", out)
	}
	if out.ServedPortions.Rows[1].Quantity != 1 || out.MissingPortions.Rows[1].Quantity != 0 {
		t.Fatal("gộp canh với bánh")
	}
	b, _ := json.Marshal(out)
	var fields map[string]json.RawMessage
	if err := json.Unmarshal(b, &fields); err != nil {
		t.Fatal(err)
	}
	for _, key := range []string{"serving_guests", "served_portions", "missing_portions", "sales_progress", "provisional_sales", "workers_present", "shortages"} {
		if _, ok := fields[key]; !ok {
			t.Fatalf("thiếu %s", key)
		}
	}
	if out.ProvisionalSales.Status != "unavailable" || out.ProvisionalSales.Name != "Tiền bán tạm tính" || out.WorkersPresent.Reason != "pos_headcount_source_missing" {
		t.Fatalf("bịa số: %s", b)
	}
	if out.Shortages.Supplies.Items[0].Balance != "7" || out.Shortages.Supplies.Items[0].Entries[0].EntryDate != "2026-10-14" {
		t.Fatal("mất nguồn sổ nguyên liệu")
	}
	for _, section := range []ChuaCo{out.ServingGuests, out.SalesProgress, out.ProvisionalSales, out.WorkersPresent, out.Shortages.Workers, out.Shortages.MenuItems} {
		if section.Status != "unavailable" || section.Name == "" || section.Reason == "" {
			t.Fatalf("chưa có phải có tên và lý do: %+v", section)
		}
	}
}

func TestI014_TamTinhKhongMangDoanhThuDaDoiSoat(t *testing.T) {
	// Bảng nhu cầu thay đổi trong ngày chưa đối soát không tạo hay sửa một số doanh thu.
	for _, board := range []string{`{"rows":[]}`, `{"rows":[{"station_code":"canh","component_name":"canh","filling_option_ids":[],"parts":[{"dining_table_id":1,"served":999,"missing":10}]}]}`} {
		out, err := lap("2026-10-15", time.Time{}, json.RawMessage(board), []nguyenlieu.ChiTiet{})
		if err != nil {
			t.Fatal(err)
		}
		b, _ := json.Marshal(out)
		for _, forbidden := range []string{"revenue", "amount_vnd", "expected_vnd"} {
			if strings.Contains(string(b), forbidden) {
				t.Fatalf("lẫn tiền đối soát hoặc bịa tạm tính: %s", b)
			}
		}
		if out.ProvisionalSales.Reason != "provisional_sales_formula_unspecified" {
			t.Fatal("tự suy công thức")
		}
	}
}

func TestQC14_NguonHongKhongThanhSoKhong(t *testing.T) {
	if _, err := lap("2026-10-15", time.Time{}, json.RawMessage(`{`), nil); err == nil {
		t.Fatal("nguồn hỏng phải báo lỗi")
	}
	out, err := lap("2026-10-15", time.Time{}, json.RawMessage(`{"rows":[]}`), []nguyenlieu.ChiTiet{})
	if err != nil || out.ServedPortions.Rows == nil || out.MissingPortions.Rows == nil || out.Shortages.Supplies.Items == nil {
		t.Fatal("danh sách rỗng phải là []")
	}
}
