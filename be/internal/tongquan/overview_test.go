package tongquan

import (
	"encoding/json"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/nguyenlieu"
)

// Không cộng những đơn vị khác nhau thành một số suất; T-199 giữ cả online.
func TestQC14_BayMucVaPhanRaBan(t *testing.T) {
	board := json.RawMessage(`{"read_at":"2026-10-15T01:00:00Z","rows":[
 {"station_code":"trang_banh","menu_component_id":1,"component_name":"bánh","filling_option_ids":[2],"parts":[{"dining_table_id":1,"served":2,"missing":3},{"dining_table_id":2,"served":1,"missing":4},{"sales_order_id":9,"served":40,"missing":50}]},
 {"station_code":"canh","menu_component_id":3,"component_name":"canh","filling_option_ids":[],"parts":[{"dining_table_id":1,"served":1,"missing":0}]}]}`)
	supplies := []nguyenlieu.Thu{{ID: 1, PurchasedTotal: "10", UsedTotal: "3", Balance: "7"}}
	out, err := lap("2026-10-15", time.Date(2026, 10, 15, 1, 0, 0, 0, time.UTC), board, supplies)
	if err != nil {
		t.Fatal(err)
	}
	if len(out.ServedPortions.Rows) != 3 || out.ServedPortions.Rows[0].Quantity != 3 || out.MissingPortions.Rows[0].Quantity != 7 {
		t.Fatalf("sai phần tại bàn: %+v", out)
	}
	if out.ServedPortions.Rows[2].Quantity != 1 || out.MissingPortions.Rows[2].Quantity != 0 {
		t.Fatal("gộp canh với bánh")
	}
	if out.ServedPortions.Rows[0].Group != "in_store" || out.ServedPortions.Rows[1].Group != "online" || out.ServedPortions.Rows[1].Quantity != 40 || out.MissingPortions.Rows[1].Quantity != 50 {
		t.Fatalf("mất online: %+v", out)
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
	if out.ProvisionalSales.Status != "available" || out.ProvisionalSales.Name != "Tiền bán tạm tính" || out.WorkersPresent.Reason != "workers_present_missing" {
		t.Fatalf("bịa số: %s", b)
	}
	if strings.Contains(string(b), `"entries"`) {
		t.Fatalf("tổng quan không được mang sổ ngày: %s", b)
	}
	if out.Shortages.Supplies.Items[0].Balance != "7" {
		t.Fatal("mất nguồn sổ nguyên liệu")
	}
	for _, section := range []MucNguoi{out.WorkersPresent, out.Shortages.Workers} {
		if section.Status != "unavailable" || section.Name == "" || section.Reason == "" {
			t.Fatalf("chưa có phải có tên và lý do: %+v", section)
		}
	}
}

func TestI014_TamTinhKhongMangDoanhThuDaDoiSoat(t *testing.T) {
	// Bảng nhu cầu thay đổi trong ngày chưa đối soát không tạo hay sửa một số doanh thu.
	for _, board := range []string{`{"rows":[]}`, `{"rows":[{"station_code":"canh","component_name":"canh","filling_option_ids":[],"parts":[{"dining_table_id":1,"served":999,"missing":10}]}]}`} {
		out, err := lap("2026-10-15", time.Time{}, json.RawMessage(board), []nguyenlieu.Thu{})
		if err != nil {
			t.Fatal(err)
		}
		b, _ := json.Marshal(out)
		for _, forbidden := range []string{"revenue", "expected_vnd"} {
			if strings.Contains(string(b), forbidden) {
				t.Fatalf("lẫn tiền đối soát hoặc bịa tạm tính: %s", b)
			}
		}
		if out.ProvisionalSales.Name != "Tiền bán tạm tính" {
			t.Fatal("mất nhãn tạm tính")
		}
	}
}

func TestQC14_NguonHongKhongThanhSoKhong(t *testing.T) {
	if _, err := lap("2026-10-15", time.Time{}, json.RawMessage(`{`), nil); err == nil {
		t.Fatal("nguồn hỏng phải báo lỗi")
	}
	out, err := lap("2026-10-15", time.Time{}, json.RawMessage(`{"rows":[]}`), []nguyenlieu.Thu{})
	if err != nil || out.ServedPortions.Rows == nil || out.MissingPortions.Rows == nil || out.Shortages.Supplies.Items == nil {
		t.Fatal("danh sách rỗng phải là []")
	}
}

func TestQC14_ToiThieuVaNguoiChuaCo(t *testing.T) {
	out, err := lap("2088-01-01", time.Time{}, json.RawMessage(`{"rows":[]}`), []nguyenlieu.Thu{})
	if err != nil {
		t.Fatal(err)
	}
	out.apDung(soTong{ServedBanh: 7, MenuItems: []Mon{}})
	if out.SalesProgress.Status != "unavailable" || out.SalesProgress.Reason != "daily_minimum_missing" || out.SalesProgress.ServedBanh != nil || out.Shortages.Workers.MinimumWorkers != nil {
		t.Fatalf("bịa tối thiểu: %+v", out)
	}
	banh, workers := int32(100), int32(4)
	out.apDung(soTong{Serving: 3, ServedBanh: 7, MinimumBanh: &banh, MinimumWorkers: &workers, AmountVnd: 5800, MenuItems: []Mon{}})
	if out.ServingGuests.Quantity != 3 || out.SalesProgress.Status != "available" || *out.SalesProgress.ServedBanh != 7 || *out.SalesProgress.MinimumBanh != 100 || out.ProvisionalSales.AmountVnd != 5800 {
		t.Fatalf("sai tổng: %+v", out)
	}
	if out.Shortages.Workers.Status != "unavailable" || out.Shortages.Workers.Reason != "workers_present_missing" || *out.Shortages.Workers.MinimumWorkers != 4 {
		t.Fatal("tự tính thiếu người")
	}
}
