package menu_test

import (
	"encoding/json"
	"fmt"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/menu"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgconn"
)

// Viết trước triển khai P3A-07; pool nil kiểm hình trước database.
func TestQC14_HinhThemDoiTenMon(t *testing.T) {
	r := gin.New()
	menu.Routes(r, menu.NewService(nil))
	for _, c := range []struct{ method, path, body, field string }{
		{"POST", "/menu-items", `{}`, "name"},
		{"POST", "/menu-items", `{"name":"  "}`, "name"},
		{"POST", "/menu-items", `{"name":"x","menu_category_id":1}`, "components"},
		{"POST", "/menu-items", `{"name":"x","menu_category_id":1,"components":[]}`, "components"},
		{"POST", "/menu-items", `{"name":"x","menu_category_id":0,"components":[{"name":"c","base_price_vnd":0,"quantity":1,"takes_filling":false}]}`, "menu_category_id"},
		{"POST", "/menu-items", `{"name":"x","menu_category_id":1,"components":[{"name":"c","quantity":1,"takes_filling":false}]}`, "components[0].base_price_vnd"},
		{"POST", "/menu-items", `{"name":"x","menu_category_id":1,"components":[{"name":"c","base_price_vnd":-1,"quantity":1,"takes_filling":false}]}`, "components[0].base_price_vnd"},
		{"POST", "/menu-items", `{"name":"x","menu_category_id":1,"components":[{"name":"c","base_price_vnd":0,"quantity":0,"takes_filling":false}]}`, "components[0].quantity"},
		{"PUT", "/menu-items/0", `{}`, "menu_item_id"},
		{"PUT", "/menu-items/1", `{"name":"x"}`, "reason"},
		{"PUT", "/menu-items/1", `{"name":" ","reason":"test"}`, "name"},
	} {
		t.Run(c.method+c.path+c.field, func(t *testing.T) {
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest(c.method, c.path, strings.NewReader(c.body)))
			var out struct{ Code, Field string }
			_ = json.Unmarshal(w.Body.Bytes(), &out)
			if w.Code != 400 || out.Code != "invalid_request" || out.Field != c.field {
				t.Fatalf("muốn 400 invalid_request %s; nhận %d %s", c.field, w.Code, w.Body.String())
			}
		})
	}
}

func monMoiBody(ten string, dm int64) map[string]any {
	return map[string]any{"name": ten, "menu_category_id": dm, "components": []any{
		map[string]any{"name": ten + "-c1", "base_price_vnd": 3000, "quantity": 2, "takes_filling": false},
		map[string]any{"name": ten + "-c2", "base_price_vnd": 5000, "quantity": 1, "takes_filling": false},
	}}
}
func TestI032_ThemMonQuyenNguyenTuVaGia(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ", true)
	thuong := k.nguoi(t, "thường", false)
	dm := k.id(t, `INSERT INTO shop.menu_category(name,person_id) VALUES ($1,$2) RETURNING id`, t.Name(), chu)
	ten := "test-" + t.Name()
	body := monMoiBody(ten, dm)
	for _, n := range []int64{0, thuong} {
		status, code := 403, "owner_only"
		if n == 0 {
			status, code = 401, "unauthenticated"
		}
		tuChoi(t, k.goi(t, "POST", "/menu-items", n, body), status, code, "")
		tuChoi(t, k.goi(t, "PUT", "/menu-items/9000000000", n, map[string]any{"name": ten, "reason": "test"}), status, code, "")
	}
	k.vaoQuay(t, thuong)
	tuChoi(t, k.goi(t, "POST", "/menu-items", thuong, body), 403, "owner_only", "")
	tuChoi(t, k.goi(t, "PUT", "/menu-items/9000000000", thuong, map[string]any{"name": ten, "reason": "test"}), 403, "owner_only", "")
	// Thành phần thứ hai trùng tên: rollback cả món, thành phần đầu và xếp danh mục.
	bad := monMoiBody(ten, dm)
	bad["components"].([]any)[1].(map[string]any)["name"] = ten + "-c1"
	tuChoi(t, k.goi(t, "POST", "/menu-items", chu, bad), 409, "menu_component_name_conflict", "")
	if n := k.id(t, `SELECT count(*) FROM shop.menu_item WHERE name=$1`, ten); n != 0 {
		t.Fatal("món dở dang")
	}
	if n := k.id(t, `SELECT count(*) FROM shop.menu_component WHERE name=$1`, ten+"-c1"); n != 0 {
		t.Fatal("thành phần mồ côi")
	}
	res := k.goi(t, "POST", "/menu-items", chu, body)
	if res.status != 201 {
		t.Fatalf("tạo: %v", res)
	}
	id := int64(res.body["menu_item_id"].(float64))
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	router := gin.New()
	gia.Routes(router, gia.NewService(pool))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, httptest.NewRequest("GET", "/menu", nil))
	if w.Code != 200 {
		t.Fatalf("GET /menu: %d %s", w.Code, w.Body.String())
	}
	var doc struct {
		Items []struct {
			ID     int64 `json:"menu_item_id"`
			Prices []struct {
				Price int64 `json:"unit_price_vnd"`
			} `json:"prices"`
		} `json:"items"`
	}
	if err = json.Unmarshal(w.Body.Bytes(), &doc); err != nil {
		t.Fatal(err)
	}
	found := false
	for _, m := range doc.Items {
		if m.ID == id {
			found = true
			if len(m.Prices) != 1 || m.Prices[0].Price != 11000 {
				t.Fatalf("giá trên menu: %v", m)
			}
		}
	}
	if !found {
		t.Fatal("món mới không xuất hiện ở GET /menu")
	}

	if got := k.id(t, `SELECT menu_category_id FROM shop.menu_item_category WHERE menu_item_id=$1`, id); got != dm {
		t.Fatal("sai danh mục")
	}
	q, e := gia.Tinh(k.ctx, pool, []gia.DongYeuCau{{MenuItemID: id, Quantity: 2}})
	if e != nil || q.TotalVnd != 22000 {
		t.Fatalf("giá %v %v", q, e)
	}
	tuChoi(t, k.goi(t, "POST", "/menu-items", chu, body), 409, "menu_item_name_conflict", "")
	path := fmt.Sprintf("/menu-items/%d", id)
	res = k.goi(t, "PUT", path, chu, map[string]any{"name": ten + " mới", "reason": "test đổi tên", "base_price_vnd": 1, "components": []any{}})
	if res.status != 200 || res.body["name"] != ten+" mới" {
		t.Fatalf("đổi tên %v", res)
	}
	q, e = gia.Tinh(k.ctx, pool, []gia.DongYeuCau{{MenuItemID: id, Quantity: 2}})
	if e != nil || q.TotalVnd != 22000 {
		t.Fatalf("đổi tên sửa giá %v %v", q, e)
	}
	if n := k.id(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_item' AND target_row=$1 AND person_id=$2 AND reason='test đổi tên' AND after_image->>'name'=$3`, id, chu, ten+" mới"); n != 1 {
		t.Fatal("thiếu vết đổi tên")
	}
	tuChoi(t, k.goi(t, "PUT", "/menu-items/9000000000", chu, map[string]any{"name": ten, "reason": "test"}), 404, "menu_item_not_found", "")
}

func TestQC10_AnhXaTenMonThanhPhan(t *testing.T) {
	for _, c := range []struct {
		name string
		code apierr.Code
	}{
		{"menu_item_name_key", apierr.CodeMenuItemNameConflict},
		{"menu_component_name_key", apierr.CodeMenuComponentNameConflict},
		{"menu_item_name_not_blank_check", apierr.CodeInvalidRequest},
		{"menu_component_name_not_blank_check", apierr.CodeInvalidRequest},
	} {
		got, _ := apierr.FromDB(&pgconn.PgError{ConstraintName: c.name})
		if got.Code != c.code {
			t.Fatalf("%s: %s", c.name, got.Code)
		}
	}
}

func TestI032_ThemDoiTenMonTuChoiKhongGhi(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ", true)
	dm := k.id(t, `INSERT INTO shop.menu_category(name,person_id) VALUES ($1,$2) RETURNING id`, t.Name(), chu)
	ten := "test-" + t.Name()
	bad := monMoiBody(ten, 9000000000)
	tuChoi(t, k.goi(t, "POST", "/menu-items", chu, bad), 404, "menu_category_not_found", "")
	if n := k.id(t, `SELECT count(*) FROM shop.menu_item WHERE name=$1`, ten); n != 0 {
		t.Fatal("món sót khi danh mục sai")
	}
	body := monMoiBody(ten, dm)
	for _, name := range []string{"", "   "} {
		body["name"] = name
		tuChoi(t, k.goi(t, "POST", "/menu-items", chu, body), 400, "invalid_request", "name")
	}
	body["name"] = ten
	body["components"] = []any{}
	tuChoi(t, k.goi(t, "POST", "/menu-items", chu, body), 400, "invalid_request", "components")
	a := k.goi(t, "POST", "/menu-items", chu, monMoiBody(ten, dm))
	b := k.goi(t, "POST", "/menu-items", chu, monMoiBody(ten+" khác", dm))
	if a.status != 201 || b.status != 201 {
		t.Fatalf("tạo: %v %v", a, b)
	}
	id := int64(b.body["menu_item_id"].(float64))
	tuChoi(t, k.goi(t, "PUT", fmt.Sprintf("/menu-items/%d", id), chu, map[string]any{"name": ten, "reason": "test"}), 409, "menu_item_name_conflict", "")
	if n := k.id(t, `SELECT count(*) FROM shop.menu_item WHERE id=$1 AND name=$2`, id, ten+" khác"); n != 1 {
		t.Fatal("tên đổi dù bị từ chối")
	}
	if n := k.id(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_item' AND target_row=$1`, id); n != 0 {
		t.Fatal("từ chối mà có vết")
	}
}
