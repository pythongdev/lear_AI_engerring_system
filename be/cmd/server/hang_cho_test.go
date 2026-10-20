// T-218 (F-074): hàng chờ bày đúng dòng đã chụp và tổng backend tính lúc ghi đơn — so với phản hồi của chính
// cửa ghi (I-009: đọc ảnh chụp, không tính lại); duyệt xong, đơn giao sang đơn đang làm với cách trao và số
// việc chưa ra bàn, đủ cho nút rời quán. Cùng khung P3-12, không t.Parallel.
package main

import (
	"fmt"
	"reflect"
	"testing"
	"time"
)

func TestI009_HangChoBayAnhChupDon(t *testing.T) {
	f := rtSetup(t, time.Hour)
	f.stream("/counter/events", f.counter)
	order := f.order("delivery", 201)
	id := order["sales_order_id"]

	_, b := f.request("GET", "/counter/queue", f.counter, nil, 200)
	cho := rtTim(t, b["orders"], "sales_order_id", id)
	if cho == nil {
		t.Fatalf("đơn %v không ở hàng chờ: %v", id, b["orders"])
	}
	if cho["total_vnd"] != order["total_vnd"] || !reflect.DeepEqual(cho["lines"], order["lines"]) {
		t.Fatalf("hàng chờ lệch phản hồi lúc ghi đơn:\n hàng chờ %v · %v\n lúc ghi  %v · %v",
			cho["total_vnd"], cho["lines"], order["total_vnd"], order["lines"])
	}
	if _, ok := b["active_orders"].([]any); !ok {
		t.Fatalf("thiếu active_orders: %v", b)
	}
	if rtTim(t, b["active_orders"], "sales_order_id", id) != nil {
		t.Fatal("đơn chờ xác nhận không phải đơn đang làm")
	}

	f.request("POST", fmt.Sprintf("/orders/%d/approval", int64(id.(float64))), f.counter, map[string]any{}, 200)
	_, b = f.request("GET", "/counter/queue", f.counter, nil, 200)
	if rtTim(t, b["orders"], "sales_order_id", id) != nil {
		t.Fatal("đơn đã duyệt vẫn ở hàng chờ")
	}
	lam := rtTim(t, b["active_orders"], "sales_order_id", id)
	if lam == nil {
		t.Fatalf("đơn giao đã duyệt không ở đơn đang làm: %v", b["active_orders"])
	}
	if lam["status"] != "in_progress" || lam["channel_code"] != "delivery" || lam["handover_code"] != "door_delivery" ||
		lam["delivery_address"] != "địa chỉ test" || lam["customer_phone"] != "0901234567" {
		t.Fatalf("đơn đang làm: %v", lam)
	}
	if n, ok := lam["unserved_jobs"].(float64); !ok || n < 1 {
		t.Fatalf("đơn vừa duyệt phải còn việc chưa ra bàn: %v", lam["unserved_jobs"])
	}
	if lam["total_vnd"] != order["total_vnd"] || !reflect.DeepEqual(lam["lines"], order["lines"]) {
		t.Fatalf("đơn đang làm lệch phản hồi lúc ghi đơn: %v · %v", lam["total_vnd"], lam["lines"])
	}
}
