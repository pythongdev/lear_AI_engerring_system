package ket_test

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/ket"
	"github.com/gin-gonic/gin"
)

func TestQC14_SuaDemHinhTruocQuyen(t *testing.T) {
	r := gin.New()
	// Không pool: nếu handler chạm quyền/database trước khi từ chối hình, test sẽ lỗi.
	ket.Routes(r, ket.NewService(nil))
	for _, ca := range []struct{ body, field string }{
		{`{"lines":[] ,"reason":"sửa"}`, "lines"},
		{`{"lines":[{"denomination_vnd":1000,"amount_vnd":1000}]}`, "reason"},
		{`{"lines":[{"denomination_vnd":1000,"amount_vnd":1000}],"reason":null}`, "reason"},
		{`{"lines":[{"denomination_vnd":1000,"amount_vnd":1000}],"reason":" \t\n\u2003"}`, "reason"},
		{`{"lines":[{"denomination_vnd":1000,"amount_vnd":1500}],"reason":"sửa"}`, "lines[0].amount_vnd"},
	} {
		req := httptest.NewRequest("PUT", "/sale-days/2031-05-01/cash-count", strings.NewReader(ca.body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		var out struct {
			Code  string `json:"code"`
			Field string `json:"field"`
		}
		if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
			t.Fatal(err)
		}
		if w.Code != 400 || out.Code != "invalid_request" || out.Field != ca.field {
			t.Fatalf("hình %s: %d %s", ca.body, w.Code, w.Body.String())
		}
	}
}
