package menu_test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/danhmuc"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/menu"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
)

func TestQC14_ThemThanhPhanHinh(t *testing.T) {
	r := gin.New()
	menu.Routes(r, menu.NewService(nil))
	for _, c := range []struct{ body, field string }{
		{`{"quantity":1,"reason":"x"}`, ""},
		{`{"quantity":1,"reason":"x","menu_component_id":1,"component":null}`, ""},
		{`{"quantity":1,"reason":"x","menu_component_id":null}`, "menu_component_id"},
		{`{"quantity":1,"reason":"x","menu_component_id":1,"component":{}}`, ""},
		{`{"quantity":1,"menu_component_id":1,"reason":"  "}`, "reason"},
		{`{"quantity":0,"menu_component_id":1,"reason":"x"}`, "quantity"},
		{`{"quantity":2147483648,"menu_component_id":1,"reason":"x"}`, ""},
		{`{"quantity":1,"menu_component_id":0,"reason":"x"}`, "menu_component_id"},
		{`{"quantity":1,"reason":"x","component":{"name":"x","base_price_vnd":0,"takes_filling":false,"station_code":"la"}}`, "component.station_code"},
		{`{"quantity":1,"reason":"x","component":{"name":"x","base_price_vnd":0,"takes_filling":false}}`, "component.station_code"},
	} {
		w := httptest.NewRecorder()
		r.ServeHTTP(w, httptest.NewRequest("POST", "/menu-items/1/components", strings.NewReader(c.body)))
		var out struct{ Code, Field string }
		_ = json.Unmarshal(w.Body.Bytes(), &out)
		if w.Code != 400 || out.Code != "invalid_request" || out.Field != c.field {
			t.Fatalf("%s: %d %s", c.body, w.Code, w.Body.String())
		}
	}
}

func TestI018_ThemThanhPhanVetTramVaTuChoi(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ", true)
	thuong := k.nguoi(t, "thường", false)
	m := k.menuGia(t)
	path := fmt.Sprintf("/menu-items/%d/components", m.mon)
	tp := k.id(t, `INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,2500,false) RETURNING id`, t.Name())
	body := map[string]any{"menu_component_id": tp, "quantity": 2, "reason": "  thêm thành phần  "}
	tuChoi(t, k.goi(t, "POST", path, thuong, body), 403, "owner_only", "")
	tuChoi(t, k.goi(t, "POST", path, chu, map[string]any{"menu_component_id": tp, "quantity": 2}), 400, "invalid_request", "reason")
	if n := k.id(t, `SELECT count(*) FROM shop.menu_item_component WHERE menu_item_id=$1 AND menu_component_id=$2`, m.mon, tp); n != 0 {
		t.Fatal("thiếu lý do vẫn ghi")
	}
	res := k.goi(t, "POST", path, chu, body)
	if res.status != 201 || res.body["quantity"] != float64(2) || res.body["menu_component_id"] != float64(tp) {
		t.Fatalf("thêm: %v", res)
	}
	if n := k.id(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_item' AND target_row=$1 AND reason='thêm thành phần' AND person_id=$2`, m.mon, chu); n != 1 {
		t.Fatal("thiếu vết")
	}
	tuChoi(t, k.goi(t, "POST", path, chu, body), 409, "menu_item_component_conflict", "")
	tuChoi(t, k.goi(t, "POST", "/menu-items/9000000000/components", chu, body), 404, "menu_item_not_found", "")
	tuChoi(t, k.goi(t, "POST", path, chu, map[string]any{"menu_component_id": 9000000000, "quantity": 1, "reason": "x"}), 404, "menu_component_not_found", "")
	moi := map[string]any{"quantity": 1, "reason": "thêm mới", "component": map[string]any{"name": t.Name() + " mới", "base_price_vnd": 1000, "takes_filling": false, "station_code": "canh"}}
	res = k.goi(t, "POST", path, chu, moi)
	if res.status != 201 {
		t.Fatalf("tạo mới: %v", res)
	}
	id := int64(res.body["menu_component_id"].(float64))
	if n := k.id(t, `SELECT count(*) FROM shop.menu_component_station WHERE menu_component_id=$1 AND station_code='canh'`, id); n != 1 {
		t.Fatal("sai trạm")
	}
	tuChoi(t, k.goi(t, "POST", path, chu, moi), 409, "menu_component_name_conflict", "")
	r := k.goi(t, "POST", fmt.Sprintf("/menu-items/%d/discontinuation", m.mon), chu, map[string]any{"reason": "ngừng"})
	if r.status != 200 {
		t.Fatal(r)
	}
	tuChoi(t, k.goi(t, "POST", path, chu, body), 409, "menu_item_discontinued", "")
}

func TestI013_ThemThanhPhanGiaMenuVaDanhMuc(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ", true)
	m := k.menuGia(t)
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	gia.Routes(r, gia.NewService(pool))
	danhmuc.Routes(r, danhmuc.NewService(pool))
	docGia := func() []int64 {
		w := httptest.NewRecorder()
		r.ServeHTTP(w, httptest.NewRequest("GET", "/menu", nil))
		if w.Code != 200 {
			t.Fatal(w.Body.String())
		}
		var out struct {
			Items []struct {
				ID     int64 `json:"menu_item_id"`
				Prices []struct {
					Price int64 `json:"unit_price_vnd"`
				} `json:"prices"`
			} `json:"items"`
		}
		if e := json.Unmarshal(w.Body.Bytes(), &out); e != nil {
			t.Fatal(e)
		}
		for _, item := range out.Items {
			if item.ID == m.mon {
				prices := []int64{}
				for _, p := range item.Prices {
					prices = append(prices, p.Price)
				}
				return prices
			}
		}
		t.Fatal("thiếu món")
		return nil
	}
	truoc := docGia()
	tp := k.id(t, `INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,2500,false) RETURNING id`, t.Name())
	res := k.goi(t, "POST", fmt.Sprintf("/menu-items/%d/components", m.mon), chu, map[string]any{"menu_component_id": tp, "quantity": 2, "reason": "thêm", "unit_price_vnd": 1})
	if res.status != 201 {
		t.Fatal(res)
	}
	sau := docGia()
	if len(truoc) == 0 || len(truoc) != len(sau) {
		t.Fatal("sai số giá")
	}
	for i := range sau {
		if sau[i]-truoc[i] != 5000 {
			t.Fatalf("giá: %v -> %v", truoc, sau)
		}
	}
	req := httptest.NewRequest("GET", "/menu-categories", nil)
	req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, chu)})
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != 200 {
		t.Fatal(w.Body.String())
	}
	var ds danhmuc.DanhSach
	if e := json.Unmarshal(w.Body.Bytes(), &ds); e != nil {
		t.Fatal(e)
	}
	items := ds.UncategorizedItems
	for _, dm := range ds.Categories {
		items = append(items, dm.Items...)
	}
	for _, item := range items {
		if item.ID == m.mon {
			for _, c := range item.Components {
				if c.ID == tp && c.Name == t.Name() && c.Quantity == 2 && c.BasePriceVnd == 2500 && !c.TakesFilling {
					return
				}
			}
		}
	}
	t.Fatal("danh mục thiếu thành phần")
}
