// Test qua cửa của sản xuất theo mẻ (P3-10, ADR-090; I-004 · I-016 · I-019 · I-020 · YC-07 · I-012).
// Viết TRƯỚC khi có package sanxuat — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào.
// Mọi lần ghi đi qua đường gọi HTTP của lát; database chỉ được đọc (và dựng tay đúng chỗ ghi rõ lý do).
// Luật của owner: POS là nơi duy nhất ghi tiến độ, ba trạm bếp chỉ đọc (architecture.md §1.1); một lần
// bấm là một mẻ, bàn là đơn vị đếm (shop-facts.md §5.4); "đã ra bàn" nhận số cái từng thứ cho một bàn —
// lời S-5 2026-10-09 (ADR-090 điểm 4 Sửa đổi).
package don_test

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"testing"
)

// --- khung của lát ---------------------------------------------------------------------------

func (c canh) bamMe(t *testing.T, nguoi int64, viec ...int64) traLoi {
	t.Helper()
	if viec == nil {
		viec = []int64{}
	}
	return c.post(t, "/production-batches", nguoi, map[string]any{"station_job_ids": viec})
}

func (c canh) luiMe(t *testing.T, nguoi, me int64) traLoi {
	t.Helper()
	return c.post(t, fmt.Sprintf("/production-batches/%d/rollback", me), nguoi, map[string]any{})
}

// mucRa: một hàng của bảng nhu cầu và số cái quầy vừa bưng — S-5, chủ quán chốt 2026-10-09: POS nhập số
// cái từng thứ cho MỘT bàn rồi bấm (shop-facts.md §5.4).
type mucRa struct {
	tram      string
	thanhPhan int64   // 0 = nước chấm
	nhan      []int64 // tuỳ chọn nhân của hàng; rỗng khi thành phần không nhận nhân
	so        int64
}

// raBanSo: POST /served-marks cho một bàn (ban ≠ 0) hoặc một đơn không bàn (don ≠ 0).
func (c canh) raBanSo(t *testing.T, nguoi, ban, don int64, muc ...mucRa) traLoi {
	t.Helper()
	body := map[string]any{}
	if ban != 0 {
		body["dining_table_id"] = ban
	}
	if don != 0 {
		body["sales_order_id"] = don
	}
	items := []map[string]any{}
	for _, m := range muc {
		var thanhPhan any
		if m.thanhPhan != 0 {
			thanhPhan = m.thanhPhan
		}
		nhan := m.nhan
		if nhan == nil {
			nhan = []int64{}
		}
		items = append(items, map[string]any{"station_code": m.tram, "menu_component_id": thanhPhan,
			"filling_option_ids": nhan, "quantity": m.so})
	}
	body["items"] = items
	return c.post(t, "/served-marks", nguoi, body)
}

// phanRa: các đơn vị đã chỉ, gom thành số cái từng thứ của từng phần (bàn, hoặc đơn không bàn) — khoá đọc
// độc lập với code, theo ảnh chụp của dòng đơn như khoaCua.
type phanRa struct {
	ban, don int64
	muc      []mucRa
}

func (c canh) phanRaCua(t *testing.T, viec ...int64) []phanRa {
	t.Helper()
	rows, err := c.owner.Query(c.ctx, `SELECT coalesce(o.dining_table_id, 0),
		CASE WHEN o.dining_table_id IS NULL THEN o.id ELSE 0 END, j.station_code, coalesce(lc.menu_component_id, 0),
		CASE WHEN lc.takes_filling THEN ARRAY(SELECT DISTINCT x.menu_option_id FROM shop.order_line_option x
		  WHERE x.order_line_id = j.order_line_id ORDER BY 1) ELSE ARRAY[]::bigint[] END AS nhan, count(*)
		FROM shop.station_job j JOIN shop.sales_order o ON o.id = j.sales_order_id
		LEFT JOIN shop.order_line_component lc ON lc.id = j.order_line_component_id
		WHERE j.id = ANY($1::bigint[]) GROUP BY 1, 2, 3, 4, 5 ORDER BY 1, 2, 3, 4, 5::text`, viec)
	if err != nil {
		t.Fatal(err)
	}
	defer rows.Close()
	var out []phanRa
	for rows.Next() {
		var ban, don int64
		var m mucRa
		if err := rows.Scan(&ban, &don, &m.tram, &m.thanhPhan, &m.nhan, &m.so); err != nil {
			t.Fatal(err)
		}
		if len(out) == 0 || out[len(out)-1].ban != ban || out[len(out)-1].don != don {
			out = append(out, phanRa{ban: ban, don: don})
		}
		out[len(out)-1].muc = append(out[len(out)-1].muc, m)
	}
	if err := rows.Err(); err != nil {
		t.Fatal(err)
	}
	return out
}

// mucCua: hàng của bảng nhu cầu chứa một đơn vị, với số cái cho trước.
func (c canh) mucCua(t *testing.T, viec, so int64) mucRa {
	t.Helper()
	p := c.phanRaCua(t, viec)
	if len(p) != 1 || len(p[0].muc) != 1 {
		t.Fatalf("đơn vị %d không đọc ra đúng một hàng: %+v", viec, p)
	}
	m := p[0].muc[0]
	m.so = so
	return m
}

// raBan: bưng đúng các đơn vị đã chỉ — mỗi phần một lần bấm số cái từng thứ. Chỉ dùng khi tập là MỌI cái đã
// làm của các hàng ấy ở phần ấy, hoặc khi phần chỉ có một lượt gọi (thứ tự lượt gọi không đổi kết quả).
func (c canh) raBan(t *testing.T, nguoi int64, viec ...int64) traLoi {
	t.Helper()
	var r traLoi
	for _, p := range c.phanRaCua(t, viec...) {
		r = c.raBanSo(t, nguoi, p.ban, p.don, p.muc...)
		if r.status != http.StatusOK {
			return r
		}
	}
	return r
}

func (c canh) chuyen(t *testing.T, nguoi int64, cap ...[2]int64) traLoi {
	t.Helper()
	ds := []map[string]any{}
	for _, p := range cap {
		ds = append(ds, map[string]any{"from_station_job_id": p[0], "to_station_job_id": p[1]})
	}
	return c.post(t, "/station-job-transfers", nguoi, map[string]any{"transfers": ds})
}

func (c canh) ghiLamSai(t *testing.T, nguoi, viec int64, ghiChu any) traLoi {
	t.Helper()
	body := map[string]any{"station_job_id": viec}
	if ghiChu != nil {
		body["note"] = ghiChu
	}
	return c.post(t, "/wrong-make-notes", nguoi, body)
}

func (c canh) huyGhiChu(t *testing.T, nguoi, ghiChu int64) traLoi {
	t.Helper()
	return c.post(t, fmt.Sprintf("/wrong-make-notes/%d/cancellation", ghiChu), nguoi, map[string]any{})
}

func (c canh) huyDon(t *testing.T, nguoi, don int64) traLoi {
	t.Helper()
	return c.post(t, fmt.Sprintf("/orders/%d/cancellation", don), nguoi, map[string]any{})
}

// viecCua: đơn vị việc trạm của một đơn ở một trạng thái, theo id — đọc database, không ghi.
func (c canh) viecCua(t *testing.T, don int64, trangThai string) []int64 {
	t.Helper()
	rows, err := c.owner.Query(c.ctx, "SELECT id FROM shop.station_job WHERE sales_order_id = $1 AND status = $2 ORDER BY id", don, trangThai)
	if err != nil {
		t.Fatal(err)
	}
	defer rows.Close()
	var ids []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			t.Fatal(err)
		}
		ids = append(ids, id)
	}
	if err := rows.Err(); err != nil {
		t.Fatal(err)
	}
	return ids
}

// viec: như viecCua, nhưng đỏ gọn (không panic) khi đơn chưa có đủ đơn vị — đơn một suất của lát có ít
// nhất ba đơn vị chưa làm, và mọi đơn đã qua mẻ có ít nhất một đơn vị đã làm xong.
func (c canh) viec(t *testing.T, don int64, trangThai string) []int64 {
	t.Helper()
	ids, can := c.viecCua(t, don, trangThai), 1
	if trangThai == "pending" {
		can = 3
	}
	if len(ids) < can {
		t.Fatalf("đơn %d có %d đơn vị %s, muốn ít nhất %d — đơn chưa nổ? (I-004)", don, len(ids), trangThai, can)
	}
	return ids
}

// phucVuHet: mọi việc chưa làm của đơn qua MỘT mẻ, rồi mọi việc đã làm xong qua MỘT lần đã ra bàn — qua cửa.
func (c canh) phucVuHet(t *testing.T, nguoi, don int64) {
	t.Helper()
	if ids := c.viecCua(t, don, "pending"); len(ids) > 0 {
		canDat(t, c.bamMe(t, nguoi, ids...), http.StatusCreated)
	}
	if ids := c.viecCua(t, don, "made"); len(ids) > 0 {
		canDat(t, c.raBan(t, nguoi, ids...), http.StatusOK)
	}
}

// anhSanXuat: mọi thứ lát này ghi, đếm toàn database, kèm trạng thái của các đơn vị đã chỉ ra. Một lời
// từ chối không được đổi chữ nào.
func (c canh) anhSanXuat(t *testing.T, viec ...int64) string {
	t.Helper()
	if viec == nil {
		viec = []int64{}
	}
	return c.docChu(t, `SELECT format('%s việc · %s mẻ (%s lùi) · %s thứ đã làm · %s lần chuyển · %s ghi chú (%s huỷ) · %s đơn huỷ | %s',
		(SELECT count(*) FROM shop.station_job), (SELECT count(*) FROM shop.production_batch),
		(SELECT count(*) FROM shop.production_batch WHERE rolled_back_at IS NOT NULL),
		(SELECT count(*) FROM shop.production_batch_item), (SELECT count(*) FROM shop.station_job_transfer),
		(SELECT count(*) FROM shop.wrong_make_note), (SELECT count(*) FROM shop.wrong_make_note WHERE cancelled_at IS NOT NULL),
		(SELECT count(*) FROM shop.sales_order WHERE status = 'cancelled'),
		(SELECT coalesce(string_agg(format('%s:%s', j.id, j.status), ',' ORDER BY j.id), '-')
		   FROM shop.station_job j WHERE j.id = ANY($1::bigint[])))`, viec)
}

// --- bảng nhu cầu: GET /production-board -----------------------------------------------------

type phanBang struct {
	ban, don                               int64 // một trong hai khác 0: bàn (đơn gắn bàn) hoặc đơn lẻ
	goi, chuaLam, daLam, daRaBan, conThieu int64
}

type hangBang struct {
	tram      string
	thanhPhan int64  // 0 = nước chấm (việc cấp đơn)
	nhan      string // mã tuỳ chọn nhân, nối bằng ","
	tong      phanBang
	phan      []phanBang
}

func (h hangBang) khoa() string { return fmt.Sprintf("%s/%d/%s", h.tram, h.thanhPhan, h.nhan) }

func soCua(t *testing.T, m map[string]any, key string) int64 {
	t.Helper()
	v, co := m[key]
	if !co {
		t.Fatalf("bảng nhu cầu thiếu trường %q: %v", key, m)
	}
	if v == nil {
		return 0
	}
	f, ok := v.(float64)
	if !ok {
		t.Fatalf("trường %q không phải số: %v", key, m)
	}
	return int64(f)
}

func bonSo(t *testing.T, m map[string]any) phanBang {
	return phanBang{goi: soCua(t, m, "ordered"), chuaLam: soCua(t, m, "pending"), daLam: soCua(t, m, "made"),
		daRaBan: soCua(t, m, "served"), conThieu: soCua(t, m, "missing")}
}

func (c canh) bang(t *testing.T, tram string) []hangBang {
	t.Helper()
	path := "/production-board"
	if tram != "" {
		path += "?station_code=" + tram
	}
	status, out := c.goi(t, "GET", path, 0, nil)
	if status != http.StatusOK {
		t.Fatalf("GET %s: %d %v", path, status, out)
	}
	ds, ok := out["rows"].([]any)
	if !ok {
		t.Fatalf("GET %s: thiếu rows: %v", path, out)
	}
	var hang []hangBang
	for _, x := range ds {
		m, _ := x.(map[string]any)
		h := hangBang{tram: fmt.Sprint(m["station_code"]), thanhPhan: soCua(t, m, "menu_component_id"), tong: bonSo(t, m)}
		var nhan []string
		ids, ok := m["filling_option_ids"].([]any)
		if !ok {
			t.Fatalf("hàng thiếu filling_option_ids (mảng, rỗng được): %v", m)
		}
		for _, id := range ids {
			nhan = append(nhan, strconv.FormatInt(int64(id.(float64)), 10))
		}
		sort.Strings(nhan)
		h.nhan = strings.Join(nhan, ",")
		ps, _ := m["parts"].([]any)
		for _, p := range ps {
			pm, _ := p.(map[string]any)
			pb := bonSo(t, pm)
			pb.ban, pb.don = soCua(t, pm, "dining_table_id"), soCua(t, pm, "sales_order_id")
			h.phan = append(h.phan, pb)
		}
		hang = append(hang, h)
	}
	return hang
}

// phanCua: phần của một bàn (hoặc một đơn lẻ) ở hàng có khoá cho trước; không có thì bốn số 0.
func phanCua(hang []hangBang, khoa string, ban, don int64) phanBang {
	for _, h := range hang {
		if h.khoa() != khoa {
			continue
		}
		for _, p := range h.phan {
			if (ban != 0 && p.ban == ban) || (don != 0 && p.don == don) {
				return p
			}
		}
	}
	return phanBang{ban: ban, don: don}
}

// khoaCua: khoá gom của một đơn vị, tính ĐỘC LẬP với code của lát — trạm + thành phần gốc + tập mã tuỳ
// chọn khi thành phần nhận nhân (05-luoc-do-san-xuat.md §2 hàng I-019 khoá gom; 03-lat-cat.md §3.4.6).
func (c canh) khoaCua(t *testing.T, viec int64) string {
	t.Helper()
	return c.docChu(t, `SELECT j.station_code || '/' || coalesce(lc.menu_component_id, 0)::text || '/' ||
		CASE WHEN lc.takes_filling THEN coalesce((SELECT string_agg(x.menu_option_id::text, ',' ORDER BY x.menu_option_id::text)
		  FROM shop.order_line_option x WHERE x.order_line_id = j.order_line_id), '') ELSE '' END
		FROM shop.station_job j LEFT JOIN shop.order_line_component lc ON lc.id = j.order_line_component_id
		WHERE j.id = $1`, viec)
}

// --- I-004: duyệt sinh đủ việc trong cùng giao dịch -------------------------------------------

// soViecMuon: số đơn vị mỗi (trạm, thành phần đã chụp) mà đơn PHẢI có — số suất × số thành phần, ở mọi
// trạm thành phần ấy chạm tới (shop-facts.md §5.3), cộng đúng một nước chấm — tính độc lập với code.
func (c canh) soViecMuon(t *testing.T, don int64) string {
	t.Helper()
	return c.docChu(t, `SELECT coalesce(string_agg(x.k || '×' || x.n, ' · ' ORDER BY x.k), '-') FROM (
		SELECT s.station_code || '/' || lc.id AS k, l.quantity * lc.quantity AS n
		  FROM shop.order_line l JOIN shop.order_line_component lc ON lc.order_line_id = l.id
		  JOIN shop.menu_component_station s ON s.menu_component_id = lc.menu_component_id
		 WHERE l.sales_order_id = $1
		UNION ALL SELECT 'canh/nước chấm', 1) x`, don)
}

func (c canh) soViecCo(t *testing.T, don int64) string {
	t.Helper()
	return c.docChu(t, `SELECT coalesce(string_agg(x.k || '×' || x.n, ' · ' ORDER BY x.k), '-') FROM (
		SELECT j.station_code || '/' || coalesce(j.order_line_component_id::text, 'nước chấm') AS k, count(*) AS n
		  FROM shop.station_job j WHERE j.sales_order_id = $1 GROUP BY 1) x`, don)
}

func TestI004_DuyetNoDuViecTrongCungGiaoDich(t *testing.T) {
	n := dungNgoai(t)
	// Khách QR: chờ duyệt ⇒ không việc nào ở cả năm trạm; duyệt ⇒ Đang thực hiện, đủ việc.
	ban := n.banMoi(t, "qr nổ")
	q := n.goiQR(t, n.capMaQR(t, ban), dauLanGui(t), n.dong(false), n.dong(true))
	canDat(t, q, http.StatusCreated)
	donQR := q.so(t, "sales_order_id")
	if co := n.soViecCo(t, donQR); co != "-" {
		t.Fatalf("đơn chờ duyệt đã có việc: %s", co)
	}
	d := n.duyet(t, n.quay, donQR)
	canDat(t, d, http.StatusOK)
	if d.chu("status") != "in_progress" || n.trangThaiDon(t, donQR) != "in_progress" {
		t.Fatalf("duyệt ⇒ Đang thực hiện cùng giao dịch: %v, database %s", d.body, n.trangThaiDon(t, donQR))
	}
	if muon, co := n.soViecMuon(t, donQR), n.soViecCo(t, donQR); muon != co {
		t.Fatalf("duyệt nổ sai:\n muốn %s\n có   %s", muon, co)
	}
	if v := n.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'sales_order' AND target_row = $1
		AND before_image ->> 'status' = 'confirmed' AND after_image ->> 'status' = 'in_progress' AND person_id = $2`, donQR, n.quay); v != 1 {
		t.Fatalf("Đã xác nhận → Đang thực hiện: %d vết mang người quầy, muốn 1", v)
	}
	t.Logf("QR %d: chờ duyệt 0 việc; duyệt ⇒ in_progress, %s", donQR, n.soViecCo(t, donQR))
	// Ba kênh còn lại: đặt hộ nổ ngay lúc tạo; kênh khách tự bấm chờ duyệt rồi mới nổ. Đơn đặt trước qua
	// điện thoại nổ theo giờ nhắc — T-142 (U-077), dat_truoc_test.go.
	for _, kenh := range []string{"staff_pos", "delivery", "pickup"} {
		r := n.taoKenh(t, kenh)
		canDat(t, r, http.StatusCreated)
		don := r.so(t, "sales_order_id")
		if r.chu("status") == "pending_confirmation" {
			if co := n.soViecCo(t, don); co != "-" {
				t.Fatalf("%s chờ duyệt đã có việc: %s", kenh, co)
			}
			canDat(t, n.duyet(t, n.quay, don), http.StatusOK)
		}
		if s := n.trangThaiDon(t, don); s != "in_progress" {
			t.Fatalf("%s: %s, muốn in_progress", kenh, s)
		}
		if muon, co := n.soViecMuon(t, don), n.soViecCo(t, don); muon != co {
			t.Fatalf("%s nổ sai:\n muốn %s\n có   %s", kenh, muon, co)
		}
		t.Logf("%s %d ⇒ in_progress, %s", kenh, don, n.soViecCo(t, don))
	}
}

func TestI004_GuiLaiKhongNoLanHai(t *testing.T) {
	c := dungBan(t)
	ban, dau := c.banMoi(t, "gửi lại"), dauLanGui(t)
	r := c.datHo(t, c.quay, ban, dau, c.dong(false))
	canDat(t, r, http.StatusCreated)
	don := r.so(t, "sales_order_id")
	truoc := c.soViecCo(t, don)
	if muon := c.soViecMuon(t, don); truoc != muon {
		t.Fatalf("đặt hộ phải nổ ngay, đủ việc (ADR-090 điểm 1): muốn %s, có %s", muon, truoc)
	}
	for i := 0; i < 2; i++ {
		canDat(t, c.datHo(t, c.quay, ban, dau, c.dong(false)), http.StatusOK)
	}
	if sau := c.soViecCo(t, don); sau != truoc {
		t.Fatalf("gửi lại nổ thêm: %s → %s", truoc, sau)
	}
}

// Cắt giữa lần nổ (sau khi đã ghi vài đơn vị, trước nước chấm): cả lần duyệt lùi — đơn còn chờ duyệt,
// 0 việc (I-004 tầng 2).
func TestI004_CatGiuaLanNoKhongNuaNaoSong(t *testing.T) {
	c := dungBan(t)
	ban := c.banMoi(t, "cắt nổ")
	q := c.goiQR(t, c.capMaQR(t, ban), dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	don := q.so(t, "sales_order_id")
	ham := fmt.Sprintf("test_cat_no_don_%d", don)
	if _, err := c.owner.Exec(c.ctx, fmt.Sprintf(`CREATE FUNCTION shop.%s() RETURNS trigger LANGUAGE plpgsql AS $$
		BEGIN
		  IF NEW.sales_order_id = %d AND NEW.order_line_id IS NULL THEN
		    RAISE EXCEPTION 'test: cắt giữa lần nổ đơn';
		  END IF;
		  RETURN NEW;
		END $$`, ham, don)); err != nil {
		t.Fatal(err)
	}
	if _, err := c.owner.Exec(c.ctx, fmt.Sprintf(`CREATE TRIGGER %s BEFORE INSERT ON shop.station_job
		FOR EACH ROW EXECUTE FUNCTION shop.%s()`, ham, ham)); err != nil {
		t.Fatal(err)
	}
	goKeo := func() {
		_, _ = c.owner.Exec(c.ctx, fmt.Sprintf("DROP TRIGGER IF EXISTS %s ON shop.station_job", ham))
		_, _ = c.owner.Exec(c.ctx, fmt.Sprintf("DROP FUNCTION IF EXISTS shop.%s()", ham))
	}
	t.Cleanup(goKeo)
	canMa(t, c.duyet(t, c.quay, don), http.StatusInternalServerError, "internal_error", "")
	if s, co := c.trangThaiDon(t, don), c.soViecCo(t, don); s != "pending_confirmation" || co != "-" {
		t.Fatalf("cắt giữa lần nổ mà một nửa sống: đơn %s, việc %s", s, co)
	}
	t.Logf("cắt giữa lần nổ ⇒ 500, đơn %d còn pending_confirmation, 0 việc", don)
	goKeo()
	canDat(t, c.duyet(t, c.quay, don), http.StatusOK)
	if muon, co := c.soViecMuon(t, don), c.soViecCo(t, don); muon != co {
		t.Fatalf("duyệt lại sau khi gỡ kéo cắt: muốn %s, có %s", muon, co)
	}
}

// --- I-020: một lần bấm là một mẻ, phủ nhiều bàn; lùi trả mọi bàn ------------------------------

func TestI020_MotMePhuNhieuBanMotLanBam(t *testing.T) {
	c := dungBan(t)
	banA, _, donA, _ := c.phienDangPhucVu(t, "mẻ A")
	banB, _, donB, _ := c.phienDangPhucVu(t, "mẻ B")
	a, b := c.viec(t, donA, "pending"), c.viec(t, donB, "pending")
	k := c.khoaCua(t, a[0])
	var cungKhoaB []int64
	for _, v := range b {
		if c.khoaCua(t, v) == k {
			cungKhoaB = append(cungKhoaB, v)
		}
	}
	if len(cungKhoaB) == 0 {
		t.Fatal("hai bàn gọi cùng món phải có đơn vị cùng khoá gom")
	}
	truocA, truocB := phanCua(c.bang(t, ""), k, banA, 0), phanCua(c.bang(t, ""), k, banB, 0)
	r := c.bamMe(t, c.quay, a[0], cungKhoaB[0])
	canDat(t, r, http.StatusCreated)
	me := r.so(t, "production_batch_id")
	sauA, sauB := phanCua(c.bang(t, ""), k, banA, 0), phanCua(c.bang(t, ""), k, banB, 0)
	if sauA.daLam != truocA.daLam+1 || sauB.daLam != truocB.daLam+1 || sauA.chuaLam != truocA.chuaLam-1 || sauB.chuaLam != truocB.chuaLam-1 {
		t.Fatalf("một lần bấm phải chia về CẢ HAI bàn: A %v → %v · B %v → %v", truocA, sauA, truocB, sauB)
	}
	if sauA.conThieu != truocA.conThieu || sauA.goi != truocA.goi {
		t.Fatalf("đã làm xong không đổi đã gọi hay còn thiếu: A %v → %v", truocA, sauA)
	}
	if v := c.docSo(t, "SELECT count(*) FROM shop.production_batch WHERE id = $1 AND made_by_person_id = $2", me, c.quay); v != 1 {
		t.Fatal("mẻ phải mang người đứng quầy đã bấm")
	}
	if v := c.docSo(t, "SELECT count(*) FROM shop.production_batch_item WHERE production_batch_id = $1", me); v != 2 {
		t.Fatalf("mẻ %d làm ra %d thứ, muốn 2", me, v)
	}
	t.Logf("mẻ %d (một lần bấm) ⇒ bàn A %+v · bàn B %+v", me, sauA, sauB)
}

func TestI020_BamMeTuChoiCaLanBam(t *testing.T) {
	c := dungBan(t)
	_, _, don, _ := c.phienDangPhucVu(t, "mẻ từ chối")
	v := c.viec(t, don, "pending")
	canDat(t, c.bamMe(t, c.quay, v[0]), http.StatusCreated)
	truoc := c.anhSanXuat(t, v...)
	canMa(t, c.bamMe(t, c.quay), http.StatusBadRequest, "invalid_request", "station_job_ids")
	canMa(t, c.bamMe(t, c.quay, v[1], v[1]), http.StatusBadRequest, "invalid_request", "station_job_ids")
	canMa(t, c.bamMe(t, c.quay, v[1], 1<<40), http.StatusNotFound, "station_job_not_found", "")
	// Một đơn vị đã làm xong trong lần bấm: CẢ lần bấm bị từ chối, đơn vị kia cũng không đổi.
	canMa(t, c.bamMe(t, c.quay, v[1], v[0]), http.StatusConflict, "station_job_transition_not_allowed", "")
	if sau := c.anhSanXuat(t, v...); sau != truoc {
		t.Fatalf("lời từ chối mà vẫn đổi:\n trước %s\n sau   %s", truoc, sau)
	}
	// Đơn vị của đơn đã huỷ không vào mẻ nào.
	_, _, donHuy, _ := c.phienDangPhucVu(t, "mẻ huỷ")
	canDat(t, c.huyDon(t, c.quay, donHuy), http.StatusOK)
	h := c.viec(t, donHuy, "pending")
	canMa(t, c.bamMe(t, c.quay, h[0]), http.StatusConflict, "station_job_transition_not_allowed", "")
	t.Logf("năm lần bấm sai ⇒ bốn mã từ chối, database y nguyên: %s", truoc)
}

// chenNhau lần gọi cùng chờ một cổng rồi mới chạy, lặp trên mọi đơn vị chờ của đơn. Không cổng thì các
// lần gọi chạy nối đuôi và bỏ khoá ở cửa vẫn xanh; một vòng có cổng chỉ bắt được khoảng hai trên ba lần
// (đo 2026-10-09 lúc duyệt P3-10, cài lỗi bỏ mọi khoá của khoaTap và vongdoi khoa.sql).
const chenNhau = 20

func TestI020_HaiLanBamCungDonViChenNhau(t *testing.T) {
	c := dungBan(t)
	_, _, don, _ := c.phienDangPhucVu(t, "mẻ chen")
	vs := c.viec(t, don, "pending")
	if len(vs) < 3 {
		t.Fatalf("đơn %d chỉ có %d đơn vị chờ, muốn ít nhất 3 vòng chen nhau", don, len(vs))
	}
	for _, v := range vs {
		var mu sync.Mutex
		dem := map[int]int{}
		var wg sync.WaitGroup
		cong := make(chan struct{})
		for i := 0; i < chenNhau; i++ {
			wg.Add(1)
			go func() {
				defer wg.Done()
				<-cong
				status, out := c.goi(t, "POST", "/production-batches", c.quay, map[string]any{"station_job_ids": []int64{v}})
				if status == http.StatusConflict && out["code"] != "station_job_transition_not_allowed" {
					status = -1
				}
				mu.Lock()
				dem[status]++
				mu.Unlock()
			}()
		}
		close(cong)
		wg.Wait()
		if dem[http.StatusCreated] != 1 || dem[http.StatusConflict] != chenNhau-1 {
			t.Fatalf("%d lần bấm chen nhau cùng đơn vị %d: %v, muốn 1×201 · %d×409 station_job_transition_not_allowed", chenNhau, v, dem, chenNhau-1)
		}
		if n := c.docSo(t, "SELECT count(*) FROM shop.production_batch_item WHERE station_job_id = $1", v); n != 1 {
			t.Fatalf("đơn vị %d do %d thứ đã làm giữ, muốn 1", v, n)
		}
	}
	t.Logf("%d vòng × %d lần bấm chen nhau ⇒ mỗi vòng 1×201, một thứ đã làm", len(vs), chenNhau)
}

func TestI020_LuiMeTraMoiBanCungLuc(t *testing.T) {
	c := dungBan(t)
	banA, _, donA, _ := c.phienDangPhucVu(t, "lùi A")
	banB, _, donB, _ := c.phienDangPhucVu(t, "lùi B")
	a, b := c.viec(t, donA, "pending"), c.viec(t, donB, "pending")
	kA, kB := c.khoaCua(t, a[0]), c.khoaCua(t, b[1])
	truoc := fmt.Sprintf("%+v %+v", phanCua(c.bang(t, ""), kA, banA, 0), phanCua(c.bang(t, ""), kB, banB, 0))
	r := c.bamMe(t, c.quay, a[0], b[1])
	canDat(t, r, http.StatusCreated)
	me := r.so(t, "production_batch_id")
	l := c.luiMe(t, c.quay, me)
	canDat(t, l, http.StatusOK)
	sau := fmt.Sprintf("%+v %+v", phanCua(c.bang(t, ""), kA, banA, 0), phanCua(c.bang(t, ""), kB, banB, 0))
	if sau != truoc {
		t.Fatalf("lùi mẻ phải trả CẢ HAI bàn về đúng như trước lúc bấm:\n trước %s\n sau   %s", truoc, sau)
	}
	if v := c.docSo(t, "SELECT count(*) FROM shop.production_batch WHERE id = $1 AND rolled_back_at IS NOT NULL AND rolled_back_by_person_id = $2", me, c.quay); v != 1 {
		t.Fatal("lần lùi phải mang mốc và người đứng quầy (YC-07)")
	}
	if v := c.docSo(t, "SELECT count(*) FROM shop.production_batch_item WHERE production_batch_id = $1", me); v != 2 {
		t.Fatalf("thứ đã làm của mẻ lùi phải ở lại làm vết: %d", v)
	}
	canMa(t, c.luiMe(t, c.quay, me), http.StatusConflict, "production_batch_already_rolled_back", "")
	canMa(t, c.luiMe(t, c.quay, 1<<40), http.StatusNotFound, "production_batch_not_found", "")
	// Bấm lại sau lùi được; mẻ có đơn vị đã ra bàn thì không lùi được (§5.4 không có Đã ra bàn → Chưa làm).
	r2 := c.bamMe(t, c.quay, a[0], b[1])
	canDat(t, r2, http.StatusCreated)
	canDat(t, c.raBan(t, c.quay, a[0]), http.StatusOK)
	truoc = c.anhSanXuat(t, a[0], b[1])
	canMa(t, c.luiMe(t, c.quay, r2.so(t, "production_batch_id")), http.StatusConflict, "production_batch_has_served_units", "")
	if s := c.anhSanXuat(t, a[0], b[1]); s != truoc {
		t.Fatalf("lùi bị từ chối mà vẫn đổi: %s → %s", truoc, s)
	}
	t.Logf("mẻ %d lùi ⇒ hai bàn về đúng %s; lùi lần hai · mẻ lạ · mẻ đã bưng ⇒ ba mã", me, truoc)
}

// --- đã ra bàn: số cái từng thứ cho một bàn (S-5, chốt 2026-10-09 — ADR-090 điểm 4) ---------

func TestI020_DaRaBanTheoSoCaiTungThuChoMotBan(t *testing.T) {
	c := dungBan(t)
	ban, phien, don, _ := c.phienDangPhucVu(t, "ra bàn")
	r2 := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false))
	canDat(t, r2, http.StatusCreated)
	don2 := r2.so(t, "sales_order_id")
	v1, v2 := c.viec(t, don, "pending"), c.viec(t, don2, "pending")
	tat := append(append([]int64{}, v1...), v2...)
	canDat(t, c.bamMe(t, c.quay, tat...), http.StatusCreated)
	k := c.khoaCua(t, v1[0])
	truoc := phanCua(c.bang(t, ""), k, ban, 0)
	if truoc.daLam < 2 {
		t.Fatalf("hai lượt gọi cùng món ⇒ hàng %s của bàn có ít nhất hai cái đã làm: %+v", k, truoc)
	}

	// Một cái của một thứ cho một bàn ⇒ đúng một đơn vị, của lượt gọi sớm hơn (ADR-090 điểm 4 Sửa đổi).
	r := c.raBanSo(t, c.quay, ban, 0, c.mucCua(t, v1[0], 1))
	canDat(t, r, http.StatusOK)
	ra, _ := r.body["station_job_ids"].([]any)
	if len(ra) != 1 {
		t.Fatalf("bưng 1 cái ⇒ đúng một đơn vị: %v", r.body)
	}
	daRa := int64(ra[0].(float64))
	if d := c.docSo(t, "SELECT sales_order_id FROM shop.station_job WHERE id = $1", daRa); d != don {
		t.Fatalf("bưng 1 cái khi hai lượt gọi cùng chờ ⇒ cái của lượt sớm hơn (đơn %d), nhận đơn %d", don, d)
	}
	sau := phanCua(c.bang(t, ""), k, ban, 0)
	if sau.daRaBan != truoc.daRaBan+1 || sau.daLam != truoc.daLam-1 || sau.conThieu != truoc.conThieu-1 {
		t.Fatalf("đã ra bàn một cái: %+v → %+v", truoc, sau)
	}
	if c.trangThaiDon(t, don) != "in_progress" {
		t.Fatal("còn việc chưa ra bàn ⇒ đơn vẫn Đang thực hiện (§5.5)")
	}
	if n := c.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'station_job' AND target_row = $1
		AND before_image ->> 'status' = 'made' AND after_image ->> 'status' = 'served' AND person_id = $2 AND btrim(reason) <> ''`, daRa, c.quay); n != 1 {
		t.Fatalf("lần bấm đã ra bàn phải để vết mang người quầy: %d", n)
	}

	// Bưng nhiều hơn số đã làm của thứ ấy ở bàn ấy ⇒ cả lần bị từ chối, không cái nào đổi (I-020).
	anh := c.anhSanXuat(t, tat...)
	canMa(t, c.raBanSo(t, c.quay, ban, 0, c.mucCua(t, v1[0], sau.daLam+1)), http.StatusConflict, "served_quantity_exceeds_made", "")
	khac := c.mucCua(t, v1[len(v1)-1], 1)
	canMa(t, c.raBanSo(t, c.quay, ban, 0, khac, c.mucCua(t, v1[0], sau.daLam+1)), http.StatusConflict, "served_quantity_exceeds_made", "")
	// Hình sai: không thứ nào, số không dương, một thứ hai lần, thiếu hoặc thừa chỗ nhận.
	canMa(t, c.raBanSo(t, c.quay, ban, 0), http.StatusBadRequest, "invalid_request", "items")
	canMa(t, c.raBanSo(t, c.quay, ban, 0, c.mucCua(t, v1[0], 0)), http.StatusBadRequest, "invalid_request", "items")
	canMa(t, c.raBanSo(t, c.quay, ban, 0, c.mucCua(t, v1[0], 1), c.mucCua(t, v1[0], 1)), http.StatusBadRequest, "invalid_request", "items")
	canMa(t, c.raBanSo(t, c.quay, 0, 0, c.mucCua(t, v1[0], 1)), http.StatusBadRequest, "invalid_request", "dining_table_id")
	canMa(t, c.raBanSo(t, c.quay, ban, don, c.mucCua(t, v1[0], 1)), http.StatusBadRequest, "invalid_request", "dining_table_id")
	canMa(t, c.raBanSo(t, c.quay, 1<<40, 0, c.mucCua(t, v1[0], 1)), http.StatusNotFound, "dining_table_not_found", "")
	canMa(t, c.raBanSo(t, c.quay, 0, 1<<40, c.mucCua(t, v1[0], 1)), http.StatusNotFound, "sales_order_not_found", "")
	if s := c.anhSanXuat(t, tat...); s != anh {
		t.Fatalf("lời từ chối mà vẫn đổi: %s → %s", anh, s)
	}
	// Chưa làm → Đã ra bàn thẳng không có ở §5.4: bàn chỉ có cái chưa làm ⇒ thiếu cái đã làm.
	ban3, _, don3, _ := c.phienDangPhucVu(t, "ra bàn thẳng")
	canMa(t, c.raBanSo(t, c.quay, ban3, 0, c.mucCua(t, c.viec(t, don3, "pending")[0], 1)), http.StatusConflict, "served_quantity_exceeds_made", "")
	// T-144 (duyệt độc lập phần S-5): đơn có bàn không bấm theo mã đơn — phần của nó là bàn.
	anh = c.anhSanXuat(t, tat...)
	canMa(t, c.raBanSo(t, c.quay, 0, don3, c.mucCua(t, c.viec(t, don3, "pending")[0], 1)), http.StatusBadRequest, "invalid_request", "sales_order_id")
	// T-144: thiếu menu_component_id, hay filling_option_ids null, là thân sai — không được đọc thành nước chấm.
	for _, muc := range []map[string]any{
		{"station_code": "canh", "filling_option_ids": []int64{}, "quantity": 1},
		{"station_code": "canh", "menu_component_id": nil, "quantity": 1},
		{"station_code": "canh", "menu_component_id": nil, "filling_option_ids": nil, "quantity": 1},
	} {
		canMa(t, c.post(t, "/served-marks", c.quay, map[string]any{"dining_table_id": ban, "items": []any{muc}}),
			http.StatusBadRequest, "invalid_request", "items")
	}
	if s := c.anhSanXuat(t, tat...); s != anh {
		t.Fatalf("thân sai mà vẫn đổi: %s → %s", anh, s)
	}

	// Nhiều lần bấm chen nhau, mỗi lần đòi hết số đã làm còn lại của thứ ấy ⇒ đúng một lần thành.
	con := sau.daLam
	het := c.mucCua(t, v1[0], con) // đọc trước: c.owner là một kết nối, không đọc chen trong goroutine
	ma := map[string]int{}
	var mu sync.Mutex
	var wg sync.WaitGroup
	cong := make(chan struct{})
	for i := 0; i < chenNhau; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			<-cong
			r := c.raBanSo(t, c.quay, ban, 0, het)
			mu.Lock()
			ma[fmt.Sprint(r.status, r.chu("code"))]++
			mu.Unlock()
		}()
	}
	close(cong)
	wg.Wait()
	if ma["200"] != 1 || ma["409served_quantity_exceeds_made"] != chenNhau-1 {
		t.Fatalf("%d lần bưng chen nhau hết %d cái: %v, muốn 1×200 · %d×409 served_quantity_exceeds_made", chenNhau, con, ma, chenNhau-1)
	}
	if p := phanCua(c.bang(t, ""), k, ban, 0); p.daLam != 0 || p.daRaBan != truoc.daRaBan+truoc.daLam {
		t.Fatalf("sau lần thành: hàng %s của bàn phải hết cái đã làm: %+v", k, p)
	}

	// Mọi thứ còn lại trong MỘT lần bấm ⇒ cả hai lượt gọi Hoàn thành cùng lần ấy (§5.2), phiên tính tiền được.
	conLai := c.phanRaCua(t, append(c.viecCua(t, don, "made"), c.viecCua(t, don2, "made")...)...)
	if len(conLai) != 1 || conLai[0].ban != ban {
		t.Fatalf("phần còn lại phải là đúng bàn %d: %+v", ban, conLai)
	}
	r = c.raBanSo(t, c.quay, ban, 0, conLai[0].muc...)
	canDat(t, r, http.StatusOK)
	for _, d := range []int64{don, don2} {
		if s := c.trangThaiDon(t, d); s != "completed" {
			t.Fatalf("mọi việc đã ra bàn ⇒ đơn %d Hoàn thành, nhận %s", d, s)
		}
	}
	xong, _ := r.body["completed_order_ids"].([]any)
	if len(xong) != 2 {
		t.Fatalf("completed_order_ids: %v, muốn [%d %d]", r.body["completed_order_ids"], don, don2)
	}
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	t.Logf("bàn %d: 1 cái ⇒ lượt %d trước; quá số đã làm ⇒ từ chối; chen nhau ⇒ một lần; phần còn lại ⇒ hai lượt completed; %s",
		ban, don, c.anhPhien(t, phien))
}

// Đơn lẻ không tự Hoàn thành ở cửa đã ra bàn: Hoàn thành của nó ghi hoá đơn ở cửa trao (P3-09, ADR-089
// điểm 2); đơn giao rời quán được khi mọi việc đã ra bàn (S-6 của ADR-088 hết chặn).
func TestI016_DonLeKhongTuHoanThanh(t *testing.T) {
	n := dungNgoai(t)
	r := n.hotline(t, n.quay, dauLanGui(t), lienHeHotlineGiao())
	canDat(t, r, http.StatusCreated)
	don := r.so(t, "sales_order_id")
	n.denGioLam(t, don) // T-142: đơn đặt trước nổ ở lần nhắc đầu
	n.phucVuHet(t, n.quay, don)
	if s := n.trangThaiDon(t, don); s != "in_progress" {
		t.Fatalf("đơn lẻ mọi việc đã ra bàn: %s, muốn in_progress", s)
	}
	canDat(t, n.roiQuan(t, n.quay, don), http.StatusOK)
}

// --- I-020 trần trên, I-019 tách ngược — đo trên bảng nhu cầu ---------------------------------

func TestI019_BangNhuCauTachNguocVeTungBan(t *testing.T) {
	n := dungNgoai(t)
	var ban, don []int64
	for _, ca := range n.caCoMa(t) {
		if ca.tuChoi {
			continue
		}
		b := n.banMoi(t, fmt.Sprintf("ca %d", ca.so))
		ids := ca.chonIDs
		if ids == nil {
			ids = []int64{}
		}
		r := n.datHo(t, n.quay, b, dauLanGui(t), map[string]any{"menu_item_id": ca.monID, "quantity": ca.soSuat, "option_ids": ids, "is_takeaway": false})
		canDat(t, r, http.StatusCreated)
		ban, don = append(ban, b), append(don, r.so(t, "sales_order_id"))
	}
	lay := n.web(t, dauLanGui(t), lienHeLay())
	canDat(t, n.duyet(t, n.quay, lay.so(t, "sales_order_id")), http.StatusOK)
	donLe := lay.so(t, "sales_order_id")
	// Một mẻ, một lần ra bàn, một đơn huỷ — để năm con số không cùng bằng nhau.
	canDat(t, n.bamMe(t, n.quay, n.viec(t, don[0], "pending")[:2]...), http.StatusCreated)
	canDat(t, n.raBan(t, n.quay, n.viec(t, don[0], "made")[0]), http.StatusOK)
	canDat(t, n.huyDon(t, n.quay, don[1]), http.StatusOK)

	hang := n.bang(t, "")
	thay := map[string]bool{}
	for _, h := range hang {
		if thay[h.khoa()] {
			t.Fatalf("hai hàng cùng khoá gom %s (I-019 tầng 3: một hàm gom)", h.khoa())
		}
		thay[h.khoa()] = true
		var cong phanBang
		for _, p := range h.phan {
			if (p.ban == 0) == (p.don == 0) {
				t.Fatalf("phần phải là một bàn HOẶC một đơn lẻ: %+v", p)
			}
			if p.conThieu != p.goi-p.daRaBan || p.conThieu < 0 || p.daLam+p.daRaBan > p.goi || p.chuaLam+p.daLam+p.daRaBan != p.goi {
				t.Fatalf("%s phần %+v sai phép tính (I-020: còn thiếu không âm, đã làm + đã bưng ≤ đã gọi)", h.khoa(), p)
			}
			cong.goi += p.goi
			cong.chuaLam += p.chuaLam
			cong.daLam += p.daLam
			cong.daRaBan += p.daRaBan
			cong.conThieu += p.conThieu
		}
		if cong != h.tong {
			t.Fatalf("%s: tổng %+v khác cộng các phần %+v (I-019 hai chiều)", h.khoa(), h.tong, cong)
		}
	}
	// Phần của từng bàn của test này khớp phép đếm độc lập trên đơn vị — đơn huỷ không có phần nào.
	soDoc := func(ban, donLe int64, khoa string) phanBang {
		var p phanBang
		rows, err := n.owner.Query(n.ctx, `SELECT j.id, j.status FROM shop.station_job j JOIN shop.sales_order o ON o.id = j.sales_order_id
			WHERE o.status <> 'cancelled' AND (o.dining_table_id = $1 OR o.id = $2)`, ban, donLe)
		if err != nil {
			t.Fatal(err)
		}
		type dv struct {
			id int64
			st string
		}
		var ds []dv
		for rows.Next() {
			var d dv
			if err := rows.Scan(&d.id, &d.st); err != nil {
				t.Fatal(err)
			}
			ds = append(ds, d)
		}
		rows.Close()
		for _, d := range ds {
			if n.khoaCua(t, d.id) != khoa {
				continue
			}
			p.goi++
			switch d.st {
			case "pending":
				p.chuaLam++
			case "made":
				p.daLam++
			case "served":
				p.daRaBan++
			}
		}
		p.conThieu = p.goi - p.daRaBan
		return p
	}
	soPhan := 0
	for _, h := range hang {
		for i, b := range ban {
			muon := soDoc(b, 0, h.khoa())
			co := phanCua(hang, h.khoa(), b, 0)
			co.ban, co.don = 0, 0
			if co != muon {
				t.Fatalf("bàn %d (đơn %d) ở %s: bảng %+v, đếm độc lập %+v", b, don[i], h.khoa(), co, muon)
			}
			if muon.goi > 0 {
				soPhan++
			}
		}
		muon, co := soDoc(0, donLe, h.khoa()), phanCua(hang, h.khoa(), 0, donLe)
		co.ban, co.don = 0, 0
		if co != muon {
			t.Fatalf("đơn lẻ %d ở %s: bảng %+v, đếm độc lập %+v", donLe, h.khoa(), co, muon)
		}
	}
	if soPhan == 0 {
		t.Fatal("bảng không có phần nào của các bàn trong test")
	}
	// Lọc theo trạm: đúng các hàng của trạm ấy, cùng con số.
	for _, tram := range []string{"trang_banh", "gap_banh", "canh"} {
		for _, h := range n.bang(t, tram) {
			if h.tram != tram {
				t.Fatalf("lọc %s mà có hàng %s", tram, h.khoa())
			}
		}
	}
	t.Logf("%d hàng, %d phần của %d bàn + 1 đơn lẻ khớp phép đếm độc lập; mọi tổng = cộng các phần", len(hang), soPhan, len(ban))
}

// --- I-004 tầng 3 · tầng 4: huỷ đơn rút nhu cầu; phần đã làm đổi chủ do quầy chọn ---------------

func TestI004_HuyDonRutNhuCauViecChuaXong(t *testing.T) {
	c := dungBan(t)
	ban, _, don, _ := c.phienDangPhucVu(t, "huỷ")
	v := c.viec(t, don, "pending")
	k := c.khoaCua(t, v[0])
	if p := phanCua(c.bang(t, ""), k, ban, 0); p.chuaLam == 0 {
		t.Fatalf("trước khi huỷ bàn phải có việc chưa làm: %+v", p)
	}
	r := c.huyDon(t, c.quay, don)
	canDat(t, r, http.StatusOK)
	if r.chu("status") != "cancelled" || c.trangThaiDon(t, don) != "cancelled" {
		t.Fatalf("huỷ đơn: %v", r.body)
	}
	if p := phanCua(c.bang(t, ""), k, ban, 0); p != (phanBang{ban: ban}) {
		t.Fatalf("đơn huỷ còn trên bảng nhu cầu: %+v", p)
	}
	// Đơn vị không bị xoá, không đổi trạng thái (QD-50; F-044 — cách đọc của lát 05-luoc-do-san-xuat.md §2).
	if len(c.viecCua(t, don, "pending")) != len(v) {
		t.Fatal("huỷ đơn không xoá, không đổi đơn vị việc trạm")
	}
	if n := c.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'sales_order' AND target_row = $1
		AND after_image ->> 'status' = 'cancelled' AND person_id = $2`, don, c.quay); n != 1 {
		t.Fatal("huỷ đơn phải để vết mang người quầy")
	}
	canMa(t, c.huyDon(t, c.quay, don), http.StatusConflict, "order_transition_not_allowed", "")
	canMa(t, c.huyDon(t, c.quay, 1<<40), http.StatusNotFound, "sales_order_not_found", "")
	// Chờ xác nhận đi cửa từ chối, không đi cửa huỷ. Hoàn thành → Huỷ: huy_hoan_thanh_test.go (T-147).
	ma := c.capMaQR(t, c.banMoi(t, "huỷ qr"))
	q := c.goiQR(t, ma, dauLanGui(t), c.dong(false))
	canMa(t, c.huyDon(t, c.quay, q.so(t, "sales_order_id")), http.StatusConflict, "order_transition_not_allowed", "")
	t.Logf("huỷ đơn %d ⇒ bàn %d rời bảng nhu cầu, %d đơn vị chưa làm ở lại", don, ban, len(v))
}

func TestI004_PhanDaLamCuaDonHuyDoiChuDoQuayChon(t *testing.T) {
	c := dungBan(t)
	_, _, donHuy, _ := c.phienDangPhucVu(t, "chuyển cũ")
	banNhan, _, donNhan, _ := c.phienDangPhucVu(t, "chuyển nhận")
	cu := c.viec(t, donHuy, "pending")
	canDat(t, c.bamMe(t, c.quay, cu[0], cu[1]), http.StatusCreated)
	// Chưa huỷ: đơn vị chưa có gì để chuyển, chưa có ai để bày ra.
	status, _ := c.goi(t, "GET", fmt.Sprintf("/station-jobs/%d/transfer-candidates", cu[0]), 0, nil)
	if status != http.StatusConflict {
		t.Fatalf("ứng viên cho đơn vị của đơn chưa huỷ: %d, muốn 409", status)
	}
	canDat(t, c.huyDon(t, c.quay, donHuy), http.StatusOK)
	k := c.khoaCua(t, cu[0])
	// Máy bày ra ai đang chờ ĐÚNG thứ ấy (shop-facts §5.4) — đơn vị chưa làm, cùng khoá gom, đơn chưa huỷ.
	status, out := c.goi(t, "GET", fmt.Sprintf("/station-jobs/%d/transfer-candidates", cu[0]), 0, nil)
	if status != http.StatusOK {
		t.Fatalf("GET ứng viên: %d %v", status, out)
	}
	ds, _ := out["candidates"].([]any)
	var dich int64
	for _, x := range ds {
		m, _ := x.(map[string]any)
		id := int64(m["station_job_id"].(float64))
		if c.khoaCua(t, id) != k || c.docChu(t, "SELECT status FROM shop.station_job WHERE id = $1", id) != "pending" {
			t.Fatalf("ứng viên %d không chờ đúng thứ %s", id, k)
		}
		if int64(m["sales_order_id"].(float64)) == donNhan {
			dich = id
		}
	}
	if dich == 0 {
		t.Fatalf("bàn nhận đang chờ đúng thứ %s mà không được bày ra: %v", k, ds)
	}
	truoc := phanCua(c.bang(t, ""), k, banNhan, 0)
	r := c.chuyen(t, c.quay, [2]int64{cu[0], dich})
	canDat(t, r, http.StatusCreated)
	sau := phanCua(c.bang(t, ""), k, banNhan, 0)
	if sau.daLam != truoc.daLam+1 || sau.chuaLam != truoc.chuaLam-1 || sau.goi != truoc.goi {
		t.Fatalf("bàn nhận: %+v → %+v, muốn đã làm +1, chưa làm −1", truoc, sau)
	}
	if n := c.docSo(t, `SELECT count(*) FROM shop.station_job_transfer WHERE from_station_job_id = $1 AND to_station_job_id = $2
		AND person_id = $3`, cu[0], dich, c.quay); n != 1 {
		t.Fatal("lần chuyển phải để vết thứ nào, chủ cũ, chủ mới, người quầy")
	}
	if n := c.docSo(t, "SELECT count(*) FROM shop.production_batch_item WHERE made_for_station_job_id = $1 AND station_job_id = $2", cu[0], dich); n != 1 {
		t.Fatal("thứ đã làm giữ nguyên 'làm cho ai lúc bấm', chỉ đổi chủ hiện tại")
	}
	// Máy không so khoá gom thay quầy (tầng 4): chuyển sang đơn vị chờ thứ KHÁC vẫn ghi được, vết bắt.
	var khac int64
	for _, v := range c.viecCua(t, donNhan, "pending") {
		if c.khoaCua(t, v) != c.khoaCua(t, cu[1]) {
			khac = v
			break
		}
	}
	if khac != 0 {
		canDat(t, c.chuyen(t, c.quay, [2]int64{cu[1], khac}), http.StatusCreated)
	}
	// Từ chối: nguồn của đơn chưa huỷ · nguồn chưa làm · đích không chờ · đích của đơn huỷ.
	_, _, donSong, _ := c.phienDangPhucVu(t, "chuyển sống")
	song := c.viec(t, donSong, "pending")
	canDat(t, c.bamMe(t, c.quay, song[0]), http.StatusCreated)
	anh := c.anhSanXuat(t, song...)
	canMa(t, c.chuyen(t, c.quay, [2]int64{song[0], song[1]}), http.StatusConflict, "transfer_source_not_available", "")
	canMa(t, c.chuyen(t, c.quay, [2]int64{cu[2], song[1]}), http.StatusConflict, "transfer_source_not_available", "")
	canMa(t, c.chuyen(t, c.quay, [2]int64{dich, song[0]}), http.StatusConflict, "transfer_source_not_available", "")
	canMa(t, c.chuyen(t, c.quay), http.StatusBadRequest, "invalid_request", "transfers")
	if s := c.anhSanXuat(t, song...); s != anh {
		t.Fatalf("lời từ chối mà vẫn đổi: %s → %s", anh, s)
	}
	t.Logf("đơn %d huỷ: thứ đã làm %d → đơn vị %d của bàn %d (%+v → %+v); vết mang người quầy", donHuy, cu[0], dich, banNhan, truoc, sau)
}

func TestI004_ChuyenTuChoiDichKhongCho(t *testing.T) {
	c := dungBan(t)
	_, _, donHuy, _ := c.phienDangPhucVu(t, "đích cũ")
	_, _, donDich, _ := c.phienDangPhucVu(t, "đích")
	_, _, donDichHuy, _ := c.phienDangPhucVu(t, "đích huỷ")
	cu := c.viec(t, donHuy, "pending")
	d := c.viec(t, donDich, "pending")
	canDat(t, c.bamMe(t, c.quay, cu[0], d[0]), http.StatusCreated)
	canDat(t, c.huyDon(t, c.quay, donHuy), http.StatusOK)
	canDat(t, c.huyDon(t, c.quay, donDichHuy), http.StatusOK)
	anh := c.anhSanXuat(t, cu[0], d[0])
	canMa(t, c.chuyen(t, c.quay, [2]int64{cu[0], d[0]}), http.StatusConflict, "transfer_target_not_waiting", "")
	canMa(t, c.chuyen(t, c.quay, [2]int64{cu[0], c.viec(t, donDichHuy, "pending")[0]}), http.StatusConflict, "transfer_target_not_waiting", "")
	canMa(t, c.chuyen(t, c.quay, [2]int64{cu[0], 1 << 40}), http.StatusNotFound, "station_job_not_found", "")
	if s := c.anhSanXuat(t, cu[0], d[0]); s != anh {
		t.Fatalf("lời từ chối mà vẫn đổi: %s → %s", anh, s)
	}
}

// Cái đã ra bàn của đơn huỷ không đổi chủ: nó đã tới tay khách, đem cộng cho bàn khác là bàn ấy được
// đếm một cái không có (ADR-090 điểm 3 — chỉ đã làm xong rời qua đổi chủ; I-019 · I-020). Thêm lúc
// duyệt P3-10 2026-10-09: bản thi công nhận cả nguồn đã ra bàn.
func TestI004_ChuyenTuChoiNguonDaRaBan(t *testing.T) {
	c := dungBan(t)
	banHuy, _, donHuy, _ := c.phienDangPhucVu(t, "nguồn đã ra")
	_, _, donDich, _ := c.phienDangPhucVu(t, "đích của nguồn đã ra")
	cu, d := c.viec(t, donHuy, "pending"), c.viec(t, donDich, "pending")
	canDat(t, c.bamMe(t, c.quay, cu[0]), http.StatusCreated)
	canDat(t, c.raBanSo(t, c.quay, banHuy, 0, c.mucCua(t, cu[0], 1)), http.StatusOK)
	if s := c.viec(t, donHuy, "served"); len(s) != 1 || s[0] != cu[0] {
		t.Fatalf("đơn vị đã ra bàn của đơn %d: %v, muốn [%d]", donHuy, s, cu[0])
	}
	canDat(t, c.huyDon(t, c.quay, donHuy), http.StatusOK)
	if status, out := c.goi(t, "GET", fmt.Sprintf("/station-jobs/%d/transfer-candidates", cu[0]), 0, nil); status != http.StatusConflict {
		t.Fatalf("ứng viên cho cái đã ra bàn của đơn huỷ: %d %v, muốn 409", status, out)
	}
	anh := c.anhSanXuat(t, cu[0], d[0])
	canMa(t, c.chuyen(t, c.quay, [2]int64{cu[0], d[0]}), http.StatusConflict, "transfer_source_not_available", "")
	if s := c.anhSanXuat(t, cu[0], d[0]); s != anh {
		t.Fatalf("lời từ chối mà vẫn đổi: %s → %s", anh, s)
	}
	t.Logf("đơn %d huỷ, đơn vị %d đã ra bàn ⇒ không bày ra, không chuyển được", donHuy, cu[0])
}

// --- YC-07 · ADR-077: ghi chú bánh làm sai và huỷ ghi chú -------------------------------------

func TestYC07_GhiChuBanhLamSaiVaHuyGhiChu(t *testing.T) {
	c := dungBan(t)
	_, _, donHuy, _ := c.phienDangPhucVu(t, "làm sai")
	_, _, donNhan, _ := c.phienDangPhucVu(t, "làm sai nhận")
	cu := c.viec(t, donHuy, "pending")
	canDat(t, c.bamMe(t, c.quay, cu[0]), http.StatusCreated)
	// Đơn chưa huỷ: không ghi chú được.
	canMa(t, c.ghiLamSai(t, c.quay, cu[0], nil), http.StatusConflict, "wrong_make_note_not_allowed", "")
	canDat(t, c.huyDon(t, c.quay, donHuy), http.StatusOK)
	// Đơn vị chưa làm của đơn huỷ: không có gì để ghi là làm sai.
	canMa(t, c.ghiLamSai(t, c.quay, cu[1], nil), http.StatusConflict, "wrong_make_note_not_allowed", "")
	canMa(t, c.ghiLamSai(t, c.quay, cu[0], "   "), http.StatusBadRequest, "invalid_request", "note")
	canMa(t, c.ghiLamSai(t, c.quay, 1<<40, nil), http.StatusNotFound, "station_job_not_found", "")
	g := c.ghiLamSai(t, c.quay, cu[0], "khách đổi ý, không bàn nào gọi")
	canDat(t, g, http.StatusCreated)
	ghi := g.so(t, "wrong_make_note_id")
	if n := c.docSo(t, `SELECT count(*) FROM shop.wrong_make_note WHERE id = $1 AND station_job_id = $2 AND person_id = $3
		AND note = 'khách đổi ý, không bàn nào gọi' AND cancelled_at IS NULL`, ghi, cu[0], c.quay); n != 1 {
		t.Fatal("ghi chú phải mang đơn vị, người quầy, chữ đúng từng byte")
	}
	canMa(t, c.ghiLamSai(t, c.quay, cu[0], nil), http.StatusConflict, "station_job_has_wrong_make_note", "")
	// Ghi chú còn hiệu lực ⇒ thứ ấy không chuyển được, mẻ của nó không lùi được (ADR-077 điểm 2).
	dich := c.viec(t, donNhan, "pending")
	var cungKhoa int64
	for _, v := range dich {
		if c.khoaCua(t, v) == c.khoaCua(t, cu[0]) {
			cungKhoa = v
		}
	}
	if cungKhoa == 0 {
		t.Fatal("bàn nhận gọi cùng món phải có đơn vị cùng khoá")
	}
	canMa(t, c.chuyen(t, c.quay, [2]int64{cu[0], cungKhoa}), http.StatusConflict, "station_job_has_wrong_make_note", "")
	me := c.docSo(t, "SELECT production_batch_id FROM shop.production_batch_item WHERE station_job_id = $1", cu[0])
	canMa(t, c.luiMe(t, c.quay, me), http.StatusConflict, "station_job_has_wrong_make_note", "")
	// Huỷ ghi chú: mốc và người huỷ, dòng ở lại; huỷ lần hai bị từ chối; huỷ rồi thì chuyển được như thường.
	canDat(t, c.huyGhiChu(t, c.quay, ghi), http.StatusOK)
	if n := c.docSo(t, `SELECT count(*) FROM shop.wrong_make_note WHERE id = $1 AND cancelled_at IS NOT NULL AND cancelled_by_person_id = $2`, ghi, c.quay); n != 1 {
		t.Fatal("huỷ ghi chú phải mang mốc và người huỷ")
	}
	canMa(t, c.huyGhiChu(t, c.quay, ghi), http.StatusConflict, "wrong_make_note_already_cancelled", "")
	canMa(t, c.huyGhiChu(t, c.quay, 1<<40), http.StatusNotFound, "wrong_make_note_not_found", "")
	canDat(t, c.chuyen(t, c.quay, [2]int64{cu[0], cungKhoa}), http.StatusCreated)
	t.Logf("ghi chú %d trên đơn vị %d ⇒ chặn chuyển và lùi; huỷ ghi chú ⇒ chuyển được", ghi, cu[0])
}

// --- I-012 · architecture.md §1.1: mọi cửa ghi của lát ở quầy; ba trạm bếp không có cửa nào ------

func TestI012_CuaSanXuatPhaiDungQuay(t *testing.T) {
	c := dungBan(t)
	ban, _, don, _ := c.phienDangPhucVu(t, "quyền")
	v := c.viec(t, don, "pending")
	m := c.mucCua(t, v[0], 1)
	bep := c.nguoi(t, "người tráng bánh", false) // có thật, không đứng quầy
	anh := c.anhSanXuat(t, v...) + " | " + c.trangThaiDon(t, don)
	for _, p := range []struct{ path string }{
		{"/production-batches"}, {"/production-batches/1/rollback"}, {"/served-marks"}, {"/station-job-transfers"},
		{"/wrong-make-notes"}, {"/wrong-make-notes/1/cancellation"}, {fmt.Sprintf("/orders/%d/cancellation", don)},
	} {
		body := map[string]any{"station_job_ids": v[:1], "station_job_id": v[0],
			"transfers":       []map[string]any{{"from_station_job_id": v[0], "to_station_job_id": v[1]}},
			"dining_table_id": ban, "items": []map[string]any{{"station_code": m.tram, "menu_component_id": m.thanhPhan,
				"filling_option_ids": append([]int64{}, m.nhan...), "quantity": 1}}}
		canMa(t, c.post(t, p.path, bep, body), http.StatusForbidden, "not_on_counter_duty", "")
		canMa(t, c.post(t, p.path, c.chu, body), http.StatusForbidden, "not_on_counter_duty", "")
		canMa(t, c.post(t, p.path, 0, body), http.StatusUnauthorized, "unauthenticated", "")
	}
	if s := c.anhSanXuat(t, v...) + " | " + c.trangThaiDon(t, don); s != anh {
		t.Fatalf("lời từ chối quyền mà vẫn đổi: %s → %s", anh, s)
	}
}

// Liệt kê đường ghi (Gate 1f) và ma trận quyền: mọi ô ghi của năm bảng sản xuất thuộc một cửa lớp
// `quay` (hoặc `theo_cua_goi`, chạy trong giao dịch của cửa gọi). Không lớp nào đứng ở trạm bếp.
func TestQC13_TramBepKhongCoCuaGhi(t *testing.T) {
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	root := strings.TrimSpace(string(goc))
	out, err := exec.Command(filepath.Join(root, "scripts/check-write-paths.sh"), "--list").Output()
	if err != nil {
		t.Fatalf("check-write-paths --list: %v\n%s", err, out)
	}
	maTran := map[string]string{}
	b, err := os.ReadFile(filepath.Join(root, "docs/product/3-be/02-vai-va-quyen.md"))
	if err != nil {
		t.Fatal(err)
	}
	dongMaTran := regexp.MustCompile("(?m)^\\| `([a-z_]+/[a-z_]+)` \\| `([a-z_]+)` \\|")
	for _, m := range dongMaTran.FindAllStringSubmatch(string(b), -1) {
		maTran[m[1]] = m[2]
	}
	sanXuat := map[string]bool{"station_job": true, "production_batch": true, "production_batch_item": true,
		"station_job_transfer": true, "wrong_make_note": true}
	var o []string
	for _, l := range strings.Split(string(out), "\n") {
		f := strings.Split(l, "\t")
		if len(f) != 4 || !sanXuat[f[0]] {
			continue
		}
		lop := maTran[f[3]]
		if lop != "quay" && lop != "theo_cua_goi" {
			t.Fatalf("ô %s %s %s thuộc cửa %s lớp %q — ghi tiến độ chỉ ở quầy (architecture.md §1.1)", f[0], f[1], f[2], f[3], lop)
		}
		o = append(o, f[0]+" "+f[1]+" "+f[2]+" → "+f[3]+" ("+lop+")")
	}
	for _, can := range []string{"station_job thêm", "station_job sửa status", "production_batch thêm", "production_batch sửa",
		"production_batch_item thêm", "production_batch_item sửa", "station_job_transfer thêm", "wrong_make_note thêm", "wrong_make_note sửa"} {
		co := false
		for _, x := range o {
			co = co || strings.HasPrefix(x, can)
		}
		if !co {
			t.Fatalf("thiếu cửa cho ô %q; liệt kê: %v", can, o)
		}
	}
	for cua, lop := range maTran {
		for _, tram := range []string{"trang_banh", "gap_banh", "canh"} {
			if strings.Contains(lop, tram) {
				t.Fatalf("cửa %s có lớp %q đứng ở trạm bếp", cua, lop)
			}
		}
	}
	t.Logf("ô ghi sản xuất: %s", strings.Join(o, " · "))
}

func TestQC12_DuongGoiCuaSanXuat(t *testing.T) {
	c := dungBan(t)
	var thieu []string
	for _, p := range []struct{ method, path string }{
		{"POST", "/production-batches"}, {"POST", "/production-batches/1/rollback"}, {"POST", "/served-marks"},
		{"POST", "/station-job-transfers"}, {"GET", "/station-jobs/1/transfer-candidates"}, {"POST", "/wrong-make-notes"},
		{"POST", "/wrong-make-notes/1/cancellation"}, {"POST", "/orders/1/cancellation"}, {"GET", "/production-board"},
	} {
		status, out := c.goi(t, p.method, p.path, 0, map[string]any{})
		if code, _ := out["code"].(string); code == "" && (status == http.StatusNotFound || status == http.StatusMethodNotAllowed) {
			thieu = append(thieu, p.method+" "+p.path)
		}
	}
	sort.Strings(thieu)
	if len(thieu) > 0 {
		t.Fatalf("thiếu đường gọi: %s", strings.Join(thieu, " · "))
	}
}
