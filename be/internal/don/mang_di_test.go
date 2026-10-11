// Test luồng ngoài bàn qua cửa (P3-08, ADR-088; I-007 · I-008 · I-022 · I-024, và vế S-6). Viết
// TRƯỚC khi có phần kênh ngoài bàn — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào.
// Mọi lời gọi đi qua ĐƯỜNG GỌI HTTP của hợp đồng; database được đọc lại bằng kết nối chủ lược đồ.
//
// Đồng hồ: cửa đọc mốc tạo đơn qua don.DongHo. Bản thật là now() của chính giao dịch của cửa —
// TestI008_MocLaNowCuaGiaoDich giữ điều ấy; mọi test khác thay nó bằng một mốc cố định, để giờ bán
// không phụ thuộc lúc chạy test. Giờ bán đọc LÚC CHẠY từ master_plan/shop-facts.md §1.
//
// Ba thứ dựng tay bằng kết nối chủ lược đồ vì cửa của chúng thuộc chỗ khác, không phải vì cửa của lát
// này được phép bỏ qua: khoảng tạm dừng nhận đơn (ai bấm — architecture.md §7, chưa có lời), khoảng quán
// mù (P3-12), và đơn tới Đang thực hiện cùng việc trạm của nó (nổ việc trạm — P3-10).
package don_test

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/db"
	"banhcuon/be/internal/dbtest"
	"banhcuon/be/internal/don"
	"github.com/jackc/pgx/v5"
)

// dongHoGoc là đồng hồ thật của cửa, giữ lại trước khi khung thay nó.
var dongHoGoc = don.DongHo

// datDongHo: cửa đọc mốc này thay cho now() tới hết test.
func datDongHo(t *testing.T, moc time.Time) {
	t.Helper()
	don.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil }
	t.Cleanup(func() { don.DongHo = dongHoGoc })
}

// gioBan đọc giờ mở và giờ đóng từ dòng "Giờ bán" của shop-facts.md §1 — không gõ lại con số.
func gioBan(t *testing.T) (mo, dong time.Duration) {
	t.Helper()
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	raw, err := os.ReadFile(filepath.Join(strings.TrimSpace(string(goc)), "master_plan", "shop-facts.md"))
	if err != nil {
		t.Fatal(err)
	}
	m := regexp.MustCompile(`(?m)^\| Giờ bán \| \*\*(\d{2}):(\d{2}) – (\d{2}):(\d{2})\*\*`).FindStringSubmatch(string(raw))
	if m == nil {
		t.Fatal("không đọc được dòng Giờ bán ở master_plan/shop-facts.md §1")
	}
	var so [4]int
	for i := range so {
		fmt.Sscanf(m[i+1], "%d", &so[i])
	}
	return time.Duration(so[0])*time.Hour + time.Duration(so[1])*time.Minute,
		time.Duration(so[2])*time.Hour + time.Duration(so[3])*time.Minute
}

func muiGio(t *testing.T) *time.Location {
	t.Helper()
	loc, err := time.LoadLocation(dbtest.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	return loc
}

// mocMacDinh: một giờ sau giờ mở, ngày 2030-06-15 — không khoảng tạm dừng hay quán mù nào của test
// phủ ngày ấy. Khung dung() đặt mốc này cho MỌI test của gói.
func mocMacDinh(t *testing.T) time.Time {
	t.Helper()
	mo, _ := gioBan(t)
	return time.Date(2030, 6, 15, 0, 0, 0, 0, muiGio(t)).Add(mo + time.Hour)
}

// --- khung của luồng ngoài bàn -------------------------------------------------------------------

type ngoai struct {
	canh
	loc      *time.Location
	gioMo    time.Duration
	gioDong  time.Duration
	banDatHo int64  // bàn cho kênh staff_pos
	maQR     string // mã của một bàn khác, cho kênh qr_table
}

func dungNgoai(t *testing.T) ngoai {
	t.Helper()
	n := ngoai{canh: dungBan(t), loc: muiGio(t)}
	n.gioMo, n.gioDong = gioBan(t)
	n.banDatHo = n.banMoi(t, "đặt hộ")
	n.maQR = n.capMaQR(t, n.banMoi(t, "qr"))
	return n
}

// luc: ngày thứ `ngay` của tháng 1/2031 theo múi giờ của quán, cộng một độ lệch từ nửa đêm. Mỗi test
// dùng ngày riêng, nên khoảng tạm dừng và quán mù của test này không phủ mốc của test khác.
func (n ngoai) luc(ngay int, lech time.Duration) time.Time {
	return time.Date(2031, 1, ngay, 0, 0, 0, 0, n.loc).Add(lech)
}

func (n ngoai) monMangDi() map[string]any {
	ids := n.mon.chonIDs
	if ids == nil {
		ids = []int64{}
	}
	return map[string]any{"menu_item_id": n.mon.monID, "quantity": n.mon.soSuat, "option_ids": ids}
}

const (
	soGoi   = "0912 345 678"
	diaChi  = "12 ngõ Huế, Hai Bà Trưng"
	canLuc  = "2031-01-20T09:30:00+07:00"
	canLucZ = "2031-01-20T02:30:00Z" // cùng một khoảnh khắc với canLuc
)

// Bốn hình liên hệ của ba kênh không gắn bàn (shop-facts.md §6.5), đủ mức tối thiểu — không hơn.
func lienHeGiao() map[string]any {
	return map[string]any{"channel_code": "delivery", "customer_phone": soGoi, "delivery_address": diaChi}
}
func lienHeLay() map[string]any {
	return map[string]any{"channel_code": "pickup", "customer_phone": soGoi, "customer_needed_at": canLuc}
}
func lienHeHotlineGiao() map[string]any {
	return map[string]any{"handover_code": "door_delivery", "customer_phone": soGoi, "delivery_address": diaChi, "customer_needed_at": canLuc}
}
func lienHeHotlineLay() map[string]any {
	return map[string]any{"handover_code": "shop_pickup", "customer_phone": soGoi, "customer_needed_at": canLuc}
}

func voiDong(lienHe map[string]any, dau string, dong ...map[string]any) map[string]any {
	body := map[string]any{"submission_code": dau, "lines": dong}
	for k, v := range lienHe {
		body[k] = v
	}
	return body
}

// web: khách tự gửi trên web — POST /online-orders, không người, không bàn.
func (n ngoai) web(t *testing.T, dau string, lienHe map[string]any) traLoi {
	t.Helper()
	return n.post(t, "/online-orders", 0, voiDong(lienHe, dau, n.monMangDi()))
}

// hotline: người đứng quầy nhập đơn đặt trước qua điện thoại — POST /phone-orders.
func (n ngoai) hotline(t *testing.T, nguoi int64, dau string, lienHe map[string]any) traLoi {
	t.Helper()
	return n.post(t, "/phone-orders", nguoi, voiDong(lienHe, dau, n.monMangDi()))
}

func (n ngoai) roiQuan(t *testing.T, nguoi, don int64) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/orders/%d/departure", don), nguoi, map[string]any{})
}

var namKenh = []string{"delivery", "pickup", "qr_table", "staff_pos", "phone_preorder"}

// taoKenh: một lần gửi mới qua đúng đường gọi của kênh.
func (n ngoai) taoKenh(t *testing.T, kenh string) traLoi {
	t.Helper()
	dau := dauLanGui(t)
	switch kenh {
	case "delivery":
		return n.web(t, dau, lienHeGiao())
	case "pickup":
		return n.web(t, dau, lienHeLay())
	case "qr_table":
		return n.goiQR(t, n.maQR, dau, n.dong(false))
	case "staff_pos":
		return n.datHo(t, n.quay, n.banDatHo, dau, n.dong(false))
	case "phone_preorder":
		return n.hotline(t, n.quay, dau, lienHeHotlineLay())
	}
	t.Fatalf("kênh lạ %q", kenh)
	return traLoi{}
}

// demTatCa: số dòng mọi bảng mà cửa tạo lượt gọi ghi — một lời từ chối không được đổi con số nào.
func (n ngoai) demTatCa(t *testing.T) string {
	t.Helper()
	return n.demGhi(t) + n.docChu(t, `SELECT format(' · %s phiên · %s bàn-phiên',
		(SELECT count(*) FROM shop.table_session), (SELECT count(*) FROM shop.table_session_member))`)
}

func (n ngoai) tamDung(t *testing.T, bat, tat time.Time) {
	t.Helper()
	n.id(t, `INSERT INTO shop.order_intake_pause (started_at, started_by_person_id, ended_at, ended_by_person_id)
		VALUES ($1, $2, $3, $2) RETURNING id`, bat, n.chu, tat)
}

func (n ngoai) quanMu(t *testing.T, tu, toi time.Time) {
	t.Helper()
	n.id(t, `INSERT INTO shop.shop_blind_spell (started_at, ended_at, ended_by_person_id)
		VALUES ($1, $2, $3) RETURNING id`, tu, toi, n.chu)
}

// dangLam: đơn tới Đang thực hiện — dựng tay. Từ P3-10 (ADR-090) duyệt và lượt gọi của người đã nổ
// đơn sang Đang thực hiện, nên với các đơn ấy lệnh này không đổi gì; để lại cho đơn dựng tay.
func (n ngoai) dangLam(t *testing.T, don int64) {
	t.Helper()
	if err := n.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(n.ctx, "UPDATE shop.sales_order SET status = 'in_progress' WHERE id = $1", don)
		return err
	}); err != nil {
		t.Fatal(err)
	}
}

// anhDon: mọi thứ của một đơn mà lát này ghi; ô trống in "-". Một lời từ chối không được đổi chữ nào.
func (n ngoai) anhDon(t *testing.T, don int64) string {
	t.Helper()
	return n.docChu(t, `SELECT format('đơn %s %s %s trao=%s phiên=%s bàn=%s mã=%s sđt=%s đc=%s cần=%s tên=%s ghi=%s | %s',
		o.id, o.channel_code, o.status, coalesce(o.handover_code, '-'), coalesce(o.table_session_id::text, '-'),
		coalesce(o.dining_table_id::text, '-'), coalesce(o.qr_code_id::text, '-'), coalesce(o.customer_phone, '-'),
		coalesce(o.delivery_address, '-'), coalesce(o.customer_needed_at::text, '-'), coalesce(o.customer_name, '-'),
		coalesce(o.contact_note, '-'),
		(SELECT string_agg(format('%s×%s', l.item_name, l.quantity), ',' ORDER BY l.id)
		   FROM shop.order_line l WHERE l.sales_order_id = o.id))
		FROM shop.sales_order o WHERE o.id = $1`, don)
}

func khongCoTruong(t *testing.T, r traLoi, truong ...string) {
	t.Helper()
	for _, f := range truong {
		if _, co := r.body[f]; co {
			t.Fatalf("đơn ngoài bàn trả về trường %q (I-007: không thuộc phiên bàn nào): %v", f, r.body)
		}
	}
}

// --- I-008: tạm dừng → giờ bán → quán mù, đúng thứ tự, ở cả năm kênh ----------------------------

// Bản thật của đồng hồ là now() của chính giao dịch — mốc xét giờ bán là mốc ghi created_at, không
// phải đồng hồ của máy gửi (02-thoi-gian-ngay-ban.md §3).
func TestI008_MocLaNowCuaGiaoDich(t *testing.T) {
	k := dung(t)
	err := db.InTx(k.ctx, k.pool, func(tx pgx.Tx) error {
		moc, err := dongHoGoc(k.ctx, tx)
		if err != nil {
			return err
		}
		var now time.Time
		if err := tx.QueryRow(k.ctx, "SELECT now()").Scan(&now); err != nil {
			return err
		}
		if !moc.Equal(now) {
			return fmt.Errorf("đồng hồ của cửa trả %v, now() của giao dịch là %v", moc, now)
		}
		t.Logf("đồng hồ thật của cửa = now() của giao dịch: %v", moc)
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}

// Giờ bán đọc từ shop-facts.md §1; hai đầu tính là trong giờ (cùng cách db/reconcile/i008.sql tập 1).
func TestI008_GioBanHaiDauTinhLaTrongGio(t *testing.T) {
	n := dungNgoai(t)
	for _, kenh := range namKenh {
		for _, ca := range []struct {
			lech time.Duration
			duoc bool
		}{{n.gioMo - time.Second, false}, {n.gioMo, true}, {n.gioDong, true}, {n.gioDong + time.Second, false}} {
			moc := n.luc(1, ca.lech)
			datDongHo(t, moc)
			truoc := n.demTatCa(t)
			r := n.taoKenh(t, kenh)
			if ca.duoc {
				canDat(t, r, http.StatusCreated)
			} else {
				canMa(t, r, http.StatusConflict, "outside_selling_hours", "")
				if sau := n.demTatCa(t); sau != truoc {
					t.Fatalf("%s lúc %s bị từ chối mà vẫn ghi: %s → %s", kenh, moc.Format("15:04:05"), truoc, sau)
				}
			}
			t.Logf("%s lúc %s ⇒ %d %s", kenh, moc.Format("15:04:05"), r.status, r.chu("code"))
		}
	}
}

func TestI008_TamDungThangGioBan(t *testing.T) {
	n := dungNgoai(t)
	bat := n.luc(2, n.gioMo+time.Hour)
	n.tamDung(t, bat, bat.Add(10*time.Minute))
	truocGio := n.luc(3, n.gioMo-time.Hour)
	n.tamDung(t, truocGio, truocGio.Add(30*time.Minute))
	truoc := n.demTatCa(t)
	for _, moc := range []time.Time{bat, bat.Add(time.Minute), truocGio.Add(10 * time.Minute)} {
		datDongHo(t, moc)
		for _, kenh := range namKenh {
			// Ngoài giờ mà đang tạm dừng: điều kiện (1) chặn trước, không xét tới (2).
			canMa(t, n.taoKenh(t, kenh), http.StatusConflict, "order_intake_paused", "")
		}
	}
	if sau := n.demTatCa(t); sau != truoc {
		t.Fatalf("tạm dừng mà vẫn ghi: %s → %s", truoc, sau)
	}
	// Khoảng [bật, tắt): đúng lúc tắt thì nhận đơn lại.
	datDongHo(t, bat.Add(10*time.Minute))
	for _, kenh := range namKenh {
		canDat(t, n.taoKenh(t, kenh), http.StatusCreated)
	}
	t.Logf("tạm dừng ⇒ order_intake_paused ở năm kênh, kể cả lúc ngoài giờ; đúng lúc tắt ⇒ nhận lại; %s", truoc)
}

func TestI008_QuanMuChiChanBaKenhKhachTuBam(t *testing.T) {
	n := dungNgoai(t)
	tu := n.luc(4, n.gioMo+time.Hour)
	n.quanMu(t, tu, tu.Add(10*time.Minute))
	datDongHo(t, tu.Add(time.Minute))
	for _, kenh := range namKenh {
		truoc := n.demTatCa(t)
		r := n.taoKenh(t, kenh)
		switch kenh {
		case "delivery", "pickup", "qr_table":
			canMa(t, r, http.StatusConflict, "shop_not_seeing_orders", "")
			if sau := n.demTatCa(t); sau != truoc {
				t.Fatalf("%s lúc quán mù bị từ chối mà vẫn ghi: %s → %s", kenh, truoc, sau)
			}
		default:
			// Hai kênh người của quán nhập vẫn nhận (shop-facts.md §6.11) — chặn nhầm cũng là hỏng.
			canDat(t, r, http.StatusCreated)
		}
		t.Logf("quán mù, %s ⇒ %d %s", kenh, r.status, r.chu("code"))
	}
	// Mù mà ngoài giờ: điều kiện (2) chặn trước (3).
	sau := n.luc(5, n.gioDong+time.Minute)
	n.quanMu(t, sau, sau.Add(20*time.Minute))
	datDongHo(t, sau.Add(5*time.Minute))
	canMa(t, n.taoKenh(t, "delivery"), http.StatusConflict, "outside_selling_hours", "")
	// Mù và tạm dừng cùng lúc: điều kiện (1) thắng, ở cả năm kênh.
	ca := n.luc(6, n.gioMo+time.Hour)
	n.quanMu(t, ca, ca.Add(10*time.Minute))
	n.tamDung(t, ca, ca.Add(10*time.Minute))
	datDongHo(t, ca.Add(time.Minute))
	for _, kenh := range namKenh {
		canMa(t, n.taoKenh(t, kenh), http.StatusConflict, "order_intake_paused", "")
	}
}

// I-024 × I-008: lần gửi lại không tạo đơn mới, nên không xét lại tạm dừng hay giờ bán.
func TestI024_GuiLaiKhongXetLaiGioBanVaTamDung(t *testing.T) {
	n := dungNgoai(t)
	moc := n.luc(7, n.gioMo+time.Hour)
	datDongHo(t, moc)
	dau := dauLanGui(t)
	r := n.web(t, dau, lienHeGiao())
	canDat(t, r, http.StatusCreated)
	id := r.so(t, "sales_order_id")
	n.tamDung(t, moc.Add(5*time.Minute), moc.Add(15*time.Minute))
	datDongHo(t, moc.Add(10*time.Minute))
	lai := n.web(t, dau, lienHeGiao())
	canDat(t, lai, http.StatusOK)
	if lai.so(t, "sales_order_id") != id {
		t.Fatalf("gửi lại lúc tạm dừng trả đơn %d, muốn %d", lai.so(t, "sales_order_id"), id)
	}
	canMa(t, n.web(t, dauLanGui(t), lienHeGiao()), http.StatusConflict, "order_intake_paused", "")
	datDongHo(t, n.luc(7, n.gioDong+time.Hour))
	lai = n.web(t, dau, lienHeGiao())
	canDat(t, lai, http.StatusOK)
	if lai.so(t, "sales_order_id") != id {
		t.Fatal("gửi lại ngoài giờ phải trả đúng đơn đã có")
	}
	t.Logf("đơn %d: gửi lại lúc tạm dừng và lúc ngoài giờ ⇒ 200 cùng đơn; lần gửi mới lúc tạm dừng ⇒ order_intake_paused", id)
}

// --- I-022: liên hệ tối thiểu theo kênh và cách trao hàng — đúng mức, không hơn -----------------

func TestI022_ThieuLienHeBiTuChoiTheoTruong(t *testing.T) {
	n := dungNgoai(t)
	bo := func(m map[string]any, khoa string) map[string]any { delete(m, khoa); return m }
	dat := func(m map[string]any, khoa string, v any) map[string]any { m[khoa] = v; return m }
	truoc := n.demTatCa(t)
	for _, ca := range []struct {
		ten    string
		hotl   bool
		lienHe map[string]any
		truong string
	}{
		{"giao thiếu số", false, bo(lienHeGiao(), "customer_phone"), "customer_phone"},
		{"giao số trắng", false, dat(lienHeGiao(), "customer_phone", "   "), "customer_phone"},
		{"giao thiếu địa chỉ", false, bo(lienHeGiao(), "delivery_address"), "delivery_address"},
		{"giao địa chỉ trắng", false, dat(lienHeGiao(), "delivery_address", " \t "), "delivery_address"},
		{"lấy thiếu giờ", false, bo(lienHeLay(), "customer_needed_at"), "customer_needed_at"},
		{"lấy giờ không độ lệch", false, dat(lienHeLay(), "customer_needed_at", "2031-01-20T09:30:00"), "customer_needed_at"},
		{"lấy thiếu số", false, bo(lienHeLay(), "customer_phone"), "customer_phone"},
		{"web thiếu kênh", false, bo(lienHeGiao(), "channel_code"), "channel_code"},
		{"web kênh tại bàn", false, dat(lienHeGiao(), "channel_code", "qr_table"), "channel_code"},
		{"web kênh hotline", false, dat(lienHeGiao(), "channel_code", "phone_preorder"), "channel_code"},
		{"hotline thiếu cách trao", true, bo(lienHeHotlineLay(), "handover_code"), "handover_code"},
		{"hotline cách trao lạ", true, dat(lienHeHotlineLay(), "handover_code", "delivery"), "handover_code"},
		{"hotline giao thiếu địa chỉ", true, bo(lienHeHotlineGiao(), "delivery_address"), "delivery_address"},
		{"hotline thiếu giờ", true, bo(lienHeHotlineLay(), "customer_needed_at"), "customer_needed_at"},
		{"hotline thiếu số", true, bo(lienHeHotlineGiao(), "customer_phone"), "customer_phone"},
	} {
		var r traLoi
		if ca.hotl {
			r = n.hotline(t, n.quay, dauLanGui(t), ca.lienHe)
		} else {
			r = n.web(t, dauLanGui(t), ca.lienHe)
		}
		canMa(t, r, http.StatusBadRequest, "invalid_request", ca.truong)
		t.Logf("%s ⇒ invalid_request field=%s", ca.ten, ca.truong)
	}
	if sau := n.demTatCa(t); sau != truoc {
		t.Fatalf("thiếu liên hệ mà vẫn ghi: %s → %s", truoc, sau)
	}
}

// Vế ngược: trường "nên có" không chặn tạo đơn — kịch bản dương của I-022.
func TestI022_TruongNenCoKhongChanTaoDon(t *testing.T) {
	n := dungNgoai(t)
	coTen := lienHeHotlineGiao()
	coTen["customer_name"] = "chị Lan"
	coTen["contact_note"] = "gọi trước khi tới"
	for _, ca := range []struct {
		ten         string
		hotl        bool
		lienHe      map[string]any
		kenh, trao  string
		trangThai   string
		muonAnhChua string
	}{
		{"giao không giờ, không tên", false, lienHeGiao(), "delivery", "door_delivery", "pending_confirmation", "cần=- tên=-"},
		{"tới lấy không địa chỉ", false, lienHeLay(), "pickup", "shop_pickup", "pending_confirmation", "đc=-"},
		// T-142 (U-077): đơn đặt trước vào Đã xác nhận, chưa nổ — giờ khách cần còn xa hơn 20 phút.
		{"hotline tới lấy không địa chỉ", true, lienHeHotlineLay(), "phone_preorder", "shop_pickup", "confirmed", "đc=-"},
		{"hotline giao kèm tên và ghi chú", true, coTen, "phone_preorder", "door_delivery", "confirmed", "tên=chị Lan ghi=gọi trước khi tới"},
	} {
		var r traLoi
		if ca.hotl {
			r = n.hotline(t, n.quay, dauLanGui(t), ca.lienHe)
		} else {
			r = n.web(t, dauLanGui(t), ca.lienHe)
		}
		canDat(t, r, http.StatusCreated)
		if r.chu("channel_code") != ca.kenh || r.chu("handover_code") != ca.trao || r.chu("status") != ca.trangThai ||
			r.chu("customer_phone") != soGoi {
			t.Fatalf("%s: trả về %v", ca.ten, r.body)
		}
		anh := n.anhDon(t, r.so(t, "sales_order_id"))
		if !strings.Contains(anh, ca.muonAnhChua) || !strings.Contains(anh, "sđt="+soGoi) {
			t.Fatalf("%s: database ghi %s, muốn chứa %q", ca.ten, anh, ca.muonAnhChua)
		}
		t.Logf("%s ⇒ 201; %s", ca.ten, anh)
	}
}

// --- I-007: đơn mang đi không thuộc phiên bàn nào, và không đường nào nối nó vào một phiên -------

func TestI007_DonMangDiKhongThuocPhienNao(t *testing.T) {
	n := dungNgoai(t)
	for _, ca := range []struct {
		hotl   bool
		lienHe map[string]any
	}{{false, lienHeGiao()}, {false, lienHeLay()}, {true, lienHeHotlineGiao()}, {true, lienHeHotlineLay()}} {
		var r traLoi
		if ca.hotl {
			r = n.hotline(t, n.quay, dauLanGui(t), ca.lienHe)
		} else {
			r = n.web(t, dauLanGui(t), ca.lienHe)
		}
		canDat(t, r, http.StatusCreated)
		khongCoTruong(t, r, "table_session_id", "dining_table_id")
		anh := n.anhDon(t, r.so(t, "sales_order_id"))
		if !strings.Contains(anh, "phiên=- bàn=- mã=-") {
			t.Fatalf("đơn ngoài bàn gắn phiên, bàn hay mã: %s", anh)
		}
		t.Logf("%s", anh)
	}
	// Yêu cầu mang định danh bàn hay phiên ⇒ invalid_request, không dùng.
	truoc := n.demTatCa(t)
	for _, f := range []string{"dining_table_id", "table_session_id"} {
		web := lienHeGiao()
		web[f] = n.banDatHo
		canMa(t, n.web(t, dauLanGui(t), web), http.StatusBadRequest, "invalid_request", f)
		hl := lienHeHotlineLay()
		hl[f] = n.banDatHo
		canMa(t, n.hotline(t, n.quay, dauLanGui(t), hl), http.StatusBadRequest, "invalid_request", f)
	}
	if sau := n.demTatCa(t); sau != truoc {
		t.Fatalf("yêu cầu mang bàn bị từ chối mà vẫn ghi: %s → %s", truoc, sau)
	}
	// Không đường nào nối: dấu của một đơn giao gửi lại qua đường tại bàn ⇒ từ chối, bàn không mở phiên.
	dau := dauLanGui(t)
	g := n.web(t, dau, lienHeGiao())
	canDat(t, g, http.StatusCreated)
	giao := g.so(t, "sales_order_id")
	anhGiao := n.anhDon(t, giao)
	ban := n.banMoi(t, "nối thử")
	canMa(t, n.datHo(t, n.quay, ban, dau, n.dong(false)), http.StatusConflict, "submission_code_conflict", "")
	if n.soDongCuaBan(t, ban) != 0 || n.anhDon(t, giao) != anhGiao {
		t.Fatalf("dấu của đơn giao qua đường tại bàn đã nối hay mở phiên: bàn %d có %d dòng; %s",
			ban, n.soDongCuaBan(t, ban), n.anhDon(t, giao))
	}
	// Và chiều ngược: dấu của một lượt gọi tại bàn gửi lại qua đường web ⇒ từ chối.
	dauBan := dauLanGui(t)
	canDat(t, n.datHo(t, n.quay, n.banDatHo, dauBan, n.dong(false)), http.StatusCreated)
	canMa(t, n.web(t, dauBan, lienHeGiao()), http.StatusConflict, "submission_code_conflict", "")
	canMa(t, n.hotline(t, n.quay, dauBan, lienHeHotlineLay()), http.StatusConflict, "submission_code_conflict", "")
	t.Logf("dấu đơn giao qua /table-orders ⇒ conflict, bàn %d không phiên; dấu tại bàn qua hai đường ngoài bàn ⇒ conflict", ban)
}

// --- I-024 ở ba kênh không gắn bàn ---------------------------------------------------------------

func TestI024_MangDiGuiLaiBaLanMotDon(t *testing.T) {
	n := dungNgoai(t)
	for _, ca := range []struct {
		ten    string
		hotl   bool
		lienHe func() map[string]any
	}{{"web giao", false, lienHeGiao}, {"web lấy", false, lienHeLay}, {"hotline giao", true, lienHeHotlineGiao}} {
		dau := dauLanGui(t)
		var id int64
		for lan := 1; lan <= 3; lan++ {
			var r traLoi
			if ca.hotl {
				r = n.hotline(t, n.quay, dau, ca.lienHe())
			} else {
				r = n.web(t, dau, ca.lienHe())
			}
			muon := http.StatusOK
			if lan == 1 {
				muon = http.StatusCreated
				id = r.so(t, "sales_order_id")
			}
			canDat(t, r, muon)
			if r.so(t, "sales_order_id") != id {
				t.Fatalf("%s lần %d: đơn %d, muốn %d", ca.ten, lan, r.so(t, "sales_order_id"), id)
			}
		}
		if so := n.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE submission_code = $1", dau); so != 1 {
			t.Fatalf("%s: %d đơn mang một dấu", ca.ten, so)
		}
		t.Logf("%s: cùng dấu ba lần ⇒ 201, 200, 200, một đơn %d", ca.ten, id)
	}
	// Gửi lại sau khi đơn đổi trạng thái: nhận lại đơn ấy, với trạng thái hiện tại.
	dau := dauLanGui(t)
	r := n.web(t, dau, lienHeGiao())
	canDat(t, r, http.StatusCreated)
	canDat(t, n.duyet(t, n.quay, r.so(t, "sales_order_id")), http.StatusOK)
	lai := n.web(t, dau, lienHeGiao())
	canDat(t, lai, http.StatusOK)
	if lai.chu("status") != "in_progress" { // P3-10 (ADR-090 điểm 1): duyệt nổ ngay
		t.Fatalf("gửi lại sau khi duyệt: trạng thái %q, muốn in_progress", lai.chu("status"))
	}
	// Cùng khoảnh khắc viết theo độ lệch khác vẫn là cùng nội dung.
	dau = dauLanGui(t)
	canDat(t, n.hotline(t, n.quay, dau, lienHeHotlineLay()), http.StatusCreated)
	z := lienHeHotlineLay()
	z["customer_needed_at"] = canLucZ
	canDat(t, n.hotline(t, n.quay, dau, z), http.StatusOK)
}

func TestI024_MangDiCungDauKhacNoiDungBiTuChoi(t *testing.T) {
	n := dungNgoai(t)
	dau := dauLanGui(t)
	r := n.web(t, dau, lienHeGiao())
	canDat(t, r, http.StatusCreated)
	id := r.so(t, "sales_order_id")
	truoc := n.anhDon(t, id) + " | " + n.demTatCa(t)
	doi := func(khoa string, v any) map[string]any { m := lienHeGiao(); m[khoa] = v; return m }
	for _, ca := range []struct {
		ten    string
		lienHe map[string]any
	}{
		{"đổi số", doi("customer_phone", "0987 654 321")},
		{"đổi địa chỉ", doi("delivery_address", "99 phố khác")},
		{"thêm tên", doi("customer_name", "anh Minh")},
		{"đổi kênh", lienHeLay()},
	} {
		canMa(t, n.web(t, dau, ca.lienHe), http.StatusConflict, "submission_code_conflict", "")
		t.Logf("cùng dấu, %s ⇒ submission_code_conflict", ca.ten)
	}
	nhieuHon := n.monMangDi()
	nhieuHon["quantity"] = n.mon.soSuat + 1
	canMa(t, n.post(t, "/online-orders", 0, voiDong(lienHeGiao(), dau, nhieuHon)), http.StatusConflict, "submission_code_conflict", "")
	canMa(t, n.hotline(t, n.quay, dau, lienHeHotlineGiao()), http.StatusConflict, "submission_code_conflict", "")
	if sau := n.anhDon(t, id) + " | " + n.demTatCa(t); sau != truoc {
		t.Fatalf("cùng dấu khác nội dung mà đơn hay số dòng đã đổi:\n trước %s\n sau   %s", truoc, sau)
	}
}

func TestI024_MangDiNoiDungGiongHetHaiDauLaHaiDon(t *testing.T) {
	n := dungNgoai(t)
	a := n.web(t, dauLanGui(t), lienHeGiao())
	b := n.web(t, dauLanGui(t), lienHeGiao())
	canDat(t, a, http.StatusCreated)
	canDat(t, b, http.StatusCreated)
	if a.so(t, "sales_order_id") == b.so(t, "sales_order_id") {
		t.Fatal("hai lần gửi thật, nội dung giống hệt, bị gộp làm một đơn")
	}
}

func TestI024_MangDiGuiLaiChenNhauMotDon(t *testing.T) {
	n := dungNgoai(t)
	dau := dauLanGui(t)
	var wg sync.WaitGroup
	kq := make([]traLoi, 5)
	for i := range kq {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			kq[i] = n.web(t, dau, lienHeLay())
		}(i)
	}
	wg.Wait()
	tao, ids := 0, map[int64]bool{}
	for _, r := range kq {
		if r.status != http.StatusCreated && r.status != http.StatusOK {
			t.Fatalf("lần gửi chen nhau bị từ chối: %d %v", r.status, r.body)
		}
		if r.status == http.StatusCreated {
			tao++
		}
		ids[r.so(t, "sales_order_id")] = true
	}
	so := n.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE submission_code = $1", dau)
	t.Logf("5 lần gửi cùng dấu chen nhau ⇒ %d lần 201, %d đơn trả về, %d đơn trong database", tao, len(ids), so)
	if tao != 1 || len(ids) != 1 || so != 1 {
		t.Fatal("muốn đúng một lần 201 và một đơn")
	}
}

// --- vòng đời: bốn hình đi qua các cửa đã có, và cửa rời quán --------------------------------

// Hoàn thành của đơn lẻ cần hoá đơn đơn lẻ (sales_order_bill_fkey) — cửa thu tiền là của P3-09, cửa
// ghi đã ra bàn là của P3-10; test này đi tới trạng thái cuối mà cửa của lát này với tới.
func TestI016_BonHinhMangDiQuaCuaCuaLat(t *testing.T) {
	n := dungNgoai(t)
	vet := func(don int64, tu, den string) int64 {
		return n.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'sales_order' AND target_row = $1
			AND before_image ->> 'status' = $2 AND after_image ->> 'status' = $3 AND person_id = $4 AND btrim(reason) <> ''`,
			don, tu, den, n.quay)
	}
	// Giao tận nơi, khách tự gửi: chờ duyệt → duyệt → (đang làm) → rời quán ⇒ Đang giao.
	g := n.web(t, dauLanGui(t), lienHeGiao())
	canDat(t, g, http.StatusCreated)
	giao := g.so(t, "sales_order_id")
	if g.chu("status") != "pending_confirmation" {
		t.Fatalf("đơn giao khách tự gửi: %q, muốn pending_confirmation", g.chu("status"))
	}
	d := n.duyet(t, n.quay, giao)
	canDat(t, d, http.StatusOK)
	// P3-10 đổi có chủ ý (ADR-090 điểm 1): duyệt nổ đơn sang Đang thực hiện; rời quán còn việc chưa ra
	// bàn ⇒ S-6; quầy bấm mẻ và đã ra bàn qua cửa (phucVuHet) rồi mới rời quán.
	if d.chu("status") != "in_progress" || d.body["table_session_id"] != nil {
		t.Fatalf("duyệt đơn giao: %v", d.body)
	}
	canMa(t, n.roiQuan(t, n.quay, giao), http.StatusConflict, "delivery_served_mark_undecided", "")
	n.phucVuHet(t, n.quay, giao)
	rq := n.roiQuan(t, n.quay, giao)
	canDat(t, rq, http.StatusOK)
	if rq.chu("status") != "delivering" || n.trangThaiDon(t, giao) != "delivering" || vet(giao, "in_progress", "delivering") != 1 {
		t.Fatalf("rời quán: %v, database %s, vết %d", rq.body, n.trangThaiDon(t, giao), vet(giao, "in_progress", "delivering"))
	}
	canMa(t, n.roiQuan(t, n.quay, giao), http.StatusConflict, "order_transition_not_allowed", "")
	t.Logf("giao (web) %d: pending_confirmation → confirmed → in_progress → delivering, vết mang người quầy", giao)

	// Tới lấy, khách tự gửi: một đơn bị từ chối; một đơn duyệt, đang làm — không có Đang giao.
	l := n.web(t, dauLanGui(t), lienHeLay())
	canDat(t, l, http.StatusCreated)
	tc := n.tuChoi(t, n.quay, l.so(t, "sales_order_id"))
	canDat(t, tc, http.StatusOK)
	if tc.chu("status") != "cancelled" {
		t.Fatalf("từ chối đơn tới lấy: %v", tc.body)
	}
	l = n.web(t, dauLanGui(t), lienHeLay())
	lay := l.so(t, "sales_order_id")
	canDat(t, n.duyet(t, n.quay, lay), http.StatusOK)
	n.dangLam(t, lay)
	canMa(t, n.roiQuan(t, n.quay, lay), http.StatusConflict, "order_transition_not_allowed", "")
	t.Logf("lấy (web): một đơn bị từ chối ⇒ cancelled; đơn %d đang làm, rời quán ⇒ order_transition_not_allowed", lay)

	// Hotline: vào thẳng Đã xác nhận; duyệt lại bị từ chối; giao thì rời quán được, tới lấy thì không.
	hg := n.hotline(t, n.quay, dauLanGui(t), lienHeHotlineGiao())
	canDat(t, hg, http.StatusCreated)
	hGiao := hg.so(t, "sales_order_id")
	if hg.chu("status") != "confirmed" {
		t.Fatalf("đơn hotline: %q, muốn confirmed (vào thẳng, nổ theo giờ nhắc — T-142)", hg.chu("status"))
	}
	canMa(t, n.duyet(t, n.quay, hGiao), http.StatusConflict, "order_transition_not_allowed", "")
	n.denGioLam(t, hGiao)
	n.phucVuHet(t, n.quay, hGiao)
	canDat(t, n.roiQuan(t, n.quay, hGiao), http.StatusOK)
	if n.trangThaiDon(t, hGiao) != "delivering" {
		t.Fatal("đơn hotline giao tận nơi phải rời quán được")
	}
	hl := n.hotline(t, n.quay, dauLanGui(t), lienHeHotlineLay())
	hLay := hl.so(t, "sales_order_id")
	n.dangLam(t, hLay)
	canMa(t, n.roiQuan(t, n.quay, hLay), http.StatusConflict, "order_transition_not_allowed", "")
	t.Logf("hotline giao %d ⇒ delivering; hotline tới lấy %d ⇒ không rời quán", hGiao, hLay)

	// Rời quán chỉ cho đơn giao tận nơi: một lượt gọi tại bàn đang làm cũng bị từ chối.
	_, _, donBan, _ := n.phienDangPhucVu(t, "bàn")
	n.dangLam(t, donBan)
	canMa(t, n.roiQuan(t, n.quay, donBan), http.StatusConflict, "order_transition_not_allowed", "")
	canMa(t, n.roiQuan(t, n.quay, 1<<40), http.StatusNotFound, "sales_order_not_found", "")
}

func TestI012_CuaNgoaiBanCuaNguoiPhaiDungQuay(t *testing.T) {
	n := dungNgoai(t)
	g := n.web(t, dauLanGui(t), lienHeGiao())
	giao := g.so(t, "sales_order_id")
	canDat(t, n.duyet(t, n.quay, giao), http.StatusOK)
	n.dangLam(t, giao)
	truoc := n.anhDon(t, giao) + " | " + n.demTatCa(t)
	for _, nguoi := range []struct {
		id   int64
		code string
		st   int
	}{{n.chu, "not_on_counter_duty", http.StatusForbidden}, {0, "unauthenticated", http.StatusUnauthorized}} {
		canMa(t, n.hotline(t, nguoi.id, dauLanGui(t), lienHeHotlineLay()), nguoi.st, nguoi.code, "")
		canMa(t, n.roiQuan(t, nguoi.id, giao), nguoi.st, nguoi.code, "")
	}
	if sau := n.anhDon(t, giao) + " | " + n.demTatCa(t); sau != truoc {
		t.Fatalf("lời từ chối của quyền mà vẫn ghi: %s → %s", truoc, sau)
	}
	t.Logf("chủ quán không đứng quầy ⇒ not_on_counter_duty, không người ⇒ unauthenticated, ở hotline và rời quán")
}

// --- S-6: quầy bấm "đã ra bàn" của đơn giao LÚC NÀO — chưa có lời, cửa không đoán ----------------

// Cửa rời quán là chỗ suy luận S-6 đặt mốc ấy (shop-facts.md §7.2). Đơn còn việc trạm chưa ra bàn thì
// rời quán buộc cửa phải chọn: tự ghi "đã ra bàn" (đoán S-6) hay để lại (đoán ngược) — cửa từ chối kèm
// mã của chỗ đang mở, không đổi gì.
func TestI016_RoiQuanKhiConViecTramChuaRaBanBiTuChoi(t *testing.T) {
	n := dungNgoai(t)
	for _, ca := range []struct {
		ten  string
		hotl bool
	}{{"giao (web)", false}, {"hotline giao", true}} {
		var r traLoi
		if ca.hotl {
			r = n.hotline(t, n.quay, dauLanGui(t), lienHeHotlineGiao())
			n.denGioLam(t, r.so(t, "sales_order_id")) // T-142: đơn đặt trước nổ ở lần nhắc đầu
		} else {
			r = n.web(t, dauLanGui(t), lienHeGiao())
			canDat(t, n.duyet(t, n.quay, r.so(t, "sales_order_id")), http.StatusOK)
		}
		don := r.so(t, "sales_order_id")
		// P3-10 đổi có chủ ý (ADR-090 điểm 1): đơn đã nổ, nước chấm là việc của chính lần nổ.
		viec := n.id(t, `SELECT id FROM shop.station_job WHERE sales_order_id = $1 AND order_line_id IS NULL`, don)
		truoc := n.anhDon(t, don) + " | " + n.docChu(t, "SELECT status FROM shop.station_job WHERE id = $1", viec)
		canMa(t, n.roiQuan(t, n.quay, don), http.StatusConflict, "delivery_served_mark_undecided", "")
		if sau := n.anhDon(t, don) + " | " + n.docChu(t, "SELECT status FROM shop.station_job WHERE id = $1", viec); sau != truoc {
			t.Fatalf("%s: lời từ chối S-6 mà vẫn đổi: %s → %s", ca.ten, truoc, sau)
		}
		t.Logf("%s %d đang làm, việc nước chấm %d chưa ra bàn ⇒ delivery_served_mark_undecided; %s", ca.ten, don, viec, truoc)
	}
}

// Mọi đường gọi của lát có thật trên mux: một 404/405 KHÔNG mang mã là đường thiếu.
func TestQC12_DuongGoiCuaLuongNgoaiBan(t *testing.T) {
	c := dungBan(t)
	var thieu []string
	for _, p := range []struct{ method, path string }{
		{"POST", "/online-orders"}, {"POST", "/phone-orders"}, {"POST", "/orders/1/departure"},
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
