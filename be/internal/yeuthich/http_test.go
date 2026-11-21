// Test của cửa món yêu thích (YT-04, ADR-145, I-045). Viết TRƯỚC khi có gói `yeuthich` (Claude Code, 2026-11-20): đỏ cho tới
// khi Codex dựng cửa. Gọi thật qua Gin như khách web (cookie `banhcuon_khach`), trên menu GIẢ riêng (test-…).
//
// Hợp đồng Claude chốt (chi tiết hình ở phiếu YT-04 và docs/product/3-be/openapi.yaml sau khi Codex ghi):
//
//	GET  /customer-accounts/current/favourites                                   → {"lines":[Line], "sets":[Set]}
//	POST /customer-accounts/current/favourites                     (LineInput)   → Line   — thả tim; trùng hình thì cộng số lượng
//	PUT  /customer-accounts/current/favourites/{favourite_line_id} (LineInput)   → Line   — thay hình và số lượng của dòng
//	POST /customer-accounts/current/favourites/{favourite_line_id}/removal       → 200    — bỏ tim (đặt mốc gỡ)
//	POST /customer-accounts/current/favourite-sets                 (SetInput)    → Set
//	PUT  /customer-accounts/current/favourite-sets/{favourite_set_id} (SetInput: name, lines) → Set — thay tên và các dòng
//	POST /customer-accounts/current/favourite-sets/{favourite_set_id}/removal    → 200
//
// LineInput = PriceLineRequest (menu_item_id + option_ids, hoặc menu_combo_id + portions) + quantity. Line = LineInput đã
// chuẩn hoá + favourite_line_id + available + unavailable_code; KHÔNG giá, KHÔNG tên. Set = favourite_set_id, kind, name, lines.
// Dòng sai hình bị từ chối bằng ĐÚNG mã `POST /price-quotes` trả cho cùng dòng; món không còn bán vẫn đọc ra với
// available=false và unavailable_code = mã price-quotes trả lúc đọc.
package yeuthich_test

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sort"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"banhcuon/be/internal/yeuthich"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

type suat struct {
	MenuItemID int64   `json:"menu_item_id"`
	Quantity   int     `json:"quantity"`
	OptionIDs  []int64 `json:"option_ids"`
}

type dong struct {
	FavouriteLineID int64   `json:"favourite_line_id"`
	MenuItemID      *int64  `json:"menu_item_id"`
	MenuComboID     *int64  `json:"menu_combo_id"`
	OptionIDs       []int64 `json:"option_ids"`
	Portions        []suat  `json:"portions"`
	Quantity        int     `json:"quantity"`
	Available       bool    `json:"available"`
	UnavailableCode *string `json:"unavailable_code"`
}

type bo struct {
	FavouriteSetID int64  `json:"favourite_set_id"`
	Kind           string `json:"kind"`
	Name           string `json:"name"`
	Lines          []dong `json:"lines"`
}

type tatCa struct {
	Lines []dong `json:"lines"`
	Sets  []bo   `json:"sets"`
}

type menuGia struct{ cuon, trung, thit, chay, thuong, nhieu, combo int64 }

type khung struct {
	t     *testing.T
	ctx   context.Context
	r     *gin.Engine
	owner *pgx.Conn
	m     menuGia
}

func (k khung) coVet(fn func(pgx.Tx) error) {
	k.t.Helper()
	err := pgx.BeginFunc(k.ctx, k.owner, func(tx pgx.Tx) error {
		if _, err := tx.Exec(k.ctx, `WITH co AS (SELECT id FROM shop.person WHERE display_name = 'test-người dựng dữ liệu' ORDER BY id LIMIT 1),
			moi AS (INSERT INTO shop.person (display_name, is_owner) SELECT 'test-người dựng dữ liệu', true WHERE NOT EXISTS (SELECT 1 FROM co) RETURNING id)
			SELECT set_config('shop.actor_person_id', id::text, true), set_config('shop.revision_reason', 'test-yt04 dựng dữ liệu', true)
			FROM (SELECT id FROM co UNION ALL SELECT id FROM moi) p`); err != nil {
			return err
		}
		return fn(tx)
	})
	if err != nil {
		k.t.Fatal(err)
	}
}

// dung dựng router chỉ có cửa yêu thích và cửa báo giá, cùng một menu giả: hai món mang Nhân · Lượng nhân (Lượng nhân chỉ
// có khi Nhân = Thịt), một combo 1 cuốn + 2 trứng.
func dung(t *testing.T) khung {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	t.Cleanup(cancel)
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	owner, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { owner.Close(context.Background()) })
	gin.SetMode(gin.TestMode)
	r := gin.New()
	yeuthich.Routes(r, yeuthich.NewService(pool))
	gia.Routes(r, gia.NewService(pool))
	k := khung{t: t, ctx: ctx, r: r, owner: owner}
	ten := " · " + t.Name()
	k.coVet(func(tx pgx.Tx) error {
		q := func(sql string, out *int64, args ...any) {
			if err := tx.QueryRow(ctx, sql, args...).Scan(out); err != nil {
				t.Fatalf("%s: %v", sql, err)
			}
		}
		var banh, gNhan, gLuong int64
		q(`INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 3000, true) RETURNING id`, &banh, "test-bánh"+ten)
		q(`INSERT INTO shop.menu_item (name) VALUES ($1) RETURNING id`, &k.m.cuon, "test-cuốn"+ten)
		q(`INSERT INTO shop.menu_item (name) VALUES ($1) RETURNING id`, &k.m.trung, "test-trứng"+ten)
		for _, mon := range []int64{k.m.cuon, k.m.trung} {
			if _, err := tx.Exec(ctx, `INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 1)`, mon, banh); err != nil {
				return err
			}
		}
		q(`INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id`, &gNhan, "test-Nhân"+ten)
		q(`INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id`, &gLuong, "test-Lượng nhân"+ten)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Thịt', 1000) RETURNING id`, &k.m.thit, gNhan)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Chay', 0) RETURNING id`, &k.m.chay, gNhan)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Thường', 0) RETURNING id`, &k.m.thuong, gLuong)
		q(`INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'test-Nhiều', 1000) RETURNING id`, &k.m.nhieu, gLuong)
		if _, err := tx.Exec(ctx, `INSERT INTO shop.option_group_prerequisite (option_group_id, menu_option_id) VALUES ($1, $2)`, gLuong, k.m.thit); err != nil {
			return err
		}
		for _, mon := range []int64{k.m.cuon, k.m.trung} {
			if _, err := tx.Exec(ctx, `INSERT INTO shop.menu_item_option_group (menu_item_id, option_group_id) VALUES ($1, $2), ($1, $3)`, mon, gNhan, gLuong); err != nil {
				return err
			}
		}
		q(`INSERT INTO shop.menu_combo (name, price_vnd) VALUES ($1, 20000) RETURNING id`, &k.m.combo, "test-combo"+ten)
		if _, err := tx.Exec(ctx, `INSERT INTO shop.menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES ($1, $2, 1), ($1, $3, 2)`,
			k.m.combo, k.m.cuon, k.m.trung); err != nil {
			return err
		}
		return nil
	})
	return k
}

// khach tạo một tài khoản khách và một phiên còn hạn; trả mã phiên thô để đặt cookie.
func (k khung) khach(so string) string {
	k.t.Helper()
	raw := make([]byte, 32) // phiên khách là 32 byte ngẫu nhiên, base64url không đệm: đúng 43 ký tự (authz.CustomerSession)
	if _, err := rand.Read(raw); err != nil {
		k.t.Fatal(err)
	}
	token := base64.RawURLEncoding.EncodeToString(raw)
	h := sha256.Sum256([]byte(token))
	var id int64
	if err := k.owner.QueryRow(k.ctx, `INSERT INTO shop.customer_account (phone, display_name) VALUES ($1, $2) RETURNING id`,
		so, "test-khách "+so).Scan(&id); err != nil {
		k.t.Fatal(err)
	}
	if _, err := k.owner.Exec(k.ctx, `INSERT INTO shop.customer_session (customer_account_id, token_hash, expires_at) VALUES ($1, $2, now() + interval '1 day')`,
		id, h[:]); err != nil {
		k.t.Fatal(err)
	}
	return token
}

func (k khung) goi(token, method, path string, body any) (int, string) {
	k.t.Helper()
	var s string
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			k.t.Fatal(err)
		}
		s = string(b)
	}
	req := httptest.NewRequest(method, path, strings.NewReader(s))
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.AddCookie(&http.Cookie{Name: "banhcuon_khach", Value: token})
	}
	w := httptest.NewRecorder()
	k.r.ServeHTTP(w, req)
	return w.Code, w.Body.String()
}

func maLoi(t *testing.T, body string) string {
	t.Helper()
	var e struct {
		Code string `json:"code"`
	}
	if err := json.Unmarshal([]byte(body), &e); err != nil || e.Code == "" {
		t.Fatalf("thân lỗi không có code: %s", body)
	}
	return e.Code
}

func (k khung) doc(token string) tatCa {
	k.t.Helper()
	st, body := k.goi(token, "GET", "/customer-accounts/current/favourites", nil)
	if st != 200 {
		k.t.Fatalf("đọc yêu thích: %d %s", st, body)
	}
	for _, cam := range []string{"_vnd", "price", "item_name", "image"} {
		if strings.Contains(body, cam) {
			k.t.Fatalf("thân đọc yêu thích mang %q — ADR-145 điểm 3 cấm giá, tên, ảnh: %s", cam, body)
		}
	}
	var out tatCa
	if err := json.Unmarshal([]byte(body), &out); err != nil {
		k.t.Fatal(err)
	}
	return out
}

func (k khung) thaTim(token string, line map[string]any) dong {
	k.t.Helper()
	st, body := k.goi(token, "POST", "/customer-accounts/current/favourites", line)
	if st != 200 {
		k.t.Fatalf("thả tim: %d %s", st, body)
	}
	var d dong
	if err := json.Unmarshal([]byte(body), &d); err != nil {
		k.t.Fatal(err)
	}
	return d
}

// maBaoGia là mã lỗi POST /price-quotes trả cho đúng dòng ấy (bỏ quantity nếu cần như dòng giỏ).
func (k khung) maBaoGia(line map[string]any) string {
	k.t.Helper()
	st, body := k.goi("", "POST", "/price-quotes", map[string]any{"lines": []any{line}})
	if st == 200 {
		k.t.Fatalf("báo giá nhận dòng mà test cho là sai: %v", line)
	}
	return maLoi(k.t, body)
}

func mon(id int64, so int, ids ...int64) map[string]any {
	if ids == nil {
		ids = []int64{}
	}
	return map[string]any{"menu_item_id": id, "quantity": so, "option_ids": ids}
}

func (k khung) combo(so int) map[string]any {
	return map[string]any{"menu_combo_id": k.m.combo, "quantity": so, "portions": []any{
		map[string]any{"menu_item_id": k.m.cuon, "quantity": so, "option_ids": []int64{k.m.thit, k.m.thuong}},
		map[string]any{"menu_item_id": k.m.trung, "quantity": 2 * so, "option_ids": []int64{k.m.chay}},
	}}
}

func sorted(ids []int64) []int64 {
	c := append([]int64(nil), ids...)
	sort.Slice(c, func(i, j int) bool { return c[i] < c[j] })
	return c
}

func TestI045_ChuaDangNhapBi401(t *testing.T) {
	k := dung(t)
	for _, c := range []struct{ method, path string }{
		{"GET", "/customer-accounts/current/favourites"},
		{"POST", "/customer-accounts/current/favourites"},
		{"PUT", "/customer-accounts/current/favourites/1"},
		{"POST", "/customer-accounts/current/favourites/1/removal"},
		{"POST", "/customer-accounts/current/favourite-sets"},
		{"PUT", "/customer-accounts/current/favourite-sets/1"},
		{"POST", "/customer-accounts/current/favourite-sets/1/removal"},
	} {
		st, body := k.goi("", c.method, c.path, mon(k.m.cuon, 1, k.m.chay))
		if st != 401 || maLoi(t, body) != "unauthenticated" {
			t.Fatalf("%s %s không phiên: %d %s", c.method, c.path, st, body)
		}
	}
}

func TestI045_ThaTimDocLaiDungHinhKhongGia(t *testing.T) {
	k := dung(t)
	a := k.khach("0987000401")
	d := k.thaTim(a, mon(k.m.cuon, 2, k.m.thuong, k.m.thit))
	if d.FavouriteLineID <= 0 || d.Quantity != 2 || !d.Available || d.UnavailableCode != nil {
		t.Fatalf("dòng vừa thả tim: %+v", d)
	}
	c := k.thaTim(a, k.combo(1))
	all := k.doc(a)
	if len(all.Lines) != 2 || len(all.Sets) != 0 {
		t.Fatalf("đọc lại: %+v", all)
	}
	l := all.Lines[0]
	if l.FavouriteLineID != d.FavouriteLineID || l.MenuItemID == nil || *l.MenuItemID != k.m.cuon || l.MenuComboID != nil ||
		fmt.Sprint(sorted(l.OptionIDs)) != fmt.Sprint(sorted([]int64{k.m.thit, k.m.thuong})) || l.Quantity != 2 || len(l.Portions) != 0 {
		t.Fatalf("dòng món đọc lại lệch: %+v", l)
	}
	cb := all.Lines[1]
	if cb.FavouriteLineID != c.FavouriteLineID || cb.MenuComboID == nil || *cb.MenuComboID != k.m.combo || cb.MenuItemID != nil ||
		len(cb.OptionIDs) != 0 || len(cb.Portions) != 2 || !cb.Available {
		t.Fatalf("dòng combo đọc lại lệch: %+v", cb)
	}
}

func TestI045_ThaTimTrungHinhCongSoLuong(t *testing.T) {
	k := dung(t)
	a := k.khach("0987000402")
	d1 := k.thaTim(a, mon(k.m.cuon, 1, k.m.thit, k.m.thuong))
	d2 := k.thaTim(a, mon(k.m.cuon, 2, k.m.thuong, k.m.thit)) // cùng tập lựa chọn, khác thứ tự
	if d2.FavouriteLineID != d1.FavouriteLineID || d2.Quantity != 3 {
		t.Fatalf("thả tim trùng hình phải cộng vào dòng cũ: %+v sau %+v", d2, d1)
	}
	k.thaTim(a, mon(k.m.cuon, 1, k.m.chay)) // khác lựa chọn ⇒ dòng mới
	k.thaTim(a, k.combo(1))
	k.thaTim(a, k.combo(1)) // combo trùng suất ⇒ cộng
	all := k.doc(a)
	if len(all.Lines) != 3 || all.Lines[2].Quantity != 2 {
		t.Fatalf("muốn 3 dòng, combo số lượng 2: %+v", all.Lines)
	}
}

func TestI045_DongSaiBiTuChoiBangMaCuaBaoGia(t *testing.T) {
	k := dung(t)
	a := k.khach("0987000403")
	for ten, line := range map[string]map[string]any{
		"món không có":        mon(999999999, 1),
		"thiếu nhóm Nhân":     mon(k.m.cuon, 1),
		"Chay kèm Lượng nhân": mon(k.m.cuon, 1, k.m.chay, k.m.thuong),
		"combo thiếu suất":    {"menu_combo_id": k.m.combo, "quantity": 1, "portions": []any{map[string]any{"menu_item_id": k.m.cuon, "quantity": 1, "option_ids": []int64{k.m.chay}}}},
		"vừa món vừa combo":   {"menu_item_id": k.m.cuon, "menu_combo_id": k.m.combo, "quantity": 1, "option_ids": []int64{k.m.chay}},
	} {
		want := k.maBaoGia(line)
		st, body := k.goi(a, "POST", "/customer-accounts/current/favourites", line)
		if st < 400 || maLoi(t, body) != want {
			t.Fatalf("%s: muốn mã %q như price-quotes, được %d %s", ten, want, st, body)
		}
	}
	if n := len(k.doc(a).Lines); n != 0 {
		t.Fatalf("dòng sai vẫn được lưu: %d dòng", n)
	}
	for _, so := range []int{0, 100} {
		st, body := k.goi(a, "POST", "/customer-accounts/current/favourites", mon(k.m.cuon, so, k.m.chay))
		if st < 400 {
			t.Fatalf("số lượng %d được nhận: %s", so, body)
		}
	}
}

func TestI045_KhachKhacKhongDocKhongSua(t *testing.T) {
	k := dung(t)
	a, b := k.khach("0987000404"), k.khach("0987000405")
	d := k.thaTim(a, mon(k.m.cuon, 1, k.m.chay))
	st, body := k.goi(a, "POST", "/customer-accounts/current/favourite-sets", map[string]any{
		"kind": "rieng", "name": "Bữa sáng", "lines": []any{mon(k.m.cuon, 1, k.m.chay)}})
	if st != 200 {
		t.Fatalf("tạo bộ: %d %s", st, body)
	}
	var s bo
	_ = json.Unmarshal([]byte(body), &s)
	if all := k.doc(b); len(all.Lines) != 0 || len(all.Sets) != 0 {
		t.Fatalf("khách hai thấy dữ liệu của khách một: %+v", all)
	}
	for _, c := range []struct {
		method, path string
		body         any
		code         string
	}{
		{"PUT", fmt.Sprintf("/customer-accounts/current/favourites/%d", d.FavouriteLineID), mon(k.m.cuon, 5, k.m.chay), "favourite_line_not_found"},
		{"POST", fmt.Sprintf("/customer-accounts/current/favourites/%d/removal", d.FavouriteLineID), nil, "favourite_line_not_found"},
		{"PUT", fmt.Sprintf("/customer-accounts/current/favourite-sets/%d", s.FavouriteSetID), map[string]any{"name": "x", "lines": []any{mon(k.m.cuon, 1, k.m.chay)}}, "favourite_set_not_found"},
		{"POST", fmt.Sprintf("/customer-accounts/current/favourite-sets/%d/removal", s.FavouriteSetID), nil, "favourite_set_not_found"},
	} {
		st, body := k.goi(b, c.method, c.path, c.body)
		if st != 404 || maLoi(t, body) != c.code {
			t.Fatalf("khách hai %s %s: %d %s", c.method, c.path, st, body)
		}
	}
	all := k.doc(a)
	if len(all.Lines) != 1 || all.Lines[0].Quantity != 1 || len(all.Sets) != 1 || all.Sets[0].Name != "Bữa sáng" {
		t.Fatalf("dữ liệu khách một bị đổi: %+v", all)
	}
}

func TestI045_SuaDongVaBoTim(t *testing.T) {
	k := dung(t)
	a := k.khach("0987000406")
	d := k.thaTim(a, mon(k.m.cuon, 1, k.m.thit, k.m.thuong))
	st, body := k.goi(a, "PUT", fmt.Sprintf("/customer-accounts/current/favourites/%d", d.FavouriteLineID), mon(k.m.cuon, 4, k.m.thit, k.m.nhieu))
	if st != 200 {
		t.Fatalf("sửa dòng: %d %s", st, body)
	}
	var moi dong
	_ = json.Unmarshal([]byte(body), &moi)
	all := k.doc(a)
	if len(all.Lines) != 1 || all.Lines[0].Quantity != 4 ||
		fmt.Sprint(sorted(all.Lines[0].OptionIDs)) != fmt.Sprint(sorted([]int64{k.m.thit, k.m.nhieu})) {
		t.Fatalf("sau sửa: %+v", all.Lines)
	}
	path := fmt.Sprintf("/customer-accounts/current/favourites/%d/removal", moi.FavouriteLineID)
	if st, body = k.goi(a, "POST", path, nil); st != 200 {
		t.Fatalf("bỏ tim: %d %s", st, body)
	}
	if n := len(k.doc(a).Lines); n != 0 {
		t.Fatalf("bỏ tim rồi vẫn đọc ra %d dòng", n)
	}
	if st, body = k.goi(a, "POST", path, nil); st != 404 || maLoi(t, body) != "favourite_line_not_found" {
		t.Fatalf("bỏ tim lần hai: %d %s", st, body)
	}
	var con int
	if err := k.owner.QueryRow(k.ctx, `SELECT count(*) FROM shop.customer_favourite_line WHERE id = $1 AND removed_at IS NOT NULL`, moi.FavouriteLineID).Scan(&con); err != nil || con != 1 {
		t.Fatalf("bỏ tim phải giữ dòng với mốc gỡ (QD-50): %d %v", con, err)
	}
}

func TestI045_MonNgungBanVanDocVoiCoHetBan(t *testing.T) {
	k := dung(t)
	a := k.khach("0987000407")
	k.thaTim(a, mon(k.m.trung, 1, k.m.chay))
	k.thaTim(a, k.combo(1))
	k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, `UPDATE shop.menu_item SET discontinued_at = now() WHERE id = $1`, k.m.trung)
		return err
	})
	want := k.maBaoGia(mon(k.m.trung, 1, k.m.chay))
	all := k.doc(a)
	if len(all.Lines) != 2 {
		t.Fatalf("món ngừng bán phải vẫn đọc ra: %+v", all.Lines)
	}
	for _, l := range all.Lines {
		if l.Available || l.UnavailableCode == nil {
			t.Fatalf("dòng chứa món ngừng bán phải available=false: %+v", l)
		}
	}
	if *all.Lines[0].UnavailableCode != want {
		t.Fatalf("unavailable_code %q, price-quotes trả %q", *all.Lines[0].UnavailableCode, want)
	}
	st, body := k.goi(a, "POST", "/customer-accounts/current/favourites", mon(k.m.trung, 1, k.m.chay))
	if st < 400 || maLoi(t, body) != want {
		t.Fatalf("thả tim món ngừng bán: %d %s", st, body)
	}
}

func TestI045_BoMonTaoSuaXoa(t *testing.T) {
	k := dung(t)
	a := k.khach("0987000408")
	st, body := k.goi(a, "POST", "/customer-accounts/current/favourite-sets", map[string]any{
		"kind": "rieng", "name": "Bữa sáng của mình", "lines": []any{mon(k.m.cuon, 2, k.m.chay), k.combo(1)}})
	if st != 200 {
		t.Fatalf("tạo bộ: %d %s", st, body)
	}
	var s bo
	if err := json.Unmarshal([]byte(body), &s); err != nil || s.FavouriteSetID <= 0 || s.Kind != "rieng" || len(s.Lines) != 2 {
		t.Fatalf("bộ vừa tạo: %+v %v", s, err)
	}
	st, body = k.goi(a, "POST", "/customer-accounts/current/favourite-sets", map[string]any{
		"kind": "da_luu", "name": "Cuối tuần", "lines": []any{mon(k.m.trung, 1, k.m.chay)}})
	if st != 200 {
		t.Fatalf("lưu thành bộ: %d %s", st, body)
	}
	all := k.doc(a)
	if len(all.Lines) != 0 || len(all.Sets) != 2 || all.Sets[0].Name != "Bữa sáng của mình" || all.Sets[1].Kind != "da_luu" {
		t.Fatalf("dòng của bộ không được lẫn vào dòng tim: %+v", all)
	}
	st, body = k.goi(a, "PUT", fmt.Sprintf("/customer-accounts/current/favourite-sets/%d", s.FavouriteSetID), map[string]any{
		"name": "Bữa sáng nhanh", "lines": []any{mon(k.m.cuon, 3, k.m.thit, k.m.nhieu)}})
	if st != 200 {
		t.Fatalf("sửa bộ: %d %s", st, body)
	}
	all = k.doc(a)
	if all.Sets[0].Name != "Bữa sáng nhanh" || len(all.Sets[0].Lines) != 1 || all.Sets[0].Lines[0].Quantity != 3 {
		t.Fatalf("sau sửa bộ: %+v", all.Sets[0])
	}
	if st, body = k.goi(a, "POST", fmt.Sprintf("/customer-accounts/current/favourite-sets/%d/removal", s.FavouriteSetID), nil); st != 200 {
		t.Fatalf("xoá bộ: %d %s", st, body)
	}
	if all = k.doc(a); len(all.Sets) != 1 || all.Sets[0].Name != "Cuối tuần" {
		t.Fatalf("sau xoá bộ: %+v", all.Sets)
	}
	for ten, in := range map[string]map[string]any{
		"tên rỗng":     {"kind": "rieng", "name": "   ", "lines": []any{mon(k.m.cuon, 1, k.m.chay)}},
		"tên 61 ký tự": {"kind": "rieng", "name": strings.Repeat("a", 61), "lines": []any{mon(k.m.cuon, 1, k.m.chay)}},
		"loại lạ":      {"kind": "combo", "name": "x", "lines": []any{mon(k.m.cuon, 1, k.m.chay)}},
		"không dòng":   {"kind": "rieng", "name": "x", "lines": []any{}},
	} {
		if st, body = k.goi(a, "POST", "/customer-accounts/current/favourite-sets", in); st < 400 || maLoi(t, body) != "invalid_request" {
			t.Fatalf("%s: %d %s", ten, st, body)
		}
	}
	bad := mon(k.m.cuon, 1)
	want := k.maBaoGia(bad)
	if st, body = k.goi(a, "POST", "/customer-accounts/current/favourite-sets", map[string]any{"kind": "rieng", "name": "x", "lines": []any{bad}}); st < 400 || maLoi(t, body) != want {
		t.Fatalf("bộ có dòng sai: muốn %q, được %d %s", want, st, body)
	}
}

func TestI045_GioiHanNamMuoiDongTim(t *testing.T) {
	k := dung(t)
	a := k.khach("0987000409")
	k.thaTim(a, mon(k.m.cuon, 1, k.m.chay))
	// Dựng thẳng thêm 49 dòng gốc chưa gỡ bằng vai chủ (database cho tới 50), rồi lần thả tim thứ 51 — một hình hợp lệ mới —
	// qua cửa phải bị từ chối bằng mã riêng, không phải lỗi máy.
	h := sha256.Sum256([]byte(a))
	if _, err := k.owner.Exec(k.ctx, `INSERT INTO shop.customer_favourite_line (customer_account_id, menu_item_id, quantity)
		SELECT s.customer_account_id, $1, 1 FROM shop.customer_session s, generate_series(1, 49) WHERE s.token_hash = $2`,
		k.m.trung, h[:]); err != nil {
		t.Fatal(err)
	}
	if got := len(k.doc(a).Lines); got != 50 {
		t.Fatalf("chuẩn bị 50 dòng, được %d", got)
	}
	st, body := k.goi(a, "POST", "/customer-accounts/current/favourites", mon(k.m.cuon, 1, k.m.thit, k.m.nhieu))
	if st != 422 || maLoi(t, body) != "favourite_limit_reached" {
		t.Fatalf("dòng tim thứ 51: %d %s", st, body)
	}
	// Thả tim trùng hình đã có vẫn được: chỉ cộng số lượng, không thêm dòng.
	if d := k.thaTim(a, mon(k.m.cuon, 1, k.m.chay)); d.Quantity != 2 {
		t.Fatalf("thả tim trùng khi đủ 50 dòng: %+v", d)
	}
}
