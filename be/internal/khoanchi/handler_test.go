package khoanchi_test

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/khoanchi"
	"github.com/gin-gonic/gin"
)

// Pool nil chứng minh yêu cầu sai bị chặn trước khi cửa đụng database/quyền.
func TestQC14_HinhKhoanChiTruocQuyen(t *testing.T) {
	r := gin.New()
	khoanchi.Routes(r, khoanchi.NewService(nil))
	for _, c := range []struct{ method, path, body, field string }{
		{"POST", "/expense-categories", `{"name":"  ","paid_from_till":true}`, "name"},
		{"POST", "/expense-categories", `{"name":"điện"}`, "paid_from_till"},
		{"POST", "/expense-categories", `{"name":"điện","paid_from_till":null}`, "paid_from_till"},
		{"POST", "/expense-categories", `{"name":"điện","paid_from_till":"true"}`, "paid_from_till"},
		{"POST", "/expenses", `{"expense_category_id":1,"paid_date":"2033-05-01"}`, "amount_vnd"},
		{"POST", "/expenses", `{"expense_category_id":1,"amount_vnd":-1,"paid_date":"2033-05-01"}`, "amount_vnd"},
		{"POST", "/expenses", `{"expense_category_id":1,"amount_vnd":1.5,"paid_date":"2033-05-01"}`, "amount_vnd"},
		{"POST", "/expenses", `{"expense_category_id":1,"amount_vnd":1,"paid_date":"2033-02-30"}`, "paid_date"},
		{"POST", "/expenses", `{"expense_category_id":1,"amount_vnd":1,"paid_date":"2033-5-1"}`, "paid_date"},
		{"POST", "/expenses", `{"amount_vnd":1,"paid_date":"2033-05-01"}`, "expense_category_id"},
		{"PUT", "/expenses/nope", `{}`, "expense_id"},
		{"PUT", "/expenses/0", `{}`, "expense_id"},
		{"PUT", "/expenses/1", `{"expense_category_id":1,"amount_vnd":1,"paid_date":"2033-05-01","reason":"  "}`, "reason"},
		{"GET", "/expenses?to=2033-05-01", "", "from"},
		{"GET", "/expenses?from=2033-05-01", "", "to"},
		{"GET", "/expenses?from=2033-05-02&to=2033-05-01", "", "to"},
		{"GET", "/expenses?from=2033-05-01&to=2033-05-31&expense_category_id=", "", "expense_category_id"},
		{"GET", "/expenses?from=2033-05-01&to=2033-05-31&expense_category_id=-1", "", "expense_category_id"},
		{"GET", "/expenses?from=2033-05-01&to=2033-05-31&paid_from_till=", "", "paid_from_till"},
		{"GET", "/expenses?from=2033-05-01&to=2033-05-31&paid_from_till=1", "", "paid_from_till"},
		{"GET", "/expenses?from=2033-05-01&to=2033-05-31&paid_from_till=TRUE", "", "paid_from_till"},
	} {
		t.Run(c.method+" "+c.path+" "+c.field, func(t *testing.T) {
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
