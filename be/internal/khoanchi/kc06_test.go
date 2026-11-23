// Test KC-06 (ADR-147 điểm 1–7, 12; I-021 · I-025 · I-026 · I-029 · I-046): các cửa ghi của phần gộp Kho và Nguyên
// liệu vào Khoản chi. Claude viết TRƯỚC code; Codex làm cho xanh mà không sửa điều kiện kiểm nào. Ngày dùng ở đây
// thuộc tháng 4/2033, không test nào khác của gói chạm; đồng hồ quán vẫn đặt 2033-06-30 (dung).
//
// Hình hợp đồng Claude chốt cho KC-06 (phiếu ../lean_wt/_claude_logs/KC-06/phieu.md):
//   - POST /expense-categories nhận thêm tracks_supply (bắt buộc, kiểm sau paid_from_till); mục trả tracks_supply.
//   - POST /expense-items: mục theo dõi ⇒ supply_item_id bắt buộc, không gửi name (tên lấy từ sổ); mục thường ⇒
//     không gửi supply_item_id. Khoản con trả supply_item_id (null khi không nối).
//   - PUT /expense-items/{id} đổi tên khoản con nối thì đổi luôn tên thứ trong sổ, cùng giao dịch.
//   - DELETE /expense-items/{id} của khoản con nối = ngừng dùng (được cả khi đã có tiền chi); POST
//     /expense-items/{id}/reopen gỡ dấu ngừng; PUT /expense-items/{id}/category chuyển mục.
//   - POST /expenses · PUT /expenses/{id} nhận received_date; POST /expenses nhận purchased_measure.
//   - POST /supply-expense-items thêm thứ + khoản con + tuỳ chọn khoản chi và con số mua vào, nguyên khối.
//   - GET /supply-items trả thêm expense_item_id · expense_category_id · stopped_at của mỗi thứ.
package khoanchi_test

import (
	"fmt"
	"net/http"
	"testing"
)

// loaiLuong tạo một mục chi có theo dõi lượng qua cửa.
func (k khung) loaiLuong(t *testing.T, ten string, tuKet bool) int64 {
	t.Helper()
	r := k.goi(t, "POST", "/expense-categories", k.chu, map[string]any{
		"name": ten + " · " + t.Name(), "paid_from_till": tuKet, "tracks_supply": true})
	canDat(t, r, http.StatusCreated)
	if r.body["tracks_supply"] != true || r.body["paid_from_till"] != tuKet {
		t.Fatalf("mục mới không mang đúng cờ: %v", r.body)
	}
	return r.so(t, "expense_category_id")
}

// thuSo tạo một thứ trong sổ qua cửa sổ cũ: nó đứng ở nhóm Chưa xếp mục cho tới khi được xếp.
func (k khung) thuSo(t *testing.T, ten, donVi string) int64 {
	t.Helper()
	r := k.goi(t, "POST", "/supply-items", k.chu, map[string]any{"name": ten + " · " + t.Name(), "purchase_unit": donVi})
	canDat(t, r, http.StatusCreated)
	return r.so(t, "supply_item_id")
}

func (k khung) xep(t *testing.T, loai, thu int64) traVe {
	t.Helper()
	return k.goi(t, "POST", "/expense-items", k.chu, map[string]any{"expense_category_id": loai, "supply_item_id": thu})
}

// muaVao trả con số mua vào của (thứ, ngày) theo phần nghìn, -1 khi chưa có con số.
func (k khung) muaVao(t *testing.T, thu int64, ngay string) int64 {
	t.Helper()
	return k.so(t, `SELECT COALESCE((SELECT (entered_measure * 1000)::bigint FROM shop.supply_day_entry
		WHERE supply_item_id = $1 AND entry_date = $2::date AND kind_code = 'purchased'), -1)`, thu, ngay)
}

// demGop đếm bốn bảng mà các cửa gộp ghi — để chứng minh một lời từ chối không để lại nửa kết quả.
func (k khung) demGop(t *testing.T) string {
	t.Helper()
	return fmt.Sprintf("%d/%d/%d/%d",
		k.so(t, "SELECT count(*) FROM shop.supply_item"),
		k.so(t, "SELECT count(*) FROM shop.expense_item"),
		k.so(t, "SELECT count(*) FROM shop.expense"),
		k.so(t, "SELECT count(*) FROM shop.supply_day_entry"))
}

// timThu đọc một thứ trong GET /supply-items.
func (k khung) timThu(t *testing.T, thu int64) map[string]any {
	t.Helper()
	r := k.goi(t, "GET", "/supply-items", k.chu, nil)
	canDat(t, r, http.StatusOK)
	ds, _ := r.body["supply_items"].([]any)
	for _, x := range ds {
		m, _ := x.(map[string]any)
		if id, _ := m["supply_item_id"].(float64); int64(id) == thu {
			return m
		}
	}
	t.Fatalf("thứ %d không có trong danh sách sổ", thu)
	return nil
}

// timKhoanCon đọc khoản con đang dùng trong GET /expense-categories; nil khi không thấy dưới mục ấy.
func (k khung) timKhoanCon(t *testing.T, loai, con int64) map[string]any {
	t.Helper()
	r := k.goi(t, "GET", "/expense-categories", k.chu, nil)
	canDat(t, r, http.StatusOK)
	cs, _ := r.body["expense_categories"].([]any)
	for _, c := range cs {
		m, _ := c.(map[string]any)
		if id, _ := m["expense_category_id"].(float64); int64(id) != loai {
			continue
		}
		if _, co := m["tracks_supply"]; !co {
			t.Fatalf("mục thiếu trường tracks_supply: %v", m)
		}
		items, _ := m["items"].([]any)
		for _, it := range items {
			im, _ := it.(map[string]any)
			if id, _ := im["expense_item_id"].(float64); int64(id) == con {
				if _, co := im["supply_item_id"]; !co {
					t.Fatalf("khoản con thiếu trường supply_item_id: %v", im)
				}
				return im
			}
		}
	}
	return nil
}

func lyDo(s string) map[string]any { return map[string]any{"reason": s} }

// --- A1: cờ theo dõi lượng khai lúc tạo mục --------------------------------------------------------------

func TestI029_KC06_MucChiKhaiTheoDoiLuongLucTao(t *testing.T) {
	k := dung(t)
	for _, body := range []string{
		`{"name":"test-kc06-thiếu cờ","paid_from_till":false}`,
		`{"name":"test-kc06-cờ null","paid_from_till":false,"tracks_supply":null}`,
		`{"name":"test-kc06-cờ chữ","paid_from_till":false,"tracks_supply":"true"}`,
	} {
		tuChoi(t, k.goi(t, "POST", "/expense-categories", k.chu, body), http.StatusBadRequest, "invalid_request", "tracks_supply")
	}
	luong := k.loaiLuong(t, "test-kc06-mục lượng", false)
	thuong := k.loai(t, "test-kc06-mục thường", false)
	r := k.goi(t, "GET", "/expense-categories", k.chu, nil)
	canDat(t, r, http.StatusOK)
	cs, _ := r.body["expense_categories"].([]any)
	gap := map[int64]any{}
	for _, c := range cs {
		m, _ := c.(map[string]any)
		id, _ := m["expense_category_id"].(float64)
		gap[int64(id)] = m["tracks_supply"]
	}
	if gap[luong] != true || gap[thuong] != false {
		t.Fatalf("cờ đọc lại sai: lượng=%v thường=%v", gap[luong], gap[thuong])
	}
}

// --- A1 · I-046: xếp mục nối đúng một thứ, một tên ---------------------------------------------------------

func TestI046_KC06_XepMucNoiDungMotThuMotTen(t *testing.T) {
	k := dung(t)
	luong := k.loaiLuong(t, "test-kc06-xếp", false)
	luong2 := k.loaiLuong(t, "test-kc06-xếp-2", false)
	thuong := k.loai(t, "test-kc06-xếp-thường", false)
	gao := k.thuSo(t, "test-kc06-gạo", "kg")
	k.thuSo(t, "test-kc06-nếp", "kg")

	// Chưa xếp: thứ có trong sổ, chưa nối khoản con nào.
	if m := k.timThu(t, gao); m["expense_item_id"] != nil || m["expense_category_id"] != nil || m["stopped_at"] != nil {
		t.Fatalf("thứ chưa xếp phải có expense_item_id/expense_category_id/stopped_at null: %v", m)
	}
	for _, f := range []string{"expense_item_id", "expense_category_id", "stopped_at"} {
		if _, co := k.timThu(t, gao)[f]; !co {
			t.Fatalf("thứ trong sổ thiếu trường %s", f)
		}
	}

	truoc := k.demGop(t)
	tuChoi(t, k.xep(t, thuong, gao), http.StatusBadRequest, "invalid_request", "supply_item_id")
	tuChoi(t, k.goi(t, "POST", "/expense-items", k.chu, map[string]any{"expense_category_id": luong, "name": "test-kc06-không nối"}),
		http.StatusBadRequest, "invalid_request", "supply_item_id")
	tuChoi(t, k.goi(t, "POST", "/expense-items", k.chu, map[string]any{"expense_category_id": luong, "supply_item_id": gao, "name": "tên khác"}),
		http.StatusBadRequest, "invalid_request", "name")
	tuChoi(t, k.xep(t, luong, 999999999), http.StatusNotFound, "supply_item_not_found", "")
	if sau := k.demGop(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	r := k.xep(t, luong, gao)
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "expense_item_id")
	if r.body["name"] != "test-kc06-gạo · "+t.Name() || r.so(t, "supply_item_id") != gao || r.so(t, "expense_category_id") != luong {
		t.Fatalf("khoản con xếp mục phải mang tên và mã của thứ: %v", r.body)
	}
	// Một thứ đứng dưới nhiều nhất một khoản con, kể cả ở mục theo dõi khác.
	tuChoi(t, k.xep(t, luong2, gao), http.StatusConflict, "supply_item_already_linked", "")
	tuChoi(t, k.xep(t, luong, gao), http.StatusConflict, "supply_item_already_linked", "")

	if im := k.timKhoanCon(t, luong, con); im == nil || im["supply_item_id"] != float64(gao) {
		t.Fatalf("khoản con đọc lại thiếu nối: %v", im)
	}
	if m := k.timThu(t, gao); m["expense_item_id"] != float64(con) || m["expense_category_id"] != float64(luong) {
		t.Fatalf("sổ đọc lại thiếu khoản con nối: %v", m)
	}
	thuongCon := k.khoanCon(t, thuong, "test-kc06-khoản thường · "+t.Name())
	if im := k.timKhoanCon(t, thuong, thuongCon); im == nil || im["supply_item_id"] != nil {
		t.Fatalf("khoản con của mục thường phải có supply_item_id null: %v", im)
	}

	// Một tên: đổi tên khoản con nối đổi luôn tên thứ trong sổ, có vết.
	vet := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'supply_item'")
	moi := "test-kc06-gạo tẻ · " + t.Name()
	r = k.goi(t, "PUT", fmt.Sprintf("/expense-items/%d", con), k.chu, map[string]any{"name": moi, "reason": "test: đổi tên"})
	canDat(t, r, http.StatusOK)
	if m := k.timThu(t, gao); m["name"] != moi {
		t.Fatalf("đổi tên khoản con mà sổ vẫn tên cũ: %v", m)
	}
	if sau := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'supply_item'"); sau <= vet {
		t.Fatalf("đổi tên thứ trong sổ không để vết (%d → %d)", vet, sau)
	}
	// Tên đã có ở một thứ khác trong sổ: từ chối, cả hai bên giữ tên.
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/expense-items/%d", con), k.chu,
		map[string]any{"name": "test-kc06-nếp · " + t.Name(), "reason": "test: trùng"}), http.StatusConflict, "supply_item_name_taken", "")
	if m := k.timThu(t, gao); m["name"] != moi {
		t.Fatalf("đổi tên bị từ chối mà sổ vẫn đổi: %v", m)
	}
	if im := k.timKhoanCon(t, luong, con); im == nil || im["name"] != moi {
		t.Fatalf("đổi tên bị từ chối mà khoản con vẫn đổi: %v", im)
	}
}

// --- A2 · I-025: ngừng dùng khoá phần lượng; dùng lại trả về đúng mục cùng lịch sử ---------------------------------

func TestI025_KC06_NgungDungKhoaPhanLuongVaDungLaiDuoc(t *testing.T) {
	k := dung(t)
	luong := k.loaiLuong(t, "test-kc06-ngừng", false)
	gao := k.thuSo(t, "test-kc06-gạo ngừng", "kg")
	r := k.xep(t, luong, gao)
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "expense_item_id")
	r = k.goi(t, "POST", "/supply-day-entries", k.chu, map[string]any{"supply_item_id": gao, "entry_date": "2033-04-02", "kind": "purchased", "measure": "10"})
	canDat(t, r, http.StatusCreated)
	conSo := r.so(t, "supply_day_entry_id")
	k.ghiCon(t, luong, con, 50000, "2033-04-02")

	tuChoi(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-items/%d", con), k.chu, lyDo("")), http.StatusBadRequest, "invalid_request", "reason")
	// Khoản con nối đã có tiền chi vẫn ngừng được (khác luật chặn của khoản con thường, T-247).
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-items/%d", con), k.chu, lyDo("test: thôi dùng")), http.StatusNoContent)

	if m := k.timThu(t, gao); m["stopped_at"] == nil || m["purchased_total"] != "10" {
		t.Fatalf("thứ đã ngừng phải còn trong sổ với dấu ngừng và tổng cũ: %v", m)
	}
	if k.timKhoanCon(t, luong, con) != nil {
		t.Fatalf("khoản con đã ngừng vẫn đứng trong danh mục đang dùng")
	}
	truoc := k.demGop(t)
	tuChoi(t, k.goi(t, "POST", "/supply-day-entries", k.chu, map[string]any{"supply_item_id": gao, "entry_date": "2033-04-03", "kind": "used", "measure": "2"}),
		http.StatusConflict, "supply_item_stopped", "")
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/supply-day-entries/%d", conSo), k.chu, map[string]any{"measure": "11", "reason": "test: sửa"}),
		http.StatusConflict, "supply_item_stopped", "")
	tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, map[string]any{"expense_category_id": luong, "expense_item_id": con, "amount_vnd": 1000, "paid_date": "2033-04-03"}),
		http.StatusNotFound, "expense_item_not_found", "")
	if sau := k.demGop(t); sau != truoc {
		t.Fatalf("ghi vào thứ đã ngừng mà database vẫn đổi: %s → %s", truoc, sau)
	}
	// Tiền cũ đọc như cũ.
	r = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-04-01&to=2033-04-30&expense_category_id=%d", luong), k.chu, nil)
	canDat(t, r, http.StatusOK)
	if r.so(t, "total_vnd") != 50000 {
		t.Fatalf("khoản chi cũ của thứ đã ngừng phải còn trong tổng: %v", r.body)
	}

	// Dùng lại: có lý do, về đúng mục cũ, cùng toàn bộ lịch sử.
	tuChoi(t, k.goi(t, "POST", fmt.Sprintf("/expense-items/%d/reopen", con), k.chu, lyDo("  ")), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "POST", "/expense-items/999999999/reopen", k.chu, lyDo("test")), http.StatusNotFound, "expense_item_not_found", "")
	r = k.goi(t, "POST", fmt.Sprintf("/expense-items/%d/reopen", con), k.chu, lyDo("test: dùng lại"))
	canDat(t, r, http.StatusOK)
	if r.so(t, "expense_item_id") != con || r.so(t, "expense_category_id") != luong || r.so(t, "supply_item_id") != gao {
		t.Fatalf("dùng lại phải trả đúng khoản con, mục và thứ: %v", r.body)
	}
	if k.timKhoanCon(t, luong, con) == nil || k.timThu(t, gao)["stopped_at"] != nil {
		t.Fatalf("dùng lại mà khoản con hay thứ vẫn mang dấu ngừng")
	}
	canDat(t, k.goi(t, "POST", "/supply-day-entries", k.chu, map[string]any{"supply_item_id": gao, "entry_date": "2033-04-03", "kind": "used", "measure": "2"}), http.StatusCreated)
	tuChoi(t, k.goi(t, "POST", fmt.Sprintf("/expense-items/%d/reopen", con), k.chu, lyDo("test: lần hai")), http.StatusConflict, "expense_item_not_stopped", "")

	// Khoản con của mục thường giữ luật cũ: đã có tiền thì không xoá; đã xoá thì không "dùng lại".
	thuong := k.loai(t, "test-kc06-ngừng-thường", false)
	a := k.khoanCon(t, thuong, "test-kc06-thường-a · "+t.Name())
	b := k.khoanCon(t, thuong, "test-kc06-thường-b · "+t.Name())
	k.ghiCon(t, thuong, a, 1000, "2033-04-04")
	tuChoi(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-items/%d", a), k.chu, lyDo("test")), http.StatusConflict, "expense_item_in_use", "")
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-items/%d", b), k.chu, lyDo("test")), http.StatusNoContent)
	tuChoi(t, k.goi(t, "POST", fmt.Sprintf("/expense-items/%d/reopen", b), k.chu, lyDo("test")), http.StatusConflict, "expense_item_not_stopped", "")
}

// Mục theo dõi còn thứ đang dùng không xoá được: xoá mục sẽ ngừng thứ mà không ai chọn ngừng.
func TestI029_KC06_XoaMucTheoDoiConThuDangDungBiChan(t *testing.T) {
	k := dung(t)
	luong := k.loaiLuong(t, "test-kc06-xoá mục", false)
	gao := k.thuSo(t, "test-kc06-gạo xoá mục", "kg")
	r := k.xep(t, luong, gao)
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "expense_item_id")
	tuChoi(t, k.goi(t, "DELETE", fmt.Sprintf("/expense-categories/%d", luong), k.chu, lyDo("test")), http.StatusConflict, "expense_category_in_use", "")
	if k.timKhoanCon(t, luong, con) == nil || k.timThu(t, gao)["stopped_at"] != nil {
		t.Fatalf("xoá mục bị từ chối mà khoản con hay thứ vẫn đổi")
	}
}

// --- A2 · điểm 12: chuyển mục chỉ giữa hai mục cùng theo dõi lượng và cùng nguồn --------------------------------

func TestI021_KC06_ChuyenMucChiGiuaHaiMucCungNguonCungTheoDoi(t *testing.T) {
	k := dung(t)
	l1 := k.loaiLuong(t, "test-kc06-chuyển-1", false)
	l2 := k.loaiLuong(t, "test-kc06-chuyển-2", false)
	lKet := k.loaiLuong(t, "test-kc06-chuyển-két", true)
	thuong := k.loai(t, "test-kc06-chuyển-thường", false)
	thuong2 := k.loai(t, "test-kc06-chuyển-thường-2", false)
	gao := k.thuSo(t, "test-kc06-gạo chuyển", "kg")
	r := k.xep(t, l1, gao)
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "expense_item_id")
	k.ghiCon(t, l1, con, 10000, "2033-04-05")
	k.ghiCon(t, l1, con, 20000, "2033-04-06")
	r = k.goi(t, "POST", "/expenses", k.chu, map[string]any{"expense_category_id": l1, "expense_item_id": con, "amount_vnd": 999, "paid_date": "2033-04-06"})
	canDat(t, r, http.StatusCreated)
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expenses/%d", r.so(t, "expense_id")), k.chu, lyDo("test: ghi nhầm")), http.StatusNoContent)

	path := fmt.Sprintf("/expense-items/%d/category", con)
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"expense_category_id": l2}), http.StatusBadRequest, "invalid_request", "reason")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"expense_category_id": 0, "reason": "test"}), http.StatusBadRequest, "invalid_request", "expense_category_id")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"expense_category_id": 999999999, "reason": "test"}), http.StatusNotFound, "expense_category_not_found", "")
	// Khác nguồn sẽ viết lại nguồn của tiền đã chi (I-021); mục thường không nhận thứ có theo dõi lượng.
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"expense_category_id": lKet, "reason": "test"}), http.StatusConflict, "expense_item_move_not_allowed", "")
	tuChoi(t, k.goi(t, "PUT", path, k.chu, map[string]any{"expense_category_id": thuong, "reason": "test"}), http.StatusConflict, "expense_item_move_not_allowed", "")

	r = k.goi(t, "PUT", path, k.chu, map[string]any{"expense_category_id": l2, "reason": "test: xếp lại"})
	canDat(t, r, http.StatusOK)
	if r.so(t, "expense_category_id") != l2 || r.so(t, "supply_item_id") != gao {
		t.Fatalf("chuyển mục trả sai: %v", r.body)
	}
	r = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-04-01&to=2033-04-30&expense_category_id=%d", l2), k.chu, nil)
	canDat(t, r, http.StatusOK)
	if ds, _ := r.body["expenses"].([]any); len(ds) != 2 || r.so(t, "total_vnd") != 30000 {
		t.Fatalf("tiền đã chi phải theo thứ sang mục mới: %v", r.body)
	}
	r = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-04-01&to=2033-04-30&expense_category_id=%d", l1), k.chu, nil)
	canDat(t, r, http.StatusOK)
	if r.so(t, "total_vnd") != 0 {
		t.Fatalf("mục cũ còn tiền của thứ đã chuyển: %v", r.body)
	}
	// Kể cả khoản đã xoá mềm cũng đổi mục — khoá ngoại (khoản con, mục) áp cho mọi dòng.
	if n := k.so(t, "SELECT count(*) FROM shop.expense WHERE expense_item_id = $1 AND expense_category_id <> $2", con, l2); n != 0 {
		t.Fatalf("%d khoản chi của thứ còn đứng ở mục cũ", n)
	}
	if m := k.timThu(t, gao); m["expense_category_id"] != float64(l2) {
		t.Fatalf("sổ đọc lại mục cũ sau khi chuyển: %v", m)
	}

	// Chỉ thứ có theo dõi lượng mới chuyển mục; khoản con thường không có cửa này.
	tc := k.khoanCon(t, thuong, "test-kc06-chuyển-khoản thường · "+t.Name())
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/expense-items/%d/category", tc), k.chu, map[string]any{"expense_category_id": thuong2, "reason": "test"}),
		http.StatusConflict, "expense_item_move_not_allowed", "")
}

// --- A1 · A3 · điểm 5–6: ngày nhập và ô lượng trên khoản chi -----------------------------------------------------

func TestI025_KC06_NgayNhapVaOLuongCuaKhoanChi(t *testing.T) {
	k := dung(t)
	luong := k.loaiLuong(t, "test-kc06-nhập", false)
	thuong := k.loai(t, "test-kc06-nhập-thường", false)
	gao := k.thuSo(t, "test-kc06-gạo nhập", "kg")
	r := k.xep(t, luong, gao)
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "expense_item_id")
	khoan := func(extra map[string]any) map[string]any {
		b := map[string]any{"expense_category_id": luong, "expense_item_id": con, "amount_vnd": 30000, "paid_date": "2033-04-12"}
		for key, v := range extra {
			b[key] = v
		}
		return b
	}

	// Mục thường và khoản không có khoản con nối: không có ngày nhập, không có ô lượng.
	truoc := k.demGop(t)
	tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, map[string]any{"expense_category_id": thuong, "amount_vnd": 1000, "paid_date": "2033-04-08", "received_date": "2033-04-08"}),
		http.StatusBadRequest, "invalid_request", "received_date")
	tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, map[string]any{"expense_category_id": thuong, "amount_vnd": 1000, "paid_date": "2033-04-08", "purchased_measure": "1"}),
		http.StatusBadRequest, "invalid_request", "purchased_measure")
	for _, c := range []struct {
		extra map[string]any
		field string
	}{
		{map[string]any{"received_date": "2033-02-30"}, "received_date"},
		{map[string]any{"purchased_measure": "-1"}, "purchased_measure"},
		{map[string]any{"purchased_measure": "1.2345"}, "purchased_measure"},
		{map[string]any{"purchased_measure": 3}, "purchased_measure"},
		// Con số mua vào ghi theo ngày nhập, mà sổ không nhận ngày sau hôm nay của quán.
		{map[string]any{"received_date": "2033-07-05", "purchased_measure": "1"}, "received_date"},
	} {
		tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, khoan(c.extra)), http.StatusBadRequest, "invalid_request", c.field)
	}
	if sau := k.demGop(t); sau != truoc {
		t.Fatalf("lời từ chối mà database vẫn đổi: %s → %s", truoc, sau)
	}

	// Không đổi ngày nhập ⇒ bằng ngày chi; không gửi ô lượng ⇒ sổ không đổi.
	r = k.goi(t, "POST", "/expenses", k.chu, khoan(map[string]any{"amount_vnd": 70000, "paid_date": "2033-04-10"}))
	canDat(t, r, http.StatusCreated)
	k70 := r.so(t, "expense_id")
	if r.body["received_date"] != "2033-04-10" || k.muaVao(t, gao, "2033-04-10") != -1 {
		t.Fatalf("ngày nhập mặc định phải bằng ngày chi và không tự thêm con số: %v", r.body)
	}
	// Ô lượng: chưa có con số của (thứ, ngày nhập) thì tạo.
	r = k.goi(t, "POST", "/expenses", k.chu, khoan(map[string]any{"received_date": "2033-04-11", "purchased_measure": "12.5"}))
	canDat(t, r, http.StatusCreated)
	k30 := r.so(t, "expense_id")
	if r.body["received_date"] != "2033-04-11" || k.muaVao(t, gao, "2033-04-11") != 12500 {
		t.Fatalf("ô lượng phải đặt con số mua vào của ngày nhập: %v, sổ=%d", r.body, k.muaVao(t, gao, "2033-04-11"))
	}
	// Đã có mà bằng: không phải một lần sửa, không cần lý do, không thêm dòng.
	r = k.goi(t, "POST", "/expenses", k.chu, khoan(map[string]any{"amount_vnd": 5000, "paid_date": "2033-04-13", "received_date": "2033-04-11", "purchased_measure": "12.50"}))
	canDat(t, r, http.StatusCreated)
	if n := k.so(t, "SELECT count(*) FROM shop.supply_day_entry WHERE supply_item_id = $1", gao); n != 1 {
		t.Fatalf("ô lượng bằng con số đã có mà sổ thêm dòng: %d dòng", n)
	}
	// Đã có mà khác: là một lần sửa con số ⇒ phải có lý do; thiếu lý do thì không ghi cả khoản chi.
	truoc = k.demGop(t)
	tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, khoan(map[string]any{"paid_date": "2033-04-14", "received_date": "2033-04-11", "purchased_measure": "15"})),
		http.StatusBadRequest, "invalid_request", "reason")
	if sau := k.demGop(t); sau != truoc || k.muaVao(t, gao, "2033-04-11") != 12500 {
		t.Fatalf("thiếu lý do mà vẫn ghi: %s → %s, sổ=%d", truoc, sau, k.muaVao(t, gao, "2033-04-11"))
	}
	vet := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'supply_day_entry'")
	canDat(t, k.goi(t, "POST", "/expenses", k.chu, khoan(map[string]any{"paid_date": "2033-04-14", "received_date": "2033-04-11", "purchased_measure": "15", "reason": "test: cân lại"})), http.StatusCreated)
	if k.muaVao(t, gao, "2033-04-11") != 15000 {
		t.Fatalf("ô lượng có lý do phải sửa con số thành 15, sổ=%d", k.muaVao(t, gao, "2033-04-11"))
	}
	if sau := k.so(t, "SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'supply_day_entry'"); sau <= vet {
		t.Fatalf("sửa con số qua ô lượng không để vết (%d → %d)", vet, sau)
	}

	// Sửa khoản: ngày nhập không gửi ⇒ bằng ngày chi; gửi ⇒ giữ đúng ngày gửi. Sửa hay xoá khoản không đổi sổ.
	path := fmt.Sprintf("/expenses/%d", k70)
	r = k.goi(t, "PUT", path, k.chu, khoan(map[string]any{"amount_vnd": 80000, "paid_date": "2033-04-10", "reason": "test: sửa tiền"}))
	canDat(t, r, http.StatusOK)
	if r.body["received_date"] != "2033-04-10" {
		t.Fatalf("sửa khoản không gửi ngày nhập: muốn bằng ngày chi, nhận %v", r.body)
	}
	r = k.goi(t, "PUT", path, k.chu, khoan(map[string]any{"amount_vnd": 80000, "paid_date": "2033-04-10", "received_date": "2033-04-09", "reason": "test: hàng về hôm trước"}))
	canDat(t, r, http.StatusOK)
	if r.body["received_date"] != "2033-04-09" {
		t.Fatalf("sửa ngày nhập không giữ: %v", r.body)
	}
	tuChoi(t, k.goi(t, "PUT", path, k.chu, khoan(map[string]any{"paid_date": "2033-04-10", "received_date": "2033-02-30", "reason": "test"})),
		http.StatusBadRequest, "invalid_request", "received_date")
	canDat(t, k.goi(t, "DELETE", fmt.Sprintf("/expenses/%d", k30), k.chu, lyDo("test: xoá khoản có ô lượng")), http.StatusNoContent)
	if k.muaVao(t, gao, "2033-04-11") != 15000 {
		t.Fatalf("xoá khoản chi mà con số của sổ đổi: %d", k.muaVao(t, gao, "2033-04-11"))
	}

	// Khoản của mục thường đọc ngày nhập null; sửa nó kèm ngày nhập bị từ chối.
	r = k.ghi(t, thuong, 1000, "2033-04-08")
	canDat(t, r, http.StatusCreated)
	if v, co := r.body["received_date"]; !co || v != nil {
		t.Fatalf("khoản mục thường phải có received_date null: %v", r.body)
	}
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/expenses/%d", r.so(t, "expense_id")), k.chu,
		map[string]any{"expense_category_id": thuong, "amount_vnd": 1000, "paid_date": "2033-04-08", "received_date": "2033-04-08", "reason": "test"}),
		http.StatusBadRequest, "invalid_request", "received_date")
	r = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-04-01&to=2033-04-30&expense_category_id=%d", luong), k.chu, nil)
	canDat(t, r, http.StatusOK)
	ds, _ := r.body["expenses"].([]any)
	for _, x := range ds {
		if m, _ := x.(map[string]any); m["received_date"] == nil {
			t.Fatalf("khoản của khoản con nối đọc lại thiếu ngày nhập: %v", m)
		}
	}
}

// Ô lượng cùng giao dịch với khoản chi: khoản từ két vào ngày đã ký bị từ chối thì sổ cũng không có con số.
func TestI021_KC06_OLuongKhongLotKhiKhoanChiBiTuChoi(t *testing.T) {
	k := dung(t)
	lKet := k.loaiLuong(t, "test-kc06-két ký", true)
	gao := k.thuSo(t, "test-kc06-gạo két ký", "kg")
	r := k.xep(t, lKet, gao)
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "expense_item_id")
	k.ngayKet(t, "2033-04-20", 500000, 500000, true)
	truoc := k.demGop(t)
	tuChoi(t, k.goi(t, "POST", "/expenses", k.chu, map[string]any{"expense_category_id": lKet, "expense_item_id": con,
		"amount_vnd": 1000, "paid_date": "2033-04-20", "purchased_measure": "3"}), http.StatusConflict, "sale_day_reconciled", "")
	if sau := k.demGop(t); sau != truoc || k.muaVao(t, gao, "2033-04-20") != -1 {
		t.Fatalf("khoản chi bị từ chối mà sổ vẫn có con số: %s → %s", truoc, sau)
	}
}

// --- A4 · điểm 7: thêm thứ kèm tiền một lần bấm, thành công cả hoặc không có gì ----------------------------------

func TestI029_KC06_ThemThuKemTienMotLanBam(t *testing.T) {
	k := dung(t)
	luong := k.loaiLuong(t, "test-kc06-thêm", false)
	lKet := k.loaiLuong(t, "test-kc06-thêm-két", true)
	thuong := k.loai(t, "test-kc06-thêm-thường", false)
	ten := "test-kc06-hành · " + t.Name()

	r := k.goi(t, "POST", "/supply-expense-items", k.chu, map[string]any{
		"expense_category_id": luong, "name": ten, "purchase_unit": "kg",
		"expense": map[string]any{"amount_vnd": 40000, "paid_date": "2033-04-15"}, "purchased_measure": "2"})
	canDat(t, r, http.StatusCreated)
	thu, _ := r.body["supply_item"].(map[string]any)
	con, _ := r.body["expense_item"].(map[string]any)
	kh, _ := r.body["expense"].(map[string]any)
	if thu == nil || con == nil || kh == nil {
		t.Fatalf("cửa gộp phải trả supply_item, expense_item, expense: %v", r.body)
	}
	thuID, _ := thu["supply_item_id"].(float64)
	conID, _ := con["expense_item_id"].(float64)
	if thu["name"] != ten || con["name"] != ten || con["supply_item_id"] != thuID || thu["purchase_unit"] != "kg" ||
		kh["expense_item_id"] != conID || kh["amount_vnd"] != float64(40000) || kh["received_date"] != "2033-04-15" {
		t.Fatalf("cửa gộp trả sai: %v", r.body)
	}
	if k.muaVao(t, int64(thuID), "2033-04-15") != 2000 {
		t.Fatalf("cửa gộp phải đặt con số mua vào của ngày nhập")
	}
	if k.timKhoanCon(t, luong, int64(conID)) == nil {
		t.Fatalf("khoản con mới không đứng dưới mục")
	}

	// Gửi lặp cùng tên: lần hai bị từ chối, không sinh khoản chi thứ hai.
	truoc := k.demGop(t)
	tuChoi(t, k.goi(t, "POST", "/supply-expense-items", k.chu, map[string]any{
		"expense_category_id": luong, "name": ten, "expense": map[string]any{"amount_vnd": 40000, "paid_date": "2033-04-15"}}),
		http.StatusConflict, "supply_item_name_taken", "")
	for _, c := range []struct {
		body  map[string]any
		field string
	}{
		{map[string]any{"expense_category_id": luong, "name": "  "}, "name"},
		{map[string]any{"expense_category_id": 0, "name": ten + "-x"}, "expense_category_id"},
		{map[string]any{"expense_category_id": thuong, "name": ten + "-x"}, "expense_category_id"},
		{map[string]any{"expense_category_id": luong, "name": ten + "-x", "purchased_measure": "1"}, "purchased_measure"},
		{map[string]any{"expense_category_id": luong, "name": ten + "-x", "expense": map[string]any{"amount_vnd": 0, "paid_date": "2033-04-15"}}, "amount_vnd"},
		{map[string]any{"expense_category_id": luong, "name": ten + "-x", "expense": map[string]any{"amount_vnd": 1, "paid_date": "2033-07-15"}}, "paid_date"},
	} {
		tuChoi(t, k.goi(t, "POST", "/supply-expense-items", k.chu, c.body), http.StatusBadRequest, "invalid_request", c.field)
	}
	tuChoi(t, k.goi(t, "POST", "/supply-expense-items", k.chu, map[string]any{"expense_category_id": 999999999, "name": ten + "-x"}),
		http.StatusNotFound, "expense_category_not_found", "")
	// Khoản từ két vào ngày đã ký: cả thứ, khoản con và con số đều không được ghi.
	k.ngayKet(t, "2033-04-21", 500000, 500000, true)
	tuChoi(t, k.goi(t, "POST", "/supply-expense-items", k.chu, map[string]any{
		"expense_category_id": lKet, "name": ten + "-két", "expense": map[string]any{"amount_vnd": 1000, "paid_date": "2033-04-21"}, "purchased_measure": "1"}),
		http.StatusConflict, "sale_day_reconciled", "")
	if sau := k.demGop(t); sau != truoc {
		t.Fatalf("cửa gộp bị từ chối mà để lại nửa kết quả: %s → %s", truoc, sau)
	}

	// Không kèm tiền: chỉ thứ và khoản con.
	r = k.goi(t, "POST", "/supply-expense-items", k.chu, map[string]any{"expense_category_id": luong, "name": ten + "-không tiền"})
	canDat(t, r, http.StatusCreated)
	if v, co := r.body["expense"]; !co || v != nil {
		t.Fatalf("không kèm tiền thì expense phải null: %v", r.body)
	}
}

// --- quyền: mọi cửa mới chỉ chủ quán ---------------------------------------------------------------------------

func TestI029_KC06_CuaMoiChiChuQuan(t *testing.T) {
	k := dung(t)
	luong := k.loaiLuong(t, "test-kc06-quyền", false)
	gao := k.thuSo(t, "test-kc06-gạo quyền", "kg")
	r := k.xep(t, luong, gao)
	canDat(t, r, http.StatusCreated)
	con := r.so(t, "expense_item_id")
	truoc := k.demGop(t)
	for _, c := range []struct {
		method, path string
		body         any
	}{
		{"POST", "/expense-categories", map[string]any{"name": "test-kc06-q · " + t.Name(), "paid_from_till": false, "tracks_supply": true}},
		{"POST", "/expense-items", map[string]any{"expense_category_id": luong, "supply_item_id": gao}},
		{"POST", fmt.Sprintf("/expense-items/%d/reopen", con), lyDo("test")},
		{"PUT", fmt.Sprintf("/expense-items/%d/category", con), map[string]any{"expense_category_id": luong, "reason": "test"}},
		{"POST", "/supply-expense-items", map[string]any{"expense_category_id": luong, "name": "test-kc06-q2 · " + t.Name()}},
		{"POST", "/expenses", map[string]any{"expense_category_id": luong, "expense_item_id": con, "amount_vnd": 1, "paid_date": "2033-04-22", "purchased_measure": "1"}},
	} {
		tuChoi(t, k.goi(t, c.method, c.path, k.quay, c.body), http.StatusForbidden, "owner_only", "")
		tuChoi(t, k.goi(t, c.method, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if sau := k.demGop(t); sau != truoc {
		t.Fatalf("lời từ chối quyền mà database vẫn đổi: %s → %s", truoc, sau)
	}
}
