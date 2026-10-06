// Test của hàm tính giá duy nhất qua hai đường đọc của nó — tính thử và menu (P3-06, ADR-086;
// I-009 · I-010 · I-013). Viết TRƯỚC khi có package gia — Claude viết, Codex làm cho xanh mà không
// sửa điều kiện kiểm nào. Ca giá đọc LÚC CHẠY từ master_plan/shop-facts.md §4.8 qua
// db/seed/seed.pl --price-cases-tsv: không con giá nào của quán được gõ vào file này.
package gia_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os/exec"
	"sort"
	"strconv"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/db"
	"banhcuon/be/internal/dbtest"
	"banhcuon/be/internal/gia"
	"github.com/jackc/pgx/v5"
)

type khung struct {
	ctx   context.Context
	srv   *httptest.Server
	owner *pgx.Conn
}

func dung(t *testing.T) khung {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	t.Cleanup(cancel)
	pool, err := db.Open(ctx, dbtest.AppDSN(t), dbtest.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	owner, err := pgx.Connect(ctx, dbtest.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { owner.Close(context.Background()) })
	mux := http.NewServeMux()
	gia.Routes(mux, pool)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	k := khung{ctx: ctx, srv: srv, owner: owner}
	k.napMenuThat(t)
	return k
}

// --- §4.8 đọc lúc chạy --------------------------------------------------------------------

type caGia struct {
	so      int
	mon     string
	soSuat  int
	chon    [][2]string // [nhóm, lựa chọn]
	tuChoi  bool
	kyVong  int64
	monID   int64
	chonIDs []int64
}

func gocRepo(t *testing.T) string {
	t.Helper()
	out, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	return strings.TrimSpace(string(out))
}

func chaySeed(t *testing.T, args ...string) string {
	t.Helper()
	cmd := exec.Command("perl", append([]string{"db/seed/seed.pl"}, args...)...)
	cmd.Dir = gocRepo(t)
	var errBuf bytes.Buffer
	cmd.Stderr = &errBuf
	out, err := cmd.Output()
	if err != nil {
		t.Fatalf("seed.pl %v: %v — %s", args, err, errBuf.String())
	}
	return string(out)
}

func docCa(t *testing.T) []caGia {
	t.Helper()
	var cas []caGia
	for _, dong := range strings.Split(strings.TrimSpace(chaySeed(t, "--price-cases-tsv")), "\n") {
		o := strings.Split(dong, "\t")
		if len(o) != 5 {
			t.Fatalf("dòng ca §4.8 sai hình: %q", dong)
		}
		c := caGia{mon: o[1]}
		var err error
		if c.so, err = strconv.Atoi(o[0]); err != nil {
			t.Fatal(err)
		}
		if c.soSuat, err = strconv.Atoi(o[2]); err != nil {
			t.Fatal(err)
		}
		if o[3] != "" {
			for _, p := range strings.Split(o[3], "|") {
				g, l, ok := strings.Cut(p, "=")
				if !ok {
					t.Fatalf("lựa chọn sai hình: %q", p)
				}
				c.chon = append(c.chon, [2]string{g, l})
			}
		}
		if o[4] == "REJECT" {
			c.tuChoi = true
		} else if c.kyVong, err = strconv.ParseInt(o[4], 10, 64); err != nil {
			t.Fatal(err)
		}
		cas = append(cas, c)
	}
	if len(cas) == 0 {
		t.Fatal("§4.8 không có ca nào")
	}
	return cas
}

// napMenuThat dựng menu thật của P2-10 (một lần cho cả database kiểm) và trả lại các ca §4.8
// kèm mã món · mã lựa chọn tra từ database.
func (k khung) napMenuThat(t *testing.T) {
	t.Helper()
	cas := docCa(t)
	var co bool
	if err := k.owner.QueryRow(k.ctx, "SELECT EXISTS (SELECT 1 FROM shop.menu_item WHERE name = $1)",
		cas[0].mon).Scan(&co); err != nil {
		t.Fatal(err)
	}
	if !co {
		if _, err := k.owner.Exec(k.ctx, chaySeed(t)); err != nil {
			t.Fatalf("nạp dữ liệu mồi: %v", err)
		}
	}
}

func (k khung) caCoMa(t *testing.T) []caGia {
	t.Helper()
	cas := docCa(t)
	for i := range cas {
		c := &cas[i]
		if err := k.owner.QueryRow(k.ctx, "SELECT id FROM shop.menu_item WHERE name = $1", c.mon).Scan(&c.monID); err != nil {
			t.Fatalf("ca %d: món %q: %v", c.so, c.mon, err)
		}
		for _, gl := range c.chon {
			var id int64
			if err := k.owner.QueryRow(k.ctx, `SELECT o.id FROM shop.menu_option o
				JOIN shop.option_group g ON g.id = o.option_group_id WHERE g.name = $1 AND o.name = $2`,
				gl[0], gl[1]).Scan(&id); err != nil {
				t.Fatalf("ca %d: lựa chọn %v: %v", c.so, gl, err)
			}
			c.chonIDs = append(c.chonIDs, id)
		}
	}
	return cas
}

func caSo(t *testing.T, cas []caGia, so int) caGia {
	t.Helper()
	for _, c := range cas {
		if c.so == so {
			return c
		}
	}
	t.Fatalf("§4.8 không còn ca %d", so)
	return caGia{}
}

// --- gọi HTTP -----------------------------------------------------------------------------

type traVe struct {
	status int
	body   map[string]any
}

func (k khung) goi(t *testing.T, method, path string, body any) traVe {
	t.Helper()
	var r *bytes.Reader
	switch b := body.(type) {
	case nil:
		r = bytes.NewReader(nil)
	case string:
		r = bytes.NewReader([]byte(b))
	default:
		raw, err := json.Marshal(b)
		if err != nil {
			t.Fatal(err)
		}
		r = bytes.NewReader(raw)
	}
	req, err := http.NewRequestWithContext(k.ctx, method, k.srv.URL+path, r)
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	out := traVe{status: res.StatusCode, body: map[string]any{}}
	_ = json.NewDecoder(res.Body).Decode(&out.body)
	return out
}

func dongCua(c caGia) map[string]any {
	ids := c.chonIDs
	if ids == nil {
		ids = []int64{}
	}
	return map[string]any{"menu_item_id": c.monID, "quantity": c.soSuat, "option_ids": ids}
}

func tinhThu(k khung, t *testing.T, dong ...map[string]any) traVe {
	t.Helper()
	return k.goi(t, "POST", "/price-quotes", map[string]any{"lines": dong})
}

func so(t *testing.T, v any, ten string) int64 {
	t.Helper()
	f, ok := v.(float64)
	if !ok {
		t.Fatalf("%s: muốn một số, nhận %T %v", ten, v, v)
	}
	return int64(f)
}

func dongThu(t *testing.T, r traVe, i int) map[string]any {
	t.Helper()
	lines, ok := r.body["lines"].([]any)
	if !ok || len(lines) <= i {
		t.Fatalf("thiếu dòng %d trong trả về: %v", i, r.body)
	}
	return lines[i].(map[string]any)
}

func tuChoi(t *testing.T, r traVe, status int, code, field string) {
	t.Helper()
	if r.status != status || r.body["code"] != code || (field != "" && r.body["field"] != field) {
		t.Fatalf("muốn %d %s field=%q, nhận %d %v", status, code, field, r.status, r.body)
	}
	if _, co := r.body["lines"]; co {
		t.Fatalf("lời từ chối không được mang dòng giá nào: %v", r.body)
	}
}

// --- test ---------------------------------------------------------------------------------

// Mọi ca §4.8 qua đường tính thử khớp từng đồng; ca từ chối bị từ chối kèm mã của I-010.
func TestI013_BangCaGiaQuaTinhThu(t *testing.T) {
	k := dung(t)
	for _, c := range k.caCoMa(t) {
		r := tinhThu(k, t, dongCua(c))
		if c.tuChoi {
			tuChoi(t, r, http.StatusUnprocessableEntity, "option_combination_invalid", "lines[0].option_ids")
			t.Logf("ca %d %s %v ⇒ %d %v (TỪ CHỐI)", c.so, c.mon, c.chon, r.status, r.body["code"])
			continue
		}
		if r.status != http.StatusOK {
			t.Fatalf("ca %d: muốn 200, nhận %d %v", c.so, r.status, r.body)
		}
		d := dongThu(t, r, 0)
		donGia, thanhTien := so(t, d["unit_price_vnd"], "unit_price_vnd"), so(t, d["line_total_vnd"], "line_total_vnd")
		tong := so(t, r.body["total_vnd"], "total_vnd")
		t.Logf("ca %d %s ×%d %v ⇒ đơn giá %d, thành tiền %d, tổng %d (§4.8 đòi %d)",
			c.so, c.mon, c.soSuat, c.chon, donGia, thanhTien, tong, c.kyVong)
		if thanhTien != c.kyVong || tong != c.kyVong || donGia*int64(c.soSuat) != c.kyVong {
			t.Fatalf("ca %d lệch §4.8", c.so)
		}
		if so(t, d["menu_item_id"], "menu_item_id") != c.monID || so(t, d["quantity"], "quantity") != int64(c.soSuat) {
			t.Fatalf("ca %d: dòng trả về không phải dòng đã gửi: %v", c.so, d)
		}
		if d["item_name"] != c.mon {
			t.Fatalf("ca %d: tên món %v, muốn %q", c.so, d["item_name"], c.mon)
		}
		if comps, _ := d["components"].([]any); len(comps) == 0 {
			t.Fatalf("ca %d: dòng giá phải kể thành phần đã tính: %v", c.so, d)
		}
		if opts, _ := d["options"].([]any); len(opts) != len(c.chonIDs) {
			t.Fatalf("ca %d: dòng giá kể %d lựa chọn, đã gửi %d", c.so, len(opts), len(c.chonIDs))
		}
	}
}

// FE nhận KẾT QUẢ, không nhận công thức: menu kể giá của mọi tổ hợp hợp lệ, tính bằng cùng hàm.
func TestI013_MenuKeGiaMoiToHop(t *testing.T) {
	k := dung(t)
	r := k.goi(t, "GET", "/menu", nil)
	if r.status != http.StatusOK {
		t.Fatalf("GET /menu: %d %v", r.status, r.body)
	}
	items, _ := r.body["items"].([]any)
	theoMa := map[int64]map[string]any{}
	for _, it := range items {
		m := it.(map[string]any)
		theoMa[so(t, m["menu_item_id"], "menu_item_id")] = m
	}
	khoa := func(ids []int64) string {
		s := append([]int64(nil), ids...)
		sort.Slice(s, func(i, j int) bool { return s[i] < s[j] })
		return fmt.Sprint(s)
	}
	for _, c := range k.caCoMa(t) {
		m, co := theoMa[c.monID]
		if !co {
			t.Fatalf("ca %d: món %q không có trên menu", c.so, c.mon)
		}
		gia := map[string]int64{}
		prices, _ := m["prices"].([]any)
		for _, p := range prices {
			pm := p.(map[string]any)
			var ids []int64
			for _, x := range pm["option_ids"].([]any) {
				ids = append(ids, int64(x.(float64)))
			}
			gia[khoa(ids)] = so(t, pm["unit_price_vnd"], "unit_price_vnd")
		}
		g, co := gia[khoa(c.chonIDs)]
		if c.tuChoi {
			if co {
				t.Fatalf("ca %d: tổ hợp bị cấm mà menu vẫn kể giá %d", c.so, g)
			}
			t.Logf("ca %d: tổ hợp cấm không có trên menu", c.so)
			continue
		}
		if !co || g*int64(c.soSuat) != c.kyVong {
			t.Fatalf("ca %d: menu kể %d (có=%t) × %d, §4.8 đòi %d", c.so, g, co, c.soSuat, c.kyVong)
		}
		if len(c.chonIDs) == 0 {
			if groups, _ := m["option_groups"].([]any); len(groups) != 0 {
				t.Fatalf("ca %d: món không nhận nhân mà menu hiện %d nhóm tuỳ chọn", c.so, len(groups))
			}
		}
		t.Logf("ca %d: menu kể %d × %d = %d", c.so, g, c.soSuat, c.kyVong)
	}
}

// I-013: giá gửi lên bị bỏ — kể cả 0đ, kể cả cao hơn giá đúng.
func TestI013_GiaGuiLenBiBo(t *testing.T) {
	k := dung(t)
	var c caGia
	for _, x := range k.caCoMa(t) {
		if !x.tuChoi && x.kyVong > 0 {
			c = x
			break
		}
	}
	for _, gia := range []int64{0, c.kyVong * 10} {
		dong := dongCua(c)
		dong["unit_price_vnd"] = gia
		dong["line_total_vnd"] = gia
		r := k.goi(t, "POST", "/price-quotes", map[string]any{"lines": []any{dong}, "total_vnd": gia})
		if r.status != http.StatusOK {
			t.Fatalf("gửi kèm giá %d: %d %v", gia, r.status, r.body)
		}
		got := so(t, dongThu(t, r, 0)["line_total_vnd"], "line_total_vnd")
		t.Logf("ca %d gửi kèm giá %d ⇒ thành tiền %d (§4.8 %d)", c.so, gia, got, c.kyVong)
		if got != c.kyVong || so(t, r.body["total_vnd"], "total_vnd") != c.kyVong {
			t.Fatalf("giá gửi lên đã được dùng")
		}
	}
}

// I-010: tổ hợp sai bị từ chối nguyên yêu cầu, không bỏ bớt, không thêm, không đổi tuỳ chọn.
func TestI010_TuChoiKhongSuaHo(t *testing.T) {
	k := dung(t)
	cas := k.caCoMa(t)
	cam := caSo(t, cas, 11) // tổ hợp cấm của §4.6 luật 3
	if !cam.tuChoi || len(cam.chonIDs) != 2 {
		t.Fatalf("§4.8 ca 11 không còn là tổ hợp cấm hai lựa chọn: %+v", cam)
	}
	hop := caSo(t, cas, 2) // cùng món, nhân khác, có lượng nhân
	if hop.tuChoi || hop.monID != cam.monID || len(hop.chonIDs) != 2 {
		t.Fatalf("§4.8 ca 2 không còn là tổ hợp hợp lệ cùng món: %+v", hop)
	}
	khongNhan := caSo(t, cas, 12) // món không nhận nhân
	nhanCam, luongCam := cam.chonIDs[0], cam.chonIDs[1]
	nhanHop := hop.chonIDs[0]
	ca := []struct {
		ten  string
		dong map[string]any
	}{
		{"không chọn nhân nào — không được tự điền mặc định",
			map[string]any{"menu_item_id": cam.monID, "quantity": 1, "option_ids": []int64{}}},
		{"hai lựa chọn của cùng một nhóm",
			map[string]any{"menu_item_id": cam.monID, "quantity": 1, "option_ids": []int64{nhanCam, nhanHop}}},
		{"lượng nhân mà không có nhân",
			map[string]any{"menu_item_id": cam.monID, "quantity": 1, "option_ids": []int64{luongCam}}},
		{"cùng một lựa chọn hai lần",
			map[string]any{"menu_item_id": cam.monID, "quantity": 1, "option_ids": []int64{nhanCam, nhanCam}}},
		{"nhóm nhân cho món không nhận nhân",
			map[string]any{"menu_item_id": khongNhan.monID, "quantity": 1, "option_ids": []int64{nhanHop}}},
	}
	for _, x := range ca {
		r := tinhThu(k, t, x.dong)
		t.Logf("%s ⇒ %d %v", x.ten, r.status, r.body)
		tuChoi(t, r, http.StatusUnprocessableEntity, "option_combination_invalid", "lines[0].option_ids")
	}
	r := tinhThu(k, t, dongCua(hop), dongCua(cam))
	t.Logf("một dòng đúng + một dòng cấm ⇒ %d %v", r.status, r.body)
	tuChoi(t, r, http.StatusUnprocessableEntity, "option_combination_invalid", "lines[1].option_ids")
}

// I-009 tầng 3: món đã ngừng bán bị từ chối tại mốc của cửa, và không còn trên menu.
func TestI009_MonNgungBanBiTuChoi(t *testing.T) {
	k := dung(t)
	ten := "test-ngừng · " + t.Name()
	var comp, mon int64
	if err := k.owner.QueryRow(k.ctx, `INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling)
		VALUES ($1, 1000, false) RETURNING id`, ten).Scan(&comp); err != nil {
		t.Fatal(err)
	}
	if err := k.owner.QueryRow(k.ctx, `INSERT INTO shop.menu_item (name) VALUES ($1) RETURNING id`, ten).Scan(&mon); err != nil {
		t.Fatal(err)
	}
	if _, err := k.owner.Exec(k.ctx, `INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity)
		VALUES ($1, $2, 1)`, mon, comp); err != nil {
		t.Fatal(err)
	}
	dong := map[string]any{"menu_item_id": mon, "quantity": 1, "option_ids": []int64{}}
	if r := tinhThu(k, t, dong); r.status != http.StatusOK {
		t.Fatalf("món đang bán phải tính được: %d %v", r.status, r.body)
	}
	if _, err := k.owner.Exec(k.ctx, `UPDATE shop.menu_item SET discontinued_at = now() WHERE id = $1`, mon); err != nil {
		t.Fatal(err)
	}
	r := tinhThu(k, t, dong)
	t.Logf("món đã ngừng ⇒ %d %v", r.status, r.body)
	tuChoi(t, r, http.StatusConflict, "menu_item_discontinued", "lines[0].menu_item_id")
	m := k.goi(t, "GET", "/menu", nil)
	for _, it := range m.body["items"].([]any) {
		if so(t, it.(map[string]any)["menu_item_id"], "menu_item_id") == mon {
			t.Fatal("món đã ngừng vẫn còn trên menu")
		}
	}
}

func TestI013_YeuCauSaiHinhBiTuChoi(t *testing.T) {
	k := dung(t)
	c := caSo(t, k.caCoMa(t), 2)
	ca := []struct {
		ten          string
		body         any
		status       int
		code, truong string
	}{
		{"JSON hỏng", "{", 400, "invalid_request", ""},
		{"không dòng nào", map[string]any{"lines": []any{}}, 400, "invalid_request", "lines"},
		{"số suất 0", map[string]any{"lines": []any{map[string]any{"menu_item_id": c.monID, "quantity": 0, "option_ids": c.chonIDs}}},
			400, "invalid_request", "lines[0].quantity"},
		{"món không có", map[string]any{"lines": []any{map[string]any{"menu_item_id": 9000000000, "quantity": 1, "option_ids": []int64{}}}},
			404, "menu_item_not_found", "lines[0].menu_item_id"},
		{"lựa chọn không có", map[string]any{"lines": []any{map[string]any{"menu_item_id": c.monID, "quantity": 1, "option_ids": []int64{9000000000}}}},
			404, "menu_option_not_found", "lines[0].option_ids"},
	}
	for _, x := range ca {
		r := k.goi(t, "POST", "/price-quotes", x.body)
		t.Logf("%s ⇒ %d %v", x.ten, r.status, r.body)
		tuChoi(t, r, x.status, x.code, x.truong)
	}
}
