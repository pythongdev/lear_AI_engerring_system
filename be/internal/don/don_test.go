// Test qua cửa tạo lượt gọi (P3-06, ADR-086; I-009 · I-010 · I-013). Viết TRƯỚC khi có package
// don — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Cửa được gọi như mọi cửa
// ghi: hàm exported của gói, quyền và giao dịch ở bên trong (QC-14, ADR-082 điểm 2). Ca giá đọc
// LÚC CHẠY từ master_plan/shop-facts.md §4.8 qua db/seed/seed.pl --price-cases-tsv.
package don_test

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os/exec"
	"strconv"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/ban"
	"banhcuon/be/internal/db"
	"banhcuon/be/internal/dbtest"
	"banhcuon/be/internal/don"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/hoadon"
	"banhcuon/be/internal/menu"
	"banhcuon/be/internal/phien"
	"banhcuon/be/internal/qr"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type xacThucTest struct{}

func (xacThucTest) PersonID(r *http.Request) (int64, bool) {
	id, err := strconv.ParseInt(r.Header.Get("X-Test-Person-Id"), 10, 64)
	return id, err == nil
}

type khung struct {
	ctx   context.Context
	pool  *pgxpool.Pool
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
	menu.Routes(mux, pool, xacThucTest{})
	// P3-07: đường gọi của luồng tại bàn (ADR-087).
	qr.Routes(mux, pool, xacThucTest{})
	don.Routes(mux, pool, xacThucTest{})
	phien.Routes(mux, pool, xacThucTest{})
	hoadon.Routes(mux, pool, xacThucTest{})
	ban.Routes(mux, pool, xacThucTest{})
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	// P3-08 thêm có chủ ý (ADR-088): cửa tạo lượt gọi xét giờ bán tại mốc của đồng hồ (I-008), nên mọi
	// test của gói chạy ở một mốc cố định trong giờ bán, bất kể lúc chạy; test của I-008 tự đặt mốc.
	datDongHo(t, mocMacDinh(t))
	k := khung{ctx: ctx, pool: pool, srv: srv, owner: owner}
	k.napMenuThat(t)
	return k
}

func (k khung) id(t *testing.T, sql string, args ...any) int64 {
	t.Helper()
	var id int64
	if err := k.owner.QueryRow(k.ctx, sql, args...).Scan(&id); err != nil {
		t.Fatalf("%s: %v", sql, err)
	}
	return id
}

// --- §4.8 đọc lúc chạy (cùng cách gia_test.go) ----------------------------------------------

type caGia struct {
	so      int
	mon     string
	soSuat  int
	chon    [][2]string
	tuChoi  bool
	kyVong  int64
	monID   int64
	chonIDs []int64
}

func chaySeed(t *testing.T, args ...string) string {
	t.Helper()
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command("perl", append([]string{"db/seed/seed.pl"}, args...)...)
	cmd.Dir = strings.TrimSpace(string(goc))
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
		c.monID = k.id(t, "SELECT id FROM shop.menu_item WHERE name = $1", c.mon)
		for _, gl := range c.chon {
			c.chonIDs = append(c.chonIDs, k.id(t, `SELECT o.id FROM shop.menu_option o
				JOIN shop.option_group g ON g.id = o.option_group_id WHERE g.name = $1 AND o.name = $2`, gl[0], gl[1]))
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

// --- người, quầy, bàn ------------------------------------------------------------------------

func (k khung) nguoi(t *testing.T, ten string, chuQuan bool) int64 {
	t.Helper()
	return k.id(t, "INSERT INTO shop.person (display_name, is_owner) VALUES ($1, $2) RETURNING id",
		fmt.Sprintf("%s · %s", ten, t.Name()), chuQuan)
}

func (k khung) vaoQuay(t *testing.T, nguoi int64) {
	t.Helper()
	time.Sleep(2 * time.Millisecond)
	if _, err := k.owner.Exec(k.ctx, "UPDATE shop.counter_duty SET ended_at = now() WHERE ended_at IS NULL"); err != nil {
		t.Fatal(err)
	}
	time.Sleep(2 * time.Millisecond)
	if _, err := k.owner.Exec(k.ctx,
		"INSERT INTO shop.counter_duty (person_id, started_at) VALUES ($1, now())", nguoi); err != nil {
		t.Fatal(err)
	}
}

// phienBan: một bàn có một phiên đang mở — dựng tay để test giá không phụ thuộc lượt gọi đầu. Từ
// P3-07 cửa tự tìm phiên từ BÀN (I-002 tầng 3: người gọi không chọn đơn vị tính tiền), nên phien chỉ
// còn để test đọc lại.
type phienBan struct{ phien, ban int64 }

func (k khung) phienBan(t *testing.T) phienBan {
	t.Helper()
	var p phienBan
	p.ban = k.id(t, "INSERT INTO shop.dining_table (label) VALUES ($1) RETURNING id", "bàn · "+t.Name())
	p.phien = k.id(t, "INSERT INTO shop.table_session (status) VALUES ('open') RETURNING id")
	k.id(t, "INSERT INTO shop.table_session_member (table_session_id, dining_table_id) VALUES ($1, $2) RETURNING id", p.phien, p.ban)
	return p
}

func dauLanGui(t *testing.T) string {
	t.Helper()
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	b[6] = b[6]&0x0f | 0x40
	b[8] = b[8]&0x3f | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
}

func dongYeuCau(c caGia) gia.DongYeuCau {
	return gia.DongYeuCau{MenuItemID: c.monID, Quantity: int32(c.soSuat), OptionIDs: c.chonIDs}
}

func (k khung) tao(t *testing.T, nguoi int64, p phienBan, dong ...gia.DongYeuCau) (don.DaTao, error) {
	t.Helper()
	goi := make([]don.DongGoi, len(dong))
	for i, d := range dong {
		goi[i] = don.DongGoi{DongYeuCau: d}
	}
	out, err := don.Tao(k.ctx, k.pool, nguoi, don.YeuCauTaiQuay{
		SubmissionCode: dauLanGui(t),
		DiningTableID:  p.ban,
		Lines:          goi,
	})
	if err == nil && out.TableSessionID != p.phien {
		t.Fatalf("lượt gọi tại bàn %d vào phiên %d, muốn phiên đang mở %d", p.ban, out.TableSessionID, p.phien)
	}
	return out, err
}

// demGhi: số dòng của bốn bảng mà cửa ghi — lời từ chối không được đổi con số nào.
func (k khung) demGhi(t *testing.T) string {
	t.Helper()
	var s string
	if err := k.owner.QueryRow(k.ctx, `SELECT format('%s đơn · %s dòng · %s thành phần · %s tuỳ chọn',
		(SELECT count(*) FROM shop.sales_order), (SELECT count(*) FROM shop.order_line),
		(SELECT count(*) FROM shop.order_line_component), (SELECT count(*) FROM shop.order_line_option))`).Scan(&s); err != nil {
		t.Fatal(err)
	}
	return s
}

func maLoi(t *testing.T, err error, code apierr.Code, field string) {
	t.Helper()
	var e apierr.Error
	if !errors.As(err, &e) || e.Code != code || (field != "" && e.Field != field) {
		t.Fatalf("muốn lời từ chối %s field=%q, nhận %v", code, field, err)
	}
}

// --- HTTP: tính thử và sửa menu --------------------------------------------------------------

func (k khung) goi(t *testing.T, method, path string, nguoi int64, body any) (int, map[string]any) {
	t.Helper()
	raw, err := json.Marshal(body)
	if err != nil {
		t.Fatal(err)
	}
	req, err := http.NewRequestWithContext(k.ctx, method, k.srv.URL+path, bytes.NewReader(raw))
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")
	if nguoi != 0 {
		req.Header.Set("X-Test-Person-Id", strconv.FormatInt(nguoi, 10))
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	out := map[string]any{}
	_ = json.NewDecoder(res.Body).Decode(&out)
	return res.StatusCode, out
}

// tinhThu trả đơn giá mà đường tính thử ra cho một dòng, hoặc mã từ chối.
func (k khung) tinhThu(t *testing.T, d gia.DongYeuCau) (int64, string) {
	t.Helper()
	ids := d.OptionIDs
	if ids == nil {
		ids = []int64{}
	}
	status, body := k.goi(t, "POST", "/price-quotes", 0, map[string]any{"lines": []any{
		map[string]any{"menu_item_id": d.MenuItemID, "quantity": d.Quantity, "option_ids": ids}}})
	if status != http.StatusOK {
		code, _ := body["code"].(string)
		return 0, code
	}
	return int64(body["lines"].([]any)[0].(map[string]any)["unit_price_vnd"].(float64)), ""
}

func (k khung) suaMenu(t *testing.T, chu int64, method, path string, body map[string]any) {
	t.Helper()
	if status, out := k.goi(t, method, path, chu, body); status != http.StatusOK {
		t.Fatalf("%s %s: %d %v", method, path, status, out)
	}
}

// --- đọc lại một dòng đơn đã ghi -------------------------------------------------------------

// anhDong: mọi thứ của một dòng đơn mà I-009 giữ — giá, tên, thành phần, tuỳ chọn đã chụp.
func (k khung) anhDong(t *testing.T, donID int64) string {
	t.Helper()
	var s string
	if err := k.owner.QueryRow(k.ctx, `SELECT string_agg(x, ' ; ' ORDER BY x) FROM (
		SELECT format('dòng %s ×%s đơn giá %s thành tiền %s khoá %s', l.item_name, l.quantity, l.unit_price_vnd,
		              l.line_total_vnd, l.priced_at) AS x
		  FROM shop.order_line l WHERE l.sales_order_id = $1
		UNION ALL
		SELECT format('tp %s #%s %s ×%s nhân=%s giá %s', l.item_name, c.position, c.component_name, c.quantity,
		              c.takes_filling, c.base_price_vnd)
		  FROM shop.order_line l JOIN shop.order_line_component c ON c.order_line_id = l.id WHERE l.sales_order_id = $1
		UNION ALL
		SELECT format('tc %s %s/%s phụ thu %s', l.item_name, o.option_group_name, o.option_name, o.surcharge_vnd)
		  FROM shop.order_line l JOIN shop.order_line_option o ON o.order_line_id = l.id WHERE l.sales_order_id = $1
	) a`, donID).Scan(&s); err != nil {
		t.Fatal(err)
	}
	return s
}

func (k khung) dong(t *testing.T, donID int64) (thanhTien, donGia int64, soTP, khaiTP int) {
	t.Helper()
	if err := k.owner.QueryRow(k.ctx, `SELECT l.line_total_vnd, l.unit_price_vnd,
		(SELECT count(*) FROM shop.order_line_component c WHERE c.order_line_id = l.id), l.component_count
		FROM shop.order_line l WHERE l.sales_order_id = $1`, donID).Scan(&thanhTien, &donGia, &soTP, &khaiTP); err != nil {
		t.Fatal(err)
	}
	return
}

// --- test --------------------------------------------------------------------------------------

// Mọi ca §4.8 qua CỬA GHI ĐƠN khớp từng đồng, và bằng đúng con số đường tính thử ra — một hàm.
func TestI013_BangCaGiaQuaCuaGhiDon(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	k.vaoQuay(t, a)
	p := k.phienBan(t)
	for _, c := range k.caCoMa(t) {
		truoc := k.demGhi(t)
		thu, maThu := k.tinhThu(t, dongYeuCau(c))
		out, err := k.tao(t, a, p, dongYeuCau(c))
		if c.tuChoi {
			maLoi(t, err, "option_combination_invalid", "lines[0].option_ids")
			if maThu != "option_combination_invalid" {
				t.Fatalf("ca %d: cửa ghi từ chối mà tính thử trả %q", c.so, maThu)
			}
			if sau := k.demGhi(t); sau != truoc {
				t.Fatalf("ca %d bị từ chối mà vẫn ghi: %s → %s", c.so, truoc, sau)
			}
			t.Logf("ca %d %s %v ⇒ TỪ CHỐI ở cả hai đường; %s", c.so, c.mon, c.chon, truoc)
			continue
		}
		if err != nil {
			t.Fatalf("ca %d: %v", c.so, err)
		}
		thanhTien, donGia, soTP, khaiTP := k.dong(t, out.SalesOrderID)
		t.Logf("ca %d %s ×%d %v ⇒ đơn %d: đơn giá %d (tính thử %d), thành tiền %d, tổng %d, %d/%d ảnh chụp thành phần (§4.8 đòi %d)",
			c.so, c.mon, c.soSuat, c.chon, out.SalesOrderID, donGia, thu, thanhTien, out.TotalVnd, soTP, khaiTP, c.kyVong)
		if thanhTien != c.kyVong || out.TotalVnd != c.kyVong || donGia != thu || soTP != khaiTP || soTP == 0 {
			t.Fatalf("ca %d lệch", c.so)
		}
	}
}

func TestI012_GhiDonPhaiDungQuay(t *testing.T) {
	k := dung(t)
	c := caSo(t, k.caCoMa(t), 2)
	a := k.nguoi(t, "A", false)
	b := k.nguoi(t, "B", false)
	k.vaoQuay(t, b)
	p := k.phienBan(t)
	truoc := k.demGhi(t)
	_, err := k.tao(t, a, p, dongYeuCau(c))
	maLoi(t, err, "not_on_counter_duty", "")
	_, err = k.tao(t, 0, p, dongYeuCau(c))
	maLoi(t, err, "unauthenticated", "")
	if sau := k.demGhi(t); sau != truoc {
		t.Fatalf("lời từ chối của quyền mà vẫn ghi: %s → %s", truoc, sau)
	}
	out, err := k.tao(t, b, p, dongYeuCau(c))
	if err != nil {
		t.Fatalf("người đang đứng quầy: %v", err)
	}
	var kenh, trangThai string
	if err := k.owner.QueryRow(k.ctx, "SELECT channel_code, status FROM shop.sales_order WHERE id = $1",
		out.SalesOrderID).Scan(&kenh, &trangThai); err != nil {
		t.Fatal(err)
	}
	t.Logf("B đứng quầy ⇒ đơn %d kênh %s trạng thái %s", out.SalesOrderID, kenh, trangThai)
	// P3-07 đổi điều kiện này có chủ ý (ADR-087 điểm 4): Mới là khoảnh khắc, kênh quyết ngay — đặt hộ
	// không phải duyệt ⇒ Đã xác nhận (05-vong-doi.md §5.2 dòng "Mới → Đã xác nhận").
	if kenh != "staff_pos" || trangThai != "confirmed" || out.Status != "confirmed" {
		t.Fatalf("lượt gọi đặt hộ tại quầy: muốn staff_pos · confirmed (05-vong-doi.md §5.2)")
	}
}

// I-010: một dòng sai thì cả lượt gọi bị từ chối — không dòng nào, không đơn nào được ghi.
func TestI010_TuChoiToanBoLuotGoi(t *testing.T) {
	k := dung(t)
	cas := k.caCoMa(t)
	hop, cam := caSo(t, cas, 2), caSo(t, cas, 11)
	a := k.nguoi(t, "A", false)
	k.vaoQuay(t, a)
	p := k.phienBan(t)
	truoc := k.demGhi(t)
	_, err := k.tao(t, a, p, dongYeuCau(hop), dongYeuCau(cam))
	maLoi(t, err, "option_combination_invalid", "lines[1].option_ids")
	_, err = k.tao(t, a, p, gia.DongYeuCau{MenuItemID: cam.monID, Quantity: 1})
	maLoi(t, err, "option_combination_invalid", "lines[0].option_ids")
	if sau := k.demGhi(t); sau != truoc {
		t.Fatalf("lượt gọi bị từ chối mà vẫn ghi: %s → %s", truoc, sau)
	}
	t.Logf("hai lượt gọi bị từ chối; bốn bảng đứng nguyên: %s", truoc)
}

// I-009: chủ quán sửa giá thành phần · phụ thu · thành phần suất rồi ngừng bán — đơn cũ đứng
// nguyên từng chữ; lượt gọi mới trong CÙNG phiên ăn giá mới (một hoá đơn hai mức giá là đúng);
// món đã ngừng thì cửa từ chối.
func TestI009_SuaMenuSauKhiDatDonCuKhongDoi(t *testing.T) {
	k := dung(t)
	ten := func(s string) string { return fmt.Sprintf("test-%s · %s", s, t.Name()) }
	banh := k.id(t, `INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 3000, true) RETURNING id`, ten("bánh"))
	gio := k.id(t, `INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 9000, false) RETURNING id`, ten("giò"))
	mon := k.id(t, `INSERT INTO shop.menu_item (name) VALUES ($1) RETURNING id`, ten("suất"))
	k.id(t, `INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 3) RETURNING id`, mon, banh)
	k.id(t, `INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, 1) RETURNING id`, mon, gio)
	nhom := k.id(t, `INSERT INTO shop.option_group (name) VALUES ($1) RETURNING id`, ten("nhân"))
	thit := k.id(t, `INSERT INTO shop.menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, 'thịt', 1000) RETURNING id`, nhom)
	k.id(t, `INSERT INTO shop.menu_item_option_group (menu_item_id, option_group_id) VALUES ($1, $2) RETURNING id`, mon, nhom)

	chu := k.nguoi(t, "chủ quán", true)
	a := k.nguoi(t, "A", false)
	k.vaoQuay(t, a)
	p := k.phienBan(t)
	d := gia.DongYeuCau{MenuItemID: mon, Quantity: 2, OptionIDs: []int64{thit}}

	thuTruoc, _ := k.tinhThu(t, d)
	donA, err := k.tao(t, a, p, d)
	if err != nil {
		t.Fatal(err)
	}
	anhA := k.anhDong(t, donA.SalesOrderID)
	_, giaA, _, _ := k.dong(t, donA.SalesOrderID)
	if giaA != thuTruoc {
		t.Fatalf("đơn A: đơn giá %d, tính thử %d", giaA, thuTruoc)
	}
	t.Logf("đơn A trước khi sửa menu: %s", anhA)

	k.suaMenu(t, chu, "PUT", fmt.Sprintf("/menu-components/%d/base-price", banh), map[string]any{"base_price_vnd": 5000, "reason": "test: đổi giá thành phần"})
	k.suaMenu(t, chu, "PUT", fmt.Sprintf("/menu-options/%d/surcharge", thit), map[string]any{"surcharge_vnd": 2000, "reason": "test: đổi phụ thu"})
	k.suaMenu(t, chu, "PUT", fmt.Sprintf("/menu-items/%d/components/%d", mon, banh), map[string]any{"quantity": 2, "reason": "test: đổi thành phần suất"})

	if sau := k.anhDong(t, donA.SalesOrderID); sau != anhA {
		t.Fatalf("sửa menu với ngược vào đơn A:\n trước %s\n sau   %s", anhA, sau)
	}
	thuSau, _ := k.tinhThu(t, d)
	donB, err := k.tao(t, a, p, d)
	if err != nil {
		t.Fatal(err)
	}
	_, giaB, soTP, khaiTP := k.dong(t, donB.SalesOrderID)
	t.Logf("cùng phiên %d: đơn A đơn giá %d, đơn B (sau ba lần sửa) đơn giá %d = tính thử %d; B có %d/%d ảnh chụp thành phần",
		p.phien, giaA, giaB, thuSau, soTP, khaiTP)
	if giaB != thuSau || giaB == giaA || soTP != khaiTP {
		t.Fatal("lượt gọi mới phải ăn giá mới, bằng đúng con số tính thử")
	}

	k.suaMenu(t, chu, "POST", fmt.Sprintf("/menu-items/%d/discontinuation", mon), map[string]any{"reason": "test: ngừng bán"})
	truoc := k.demGhi(t)
	_, err = k.tao(t, a, p, d)
	maLoi(t, err, "menu_item_discontinued", "lines[0].menu_item_id")
	if _, ma := k.tinhThu(t, d); ma != "menu_item_discontinued" {
		t.Fatalf("tính thử món đã ngừng: muốn menu_item_discontinued, nhận %q", ma)
	}
	if sau := k.demGhi(t); sau != truoc {
		t.Fatalf("món đã ngừng mà vẫn ghi: %s → %s", truoc, sau)
	}
	if sau := k.anhDong(t, donA.SalesOrderID); sau != anhA {
		t.Fatalf("ngừng bán với ngược vào đơn A: %s", sau)
	}
	t.Logf("ngừng bán ⇒ lượt gọi mới bị từ chối, đơn A vẫn: %s", anhA)
}
