package nguyenlieu_test

import (
	"fmt"
	"net/http"
	"reflect"
	"testing"
)

// Cửa kho, danh sách và chi tiết dùng cùng phép đọc, cùng JSON cho từng thứ.
func (k khung) kho(t *testing.T, id int64) map[string]any {
	t.Helper()
	detail := k.goi(t, "GET", fmt.Sprintf("/supply-items/%d", id), k.chu, nil)
	canDat(t, detail, http.StatusOK)
	delete(detail.body, "entries")
	for _, path := range []string{"/supply-stock", "/supply-items"} {
		r := k.goi(t, "GET", path, k.chu, nil)
		canDat(t, r, http.StatusOK)
		found := false
		items, ok := r.body["supply_items"].([]any)
		if !ok {
			t.Fatalf("thiếu supply_items: %v", r.body)
		}
		for _, raw := range items {
			item := raw.(map[string]any)
			if item["supply_item_id"] != float64(id) {
				continue
			}
			found = true
			if !reflect.DeepEqual(item, detail.body) {
				t.Fatalf("%s khác chi tiết: %v / %v", path, item, detail.body)
			}
		}
		if !found {
			t.Fatalf("%s không có thứ %d", path, id)
		}
	}
	return detail.body
}

func TestI025_KhoTongVaBienNhacKiemTra(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kho-biên", "kg")
	// Cố ý gõ ngày mới trước: gần nhất theo ngày hàng mua về, không theo lúc gõ/id.
	canDat(t, k.ghi(t, id, "2033-05-03", "purchased", "5"), 201)
	canDat(t, k.ghi(t, id, "2033-05-01", "purchased", "10"), 201)
	used := k.ghi(t, id, "2033-05-03", "used", "13.999")
	canDat(t, used, 201)
	entry := used.so(t, "supply_day_entry_id")
	// Tổng nhập 15, lần gần nhất 5, tỉ lệ 0.2 => mốc nhắc 1, không phải 3.
	for _, c := range []struct {
		used, balance string
		remind        bool
	}{
		{"13.999", "1.001", false}, // trên mốc
		{"14", "1", false},         // bằng mốc: KHÔNG nhắc
		{"14.001", "0.999", true},  // dưới mốc
		{"16", "-1", true},         // hiệu âm vẫn giữ số, không gán kết luận
	} {
		canDat(t, k.goi(t, "PUT", fmt.Sprintf("/supply-day-entries/%d", entry), k.chu,
			map[string]any{"measure": c.used, "reason": "test kiểm biên nhắc"}), 200)
		got := k.kho(t, id)
		for key, want := range map[string]any{
			"purchased_total": "15", "used_total": c.used, "balance": c.balance,
			"latest_purchase_date": "2033-05-03", "latest_purchase_measure": "5",
			"reminder_ratio": "0.2", "reminder_status": "ready", "check_reminder": c.remind,
		} {
			if got[key] != want {
				t.Fatalf("%s: muốn %v nhận %v; %v", key, want, got[key], got)
			}
		}
	}
	// Số lẻ dùng numeric: 0.2 × 0.2 = 0.04 chính xác.
	decimal := k.thu(t, "test-kho-số-lẻ", "lít")
	canDat(t, k.ghi(t, decimal, "2033-05-01", "purchased", "0.3"), 201)
	canDat(t, k.ghi(t, decimal, "2033-05-03", "purchased", "0.2"), 201)
	d := k.ghi(t, decimal, "2033-05-03", "used", "0.46")
	canDat(t, d, 201)
	got := k.kho(t, decimal)
	if got["balance"] != "0.04" || got["check_reminder"] != false {
		t.Fatalf("biên thập phân: %v", got)
	}
	canDat(t, k.goi(t, "PUT", fmt.Sprintf("/supply-day-entries/%d", d.so(t, "supply_day_entry_id")), k.chu,
		map[string]any{"measure": "0.461", "reason": "test dưới biên thập phân"}), 200)
	got = k.kho(t, decimal)
	if got["balance"] != "0.039" || got["check_reminder"] != true {
		t.Fatalf("dưới biên thập phân: %v", got)
	}
}

func TestI025_KhoChiChuQuanVaTiLeTheoTungThu(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kho-quyền", "kg")
	other := k.thu(t, "test-kho-thứ-khác", "kg")
	canDat(t, k.ghi(t, id, "2033-05-01", "purchased", "10"), 201)
	canDat(t, k.ghi(t, id, "2033-05-01", "used", "8"), 201)
	path := fmt.Sprintf("/supply-items/%d/reminder-ratio", id)
	body := map[string]any{"reminder_ratio": "0.3", "reason": "test chủ quán đặt tỉ lệ"}
	before := k.soDong(t)
	for _, p := range []struct {
		who    int64
		status int
		code   string
	}{
		{k.quay, 403, "owner_only"}, {0, 401, "unauthenticated"},
	} {
		tuChoi(t, k.goi(t, "GET", "/supply-stock", p.who, nil), p.status, p.code, "")
		tuChoi(t, k.goi(t, "PUT", path, p.who, body), p.status, p.code, "")
	}
	if after := k.soDong(t); before != after {
		t.Fatalf("từ chối làm đổi DB: %s / %s", before, after)
	}
	for _, c := range []struct {
		ratio  string
		remind bool
	}{
		{"0.3", true}, {"0.2", false}, {"0", false}, {"1", true},
	} {
		body["reminder_ratio"] = c.ratio
		r := k.goi(t, "PUT", path, k.chu, body)
		canDat(t, r, 200)
		if r.body["reminder_ratio"] != c.ratio || r.body["check_reminder"] != c.remind ||
			r.body["purchased_total"] != "10" || r.body["used_total"] != "8" || r.body["balance"] != "2" {
			t.Fatalf("đặt tỉ lệ phải tính lại nhắc, không đổi con số: %v", r.body)
		}
	}
	if k.kho(t, other)["reminder_ratio"] != "0.2" {
		t.Fatal("đổi tỉ lệ của thứ khác")
	}
	if n := k.so(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='supply_item'
        AND target_row=$1 AND person_id=$2 AND reason=$3 AND revised_at IS NOT NULL
        AND before_image->>'reminder_ratio'='0.2' AND after_image->>'reminder_ratio'='0.3'`, id, k.chu, body["reason"]); n != 1 {
		t.Fatalf("muốn một vết đủ người/lúc/lý do và 0.2 → 0.3, nhận %d", n)
	}
	tuChoi(t, k.goi(t, "PUT", "/supply-items/9223372036854775807/reminder-ratio", k.chu, body),
		404, "supply_item_not_found", "")
}

func TestI025_KhoTrangThaiChuaCoLoi(t *testing.T) {
	k := dung(t)
	id := k.thu(t, "test-kho-chưa-có-lời", "")
	got := k.kho(t, id)
	// U-102 (T-204): chưa có lần nhập ⇒ nhắc; lần nhập gần nhất 0 ⇒ nhắc; dùng trước lần nhập đầu ⇒ so tỉ lệ như thường.
	if got["reminder_status"] != "no_purchase" || got["check_reminder"] != true ||
		got["latest_purchase_date"] != nil || got["latest_purchase_measure"] != nil ||
		got["purchased_total"] != "0" || got["used_total"] != "0" || got["balance"] != "0" {
		t.Fatalf("chưa có lần nhập thì nhắc, không đoán số: %v", got)
	}
	canDat(t, k.ghi(t, id, "2033-05-01", "used", "1"), 201)
	got = k.kho(t, id)
	if got["reminder_status"] != "no_purchase" || got["check_reminder"] != true || got["balance"] != "-1" {
		t.Fatalf("chỉ có dùng vẫn chưa có mốc nhập, vẫn nhắc: %v", got)
	}
	canDat(t, k.ghi(t, id, "2033-05-02", "purchased", "5"), 201)
	got = k.kho(t, id)
	if got["reminder_status"] != "usage_before_first_purchase" || got["check_reminder"] != false || got["balance"] != "4" {
		t.Fatalf("dùng trước ngày mua có trạng thái, so tỉ lệ như thường (4 ≥ 0.2 × 5): %v", got)
	}
	canDat(t, k.ghi(t, id, "2033-05-03", "purchased", "0"), 201)
	got = k.kho(t, id)
	if got["reminder_status"] != "latest_purchase_zero" || got["check_reminder"] != true || got["latest_purchase_measure"] != "0" {
		t.Fatalf("lần nhập 0 có trạng thái và nhắc: %v", got)
	}
}
