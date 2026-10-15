package danhmuc_test

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/danhmuc"
	"github.com/gin-gonic/gin"
)

// Pool nil chứng minh yêu cầu sai bị chặn trước khi cửa đụng database/quyền.
func TestQC14_HinhDanhMucTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	danhmuc.Routes(r, danhmuc.NewService(nil))
	for _, c := range []struct{ method, path, body, field string }{
		{"POST", "/menu-categories", `{}`, "name"},
		{"POST", "/menu-categories", `{"name":"  "}`, "name"},
		{"POST", "/menu-categories", `{"name":4}`, "name"},
		{"POST", "/menu-categories", `{`, ""},
		{"PUT", "/menu-categories/1", `{"name":"x"}`, "reason"},
		{"PUT", "/menu-categories/1", `{"name":"x","reason":"  "}`, "reason"},
		{"PUT", "/menu-categories/1", `{"reason":"x"}`, "name"},
		{"PUT", "/menu-categories/1", `{"name":"  ","reason":"x"}`, "name"},
		{"PUT", "/menu-categories/0", `{}`, "menu_category_id"},
		{"PUT", "/menu-categories/nope", `{}`, "menu_category_id"},
		{"POST", "/menu-categories/-1/hiding", `{}`, "menu_category_id"},
		{"POST", "/menu-categories/nope/hiding", `{}`, "menu_category_id"},
		{"POST", "/menu-categories/1/hiding", `{}`, "reason"},
		{"POST", "/menu-categories/1/hiding", `{"reason":"  "}`, "reason"},
		{"PUT", "/menu-items/abc/category", `{}`, "menu_item_id"},
		{"PUT", "/menu-items/0/category", `{}`, "menu_item_id"},
		{"PUT", "/menu-items/-1/category", `{}`, "menu_item_id"},
		{"PUT", "/menu-items/1/category", `{}`, "menu_category_id"},
		{"PUT", "/menu-items/1/category", `{"menu_category_id":0}`, "menu_category_id"},
		{"PUT", "/menu-items/1/category", `{"menu_category_id":-1}`, "menu_category_id"},
		{"PUT", "/menu-items/1/category", `{"menu_category_id":"1"}`, "menu_category_id"},
		{"PUT", "/menu-items/1/category", `{"menu_category_id":1,"reason":2}`, "reason"},
		{"GET", "/menu-categories?include_hidden=", ``, "include_hidden"},
		{"GET", "/menu-categories?include_hidden=TRUE", ``, "include_hidden"},
		{"GET", "/menu-categories?include_hidden=1", ``, "include_hidden"},
		{"GET", "/menu-categories?include_hidden=maybe", ``, "include_hidden"},
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
