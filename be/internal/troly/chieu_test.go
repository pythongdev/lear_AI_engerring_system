// Test chiếu kết quả công cụ đọc nội bộ (CHAT-08, ADR-139 điểm 7(a) · 9 và Sửa đổi 2026-11-06; I-043). Claude viết TRƯỚC
// khi có code; Codex làm cho xanh, không sửa điều kiện kiểm. Không cần database: chạy được trong sandbox không có Docker.
//
// Hợp đồng Claude chốt trong test này (2026-11-06):
//   - troly.ChieuBangPhucVu(tongquan.BangVanHanh) (json.RawMessage, error) — kết quả của công cụ doc_bang_phuc_vu.
//     Hình: {"sale_date","read_at","sessions":[{"table_session_id","session_status","service_group","tables":[{"label"}],
//     "items":[{"component_name","options":[{"option_group_name","option_name"}],"extra_filling","ordered","served","missing"}]}],
//     "empty_tables":[{"label"}]}. Không serve_history (mang tên người đem ra), không số tiền, không id người.
//     Danh sách rỗng là [] (không null).
//   - troly.ChieuTongQuan(tongquan.TongQuan) (json.RawMessage, error) — kết quả của công cụ doc_tong_quan.
//     Giữ nguyên hình GET /owner-overview TRỪ: bỏ person_id · person_name ở workers_present và shortages.workers; dòng phần ăn
//     (served_portions.rows · missing_portions.rows) chỉ còn group · station_code · component_name · quantity; nguyên liệu
//     (shortages.supplies.items) chỉ còn name · purchase_unit · balance · reminder_status · check_reminder; món thiếu
//     (shortages.menu_items.items) chỉ còn name · ordered · served. Trường omitempty của nguồn giữ omitempty.
//   - Mỗi khoá ở mọi tầng của kết quả nằm trong danh sách được phép của công cụ ấy (dưới đây) — danh sách được phép, không
//     phải danh sách cấm: thêm trường ở nguồn không tự lọt ra model.
package troly_test

import (
	"encoding/json"
	"sort"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/nguyenlieu"
	"banhcuon/be/internal/tongquan"
	"banhcuon/be/internal/troly"
)

var duocPhepBangPhucVu = tapKhoa("sale_date", "read_at", "sessions", "table_session_id", "session_status", "service_group",
	"tables", "label", "items", "component_name", "options", "option_group_name", "option_name", "extra_filling", "ordered",
	"served", "missing", "empty_tables")

var duocPhepTongQuan = tapKhoa("sale_date", "read_at", "serving_guests", "status", "name", "quantity", "served_portions", "rows",
	"group", "station_code", "component_name", "missing_portions", "sales_progress", "reason", "served_banh", "minimum_banh",
	"provisional_sales", "amount_vnd", "workers_present", "worker_count", "declared_at", "minimum_workers", "short",
	"missing_workers", "shortages", "supplies", "items", "purchase_unit", "balance", "reminder_status", "check_reminder",
	"workers", "menu_items", "ordered", "served")

func tapKhoa(k ...string) map[string]bool {
	m := map[string]bool{}
	for _, x := range k {
		m[x] = true
	}
	return m
}

// khoaLa trả mọi khoá ở mọi tầng không nằm trong tập được phép.
func khoaLa(t *testing.T, raw json.RawMessage, duocPhep map[string]bool) []string {
	t.Helper()
	var v any
	if err := json.Unmarshal(raw, &v); err != nil {
		t.Fatalf("kết quả công cụ không phải JSON: %s", raw)
	}
	la := map[string]bool{}
	var di func(any)
	di = func(x any) {
		switch y := x.(type) {
		case map[string]any:
			for k, con := range y {
				if !duocPhep[k] {
					la[k] = true
				}
				di(con)
			}
		case []any:
			for _, con := range y {
				di(con)
			}
		}
	}
	di(v)
	out := make([]string, 0, len(la))
	for k := range la {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}

func i64(v int64) *int64   { return &v }
func i32(v int32) *int32   { return &v }
func chu(v string) *string { return &v }
func dung(v bool) *bool    { return &v }

const tenNguoiLam = "Nguyễn Thị Lan"

// ADR-139 điểm 7(a), §8.11 điểm 5: bảng phục vụ tới model không mang tên người đem ra, không số tiền, số thiếu giữ nguyên.
func TestI043_ChieuBangPhucVuChiTruongDuocPhep(t *testing.T) {
	moc := time.Date(2026, 11, 6, 11, 30, 0, 0, time.UTC)
	b := tongquan.BangVanHanh{
		SaleDate: "2026-11-06", ReadAt: moc,
		Sessions: []tongquan.PhienBan{{
			TableSessionID: 41, SessionStatus: "open", ServiceGroup: "tai_ban",
			Tables:        []tongquan.BanTrong{{DiningTableID: 3, Label: "Bàn 3"}},
			OrderTotalVnd: 185000, ServedAmountVnd: 90000,
			Items: []tongquan.ThuCuaBan{{
				MenuComponentID: i64(9), ComponentName: "Bánh cuốn", FillingOptionIDs: []int64{12},
				Options: []tongquan.LuaChonChup{{OptionGroupName: "Nhân", OptionName: "Thịt"}}, ExtraFilling: true,
				Ordered: 5, Served: 3, Missing: 2,
			}},
		}},
		EmptyTables: []tongquan.BanTrong{{DiningTableID: 4, Label: "Bàn 4"}},
		ServeHistory: []tongquan.LanDemRa{{ServedAt: moc, PersonID: 77, PersonName: tenNguoiLam, DiningTableID: 3,
			TableLabel: "Bàn 3", StationCode: "trang", ComponentName: "Bánh cuốn", Quantity: 3}},
	}
	raw, err := troly.ChieuBangPhucVu(b)
	if err != nil {
		t.Fatal(err)
	}
	if la := khoaLa(t, raw, duocPhepBangPhucVu); len(la) != 0 {
		t.Fatalf("khoá ngoài danh sách được phép: %v\n%s", la, raw)
	}
	for _, cam := range []string{tenNguoiLam, "185000", "90000", "serve_history", "person"} {
		if strings.Contains(string(raw), cam) {
			t.Fatalf("kết quả tới model còn %q: %s", cam, raw)
		}
	}
	var out struct {
		SaleDate string    `json:"sale_date"`
		ReadAt   time.Time `json:"read_at"`
		Sessions []struct {
			TableSessionID int64  `json:"table_session_id"`
			SessionStatus  string `json:"session_status"`
			ServiceGroup   string `json:"service_group"`
			Tables         []struct {
				Label string `json:"label"`
			} `json:"tables"`
			Items []struct {
				ComponentName string `json:"component_name"`
				Options       []struct {
					OptionGroupName string `json:"option_group_name"`
					OptionName      string `json:"option_name"`
				} `json:"options"`
				ExtraFilling             bool `json:"extra_filling"`
				Ordered, Served, Missing int64
			} `json:"items"`
		} `json:"sessions"`
		EmptyTables []struct {
			Label string `json:"label"`
		} `json:"empty_tables"`
	}
	if err := json.Unmarshal(raw, &out); err != nil {
		t.Fatal(err)
	}
	if out.SaleDate != "2026-11-06" || !out.ReadAt.Equal(moc) || len(out.Sessions) != 1 || len(out.EmptyTables) != 1 ||
		out.EmptyTables[0].Label != "Bàn 4" {
		t.Fatalf("mất ngày bán, mốc đọc hay bàn trống: %s", raw)
	}
	p := out.Sessions[0]
	if p.TableSessionID != 41 || p.SessionStatus != "open" || p.ServiceGroup != "tai_ban" || len(p.Tables) != 1 ||
		p.Tables[0].Label != "Bàn 3" || len(p.Items) != 1 {
		t.Fatalf("mất phiên bàn: %s", raw)
	}
	it := p.Items[0]
	if it.ComponentName != "Bánh cuốn" || len(it.Options) != 1 || it.Options[0].OptionName != "Thịt" ||
		it.Options[0].OptionGroupName != "Nhân" || !it.ExtraFilling || it.Ordered != 5 || it.Served != 3 || it.Missing != 2 {
		t.Fatalf("số thiếu phải là đúng số backend trả: %s", raw)
	}

	rong, err := troly.ChieuBangPhucVu(tongquan.BangVanHanh{SaleDate: "2026-11-06", ReadAt: moc})
	if err != nil {
		t.Fatal(err)
	}
	var r map[string]json.RawMessage
	if err := json.Unmarshal(rong, &r); err != nil {
		t.Fatal(err)
	}
	if string(r["sessions"]) != "[]" || string(r["empty_tables"]) != "[]" {
		t.Fatalf("danh sách rỗng phải là [], không null — model không được đọc null thành hết việc: %s", rong)
	}
}

// ADR-139 điểm 7(a), §8.11 điểm 5: tổng quan chủ quán tới model không mang tên hay id người khai số người.
func TestI043_ChieuTongQuanBoNguoi(t *testing.T) {
	moc := time.Date(2026, 11, 6, 11, 30, 0, 0, time.UTC)
	nguoi := tongquan.MucNguoi{Status: "available", Name: "Số người đang làm", WorkerCount: i32(4), PersonID: i64(77),
		PersonName: chu(tenNguoiLam), DeclaredAt: &moc, MinimumWorkers: i32(5), Short: dung(true), MissingWorkers: i32(1)}
	phan := tongquan.CacPhan{Status: "available", ReadAt: moc, Rows: []tongquan.Phan{{Group: "banh_cuon", StationCode: "trang",
		MenuComponentID: i64(9), ComponentName: "Bánh cuốn", FillingOptionIDs: []int64{12}, Quantity: 7}}}
	tq := tongquan.TongQuan{
		SaleDate: "2026-11-06", ReadAt: moc,
		ServingGuests:    tongquan.SoPhien{Status: "available", Name: "Khách đang phục vụ", Quantity: 6},
		ServedPortions:   phan,
		MissingPortions:  phan,
		SalesProgress:    tongquan.TienDo{Status: "available", Name: "Tiến độ bán", ServedBanh: i64(120), MinimumBanh: i32(300)},
		ProvisionalSales: tongquan.TamTinh{Status: "available", Name: "Doanh thu tạm tính", AmountVnd: 2450000},
		WorkersPresent:   nguoi,
		Shortages: tongquan.Thieu{
			Supplies: tongquan.NguyenLieu{Status: "available", Items: []nguyenlieu.Thu{{ID: 5, Name: "Bột gạo",
				PurchaseUnit: chu("kg"), Balance: "2.5", ReminderStatus: "low", CheckReminder: true, ReminderRatio: "0.2",
				PurchasedTotal: "10", UsedTotal: "7.5"}}},
			Workers:   nguoi,
			MenuItems: tongquan.ThieuMon{Status: "available", Items: []tongquan.Mon{{MenuItemID: i64(2), Name: "Canh bánh cuốn", Ordered: 4, Served: 1}}},
		},
	}
	raw, err := troly.ChieuTongQuan(tq)
	if err != nil {
		t.Fatal(err)
	}
	if la := khoaLa(t, raw, duocPhepTongQuan); len(la) != 0 {
		t.Fatalf("khoá ngoài danh sách được phép: %v\n%s", la, raw)
	}
	if strings.Contains(string(raw), tenNguoiLam) || strings.Contains(string(raw), "person") {
		t.Fatalf("kết quả tới model còn người khai: %s", raw)
	}
	var out struct {
		SaleDate         string `json:"sale_date"`
		ProvisionalSales struct {
			AmountVnd int64 `json:"amount_vnd"`
		} `json:"provisional_sales"`
		WorkersPresent struct {
			Name           string `json:"name"`
			WorkerCount    *int32 `json:"worker_count"`
			MissingWorkers *int32 `json:"missing_workers"`
		} `json:"workers_present"`
		MissingPortions struct {
			Rows []struct {
				ComponentName string `json:"component_name"`
				Quantity      int64  `json:"quantity"`
			} `json:"rows"`
		} `json:"missing_portions"`
		Shortages struct {
			Supplies struct {
				Items []struct {
					Name    string `json:"name"`
					Balance string `json:"balance"`
				} `json:"items"`
			} `json:"supplies"`
			Workers struct {
				WorkerCount *int32 `json:"worker_count"`
			} `json:"workers"`
			MenuItems struct {
				Items []struct {
					Name            string `json:"name"`
					Ordered, Served int64
				} `json:"items"`
			} `json:"menu_items"`
		} `json:"shortages"`
	}
	if err := json.Unmarshal(raw, &out); err != nil {
		t.Fatal(err)
	}
	if out.SaleDate != "2026-11-06" || out.ProvisionalSales.AmountVnd != 2450000 || out.WorkersPresent.WorkerCount == nil ||
		*out.WorkersPresent.WorkerCount != 4 || out.WorkersPresent.MissingWorkers == nil || *out.WorkersPresent.MissingWorkers != 1 ||
		out.WorkersPresent.Name != "Số người đang làm" {
		t.Fatalf("mất số của tổng quan: %s", raw)
	}
	if len(out.MissingPortions.Rows) != 1 || out.MissingPortions.Rows[0].Quantity != 7 || out.MissingPortions.Rows[0].ComponentName != "Bánh cuốn" ||
		len(out.Shortages.Supplies.Items) != 1 || out.Shortages.Supplies.Items[0].Balance != "2.5" ||
		out.Shortages.Workers.WorkerCount == nil || *out.Shortages.Workers.WorkerCount != 4 ||
		len(out.Shortages.MenuItems.Items) != 1 || out.Shortages.MenuItems.Items[0].Ordered != 4 || out.Shortages.MenuItems.Items[0].Served != 1 {
		t.Fatalf("mất phần ăn, nguyên liệu hay món thiếu: %s", raw)
	}
}
