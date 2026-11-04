// T-237 — GET /menu mang danh mục của từng món (I-032). Claude viết TRƯỚC khi đổi hợp đồng; Codex làm cho xanh,
// không sửa điều kiện kiểm.
//
// Hợp đồng Claude chốt (2026-11-04), chỉ thêm, không bỏ trường nào:
//   - Mỗi phần tử `items` thêm `menu_category_id` (luôn có mặt): id danh mục của món nếu danh mục ấy chưa ẩn; null khi
//     món chưa xếp hoặc thuộc danh mục đã ẩn.
//   - `Menu` thêm `categories` (luôn có mặt, có thể rỗng): mỗi phần tử `{menu_category_id, name}`, chỉ danh mục chưa ẩn
//     có ít nhất một món trong `items`; xếp theo `name` (collation của cột) rồi `menu_category_id`.
//   - Món ngừng bán vẫn không có trên menu; danh mục chỉ có món ngừng bán không có trong `categories`.
//   - Thứ tự và nội dung `items`, `combos` giữ nguyên như trước.
package gia_test

import (
	"fmt"
	"net/http"
	"testing"

	"github.com/jackc/pgx/v5"
)

func TestI032_MenuMangDanhMucCuaMon(t *testing.T) {
	k := dung(t)
	ten := func(s string) string { return fmt.Sprintf("%s · %s", s, t.Name()) }
	var banh, anKem, an, rong, chiNgung, m1, m2, m3, m4, m5 int64
	if err := k.coVet(func(tx pgx.Tx) error {
		dm := func(name string, hidden bool, out *int64) error {
			if hidden {
				return tx.QueryRow(k.ctx, "INSERT INTO shop.menu_category(name, hidden_at, hidden_by_person_id) VALUES ($1, now(), shop.actor_person_id()) RETURNING id", name).Scan(out)
			}
			return tx.QueryRow(k.ctx, "INSERT INTO shop.menu_category(name) VALUES ($1) RETURNING id", name).Scan(out)
		}
		// Món đang bán phải có một thành phần có giá, nếu không hàm giá của cả menu lỗi (cùng khuôn monThuSuat của gói don).
		mon := func(name string, ngung bool, out *int64) error {
			if ngung {
				return tx.QueryRow(k.ctx, "INSERT INTO shop.menu_item(name, discontinued_at) VALUES ($1, now()) RETURNING id", name).Scan(out)
			}
			if err := tx.QueryRow(k.ctx, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", name).Scan(out); err != nil {
				return err
			}
			var tp int64
			if err := tx.QueryRow(k.ctx, "INSERT INTO shop.menu_component(name, base_price_vnd, takes_filling) VALUES ($1, 1000, false) RETURNING id", name+" tp").Scan(&tp); err != nil {
				return err
			}
			_, err := tx.Exec(k.ctx, "INSERT INTO shop.menu_item_component(menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 1)", *out, tp)
			return err
		}
		xep := func(item, cat int64) error {
			_, err := tx.Exec(k.ctx, "INSERT INTO shop.menu_item_category(menu_item_id, menu_category_id) VALUES ($1, $2)", item, cat)
			return err
		}
		for _, b := range []struct {
			name   string
			hidden bool
			out    *int64
		}{{ten("test-Bánh"), false, &banh}, {ten("test-Ăn kèm"), false, &anKem}, {ten("test-Ẩn"), true, &an},
			{ten("test-Rỗng"), false, &rong}, {ten("test-Chỉ ngừng bán"), false, &chiNgung}} {
			if err := dm(b.name, b.hidden, b.out); err != nil {
				return err
			}
		}
		for _, m := range []struct {
			name  string
			ngung bool
			out   *int64
		}{{ten("test-món bánh"), false, &m1}, {ten("test-món kèm"), false, &m2}, {ten("test-món danh mục ẩn"), false, &m3},
			{ten("test-món chưa xếp"), false, &m4}, {ten("test-món ngừng"), true, &m5}} {
			if err := mon(m.name, m.ngung, m.out); err != nil {
				return err
			}
		}
		for _, x := range [][2]int64{{m1, banh}, {m2, anKem}, {m3, an}, {m5, chiNgung}} {
			if err := xep(x[0], x[1]); err != nil {
				return err
			}
		}
		return nil
	}); err != nil {
		t.Fatal(err)
	}

	r := k.goi(t, "GET", "/menu", nil)
	if r.status != http.StatusOK {
		t.Fatalf("GET /menu: %d %v", r.status, r.body)
	}
	items, ok := r.body["items"].([]any)
	if !ok {
		t.Fatalf("menu thiếu items: %v", r.body)
	}
	cats, ok := r.body["categories"].([]any)
	if !ok {
		t.Fatalf("menu thiếu categories: %v", r.body)
	}
	if _, ok := r.body["combos"].([]any); !ok {
		t.Fatalf("menu thiếu combos: %v", r.body)
	}

	// Mọi món có khoá menu_category_id; mọi id khác null có trong categories.
	trongDanhMuc := map[int64]bool{}
	for _, x := range cats {
		c := x.(map[string]any)
		if _, co := c["name"].(string); !co {
			t.Fatalf("danh mục thiếu name: %v", c)
		}
		trongDanhMuc[so(t, c["menu_category_id"], "menu_category_id")] = true
	}
	cuaMon := map[int64]*int64{}
	coMon := map[int64]bool{}
	for _, x := range items {
		m := x.(map[string]any)
		v, co := m["menu_category_id"]
		if !co {
			t.Fatalf("món thiếu khoá menu_category_id: %v", m)
		}
		id := so(t, m["menu_item_id"], "menu_item_id")
		if v == nil {
			cuaMon[id] = nil
			continue
		}
		c := so(t, v, "menu_category_id")
		if !trongDanhMuc[c] {
			t.Fatalf("món %d trỏ danh mục %d không có trong categories", id, c)
		}
		cuaMon[id] = &c
		coMon[c] = true
	}
	// Mọi danh mục trả về có ít nhất một món trên menu.
	for c := range trongDanhMuc {
		if !coMon[c] {
			t.Fatalf("danh mục %d không có món nào trên menu mà vẫn được trả", c)
		}
	}

	muon := map[int64]*int64{m1: &banh, m2: &anKem, m3: nil, m4: nil}
	for id, want := range muon {
		got, co := cuaMon[id]
		if !co {
			t.Fatalf("món đang bán %d không có trên menu", id)
		}
		if (want == nil) != (got == nil) || (want != nil && *want != *got) {
			t.Fatalf("món %d: danh mục muốn %v, nhận %v", id, want, got)
		}
	}
	if _, co := cuaMon[m5]; co {
		t.Fatalf("món ngừng bán %d vẫn trên menu", m5)
	}
	for _, c := range []int64{an, rong, chiNgung} {
		if trongDanhMuc[c] {
			t.Fatalf("danh mục %d (ẩn, rỗng hoặc chỉ có món ngừng bán) vẫn được trả", c)
		}
	}

	// Thứ tự: theo tên (collation của cột) rồi id — "Ăn kèm" đứng trước "Bánh".
	viTri := map[int64]int{}
	for i, x := range cats {
		viTri[so(t, x.(map[string]any)["menu_category_id"], "menu_category_id")] = i
	}
	if viTri[anKem] >= viTri[banh] {
		t.Fatalf("danh mục không theo tên: %v", cats)
	}
	var ten1, ten2 string
	for i := 1; i < len(cats); i++ {
		a, b := cats[i-1].(map[string]any), cats[i].(map[string]any)
		ten1, ten2 = a["name"].(string), b["name"].(string)
		var dung bool
		if err := k.owner.QueryRow(k.ctx, `SELECT $1::text COLLATE "vi-x-icu" < $2::text COLLATE "vi-x-icu"
			OR ($1::text COLLATE "vi-x-icu" = $2::text COLLATE "vi-x-icu" AND $3::bigint < $4::bigint)`,
			ten1, ten2, so(t, a["menu_category_id"], "id"), so(t, b["menu_category_id"], "id")).Scan(&dung); err != nil {
			t.Fatal(err)
		}
		if !dung {
			t.Fatalf("danh mục %d (%q) đứng trước %d (%q) sai thứ tự", i-1, ten1, i, ten2)
		}
	}
}
