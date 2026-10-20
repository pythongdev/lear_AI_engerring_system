// T-217 (F-073): quầy đọc lại mã việc trạm và mã mẻ sau khi tải lại màn — bấm mẻ bằng mã đọc được,
// rồi lùi đúng mẻ ấy chỉ từ đường đọc, không từ phản hồi lúc bấm. Cùng khung P3-12, không t.Parallel.
package main

import (
	"fmt"
	"slices"
	"testing"
	"time"
)

func rtTim(t *testing.T, list any, key string, id any) map[string]any {
	t.Helper()
	for _, v := range list.([]any) {
		if m := v.(map[string]any); m[key] == id {
			return m
		}
	}
	return nil
}

func rtMa(t *testing.T, v any) []int64 {
	t.Helper()
	out := []int64{}
	for _, x := range v.([]any) {
		out = append(out, int64(x.(float64)))
	}
	slices.Sort(out)
	return out
}

func TestI019_QuayDocLaiViecTramVaMe(t *testing.T) {
	f := rtSetup(t, time.Hour)
	_, b := f.request("GET", "/counter/station-jobs", f.outsider, nil, 403)
	rtCode(t, b, "not_on_counter_duty")

	order := f.order("staff_pos", 201)
	_, b = f.request("GET", "/counter/station-jobs", f.counter, nil, 200)
	if b["poll_interval_seconds"] != float64(20) || b["read_at"] == nil {
		t.Fatal(b)
	}
	cho := []int64{}
	for _, v := range b["jobs"].([]any) {
		j := v.(map[string]any)
		if j["sales_order_id"] != order["sales_order_id"] {
			continue
		}
		for _, k := range []string{"station_job_id", "station_code", "menu_component_id", "component_name",
			"filling_option_ids", "dining_table_id", "status", "order_status", "production_batch_id",
			"wrong_make_note_id", "transferable"} {
			if _, ok := j[k]; !ok {
				t.Fatalf("việc thiếu %s: %v", k, j)
			}
		}
		if j["status"] != "pending" || j["production_batch_id"] != nil || j["transferable"] != false {
			t.Fatalf("việc mới phải chờ, chưa mẻ, không chuyển được: %v", j)
		}
		cho = append(cho, int64(j["station_job_id"].(float64)))
	}
	if len(cho) == 0 {
		t.Fatalf("đơn %v không có việc nào trong đường đọc của quầy: %v", order["sales_order_id"], b)
	}
	slices.Sort(cho)

	_, me := f.request("POST", "/production-batches", f.counter, map[string]any{"station_job_ids": cho}, 201)
	batch := me["production_batch_id"]

	// "Tải lại màn": chỉ dùng đường đọc để tìm mẻ.
	_, b = f.request("GET", "/counter/station-jobs", f.counter, nil, 200)
	doc := rtTim(t, b["batches"], "production_batch_id", batch)
	if doc == nil {
		t.Fatalf("mẻ %v vừa bấm không có trong đường đọc: %v", batch, b["batches"])
	}
	if got := rtMa(t, doc["station_job_ids"]); !slices.Equal(got, cho) || doc["has_served_units"] != false || doc["made_at"] == nil {
		t.Fatalf("mẻ đọc lại: %v, muốn việc %v và chưa ra bàn", doc, cho)
	}
	for _, id := range cho {
		j := rtTim(t, b["jobs"], "station_job_id", float64(id))
		if j == nil || j["status"] != "made" || j["production_batch_id"] != batch {
			t.Fatalf("việc %d sau bấm mẻ: %v", id, j)
		}
	}

	_, lui := f.request("POST", fmt.Sprintf("/production-batches/%d/rollback", int64(batch.(float64))), f.counter, nil, 200)
	if got := rtMa(t, lui["station_job_ids"]); !slices.Equal(got, cho) {
		t.Fatalf("lùi mẻ trả %v, muốn %v", got, cho)
	}
	_, b = f.request("GET", "/counter/station-jobs", f.counter, nil, 200)
	if rtTim(t, b["batches"], "production_batch_id", batch) != nil {
		t.Fatalf("mẻ đã lùi vẫn được kê là lùi được: %v", b["batches"])
	}
	for _, id := range cho {
		if j := rtTim(t, b["jobs"], "station_job_id", float64(id)); j == nil || j["status"] != "pending" || j["production_batch_id"] != nil {
			t.Fatalf("việc %d sau lùi mẻ: %v", id, j)
		}
	}
}
