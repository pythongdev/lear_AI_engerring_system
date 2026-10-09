package don

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

type camDocNguoi struct{}

func (camDocNguoi) PersonID(*http.Request) (int64, bool) {
	panic("đã đọc người trước khi kiểm xong hình")
}

// Pool nil và bộ đọc người từ chối mọi lần gọi: yêu cầu sai hình phải dừng trước cả hai.
func TestMangDiHinh_TruocQuyen(t *testing.T) {
	for _, ca := range []struct{ name, body, field string }{
		{"dấu trước bàn", `{"submission_code":"sai","dining_table_id":null}`, "submission_code"},
		{"bàn trước kênh", `{"dining_table_id":null}`, "dining_table_id"},
		{"phiên trước kênh", `{"table_session_id":null}`, "table_session_id"},
		{"kênh trước liên hệ", `{}`, "channel_code"},
		{"số trước địa chỉ", `{"channel_code":"delivery","customer_phone":" \t "}`, "customer_phone"},
		{"địa chỉ trước mốc", `{"channel_code":"delivery","customer_phone":"1","customer_needed_at":"sai"}`, "delivery_address"},
		{"mốc thiếu độ lệch", `{"channel_code":"pickup","customer_phone":"1","customer_needed_at":"2031-01-20T09:30:00"}`, "customer_needed_at"},
		{"dòng rỗng", `{"channel_code":"delivery","customer_phone":"1","delivery_address":"x","lines":[]}`, "lines"},
		{"dòng thiếu lượng", `{"channel_code":"delivery","customer_phone":"1","delivery_address":"x","lines":[{"menu_item_id":1,"option_ids":[]}]}`, "lines[0].quantity"},
		{"lựa chọn null", `{"channel_code":"delivery","customer_phone":"1","delivery_address":"x","lines":[{"menu_item_id":1,"quantity":1,"option_ids":[null]}]}`, "lines[0].option_ids"},
	} {
		t.Run(ca.name, func(t *testing.T) {
			var body map[string]any
			if err := json.Unmarshal([]byte(ca.body), &body); err != nil {
				t.Fatal(err)
			}
			if _, co := body["submission_code"]; !co {
				body["submission_code"] = "11111111-1111-1111-1111-111111111111"
			}
			raw, _ := json.Marshal(body)
			rec := httptest.NewRecorder()
			handler{auth: camDocNguoi{}}.taoOnline(rec, httptest.NewRequest("POST", "/online-orders", strings.NewReader(string(raw))))
			var out struct{ Code, Field string }
			if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil {
				t.Fatal(err)
			}
			if rec.Code != 400 || out.Code != "invalid_request" || out.Field != ca.field {
				t.Fatalf("%d %s", rec.Code, rec.Body.String())
			}
		})
	}
}

func TestMangDiHinh_DauSoChuVaKhoanhKhac(t *testing.T) {
	doc := func(them string) YeuCauTaiQuay {
		t.Helper()
		var raw map[string]json.RawMessage
		body := `{"submission_code":"11111111-1111-1111-1111-111111111111","channel_code":"pickup","customer_phone":" 0912 ","lines":[{"menu_item_id":1,"quantity":1,"option_ids":[]}]` + them + `}`
		if err := json.Unmarshal([]byte(body), &raw); err != nil {
			t.Fatal(err)
		}
		yc, err := docNgoaiBan(raw, false)
		if err != nil {
			t.Fatal(err)
		}
		return yc
	}
	a := doc(`,"customer_needed_at":"2031-01-20T09:30:00+07:00"`)
	b := doc(`,"customer_needed_at":"2031-01-20T02:30:00Z","customer_name":null,"contact_note":null,"delivery_address":null`)
	if a.ngoaiBan.CustomerPhone != " 0912 " || !cungLienHe(*a.ngoaiBan, *b.ngoaiBan) {
		t.Fatal("phải giữ từng byte và so cùng khoảnh khắc, vắng tương đương null")
	}
	b.ngoaiBan.CustomerPhone = "0912"
	if cungLienHe(*a.ngoaiBan, *b.ngoaiBan) {
		t.Fatal("không được bỏ khoảng trắng khi so dấu")
	}
	b.ngoaiBan.CustomerPhone = a.ngoaiBan.CustomerPhone
	note := ""
	b.ngoaiBan.ContactNote = &note
	if cungLienHe(*a.ngoaiBan, *b.ngoaiBan) {
		t.Fatal("chuỗi rỗng khác null")
	}
	// PostgreSQL giữ tới micro giây: phần nhỏ hơn bị cắt lúc đọc, nên lần gửi lại khớp mốc đã ghi.
	c := doc(`,"customer_needed_at":"2031-01-20T09:30:00.123456789+07:00"`)
	if c.ngoaiBan.CustomerNeededAt.Nanosecond() != 123456000 {
		t.Fatalf("mốc không cắt về micro giây: %v", c.ngoaiBan.CustomerNeededAt)
	}
}
