// Test KC-07 (ADR-147 điểm 8; I-025 vế 3 sửa 2026-11-22): ước tính còn dùng của từng thứ trong sổ, tính lúc đọc,
// không cất. Claude viết TRƯỚC code; Codex làm cho xanh mà không sửa điều kiện kiểm nào. Ngày dùng ở đây thuộc tháng
// 6/2033; đồng hồ quán đặt 2033-06-30 (dung), riêng một test kéo đồng hồ lùi để thử mốc *tới ngày bán hôm nay*.
//
// Hình hợp đồng Claude chốt (0.80.0, phiếu ../lean_wt/_claude_logs/KC-07/phieu.md): mỗi SupplyItem — ở
// GET /supply-items, GET /supply-items/{id}, GET /supply-stock và mọi cửa trả SupplyItem — có thêm khối bắt buộc
// usage_estimate {status, usage_days, used_in_window, days_left}:
//   - Cửa sổ = tối đa 7 ngày gần nhất có con số *đã dùng* (con số 0 đã ghi là một ngày có ghi), entry_date ≤ ngày bán
//     hôm nay của quán. Ngày không ghi không tính; không phải 7 ngày lịch.
//   - usage_days = số ngày trong cửa sổ (0…7); used_in_window = tổng các con số đã dùng ấy, chuỗi thập phân như
//     Measure ("0" khi không có ngày). FE không tự chia: số ngày còn do backend trả.
//   - status: balance ≤ 0 ⇒ out_by_ledger (đứng trước mọi nhánh); còn lại usage_days = 0 ⇒ no_usage;
//     used_in_window = 0 ⇒ zero_usage; ngược lại ready.
//   - days_left: chỉ khi ready, = balance ÷ (used_in_window ÷ usage_days) làm tròn XUỐNG một chữ số thập phân, luôn đúng
//     một chữ số sau dấu chấm ("2.8", "3.0", "0.0"); null ở ba trạng thái kia. Phép tính bằng numeric, không float.
//   - balance vẫn là hiệu số mọi ngày (I-026), không đổi; check_reminder và nhắc POS không đổi theo ước tính.
package nguyenlieu_test

import (
	"context"
	"fmt"
	"net/http"
	"testing"
	"time"

	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

type uocTinh struct {
	status, used, days string
	n                  float64
	daysNull           bool
}

// uoc đọc khối usage_estimate của một thứ qua kho(): danh sách, chi tiết và kho phải nói cùng một đáp số.
func (k khung) uoc(t *testing.T, id int64) uocTinh {
	t.Helper()
	m, ok := k.kho(t, id)["usage_estimate"].(map[string]any)
	if !ok {
		t.Fatalf("thứ %d thiếu khối usage_estimate", id)
	}
	var u uocTinh
	u.status, _ = m["status"].(string)
	u.used, _ = m["used_in_window"].(string)
	var okN bool
	if u.n, okN = m["usage_days"].(float64); !okN {
		t.Fatalf("usage_days không phải số: %v", m)
	}
	if v, has := m["days_left"]; !has {
		t.Fatalf("thiếu khoá days_left (phải có, null khi không tính): %v", m)
	} else if v == nil {
		u.daysNull = true
	} else if u.days, okN = v.(string); !okN {
		t.Fatalf("days_left không phải chuỗi: %v", m)
	}
	return u
}

func canUoc(t *testing.T, got uocTinh, status string, n float64, used, days string) {
	t.Helper()
	if got.status != status || got.n != n || got.used != used {
		t.Fatalf("muốn status=%s usage_days=%v used_in_window=%s, nhận %+v", status, n, used, got)
	}
	if days == "" {
		if !got.daysNull {
			t.Fatalf("status %s phải trả days_left null, nhận %q", status, got.days)
		}
		return
	}
	if got.daysNull || got.days != days {
		t.Fatalf("muốn days_left=%s, nhận %+v", days, got)
	}
}

func (k khung) ghiDat(t *testing.T, thu int64, ngay, loai, so string) {
	t.Helper()
	canDat(t, k.ghi(t, thu, ngay, loai, so), http.StatusCreated)
}

// Trung bình trên số ngày có ghi khi ít hơn 7 ngày, và làm tròn XUỐNG: 10 ÷ 3,5 = 2,857… ⇒ "2.8", không "2.9".
func TestI025_KC07_UocTinhLamTronXuongTrenSoNgayCoGhi(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kc07-ít ngày", "kg")
	k.ghiDat(t, id, "2033-06-01", "purchased", "17")
	k.ghiDat(t, id, "2033-06-02", "used", "3")
	k.ghiDat(t, id, "2033-06-03", "used", "4")
	if _, _, hieu := k.tong(t, id); hieu != "10" {
		t.Fatalf("hiệu số phải giữ nguyên phép cộng mọi ngày (I-026): %s", hieu)
	}
	canUoc(t, k.uoc(t, id), "ready", 2, "7", "2.8")

	// Chia chẵn vẫn trả đúng một chữ số thập phân.
	id2 := k.thu(t, "test-kc07-chia chẵn", "kg")
	k.ghiDat(t, id2, "2033-06-01", "purchased", "16")
	k.ghiDat(t, id2, "2033-06-02", "used", "2")
	k.ghiDat(t, id2, "2033-06-04", "used", "2")
	canUoc(t, k.uoc(t, id2), "ready", 2, "4", "6.0")
}

// Cửa sổ là 7 NGÀY CÓ GHI gần nhất, không phải 7 ngày lịch; ngày ghi 0 là một ngày có ghi; ngày cũ hơn bị loại.
func TestI025_KC07_CuaSoBayNgayCoGhiTinhCaNgayGhiKhong(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kc07-bảy ngày", "quả")
	k.ghiDat(t, id, "2033-06-01", "purchased", "300")
	// Hai ngày cũ dùng nhiều phải rơi khỏi cửa sổ; có một ngày trống (06-05) và một khoảng trống dài trước 06-12.
	for _, c := range []struct{ ngay, so string }{
		{"2033-06-01", "100"}, {"2033-06-02", "100"},
		{"2033-06-03", "2"}, {"2033-06-04", "2"}, {"2033-06-06", "2"}, {"2033-06-07", "2"},
		{"2033-06-08", "2"}, {"2033-06-09", "2"}, {"2033-06-12", "0"},
	} {
		k.ghiDat(t, id, c.ngay, "used", c.so)
	}
	// Hiệu số 300 − 212 = 88; cửa sổ 06-03…06-12 (bảy ngày, gồm ngày ghi 0): tổng 12, mức 12/7 ⇒ 88 × 7 / 12 = 51,33…
	// Nếu bỏ ngày ghi 0 thì 06-02 lọt vào (5,5); nếu lấy 7 ngày lịch tính từ 06-30 thì không có ngày nào.
	canUoc(t, k.uoc(t, id), "ready", 7, "12", "51.3")
}

// Bốn trạng thái và thứ tự của chúng: hiệu số ≤ 0 đứng trước; chưa ghi dùng; dùng toàn 0.
func TestI025_KC07_BonTrangThaiCuaUocTinh(t *testing.T) {
	k := dung(t)

	chuaDung := k.thu(t, "test-kc07-chưa dùng", "kg")
	k.ghiDat(t, chuaDung, "2033-06-01", "purchased", "5")
	canUoc(t, k.uoc(t, chuaDung), "no_usage", 0, "0", "")

	dungKhong := k.thu(t, "test-kc07-dùng 0", "kg")
	k.ghiDat(t, dungKhong, "2033-06-01", "purchased", "5")
	k.ghiDat(t, dungKhong, "2033-06-02", "used", "0")
	k.ghiDat(t, dungKhong, "2033-06-03", "used", "0.000")
	canUoc(t, k.uoc(t, dungKhong), "zero_usage", 2, "0", "")

	vuaHet := k.thu(t, "test-kc07-vừa hết", "kg")
	k.ghiDat(t, vuaHet, "2033-06-01", "purchased", "5")
	k.ghiDat(t, vuaHet, "2033-06-02", "used", "5")
	canUoc(t, k.uoc(t, vuaHet), "out_by_ledger", 1, "5", "")

	am := k.thu(t, "test-kc07-hiệu âm", "kg")
	k.ghiDat(t, am, "2033-06-02", "used", "6")
	canUoc(t, k.uoc(t, am), "out_by_ledger", 1, "6", "")

	// Thứ chưa có con số nào: hiệu số 0 ⇒ out_by_ledger (đứng trước no_usage). FE ghép với reminder_status=no_purchase
	// để hiện *Chưa nhập* — đây là thứ tự phiên chọn, ghi ở phiếu.
	moi := k.thu(t, "test-kc07-chưa có số", "")
	canUoc(t, k.uoc(t, moi), "out_by_ledger", 0, "0", "")

	// Còn ít hơn 0,1 ngày nhưng chưa hết: vẫn ready, "0.0" — không đổi thành out_by_ledger.
	sapHet := k.thu(t, "test-kc07-dưới 0,1 ngày", "kg")
	k.ghiDat(t, sapHet, "2033-06-01", "purchased", "1.05")
	k.ghiDat(t, sapHet, "2033-06-02", "used", "1")
	canUoc(t, k.uoc(t, sapHet), "ready", 1, "1", "0.0")
}

// Số lẻ nhỏ đi qua numeric, không qua float; tổng cửa sổ giữ đủ chữ số; sửa con số thì đọc lại theo số mới.
func TestI025_KC07_SoLeNhoKhongQuaSoThuc(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kc07-số lẻ", "kg")
	k.ghiDat(t, id, "2033-06-01", "purchased", "1")
	k.ghiDat(t, id, "2033-06-02", "used", "0.001")
	k.ghiDat(t, id, "2033-06-03", "used", "0.002")
	// Hiệu số 0,997; mức (0,001 + 0,002) / 2 = 0,0015 ⇒ 664,66… ⇒ "664.6".
	canUoc(t, k.uoc(t, id), "ready", 2, "0.003", "664.6")

	// Sửa một con số đã dùng thì ước tính đọc lại theo con số mới, không cất bản cũ.
	r := k.goi(t, "GET", fmt.Sprintf("/supply-items/%d", id), k.chu, nil)
	canDat(t, r, http.StatusOK)
	entries, _ := r.body["entries"].([]any)
	var sua int64
	for _, x := range entries {
		e, _ := x.(map[string]any)
		if e["entry_date"] == "2033-06-03" && e["kind"] == "used" {
			sua = int64(e["supply_day_entry_id"].(float64))
		}
	}
	if sua == 0 {
		t.Fatalf("không thấy con số đã dùng ngày 2033-06-03: %v", entries)
	}
	canDat(t, k.goi(t, "PUT", fmt.Sprintf("/supply-day-entries/%d", sua), k.chu,
		map[string]any{"measure": "0.005", "reason": "test-kc07 gõ nhầm"}), http.StatusOK)
	// Hiệu số 0,994; mức 0,003 ⇒ 331,33… ⇒ "331.3".
	canUoc(t, k.uoc(t, id), "ready", 2, "0.006", "331.3")
}

// Cửa sổ dừng ở ngày bán hôm nay của quán: con số mang ngày sau hôm nay (dữ liệu cũ, hay đồng hồ lùi) không vào mức
// dùng. Hiệu số vẫn là phép cộng mọi con số (I-026) — ước tính không viết lại hiệu số.
func TestI025_KC07_CuaSoDungOHomNayCuaQuan(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kc07-tới hôm nay", "kg")
	k.ghiDat(t, id, "2033-06-01", "purchased", "20")
	k.ghiDat(t, id, "2033-06-02", "used", "2")
	k.ghiDat(t, id, "2033-06-10", "used", "8")
	// Hôm nay 06-30: hai ngày, tổng 10, mức 5; hiệu số 10 ⇒ "2.0".
	canUoc(t, k.uoc(t, id), "ready", 2, "10", "2.0")

	loc, err := time.LoadLocation(testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	moc := time.Date(2033, 6, 5, 9, 0, 0, 0, loc)
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil } // dung() trả đồng hồ gốc lúc dọn
	// Hôm nay 06-05: chỉ ngày 06-02 trong cửa sổ, mức 2; hiệu số vẫn 10 ⇒ "5.0".
	canUoc(t, k.uoc(t, id), "ready", 1, "2", "5.0")
}

// Ước tính chỉ để xem: không đổi cờ nhắc POS (I-025 vế 3), không ghi dòng nào khi đọc.
func TestI025_KC07_UocTinhKhongDoiNhacKiemVaKhongCat(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kc07-chỉ xem", "kg")
	k.ghiDat(t, id, "2033-06-01", "purchased", "10")
	k.ghiDat(t, id, "2033-06-02", "used", "9.5")
	// Hiệu số 0,5 < 0,2 × 10 ⇒ nhắc; ước tính vẫn ready 0,5 ÷ 9,5 = 0,05… ⇒ "0.0". Hai thứ không ăn vào nhau.
	truoc := k.soDong(t)
	m := k.kho(t, id)
	if m["check_reminder"] != true || m["reminder_status"] != "ready" {
		t.Fatalf("cờ nhắc phải giữ luật tỉ lệ cũ: %v", m)
	}
	canUoc(t, k.uoc(t, id), "ready", 1, "9.5", "0.0")
	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("đọc ước tính đã ghi dòng: %s ⇒ %s", truoc, sau)
	}
	// Khối nhắc POS vẫn đúng hình cũ, không mang ước tính.
	r := k.goi(t, "GET", "/supply-check-reminders", k.quay, nil)
	canDat(t, r, http.StatusOK)
	items, _ := r.body["items"].([]any)
	for _, x := range items {
		it, _ := x.(map[string]any)
		if _, has := it["usage_estimate"]; has {
			t.Fatalf("nhắc POS không được mang ước tính: %v", it)
		}
	}
}
