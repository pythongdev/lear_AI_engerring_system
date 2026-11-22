// Test KC-05 (ADR-147 điểm 10): tổng tiền theo ngày do backend cộng, đọc lịch sử một khoản con, và ngày chi gần
// nhất của mục/khoản con tính trên mọi ngày — để FE không tự cộng tiền và có mốc 7 ngày mặc định ngoài bộ lọc chung.
// Claude viết TRƯỚC code. Ngày dùng ở đây thuộc tháng 3/2033, không test nào khác của gói chạm.
package khoanchi_test

import (
	"fmt"
	"net/http"
	"testing"
)

func (k khung) khoanCon(t *testing.T, loai int64, ten string) int64 {
	t.Helper()
	r := k.goi(t, "POST", "/expense-items", k.chu, map[string]any{"expense_category_id": loai, "name": ten})
	canDat(t, r, http.StatusCreated)
	return r.so(t, "expense_item_id")
}

func (k khung) ghiCon(t *testing.T, loai, con, tien int64, ngay string) {
	t.Helper()
	canDat(t, k.goi(t, "POST", "/expenses", k.chu, map[string]any{
		"expense_category_id": loai, "expense_item_id": con, "amount_vnd": tien, "paid_date": ngay}), http.StatusCreated)
}

func TestI029_KC05_TongTheoNgayLaPhepCongCuaBackend(t *testing.T) {
	k := dung(t)
	a := k.loai(t, "test-kc05-a", false)
	b := k.loai(t, "test-kc05-b", false)
	canDat(t, k.ghi(t, a, 100000, "2033-03-02"), http.StatusCreated)
	canDat(t, k.ghi(t, a, 50000, "2033-03-02"), http.StatusCreated)
	canDat(t, k.ghi(t, b, 30000, "2033-03-02"), http.StatusCreated)
	canDat(t, k.ghi(t, a, 20000, "2033-03-05"), http.StatusCreated)

	r := k.goi(t, "GET", "/expenses?from=2033-03-01&to=2033-03-09", k.chu, nil)
	canDat(t, r, http.StatusOK)
	ngay, _ := r.body["day_totals"].([]any)
	if len(ngay) != 2 {
		t.Fatalf("muốn 2 ngày, nhận %v", r.body["day_totals"])
	}
	muon := []struct {
		ngay      string
		soLan, tg int64
	}{{"2033-03-05", 1, 20000}, {"2033-03-02", 3, 180000}} // ngày mới trước
	var cong int64
	for i, w := range muon {
		d, _ := ngay[i].(map[string]any)
		lan, _ := d["expense_count"].(float64)
		tien, _ := d["total_vnd"].(float64)
		if d["paid_date"] != w.ngay || int64(lan) != w.soLan || int64(tien) != w.tg {
			t.Fatalf("ngày %d: muốn %+v, nhận %v", i, w, d)
		}
		cong += int64(tien)
	}
	if cong != r.so(t, "total_vnd") {
		t.Fatalf("tổng các ngày %d khác tổng kỳ %d", cong, r.so(t, "total_vnd"))
	}

	// Lọc theo mục: tổng ngày theo đúng tập lọc.
	r = k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-03-01&to=2033-03-09&expense_category_id=%d", b), k.chu, nil)
	canDat(t, r, http.StatusOK)
	if ngay, _ := r.body["day_totals"].([]any); len(ngay) != 1 {
		t.Fatalf("mục b: muốn 1 ngày, nhận %v", r.body["day_totals"])
	}

	// Khoảng rỗng: mảng rỗng, không null.
	r = k.goi(t, "GET", "/expenses?from=2033-03-20&to=2033-03-21", k.chu, nil)
	canDat(t, r, http.StatusOK)
	if ngay, ok := r.body["day_totals"].([]any); !ok || len(ngay) != 0 {
		t.Fatalf("khoảng rỗng: muốn [], nhận %v", r.body["day_totals"])
	}
}

func TestI029_KC05_LichSuKhoanConVaNgayChiGanNhatNgoaiBoLoc(t *testing.T) {
	k := dung(t)
	a := k.loai(t, "test-kc05-lich-su", false)
	x := k.khoanCon(t, a, "test-kc05-x · "+t.Name())
	y := k.khoanCon(t, a, "test-kc05-y · "+t.Name())
	z := k.khoanCon(t, a, "test-kc05-z · "+t.Name())
	k.ghiCon(t, a, x, 10000, "2033-03-10")
	k.ghiCon(t, a, x, 15000, "2033-03-20")
	k.ghiCon(t, a, y, 7000, "2033-03-25")

	r := k.goi(t, "GET", fmt.Sprintf("/expenses?from=2033-03-01&to=2033-03-31&expense_item_id=%d", x), k.chu, nil)
	canDat(t, r, http.StatusOK)
	if ds, _ := r.body["expenses"].([]any); len(ds) != 2 || r.so(t, "total_vnd") != 25000 {
		t.Fatalf("lịch sử khoản con x: muốn 2 khoản 25000, nhận %v", r.body)
	}
	tuChoi(t, k.goi(t, "GET", "/expenses?from=2033-03-01&to=2033-03-31&expense_item_id=abc", k.chu, nil),
		http.StatusBadRequest, "invalid_request", "expense_item_id")
	tuChoi(t, k.goi(t, "GET", "/expenses?from=2033-03-01&to=2033-03-31&expense_item_id=0", k.chu, nil),
		http.StatusBadRequest, "invalid_request", "expense_item_id")

	// Ngày chi gần nhất tính trên mọi ngày, không theo bộ lọc nào; khoản con chưa chi thì null.
	r = k.goi(t, "GET", "/expense-categories", k.chu, nil)
	canDat(t, r, http.StatusOK)
	cs, _ := r.body["expense_categories"].([]any)
	thay := false
	for _, c := range cs {
		m, _ := c.(map[string]any)
		if id, _ := m["expense_category_id"].(float64); int64(id) != a {
			continue
		}
		thay = true
		if m["last_paid_date"] != "2033-03-25" {
			t.Fatalf("mục: muốn last_paid_date 2033-03-25, nhận %v", m)
		}
		items, _ := m["items"].([]any)
		gap := map[int64]any{}
		for _, it := range items {
			im, _ := it.(map[string]any)
			id, _ := im["expense_item_id"].(float64)
			v, co := im["last_paid_date"]
			if !co {
				t.Fatalf("khoản con thiếu trường last_paid_date: %v", im)
			}
			gap[int64(id)] = v
		}
		if gap[x] != "2033-03-20" || gap[y] != "2033-03-25" || gap[z] != nil {
			t.Fatalf("ngày chi gần nhất của khoản con sai: %v", gap)
		}
	}
	if !thay {
		t.Fatalf("không thấy mục của test trong %v", r.body)
	}
}
