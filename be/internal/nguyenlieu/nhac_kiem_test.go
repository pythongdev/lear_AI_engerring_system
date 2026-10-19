package nguyenlieu_test

import (
	"banhcuon/be/internal/nguyenlieu"
	"github.com/gin-gonic/gin"
	"reflect"
	"testing"
	"time"
)

func TestI025_NhacKiemTraCoDuongDoc(t *testing.T) {
	r := gin.New()
	nguyenlieu.Routes(r, nil)
	for _, route := range r.Routes() {
		if route.Method == "GET" && route.Path == "/supply-check-reminders" {
			return
		}
	}
	t.Fatal("thiếu GET /supply-check-reminders")
}

func TestI025_NhacKiemTraQuyenVaCungTapKho(t *testing.T) {
	k := dung(t)
	ngoai := k.so(t, "INSERT INTO shop.person (display_name) VALUES ('test-ngoài quầy nhắc kho') RETURNING id")
	tuChoi(t, k.goi(t, "GET", "/supply-check-reminders", ngoai, nil), 403, "not_on_counter_duty", "")
	tuChoi(t, k.goi(t, "GET", "/supply-check-reminders", 0, nil), 401, "unauthenticated", "")
	tuChoi(t, k.goi(t, "GET", "/supply-stock", k.quay, nil), 403, "owner_only", "")
	for _, c := range []struct {
		name, used, status string
		buy                bool
		day                string
		remind             bool
	}{
		{"dưới", "8.001", "ready", true, "2033-05-02", true},
		{"bằng", "8", "ready", true, "2033-05-02", false},
		{"trên", "7.999", "ready", true, "2033-05-02", false},
		{"chưa nhập", "1", "no_purchase", false, "2033-05-02", false},
		{"nhập không", "10", "latest_purchase_zero", true, "2033-05-02", false},
		{"dùng trước", "10", "usage_before_first_purchase", true, "2033-05-01", false},
	} {
		id := k.thu(t, "test-nhắc-"+c.name, "kg")
		if c.buy {
			canDat(t, k.ghi(t, id, "2033-05-02", "purchased", "10"), 201)
		}
		canDat(t, k.ghi(t, id, c.day, "used", c.used), 201)
		if c.name == "nhập không" {
			canDat(t, k.ghi(t, id, "2033-05-03", "purchased", "0"), 201)
		}
		item := k.kho(t, id)
		if item["reminder_status"] != c.status || (item["check_reminder"] == true) != c.remind {
			t.Fatalf("sai ca %s: %v", c.name, item)
		}
	}
	stock := k.goi(t, "GET", "/supply-stock", k.chu, nil)
	canDat(t, stock, 200)
	want := map[float64]map[string]any{}
	for _, raw := range stock.body["supply_items"].([]any) {
		v := raw.(map[string]any)
		if v["check_reminder"] == true {
			want[v["supply_item_id"].(float64)] = map[string]any{"supply_item_id": v["supply_item_id"], "name": v["name"], "purchase_unit": v["purchase_unit"]}
		}
	}
	for _, who := range []int64{k.chu, k.quay} {
		var before, after time.Time
		if err := k.owner.QueryRow(k.ctx, "SELECT now()").Scan(&before); err != nil {
			t.Fatal(err)
		}
		r := k.goi(t, "GET", "/supply-check-reminders", who, nil)
		canDat(t, r, 200)
		if err := k.owner.QueryRow(k.ctx, "SELECT now()").Scan(&after); err != nil {
			t.Fatal(err)
		}
		stamp, _ := r.body["read_at"].(string)
		at, err := time.Parse(time.RFC3339Nano, stamp)
		if err != nil || at.Before(before) || at.After(after) {
			t.Fatalf("read_at không thuộc mốc database: %v %v [%v,%v]", stamp, err, before, after)
		}
		if len(r.body) != 2 {
			t.Fatalf("lộ trường ngoài hợp đồng: %v", r.body)
		}
		items, ok := r.body["items"].([]any)
		if !ok {
			t.Fatalf("items không phải mảng: %v", r.body)
		}
		got := map[float64]map[string]any{}
		for _, raw := range items {
			v := raw.(map[string]any)
			id := v["supply_item_id"].(float64)
			if _, exists := got[id]; exists {
				t.Fatal("lặp thứ")
			}
			got[id] = v
		}
		if !reflect.DeepEqual(got, want) {
			t.Fatalf("lời nhắc khác tập kho hoặc lộ số: %v / %v", got, want)
		}
	}
	// Đưa mọi hiệu số đang nhắc lên trên ngưỡng bằng một dòng nhập mới qua cửa chủ quán.
	for id := range want {
		canDat(t, k.ghi(t, int64(id), "2033-06-29", "purchased", "999999999"), 201)
	}
	r := k.goi(t, "GET", "/supply-check-reminders", k.quay, nil)
	canDat(t, r, 200)
	items, ok := r.body["items"].([]any)
	if !ok || len(items) != 0 {
		t.Fatalf("muốn items=[]: %v", r.body)
	}
}
