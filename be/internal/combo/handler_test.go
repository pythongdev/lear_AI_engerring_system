package combo_test

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/combo"
	"github.com/gin-gonic/gin"
)

// Pool nil chứng minh yêu cầu sai bị chặn trước khi cửa đụng database/quyền.
func TestQC14_HinhComboTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	combo.Routes(r, combo.NewService(nil))
	for _, c := range []struct{ method, path, body, field string }{
		{"POST", "/menu-combos", `{}`, "name"},
		{"POST", "/menu-combos", `{"name":"  "}`, "name"},
		{"POST", "/menu-combos", `{`, ""},
		{"POST", "/menu-combos", `{"name":"x"}`, "price_vnd"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":null}`, "price_vnd"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":0}`, "price_vnd"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":-1}`, "price_vnd"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":1500.5}`, "price_vnd"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":9223372036854775808}`, "price_vnd"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":"50000"}`, ""},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":true}`, ""},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":{}}`, ""},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":[]}`, ""},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":1000,"items":null}`, "items"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":1000,"items":[]}`, "items"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":1000,"items":[{"menu_item_id":0,"quantity":0}]}`, "items[0].menu_item_id"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":1000,"items":[{"menu_item_id":1,"quantity":0}]}`, "items[0].quantity"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":1000,"items":[{"menu_item_id":1,"quantity":1},{"menu_item_id":1,"quantity":-2}]}`, "items[1].quantity"},
		{"POST", "/menu-combos", `{"name":"x","price_vnd":1000,"items":[{"menu_item_id":1,"quantity":1},{"menu_item_id":1,"quantity":2}]}`, "items[1].menu_item_id"},
		{"PUT", "/menu-combos/abc/price", `{}`, "menu_combo_id"},
		{"PUT", "/menu-combos/0/price", `{}`, "menu_combo_id"},
		{"PUT", "/menu-combos/-1/price", `{}`, "menu_combo_id"},
		{"POST", "/menu-combos/abc/hiding", `{}`, "menu_combo_id"},
		{"POST", "/menu-combos/0/hiding", `{}`, "menu_combo_id"},
		{"POST", "/menu-combos/-1/hiding", `{}`, "menu_combo_id"},
		{"PUT", "/menu-combos/1/price", `{}`, "price_vnd"},
		{"PUT", "/menu-combos/1/price", `{"price_vnd":1500.5,"reason":"x"}`, "price_vnd"},
		{"PUT", "/menu-combos/1/price", `{"price_vnd":"1500","reason":"x"}`, ""},
		{"PUT", "/menu-combos/1/price", `{"price_vnd":1000}`, "reason"},
		{"PUT", "/menu-combos/1/price", `{"price_vnd":1000,"reason":"  "}`, "reason"},
		{"POST", "/menu-combos/1/hiding", `{}`, "reason"},
		{"POST", "/menu-combos/1/hiding", `{"reason":"  "}`, "reason"},
		{"GET", "/menu-combos?include_hidden=", ``, "include_hidden"},
		{"GET", "/menu-combos?include_hidden=TRUE", ``, "include_hidden"},
		{"GET", "/menu-combos?include_hidden=1", ``, "include_hidden"},
		{"GET", "/menu-combos?include_hidden=maybe", ``, "include_hidden"},
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
