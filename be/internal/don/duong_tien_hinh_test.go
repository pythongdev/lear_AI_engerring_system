package don_test

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/hoadon"
	"banhcuon/be/internal/ket"
	"banhcuon/be/internal/tratruoc"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

type khongDocNguoi struct{ t *testing.T }

func (a khongDocNguoi) PersonID(*http.Request) (int64, bool) {
	a.t.Fatal("hình sai mà đọc người")
	return 0, false
}

// Không pool: mọi ca phải bị chặn trước quyền và trước database.
func TestQC14_HinhDuongTienTruocQuyen(t *testing.T) {
	mux := http.NewServeMux()
	a := khongDocNguoi{t}
	hoadon.Routes(mux, nil, a)
	tratruoc.Routes(mux, nil, a)
	ket.Routes(mux, nil, a)
	cases := []struct{ path, body, field string }{
		{"/orders/1/handover", `{"transfer_vnd":1}`, "cash_vnd"},
		{"/orders/1/delivered", `{"cash_vnd":-1,"transfer_vnd":1}`, "cash_vnd"},
		{"/orders/1/handover", `{"cash_vnd":0,"transfer_vnd":0,"prepaid_cash_vnd":-1}`, "prepaid_cash_vnd"},
		{"/orders/1/handover", `{"cash_vnd":0,"transfer_vnd":0,"discount_vnd":-1}`, "discount_vnd"},
		{"/orders/1/handover", `{"cash_vnd":0.5,"transfer_vnd":0}`, "cash_vnd"},
		{"/orders/1/prepayment", `{"cash_vnd":null,"transfer_vnd":0}`, "cash_vnd"},
		{"/orders/1/prepayment", `{"cash_vnd":0,"transfer_vnd":0}`, ""},
		{"/bills/1/debt-collections", `{"cash_vnd":9223372036854775807,"transfer_vnd":1}`, ""},
		{"/bills/1/refunds", `{"amount_vnd":0,"method_code":"cash","source_method_code":"cash","reason":"x"}`, "amount_vnd"},
		{"/bills/1/refunds", `{"amount_vnd":1,"method_code":"x","source_method_code":"cash","reason":"x"}`, "method_code"},
		{"/bills/1/refunds", `{"amount_vnd":1,"method_code":"cash","source_method_code":"x","reason":"x"}`, "source_method_code"},
		{"/bills/1/refunds", `{"amount_vnd":1,"method_code":"cash","source_method_code":"cash","reason":"  "}`, "reason"},
		{"/prepayments/1/returns", `{"method_code":"cash","take_transfer_vnd":1,"reason":"x"}`, "take_cash_vnd"},
		{"/prepayments/1/returns", `{"method_code":"cash","take_cash_vnd":0,"take_transfer_vnd":0,"reason":"x"}`, ""},
		{"/prepayments/1/returns", `{"method_code":"cash","take_cash_vnd":1,"take_transfer_vnd":0,"reason":" "}`, "reason"},
		{"/opening-floats", `{"lines":[]}`, "lines"},
		{"/cash-counts", `{"lines":[{"denomination_vnd":1000,"amount_vnd":500}]}`, "lines[0].amount_vnd"},
		{"/opening-floats", `{"lines":[{"denomination_vnd":0,"amount_vnd":0}]}`, "lines[0].denomination_vnd"},
		{"/cash-counts", `{"lines":[{"denomination_vnd":1000,"amount_vnd":0},{"denomination_vnd":1000,"amount_vnd":1000}]}`, "lines[1].denomination_vnd"},
		{"/sale-days/2031-02-30/reconciliation", `{}`, "sale_date"},
		{"/table-sessions/1/closing", `{"cash_vnd":0,"transfer_vnd":0,"debt_vnd":0,"discount_vnd":-1}`, "discount_vnd"},
	}
	for _, c := range cases {
		t.Run(c.path+"/"+c.field, func(t *testing.T) {
			w := httptest.NewRecorder()
			mux.ServeHTTP(w, httptest.NewRequest("POST", c.path, strings.NewReader(c.body)))
			var e apierr.Error
			if err := json.Unmarshal(w.Body.Bytes(), &e); err != nil {
				t.Fatal(err)
			}
			if w.Code != 400 || e.Code != apierr.CodeInvalidRequest || e.Field != c.field {
				t.Fatalf("muốn invalid_request/%s, nhận %d %s", c.field, w.Code, w.Body)
			}
		})
	}
}
