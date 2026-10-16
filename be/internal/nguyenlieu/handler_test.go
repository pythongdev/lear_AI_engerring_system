package nguyenlieu_test

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/nguyenlieu"
	"github.com/gin-gonic/gin"
)

// Pool nil: hình sai phải bị chặn trước quyền và mọi lần chạm database.
func TestI025_HinhSaiTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	nguyenlieu.Routes(r, nguyenlieu.NewService(nil))
	cases := []struct{ method, path, body, field string }{
		{"POST", "/supply-items", `{}`, "name"},
		{"POST", "/supply-items", `{"name":" \t"}`, "name"},
		{"POST", "/supply-items", `{"name":"gạo","purchase_unit":" "}`, "purchase_unit"},
		{"PUT", "/supply-items/1/purchase-unit", `{}`, "purchase_unit"},
		{"PUT", "/supply-items/1/purchase-unit", `{"purchase_unit":null}`, "purchase_unit"},
		{"PUT", "/supply-items/1/purchase-unit", `{"purchase_unit":" "}`, "purchase_unit"},
		{"GET", "/supply-items/0", "", "supply_item_id"},
		{"GET", "/supply-items/nope", "", "supply_item_id"},
		{"PUT", "/supply-day-entries/0", `{}`, "supply_day_entry_id"},
		{"POST", "/supply-day-entries", `{"entry_date":"2033-05-01","kind":"used","measure":"1"}`, "supply_item_id"},
		{"POST", "/supply-day-entries", `{"supply_item_id":1,"entry_date":"2033-02-30","kind":"used","measure":"1"}`, "entry_date"},
		{"POST", "/supply-day-entries", `{"supply_item_id":1,"kind":"used","measure":"1"}`, "entry_date"},
		{"POST", "/supply-day-entries", `{"supply_item_id":1,"entry_date":"2033-05-01","kind":"wasted","measure":"1"}`, "kind"},
		{"PUT", "/supply-day-entries/1", `{"measure":"1","reason":" \t"}`, "reason"},
	}
	for _, measure := range []string{`null`, `5`, `1.5`, `""`, `"NaN"`, `"Infinity"`, `"1e3"`, `"-1"`, `"+1"`, `"01"`, `".1"`, `"1."`, `"1.0000"`, `"1000000000"`, `" 1"`, `[]`, `{}`} {
		cases = append(cases, struct{ method, path, body, field string }{"POST", "/supply-day-entries", `{"supply_item_id":1,"entry_date":"2033-05-01","kind":"used","measure":` + measure + `}`, "measure"})
		cases = append(cases, struct{ method, path, body, field string }{"PUT", "/supply-day-entries/1", `{"measure":` + measure + `,"reason":"sửa"}`, "measure"})
	}
	cases = append(cases, struct{ method, path, body, field string }{"POST", "/supply-day-entries", `{"supply_item_id":1,"entry_date":"2033-05-01","kind":"used"}`, "measure"})
	for _, c := range cases {
		t.Run(c.method+" "+c.path+" "+c.body, func(t *testing.T) {
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest(c.method, c.path, strings.NewReader(c.body)))
			var out struct{ Code, Field string }
			if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
				t.Fatal(err)
			}
			if w.Code != 400 || out.Code != "invalid_request" || out.Field != c.field {
				t.Fatalf("muốn 400 invalid_request field=%s; nhận %d %s", c.field, w.Code, w.Body.String())
			}
		})
	}
}

// Không cần database: payload sai bị chặn trước mọi truy vấn.
func TestQC14_TiLeNhacSaiTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	nguyenlieu.Routes(r, nguyenlieu.NewService(nil))
	cases := []struct{ path, body, field string }{
		{"/supply-items/0/reminder-ratio", `{}`, "supply_item_id"},
		{"/supply-items/nope/reminder-ratio", `{}`, "supply_item_id"},
		{"/supply-items/1/reminder-ratio", `{}`, "reminder_ratio"},
		{"/supply-items/1/reminder-ratio", `{"reminder_ratio":"0.2"}`, "reason"},
		{"/supply-items/1/reminder-ratio", `{"reminder_ratio":"0.2","reason":" \t"}`, "reason"},
	}
	for _, raw := range []string{`null`, `0.2`, `""`, `"NaN"`, `"Infinity"`, `"-0.1"`, `"1.001"`, `"20"`, `"1e-1"`, `".2"`, `"00.2"`, `" 0.2"`, `"0.1234567"`, `[]`, `{}`} {
		cases = append(cases, struct{ path, body, field string }{"/supply-items/1/reminder-ratio", `{"reminder_ratio":` + raw + `,"reason":"test"}`, "reminder_ratio"})
	}
	for _, c := range cases {
		t.Run(c.path+c.body, func(t *testing.T) {
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest("PUT", c.path, strings.NewReader(c.body)))
			var out struct{ Code, Field string }
			if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
				t.Fatal(err)
			}
			if w.Code != 400 || out.Code != "invalid_request" || out.Field != c.field {
				t.Fatalf("muốn 400 invalid_request field=%s; nhận %d %s", c.field, w.Code, w.Body.String())
			}
		})
	}
}
