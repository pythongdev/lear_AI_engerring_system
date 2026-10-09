// Test đường tiền qua cửa (P3-09, ADR-089; I-005 · I-012 · I-014 · I-015 · I-021 · YC-01 · YC-10 ·
// YC-23). Viết TRƯỚC khi có cửa — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào.
// Mọi lời gọi đi qua ĐƯỜNG GỌI HTTP của hợp đồng (ADR-082 điểm 2); database được đọc lại bằng kết nối
// chủ lược đồ sau mỗi lời từ chối.
//
// Ngày bán: mọi cửa tiền ghi booked_at và sale_date từ ngayban.DongHo (ADR-089 điểm 3). Mỗi test dùng
// một ngày riêng của tháng 3/2031 theo múi giờ của quán, nên số đếm, tiền đầu két và dấu đối soát của
// test này không chạm ngày của test khác. Cửa tạo đơn đọc cùng mốc qua don.DongHo.
//
// Ba thứ dựng tay bằng kết nối chủ lược đồ vì cửa của chúng thuộc chỗ khác: đơn tới Hoàn thành hay Đang
// thực hiện và việc trạm (P3-10), lượt sổ giấy (P3-11), khoản tạm ứng (lane admin). Một lần thu ghi nhầm
// phương thức là LỖI CÀI có chủ ý — đối soát phải kêu.
package don_test

import (
	"context"
	"fmt"
	"net/http"
	"os/exec"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"banhcuon/be/internal/dbtest"
	"banhcuon/be/internal/ngayban"
	"github.com/jackc/pgx/v5"
)

// --- khung --------------------------------------------------------------------------------------

type tien struct{ ngoai }

func dungTien(t *testing.T) tien {
	t.Helper()
	return tien{dungNgoai(t)}
}

// moc: 07:00 (giờ mở + 1 giờ) ngày `ngay` của tháng 3/2031 theo múi giờ của quán.
func (n tien) moc(ngay int) time.Time {
	return time.Date(2031, 3, ngay, 0, 0, 0, 0, n.loc).Add(n.gioMo + time.Hour)
}

func ngayChu(ngay int) string { return fmt.Sprintf("2031-03-%02d", ngay) }

// datNgay: từ đây tới hết test, mọi cửa tiền và cửa tạo đơn đọc mốc của ngày ấy.
func (n tien) datNgay(t *testing.T, ngay int) time.Time {
	t.Helper()
	moc := n.moc(ngay)
	goc := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil }
	t.Cleanup(func() { ngayban.DongHo = goc })
	datDongHo(t, moc)
	return moc
}

func nghin(x int64) int64 { return x / 1000 * 1000 }

func thu(tienMat, chuyenKhoan int64) map[string]any {
	return map[string]any{"cash_vnd": tienMat, "transfer_vnd": chuyenKhoan}
}

func voi(body map[string]any, them map[string]any) map[string]any {
	out := map[string]any{}
	for k, v := range body {
		out[k] = v
	}
	for k, v := range them {
		out[k] = v
	}
	return out
}

// --- đơn và phiên đi tới chỗ cần thu --------------------------------------------------------------

// donLay: đơn hotline khách tới quán lấy — Đã xác nhận. Trả mã đơn và tổng.
func (n tien) donLay(t *testing.T) (int64, int64) {
	t.Helper()
	r := n.hotline(t, n.quay, dauLanGui(t), lienHeHotlineLay())
	canDat(t, r, http.StatusCreated)
	return r.so(t, "sales_order_id"), r.so(t, "total_vnd")
}

// donGiao: đơn hotline giao tận nơi đã rời quán — Đang giao.
func (n tien) donGiao(t *testing.T) (int64, int64) {
	t.Helper()
	r := n.hotline(t, n.quay, dauLanGui(t), lienHeHotlineGiao())
	canDat(t, r, http.StatusCreated)
	don := r.so(t, "sales_order_id")
	n.dangLam(t, don)
	canDat(t, n.roiQuan(t, n.quay, don), http.StatusOK)
	return don, r.so(t, "total_vnd")
}

var soBan atomic.Int64

// banTien: tên bàn chưa dùng — một test dựng nhiều phiên, nhãn bàn là khoá duy nhất.
func banTien() string { return fmt.Sprintf("bàn tiền %d", soBan.Add(1)) }

// phienDaTinh: một bàn mới, một lượt đặt hộ đã ra hết, đã tính tiền — Chờ thanh toán. Trả phiên, tổng.
func (n tien) phienDaTinh(t *testing.T) (int64, int64) {
	t.Helper()
	_, phien, don, tong := n.phienDangPhucVu(t, banTien())
	n.xong(t, don)
	canDat(t, n.tinhTien(t, n.quay, phien), http.StatusOK)
	return phien, tong
}

// hoaDonBan: phiên mới đóng bằng tiền mặt đủ; trả mã hoá đơn và tổng.
func (n tien) hoaDonBan(t *testing.T) (int64, int64) {
	t.Helper()
	phien, tong := n.phienDaTinh(t)
	r := n.dongPhien(t, n.quay, phien, tong, 0, 0, "")
	canDat(t, r, http.StatusCreated)
	return r.so(t, "bill_id"), tong
}

// --- đường gọi của lát -------------------------------------------------------------------------

func (n tien) traoTaiQuay(t *testing.T, nguoi, don int64, body map[string]any) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/orders/%d/handover", don), nguoi, body)
}

func (n tien) giaoXong(t *testing.T, nguoi, don int64, body map[string]any) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/orders/%d/delivered", don), nguoi, body)
}

func (n tien) nhanTraTruoc(t *testing.T, nguoi, don, tienMat, chuyenKhoan int64) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/orders/%d/prepayment", don), nguoi, thu(tienMat, chuyenKhoan))
}

func (n tien) traLai(t *testing.T, nguoi, khoan int64, phuongThuc string, layTienMat, layChuyenKhoan int64, lyDo string) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/prepayments/%d/returns", khoan), nguoi, map[string]any{
		"method_code": phuongThuc, "take_cash_vnd": layTienMat, "take_transfer_vnd": layChuyenKhoan, "reason": lyDo})
}

func (n tien) hoan(t *testing.T, nguoi, hoaDon, soTien int64, traBang, daThuBang, lyDo string) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/bills/%d/refunds", hoaDon), nguoi, map[string]any{
		"amount_vnd": soTien, "method_code": traBang, "source_method_code": daThuBang, "reason": lyDo})
}

func (n tien) thuNo(t *testing.T, nguoi, hoaDon, tienMat, chuyenKhoan int64) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/bills/%d/debt-collections", hoaDon), nguoi, thu(tienMat, chuyenKhoan))
}

type xap struct{ menhGia, soTien int64 }

func cacXap(ds []xap) map[string]any {
	lines := make([]any, len(ds))
	for i, x := range ds {
		lines[i] = map[string]any{"denomination_vnd": x.menhGia, "amount_vnd": x.soTien}
	}
	return map[string]any{"lines": lines}
}

// dauKetMau: tiền lẻ chủ quán bỏ vào két (shop-facts.md §8.5) — tổng 1.200.000 là phép cộng của test.
func dauKetMau() []xap {
	return []xap{{50000, 500000}, {20000, 400000}, {10000, 100000}, {5000, 100000}, {2000, 60000}, {1000, 40000}}
}

func (n tien) khaiDauKet(t *testing.T, nguoi int64, ds []xap) traLoi {
	t.Helper()
	return n.post(t, "/opening-floats", nguoi, cacXap(ds))
}

func (n tien) demKet(t *testing.T, nguoi int64, ds []xap) traLoi {
	t.Helper()
	return n.post(t, "/cash-counts", nguoi, cacXap(ds))
}

func (n tien) doiSoatXong(t *testing.T, nguoi int64, ngay int) traLoi {
	t.Helper()
	return n.post(t, fmt.Sprintf("/sale-days/%s/reconciliation", ngayChu(ngay)), nguoi, map[string]any{})
}

func (n tien) docDoiSoat(t *testing.T, nguoi int64, ngay int) traLoi {
	t.Helper()
	status, out := n.goi(t, "GET", fmt.Sprintf("/sale-days/%s/cash-reconciliation", ngayChu(ngay)), nguoi, nil)
	return traLoi{status, out}
}

// demTien: số dòng mọi bảng tiền — một lời từ chối không được đổi con số nào.
func (n tien) demTien(t *testing.T) string {
	t.Helper()
	return n.docChu(t, `SELECT format('%s hoá đơn · %s thu nợ · %s trả trước · %s mắt · %s hoàn · %s đầu két/%s · %s đếm/%s · %s dấu · %s đơn xong',
		(SELECT count(*) FROM shop.bill), (SELECT count(*) FROM shop.debt_collection),
		(SELECT count(*) FROM shop.prepayment), (SELECT count(*) FROM shop.prepayment_use),
		(SELECT count(*) FROM shop.refund), (SELECT count(*) FROM shop.opening_float),
		(SELECT count(*) FROM shop.opening_float_line), (SELECT count(*) FROM shop.cash_count),
		(SELECT count(*) FROM shop.cash_count_line), (SELECT count(*) FROM shop.reconciled_day),
		(SELECT count(*) FROM shop.sales_order WHERE status = 'completed'))`)
}

func (n tien) khongDoi(t *testing.T, truoc string, viec string) {
	t.Helper()
	if sau := n.demTien(t); sau != truoc {
		t.Fatalf("%s bị từ chối mà vẫn ghi: %s → %s", viec, truoc, sau)
	}
}

// anhHoaDon: một hoá đơn đọc lại — đơn vị, các phần, người bấm, ngày bán, mốc.
func (n tien) anhHoaDon(t *testing.T, hd int64) string {
	t.Helper()
	return n.docChu(t, `SELECT format('phiên=%s đơn=%s phải=%s mặt=%s ck=%s ttmặt=%s ttck=%s nợ=%s người=%s ngày=%s lúc=%s',
		coalesce(table_session_id::text, '-'), coalesce(sales_order_id::text, '-'), due_vnd, cash_vnd, transfer_vnd,
		prepaid_cash_vnd, prepaid_transfer_vnd, debt_vnd, person_id, sale_date, extract(epoch FROM booked_at)::bigint)
		FROM shop.bill WHERE id = $1`, hd)
}

func (n tien) canHoaDon(t *testing.T, hd int64, muon string) {
	t.Helper()
	if co := n.anhHoaDon(t, hd); co != muon {
		t.Fatalf("hoá đơn %d:\n muốn %s\n có   %s", hd, muon, co)
	}
}

// ketNgayDoiChieu: phép trừ két của ngày ấy theo BỘ ĐỐI CHIẾU của P2-11 — prelude đọc lúc chạy từ
// scripts/reconcile.sh --emit-prelude, hàm tạm pg_temp.ket_ngay, trên một kết nối chủ lược đồ riêng.
func (n tien) ketNgayDoiChieu(t *testing.T, ngay int) (demDuoc, dauKet, vePhai int64, choU072 bool) {
	t.Helper()
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command("./scripts/reconcile.sh", "--emit-prelude")
	cmd.Dir = strings.TrimSpace(string(goc))
	prelude, err := cmd.Output()
	if err != nil {
		t.Fatalf("reconcile.sh --emit-prelude: %v", err)
	}
	conn, err := pgx.Connect(n.ctx, dbtest.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(context.Background())
	if _, err := conn.Exec(n.ctx, "SET search_path TO shop, public"); err != nil {
		t.Fatal(err)
	}
	if _, err := conn.Exec(n.ctx, string(prelude)); err != nil {
		t.Fatalf("nạp prelude của bộ đối chiếu: %v", err)
	}
	if err := conn.QueryRow(n.ctx, `SELECT dem_duoc, dau_ket, ve_phai, cho_u072 FROM pg_temp.ket_ngay($1)
		WHERE ngay = $2::date`, dbtest.ShopTZ(t), ngayChu(ngay)).Scan(&demDuoc, &dauKet, &vePhai, &choU072); err != nil {
		t.Fatalf("ket_ngay ngày %s: %v", ngayChu(ngay), err)
	}
	return
}

// --- hoá đơn đơn lẻ: trao tại quầy (I-015 · I-007 · I-014) ---------------------------------------

func TestI015_TraoTaiQuayGhiHoaDonDonLe(t *testing.T) {
	n := dungTien(t)
	moc := n.datNgay(t, 2)
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)
	d, tong := n.donLay(t)
	if tong < 2000 {
		t.Fatalf("tổng đơn %d quá nhỏ cho test", tong)
	}

	// Đã xác nhận chưa tới Đang thực hiện: không có dòng Đã xác nhận → Hoàn thành ở §5.2.
	truoc := n.demTien(t)
	canMa(t, n.traoTaiQuay(t, n.quay, d, thu(tong, 0)), http.StatusConflict, "order_transition_not_allowed", "")
	n.khongDoi(t, truoc, "trao đơn chưa làm")
	n.dangLam(t, d)

	canMa(t, n.traoTaiQuay(t, n.quay, d, map[string]any{"transfer_vnd": tong}), http.StatusBadRequest, "invalid_request", "cash_vnd")
	canMa(t, n.traoTaiQuay(t, n.quay, d, thu(-1, tong+1)), http.StatusBadRequest, "invalid_request", "cash_vnd")
	canMa(t, n.traoTaiQuay(t, n.quay, d, thu(tong-1000, 0)), http.StatusUnprocessableEntity, "payment_parts_mismatch", "")
	canMa(t, n.traoTaiQuay(t, n.quay, d, thu(tong, 1000)), http.StatusUnprocessableEntity, "payment_parts_mismatch", "")
	canMa(t, n.traoTaiQuay(t, khac, d, thu(tong, 0)), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.traoTaiQuay(t, 0, d, thu(tong, 0)), http.StatusUnauthorized, "unauthenticated", "")
	canMa(t, n.traoTaiQuay(t, n.quay, 999999999, thu(tong, 0)), http.StatusNotFound, "sales_order_not_found", "")
	_, _, donBan, tongBan := n.phienDangPhucVu(t, banTien())
	n.dangLam(t, donBan)
	canMa(t, n.traoTaiQuay(t, n.quay, donBan, thu(tongBan, 0)), http.StatusConflict, "order_handover_mismatch", "")
	n.khongDoi(t, truoc, "trao tại quầy sai")
	if s := n.trangThaiDon(t, d); s != "in_progress" {
		t.Fatalf("đơn bị từ chối mà đổi trạng thái: %s", s)
	}

	tm := nghin(tong / 2)
	r := n.traoTaiQuay(t, n.quay, d, thu(tm, tong-tm))
	canDat(t, r, http.StatusCreated)
	if r.so(t, "sales_order_id") != d || r.so(t, "due_vnd") != tong || r.chu("status") != "completed" {
		t.Fatalf("trao tại quầy: %v", r.body)
	}
	hd := r.so(t, "bill_id")
	n.canHoaDon(t, hd, fmt.Sprintf("phiên=- đơn=%d phải=%d mặt=%d ck=%d ttmặt=0 ttck=0 nợ=0 người=%d ngày=%s lúc=%d",
		d, tong, tm, tong-tm, n.quay, ngayChu(2), moc.Unix()))
	if s := n.trangThaiDon(t, d); s != "completed" {
		t.Fatalf("đơn sau khi trao: %s", s)
	}
	t.Logf("đơn %d trao tại quầy ⇒ %s", d, n.anhHoaDon(t, hd))

	truoc = n.demTien(t)
	canMa(t, n.traoTaiQuay(t, n.quay, d, thu(tong, 0)), http.StatusConflict, "order_transition_not_allowed", "")
	n.khongDoi(t, truoc, "trao lần hai")
}

// --- hoá đơn đơn lẻ: người đi giao bấm đã giao + đã thu tiền (I-012 ca có tên) --------------------

func TestI012_GiaoXongDoNguoiDiGiaoBam(t *testing.T) {
	n := dungTien(t)
	moc := n.datNgay(t, 3)
	giao := n.nguoi(t, "người đi giao", false) // không đứng quầy, không là chủ quán
	dG, tongG := n.donGiao(t)
	dL, tongL := n.donLay(t)
	n.dangLam(t, dL)

	truoc := n.demTien(t)
	canMa(t, n.giaoXong(t, giao, dL, thu(tongL, 0)), http.StatusConflict, "order_handover_mismatch", "")
	canMa(t, n.traoTaiQuay(t, n.quay, dG, thu(tongG, 0)), http.StatusConflict, "order_handover_mismatch", "")
	canMa(t, n.giaoXong(t, 0, dG, thu(tongG, 0)), http.StatusUnauthorized, "unauthenticated", "")
	canMa(t, n.giaoXong(t, giao, dG, thu(0, tongG-1000)), http.StatusUnprocessableEntity, "payment_parts_mismatch", "")
	n.khongDoi(t, truoc, "giao xong sai")

	r := n.giaoXong(t, giao, dG, thu(0, tongG))
	canDat(t, r, http.StatusCreated)
	hd := r.so(t, "bill_id")
	n.canHoaDon(t, hd, fmt.Sprintf("phiên=- đơn=%d phải=%d mặt=0 ck=%d ttmặt=0 ttck=0 nợ=0 người=%d ngày=%s lúc=%d",
		dG, tongG, tongG, giao, ngayChu(3), moc.Unix()))
	if s := n.trangThaiDon(t, dG); s != "completed" {
		t.Fatalf("đơn giao sau khi giao xong: %s", s)
	}
	t.Logf("người đi giao %d bấm đã giao + đã thu ⇒ %s", giao, n.anhHoaDon(t, hd))
}

// §5.2 dòng Đang thực hiện → Hoàn thành: mọi việc trạm phải ra tới tay khách.
func TestI016_TraoTaiQuayKhiConViecChuaRaBanBiTuChoi(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 4)
	d, tong := n.donLay(t)
	n.dangLam(t, d)
	n.id(t, `INSERT INTO shop.station_job (sales_order_id, station_code, position) VALUES ($1, 'canh', 1) RETURNING id`, d)
	truoc := n.demTien(t)
	canMa(t, n.traoTaiQuay(t, n.quay, d, thu(tong, 0)), http.StatusConflict, "order_jobs_not_served", "")
	n.khongDoi(t, truoc, "trao khi còn việc trạm")
	if s := n.trangThaiDon(t, d); s != "in_progress" {
		t.Fatalf("đơn đổi trạng thái: %s", s)
	}
}

// --- hai thao tác chờ lời chủ quán: từ chối kèm mã, không ghi gì --------------------------------

func TestI015_GiamGiaCaDonBiTuChoiChoU058(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 5)
	giao := n.nguoi(t, "người đi giao", false)
	dL, tongL := n.donLay(t)
	n.dangLam(t, dL)
	dG, tongG := n.donGiao(t)
	phien, tongP := n.phienDaTinh(t)

	truoc := n.demTien(t)
	giam := map[string]any{"discount_vnd": 1000} // đơn mẫu của §4.8 chỉ vài nghìn đồng
	canMa(t, n.traoTaiQuay(t, n.quay, dL, voi(thu(tongL-1000, 0), giam)), http.StatusConflict, "order_discount_undecided", "")
	canMa(t, n.giaoXong(t, giao, dG, voi(thu(tongG-1000, 0), giam)), http.StatusConflict, "order_discount_undecided", "")
	canMa(t, n.post(t, fmt.Sprintf("/table-sessions/%d/closing", phien), n.quay,
		voi(map[string]any{"cash_vnd": tongP - 1000, "transfer_vnd": 0, "debt_vnd": 0}, giam)),
		http.StatusConflict, "order_discount_undecided", "")
	n.khongDoi(t, truoc, "giảm giá")
	if n.trangThaiPhien(t, phien) != "awaiting_payment" || n.trangThaiDon(t, dL) != "in_progress" || n.trangThaiDon(t, dG) != "delivering" {
		t.Fatal("lời từ chối giảm giá mà đổi trạng thái")
	}
	// Không giảm (0) là không có gì chờ lời.
	canDat(t, n.traoTaiQuay(t, n.quay, dL, voi(thu(tongL, 0), map[string]any{"discount_vnd": 0})), http.StatusCreated)
}

func TestI005_NoTrenDonLeBiTuChoiChoU076(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 6)
	giao := n.nguoi(t, "người đi giao", false)
	dL, tongL := n.donLay(t)
	n.dangLam(t, dL)
	dG, tongG := n.donGiao(t)
	truoc := n.demTien(t)
	no := func(tong int64) map[string]any {
		return voi(thu(tong-1000, 0), map[string]any{"debt_vnd": 1000, "debtor_name": "anh Sáu"})
	}
	canMa(t, n.traoTaiQuay(t, n.quay, dL, no(tongL)), http.StatusConflict, "standalone_debt_undecided", "")
	canMa(t, n.giaoXong(t, giao, dG, no(tongG)), http.StatusConflict, "standalone_debt_undecided", "")
	n.khongDoi(t, truoc, "nợ trên đơn lẻ")
}

// --- trả trước: nhận, trả lại, thành doanh thu qua hoá đơn của chính đơn (YC-23 · I-014) -----------

func TestYC23_TraTruocNhanTraLaiVaDungChoHoaDon(t *testing.T) {
	n := dungTien(t)
	moc := n.datNgay(t, 7)
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)
	d, tong := n.donLay(t)
	tt := nghin(tong / 2)
	if tt < 2000 {
		t.Fatalf("tổng đơn %d quá nhỏ cho test", tong)
	}

	truoc := n.demTien(t)
	canMa(t, n.nhanTraTruoc(t, khac, d, 0, tt), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.nhanTraTruoc(t, 0, d, 0, tt), http.StatusUnauthorized, "unauthenticated", "")
	canMa(t, n.nhanTraTruoc(t, n.quay, 999999999, 0, tt), http.StatusNotFound, "sales_order_not_found", "")
	_, _, donBan, _ := n.phienDangPhucVu(t, banTien())
	canMa(t, n.nhanTraTruoc(t, n.quay, donBan, 0, tt), http.StatusConflict, "order_not_prepayable", "")
	n.khongDoi(t, truoc, "nhận trả trước sai")

	r := n.nhanTraTruoc(t, n.quay, d, 0, tt)
	canDat(t, r, http.StatusCreated)
	kt := r.so(t, "prepayment_id")
	if got := n.docChu(t, `SELECT format('đơn=%s mặt=%s ck=%s người=%s ngày=%s lúc=%s', sales_order_id, cash_vnd,
		transfer_vnd, person_id, sale_date, extract(epoch FROM booked_at)::bigint) FROM shop.prepayment WHERE id = $1`, kt); got !=
		fmt.Sprintf("đơn=%d mặt=0 ck=%d người=%d ngày=%s lúc=%d", d, tt, n.quay, ngayChu(7), moc.Unix()) {
		t.Fatalf("khoản trả trước: %s", got)
	}
	truoc = n.demTien(t)
	canMa(t, n.nhanTraTruoc(t, n.quay, d, 1000, 0), http.StatusConflict, "prepayment_already_received", "")

	// Trả lại phần chưa thành doanh thu: lý do bắt buộc, phương thức trong hai, không quá số dư.
	canMa(t, n.traLai(t, n.quay, kt, "cash", 0, 1000, "  "), http.StatusBadRequest, "invalid_request", "reason")
	canMa(t, n.traLai(t, n.quay, kt, "the", 0, 1000, "khách bớt món"), http.StatusBadRequest, "invalid_request", "method_code")
	canMa(t, n.traLai(t, n.quay, kt, "cash", 0, tt+1000, "khách bớt món"), http.StatusConflict, "prepayment_balance_exceeded", "")
	canMa(t, n.traLai(t, n.quay, kt, "cash", 1000, 0, "khách bớt món"), http.StatusConflict, "prepayment_balance_exceeded", "")
	canMa(t, n.traLai(t, khac, kt, "cash", 0, 1000, "khách bớt món"), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.traLai(t, n.quay, 999999999, "cash", 0, 1000, "khách bớt món"), http.StatusNotFound, "prepayment_not_found", "")
	n.khongDoi(t, truoc, "trả lại sai")

	r = n.traLai(t, n.quay, kt, "cash", 0, 1000, "khách bớt một món")
	canDat(t, r, http.StatusCreated)
	if got := n.docChu(t, `SELECT format('khoản=%s hđ=%s %s/%s %s người=%s ngày=%s | mắt %s lấy ck %s còn ck %s',
		r.prepayment_id, coalesce(r.bill_id::text, '-'), r.method_code, coalesce(r.source_method_code, '-'), r.amount_vnd,
		r.person_id, r.sale_date, u.use_no, u.take_transfer_vnd, u.transfer_after_vnd)
		FROM shop.refund r JOIN shop.prepayment_use u ON u.refund_id = r.id WHERE r.id = $1`, r.so(t, "refund_id")); got !=
		fmt.Sprintf("khoản=%d hđ=- cash/- 1000 người=%d ngày=%s | mắt 1 lấy ck 1000 còn ck %d", kt, n.quay, ngayChu(7), tt-1000) {
		t.Fatalf("lần trả lại: %s", got)
	}

	// Phần còn lại thành doanh thu qua hoá đơn của chính đơn — không quá số dư.
	n.dangLam(t, d)
	truoc = n.demTien(t)
	canMa(t, n.traoTaiQuay(t, n.quay, d, voi(thu(tong-tt, 0), map[string]any{"prepaid_transfer_vnd": tt})),
		http.StatusConflict, "prepayment_balance_exceeded", "")
	n.khongDoi(t, truoc, "dùng trả trước quá số dư")
	r = n.traoTaiQuay(t, n.quay, d, voi(thu(tong-(tt-1000), 0), map[string]any{"prepaid_transfer_vnd": tt - 1000}))
	canDat(t, r, http.StatusCreated)
	hd := r.so(t, "bill_id")
	n.canHoaDon(t, hd, fmt.Sprintf("phiên=- đơn=%d phải=%d mặt=%d ck=0 ttmặt=0 ttck=%d nợ=0 người=%d ngày=%s lúc=%d",
		d, tong, tong-(tt-1000), tt-1000, n.quay, ngayChu(7), moc.Unix()))
	if got := n.docChu(t, `SELECT format('mắt %s lấy ck %s còn ck %s', use_no, take_transfer_vnd, transfer_after_vnd)
		FROM shop.prepayment_use WHERE bill_id = $1`, hd); got != "mắt 2 lấy ck "+fmt.Sprint(tt-1000)+" còn ck 0" {
		t.Fatalf("mắt chuỗi của hoá đơn: %s", got)
	}

	// Đơn đã xong thì không nhận trả trước nữa.
	dX, tongX := n.donLay(t)
	n.dangLam(t, dX)
	canDat(t, n.traoTaiQuay(t, n.quay, dX, thu(tongX, 0)), http.StatusCreated)
	canMa(t, n.nhanTraTruoc(t, n.quay, dX, tongX, 0), http.StatusConflict, "order_not_prepayable", "")
}

// --- thu nợ dần theo chuỗi ADR-075; một lần trả không là một lần bán (YC-10 · I-014) ---------------

func TestYC10_ThuNoDanQuaCua(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 9)
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)
	phien, tong := n.phienDaTinh(t)
	if tong < 4000 {
		t.Fatalf("tổng phiên %d quá nhỏ cho test", tong)
	}
	r := n.dongPhien(t, n.quay, phien, 1000, 0, tong-1000, "anh Năm")
	canDat(t, r, http.StatusCreated)
	hd := r.so(t, "bill_id")
	hdDu, _ := n.hoaDonBan(t)

	conNo := func() (int64, bool) {
		status, out := n.goi(t, "GET", "/debts", n.quay, nil)
		if status != http.StatusOK {
			t.Fatalf("GET /debts: %d %v", status, out)
		}
		ds, _ := out["debts"].([]any)
		for _, x := range ds {
			m, _ := x.(map[string]any)
			if id, _ := m["bill_id"].(float64); int64(id) == hd {
				ten, _ := m["debtor_name"].(string)
				no, _ := m["debt_vnd"].(float64)
				if ten != "anh Năm" || int64(no) != tong-1000 {
					t.Fatalf("dòng nợ: %v", m)
				}
				con, _ := m["remaining_vnd"].(float64)
				return int64(con), true
			}
		}
		return 0, false
	}
	if con, co := conNo(); !co || con != tong-1000 {
		t.Fatalf("nợ mới ghi phải nằm trong danh sách, còn %d: %v %v", tong-1000, con, co)
	}

	soHoaDon := n.docSo(t, "SELECT count(*) FROM shop.bill")
	truoc := n.demTien(t)
	canMa(t, n.thuNo(t, n.quay, hdDu, 1000, 0), http.StatusConflict, "bill_has_no_debt", "")
	canMa(t, n.thuNo(t, n.quay, hd, 0, 0), http.StatusBadRequest, "invalid_request", "")
	canMa(t, n.thuNo(t, n.quay, hd, tong, 0), http.StatusConflict, "debt_overpaid", "")
	canMa(t, n.thuNo(t, khac, hd, 1000, 0), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.thuNo(t, n.quay, 999999999, 1000, 0), http.StatusNotFound, "bill_not_found", "")
	n.khongDoi(t, truoc, "thu nợ sai")

	// Hôm sau khách trả một phần, rồi trả nốt.
	moc := n.datNgay(t, 10)
	r = n.thuNo(t, n.quay, hd, 1000, 0)
	canDat(t, r, http.StatusCreated)
	if r.so(t, "remaining_vnd") != tong-2000 {
		t.Fatalf("lần trả đầu: %v", r.body)
	}
	if got := n.docChu(t, `SELECT format('trước=%s sau=%s mặt=%s ck=%s người=%s ngày=%s lúc=%s',
		coalesce(remaining_before_vnd::text, '-'), remaining_vnd, cash_vnd, transfer_vnd, person_id, sale_date,
		extract(epoch FROM booked_at)::bigint) FROM shop.debt_collection WHERE id = $1`, r.so(t, "debt_collection_id")); got !=
		fmt.Sprintf("trước=- sau=%d mặt=1000 ck=0 người=%d ngày=%s lúc=%d", tong-2000, n.quay, ngayChu(10), moc.Unix()) {
		t.Fatalf("lần trả đầu đọc lại: %s", got)
	}
	if con, co := conNo(); !co || con != tong-2000 {
		t.Fatalf("còn nợ sau lần đầu: %d %v", con, co)
	}
	r = n.thuNo(t, n.quay, hd, 1000, tong-3000)
	canDat(t, r, http.StatusCreated)
	if r.so(t, "remaining_vnd") != 0 {
		t.Fatalf("trả nốt: %v", r.body)
	}
	if _, co := conNo(); co {
		t.Fatal("nợ đã trả xong mà vẫn nằm trong danh sách nợ chưa thu")
	}
	truoc = n.demTien(t)
	canMa(t, n.thuNo(t, n.quay, hd, 1000, 0), http.StatusConflict, "debt_already_settled", "")
	n.khongDoi(t, truoc, "thu nợ đã xong")

	if got := n.docSo(t, "SELECT count(*) FROM shop.bill"); got != soHoaDon {
		t.Fatalf("thu nợ sinh hoá đơn mới: %d → %d (YC-10)", soHoaDon, got)
	}
	if got := n.docSo(t, "SELECT coalesce(sum(due_vnd), 0) FROM shop.bill WHERE sale_date = $1::date", ngayChu(10)); got != 0 {
		t.Fatalf("doanh thu ngày thu nợ phải 0, có %d", got)
	}
}

// --- hoàn tiền có đủ vết (YC-01 · I-012 tập 4) ----------------------------------------------------

func TestYC01_HoanTienCoDuVet(t *testing.T) {
	n := dungTien(t)
	moc := n.datNgay(t, 11)
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)
	hd, _ := n.hoaDonBan(t)

	truoc := n.demTien(t)
	canMa(t, n.hoan(t, n.quay, hd, 2000, "transfer", "cash", ""), http.StatusBadRequest, "invalid_request", "reason")
	canMa(t, n.hoan(t, n.quay, hd, 2000, "transfer", "cash", "   "), http.StatusBadRequest, "invalid_request", "reason")
	canMa(t, n.hoan(t, n.quay, hd, 2000, "the", "cash", "khách chê nguội"), http.StatusBadRequest, "invalid_request", "method_code")
	canMa(t, n.hoan(t, n.quay, hd, 2000, "cash", "x", "khách chê nguội"), http.StatusBadRequest, "invalid_request", "source_method_code")
	canMa(t, n.hoan(t, n.quay, hd, 0, "cash", "cash", "khách chê nguội"), http.StatusBadRequest, "invalid_request", "amount_vnd")
	canMa(t, n.hoan(t, khac, hd, 2000, "cash", "cash", "khách chê nguội"), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.hoan(t, 0, hd, 2000, "cash", "cash", "khách chê nguội"), http.StatusUnauthorized, "unauthenticated", "")
	canMa(t, n.hoan(t, n.quay, 999999999, 2000, "cash", "cash", "khách chê nguội"), http.StatusNotFound, "bill_not_found", "")
	n.khongDoi(t, truoc, "hoàn sai")

	r := n.hoan(t, n.quay, hd, 2000, "transfer", "cash", "khách chê nguội")
	canDat(t, r, http.StatusCreated)
	if got := n.docChu(t, `SELECT format('hđ=%s %s/%s %s lý do=%s người=%s ngày=%s lúc=%s', bill_id, method_code,
		source_method_code, amount_vnd, reason, person_id, sale_date, extract(epoch FROM booked_at)::bigint)
		FROM shop.refund WHERE id = $1`, r.so(t, "refund_id")); got !=
		fmt.Sprintf("hđ=%d transfer/cash 2000 lý do=khách chê nguội người=%d ngày=%s lúc=%d", hd, n.quay, ngayChu(11), moc.Unix()) {
		t.Fatalf("vết hoàn: %s", got)
	}
}

// --- tiền đầu két và số đếm: bảng mệnh giá, một lần mỗi ngày, quầy hoặc chủ quán (I-021) ----------

func TestI021_TienDauKetVaSoDemKet(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 12)
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)

	truoc := n.demTien(t)
	canMa(t, n.khaiDauKet(t, n.quay, []xap{{50000, 30000}}), http.StatusBadRequest, "invalid_request", "lines[0].amount_vnd")
	canMa(t, n.khaiDauKet(t, n.quay, []xap{}), http.StatusBadRequest, "invalid_request", "lines")
	canMa(t, n.khaiDauKet(t, khac, dauKetMau()), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.khaiDauKet(t, 0, dauKetMau()), http.StatusUnauthorized, "unauthenticated", "")
	canMa(t, n.demKet(t, khac, dauKetMau()), http.StatusForbidden, "not_on_counter_duty", "")
	n.khongDoi(t, truoc, "khai két sai")

	// Chủ quán không đứng quầy vẫn khai được (shop-facts.md §6.27 · §8.5).
	r := n.khaiDauKet(t, n.chu, dauKetMau())
	canDat(t, r, http.StatusCreated)
	if r.so(t, "total_vnd") != 1200000 || r.chu("sale_date") != ngayChu(12) {
		t.Fatalf("tiền đầu két: %v", r.body)
	}
	if got := n.docChu(t, `SELECT format('ngày=%s người=%s xấp=%s tổng=%s', f.sale_date, f.person_id,
		(SELECT count(*) FROM shop.opening_float_line x WHERE x.opening_float_id = f.id),
		(SELECT sum(amount_vnd) FROM shop.opening_float_line x WHERE x.opening_float_id = f.id))
		FROM shop.opening_float f WHERE f.id = $1`, r.so(t, "opening_float_id")); got !=
		fmt.Sprintf("ngày=%s người=%d xấp=6 tổng=1200000", ngayChu(12), n.chu) {
		t.Fatalf("tiền đầu két đọc lại: %s", got)
	}
	truoc = n.demTien(t)
	canMa(t, n.khaiDauKet(t, n.quay, dauKetMau()), http.StatusConflict, "opening_float_already_declared", "")
	n.khongDoi(t, truoc, "khai đầu két lần hai")

	r = n.demKet(t, n.quay, dauKetMau())
	canDat(t, r, http.StatusCreated)
	if r.so(t, "total_vnd") != 1200000 || r.chu("sale_date") != ngayChu(12) {
		t.Fatalf("số đếm: %v", r.body)
	}
	truoc = n.demTien(t)
	canMa(t, n.demKet(t, n.chu, dauKetMau()), http.StatusConflict, "cash_count_already_recorded", "")
	n.khongDoi(t, truoc, "đếm két lần hai")
}

// --- MỘT NGÀY BÁN GIẢ ĐI HẾT QUA CỬA ⇒ 0đ LỆCH (I-021 · I-005 · I-014 · I-012) -------------------
//
// Mọi hạng tử của architecture.md §6.4 có ít nhất một khoản: hoá đơn tiền mặt, chia hai phương thức,
// ghi nợ, nợ cũ thu được, trả trước nhận trong ngày (đơn đóng cùng ngày và đơn chưa đóng), trả trước
// thành doanh thu, trả lại trả trước, hoàn thường, hoàn chéo hai chiều; hoá đơn của người đi giao.
func TestI021_MotNgayBanGiaQuaCuaRa0dLech(t *testing.T) {
	n := dungTien(t)
	giao := n.nguoi(t, "người đi giao", false)
	const D = 14

	// Ngày D−1: một bàn ghi nợ toàn bộ — khoản nợ cũ để ngày D thu.
	n.datNgay(t, D-1)
	phCu, tongCu := n.phienDaTinh(t)
	r := n.dongPhien(t, n.quay, phCu, 0, 0, tongCu, "anh Ba")
	canDat(t, r, http.StatusCreated)
	hdCu := r.so(t, "bill_id")

	n.datNgay(t, D)
	canDat(t, n.khaiDauKet(t, n.quay, dauKetMau()), http.StatusCreated)

	phA, tongA := n.phienDaTinh(t) // A: tiền mặt đủ
	r = n.dongPhien(t, n.quay, phA, tongA, 0, 0, "")
	canDat(t, r, http.StatusCreated)
	hdA := r.so(t, "bill_id")

	phB, tongB := n.phienDaTinh(t) // B: chia hai phương thức
	tmB := nghin(tongB / 2)
	r = n.dongPhien(t, n.quay, phB, tmB, tongB-tmB, 0, "")
	canDat(t, r, http.StatusCreated)
	hdB := r.so(t, "bill_id")

	phC, tongC := n.phienDaTinh(t) // C: thu 1.000 tiền mặt, nợ phần còn lại
	canDat(t, n.dongPhien(t, n.quay, phC, 1000, 0, tongC-1000, "chị Tư"), http.StatusCreated)

	dP, tongP := n.donLay(t) // P: trả trước nửa đơn bằng tiền mặt, trao tại quầy cùng ngày
	ttP := nghin(tongP / 2)
	canDat(t, n.nhanTraTruoc(t, n.quay, dP, ttP, 0), http.StatusCreated)
	n.dangLam(t, dP)
	canDat(t, n.traoTaiQuay(t, n.quay, dP, voi(thu(tongP-ttP, 0), map[string]any{"prepaid_cash_vnd": ttP})), http.StatusCreated)

	dG, tongG := n.donGiao(t) // G: người đi giao thu tiền mặt tại chỗ khách
	canDat(t, n.giaoXong(t, giao, dG, thu(tongG, 0)), http.StatusCreated)

	canDat(t, n.thuNo(t, n.quay, hdCu, 1000, 1000), http.StatusCreated) // nợ cũ: 1.000 mặt + 1.000 ck

	dQ, tongQ := n.donLay(t) // Q: trả trước đủ bằng tiền mặt, giao ngày sau
	canDat(t, n.nhanTraTruoc(t, n.quay, dQ, tongQ, 0), http.StatusCreated)

	dR, _ := n.donLay(t) // R: trả trước 3.000 chuyển khoản, quầy trả lại bằng tiền mặt
	r = n.nhanTraTruoc(t, n.quay, dR, 0, 3000)
	canDat(t, r, http.StatusCreated)
	canDat(t, n.traLai(t, n.quay, r.so(t, "prepayment_id"), "cash", 0, 3000, "khách huỷ"), http.StatusCreated)

	canDat(t, n.hoan(t, n.quay, hdA, 1000, "cash", "cash", "thiếu nước chấm"), http.StatusCreated)
	canDat(t, n.hoan(t, n.quay, hdA, 1000, "transfer", "cash", "khách xin chuyển khoản lại"), http.StatusCreated)
	canDat(t, n.hoan(t, n.quay, hdB, 1000, "cash", "transfer", "trả tiền mặt cho phần đã chuyển"), http.StatusCreated)

	// Tiền mặt thật trong két — test tự cộng, không hỏi máy:
	//   + A + phần mặt của B + 1.000 của C + P (trả trước mặt + phần còn lại) + G + 1.000 nợ cũ + Q
	//   − 1.000 hoàn A − 1.000 hoàn chéo B − 3.000 trả lại R   (hoàn chéo của A không làm két đổi)
	const dauKet = 1200000
	dem := int64(dauKet) + tongA + tmB + 1000 + tongP + tongG + 1000 + tongQ - 1000 - 1000 - 3000
	xaps := dauKetMau()
	xaps[len(xaps)-1].soTien += dem - dauKet // dồn phần bán được vào xấp 1.000
	if (dem-dauKet)%1000 != 0 {
		t.Fatalf("tiền bán được %d không chia hết 1.000 — menu đổi?", dem-dauKet)
	}
	canDat(t, n.demKet(t, n.quay, xaps), http.StatusCreated)

	// Cửa đọc phép trừ két: 0đ lệch.
	r = n.docDoiSoat(t, n.quay, D)
	canDat(t, r, http.StatusOK)
	if r.so(t, "counted_vnd") != dem || r.so(t, "opening_float_vnd") != dauKet || r.so(t, "expected_vnd") != dem-dauKet ||
		r.so(t, "gap_vnd") != 0 || r.chu("sale_date") != ngayChu(D) {
		t.Fatalf("đối soát qua cửa: muốn đếm %d, đầu két %d, vế phải %d, lệch 0; nhận %v", dem, dauKet, dem-dauKet, r.body)
	}
	// Bộ đối chiếu của P2-11 ra đúng con số ấy.
	demDC, dauDC, veDC, u072 := n.ketNgayDoiChieu(t, D)
	if u072 || demDC != dem || dauDC != dauKet || veDC != dem-dauKet {
		t.Fatalf("ket_ngay của bộ đối chiếu: đếm %d đầu két %d vế phải %d chờ U-072 %v; cửa nói %d %d %d",
			demDC, dauDC, veDC, u072, dem, dauKet, dem-dauKet)
	}
	t.Logf("ngày %s: két %d − đầu két %d = vế phải %d ⇒ lệch 0 (cửa và bộ đối chiếu)", ngayChu(D), dem, dauKet, veDC)

	// I-012: mọi thao tác chạm tiền của ngày có người, đúng người bấm.
	if sai := n.docChu(t, `SELECT coalesce(string_agg(x, ', '), '') FROM (
		SELECT format('hoá đơn %s người %s', id, person_id) AS x FROM shop.bill WHERE sale_date = $1::date
		   AND person_id IS DISTINCT FROM CASE WHEN sales_order_id = $2::bigint THEN $3::bigint ELSE $4::bigint END
		UNION ALL SELECT format('thu nợ %s', id) FROM shop.debt_collection WHERE sale_date = $1::date AND person_id IS DISTINCT FROM $4::bigint
		UNION ALL SELECT format('trả trước %s', id) FROM shop.prepayment WHERE sale_date = $1::date AND person_id IS DISTINCT FROM $4::bigint
		UNION ALL SELECT format('hoàn %s', id) FROM shop.refund WHERE sale_date = $1::date AND person_id IS DISTINCT FROM $4::bigint) a`,
		ngayChu(D), dG, giao, n.quay); sai != "" {
		t.Fatalf("thao tác chạm tiền sai người bấm: %s", sai)
	}
	// I-014 · YC-10 · YC-23: doanh thu ngày D = năm hoá đơn − ba lần hoàn cho hoá đơn; thu nợ và trả trước
	// chưa thành doanh thu (Q, R) không vào.
	doanhThu := tongA + tongB + tongC + tongP + tongG - 3000
	if got := n.docSo(t, `SELECT (SELECT coalesce(sum(due_vnd), 0) FROM shop.bill WHERE sale_date = $1::date)
		- (SELECT coalesce(sum(amount_vnd), 0) FROM shop.refund WHERE bill_id IS NOT NULL AND sale_date = $1::date)`, ngayChu(D)); got != doanhThu {
		t.Fatalf("doanh thu ngày %s: muốn %d, có %d", ngayChu(D), doanhThu, got)
	}

	// Đóng ngày: chủ quán không đứng quầy bấm được.
	r = n.doiSoatXong(t, n.chu, D)
	canDat(t, r, http.StatusCreated)
	if got := n.docChu(t, "SELECT format('%s người %s', sale_date, person_id) FROM shop.reconciled_day WHERE sale_date = $1::date",
		ngayChu(D)); got != fmt.Sprintf("%s người %d", ngayChu(D), n.chu) {
		t.Fatalf("dấu đối soát: %s", got)
	}

	// Ngày đã ký: không cửa nào ghi thêm tiền vào ngày ấy (ADR-089 điểm 4).
	dS, tongS := n.donLay(t)
	phS, tongPS := n.phienDaTinh(t)
	truoc := n.demTien(t)
	canMa(t, n.hoan(t, n.quay, hdA, 1000, "cash", "cash", "phát hiện muộn"), http.StatusConflict, "sale_day_reconciled", "")
	canMa(t, n.thuNo(t, n.quay, hdCu, 1000, 0), http.StatusConflict, "sale_day_reconciled", "")
	canMa(t, n.nhanTraTruoc(t, n.quay, dS, tongS, 0), http.StatusConflict, "sale_day_reconciled", "")
	canMa(t, n.dongPhien(t, n.quay, phS, tongPS, 0, 0, ""), http.StatusConflict, "sale_day_reconciled", "")
	n.khongDoi(t, truoc, "ghi tiền vào ngày đã ký")
	if got := n.docSo(t, "SELECT count(*) FROM shop.bill WHERE sale_date = $1::date", ngayChu(D)); got != 5 {
		t.Fatalf("ngày đã ký có %d hoá đơn, muốn 5", got)
	}

	// Sang ngày sau, cùng lần hoàn ghi được — và rơi vào ngày mới (shop-facts.md §6.4).
	n.datNgay(t, D+1)
	r = n.hoan(t, n.quay, hdA, 1000, "cash", "cash", "phát hiện muộn")
	canDat(t, r, http.StatusCreated)
	if got := n.docChu(t, "SELECT sale_date::text FROM shop.refund WHERE id = $1", r.so(t, "refund_id")); got != ngayChu(D+1) {
		t.Fatalf("lần hoàn sau ngày ký rơi vào ngày %s", got)
	}
}

// --- LỖI CÀI: một lần thu ghi nhầm phương thức ⇒ cửa và bộ đối chiếu cùng kêu, ngày không đóng được --

func TestI021_CaiMotLanThuSaiDoiSoatKeu(t *testing.T) {
	n := dungTien(t)
	const E = 16
	n.datNgay(t, E)
	dau := []xap{{50000, 100000}}
	canDat(t, n.khaiDauKet(t, n.quay, dau), http.StatusCreated)
	hd, tong := n.hoaDonBan(t)

	// Tiền mặt đã vào két, máy ghi thành chuyển khoản.
	if _, err := n.owner.Exec(n.ctx, "UPDATE shop.bill SET cash_vnd = 0, transfer_vnd = due_vnd WHERE id = $1", hd); err != nil {
		t.Fatal(err)
	}
	canDat(t, n.demKet(t, n.quay, []xap{{50000, 100000}, {1000, tong}}), http.StatusCreated)

	r := n.docDoiSoat(t, n.quay, E)
	canDat(t, r, http.StatusOK)
	if r.so(t, "gap_vnd") != tong {
		t.Fatalf("lần thu ghi nhầm %d phải làm lệch đúng %d; cửa đọc %v", tong, tong, r.body)
	}
	demDC, dauDC, veDC, _ := n.ketNgayDoiChieu(t, E)
	if demDC-dauDC-veDC != tong {
		t.Fatalf("bộ đối chiếu phải kêu lệch %d, ra %d", tong, demDC-dauDC-veDC)
	}
	truoc := n.demTien(t)
	canMa(t, n.doiSoatXong(t, n.quay, E), http.StatusConflict, "cash_day_not_balanced", "")
	n.khongDoi(t, truoc, "đóng ngày lệch")
	t.Logf("lỗi cài: hoá đơn %d ghi chuyển khoản %d ⇒ lệch %d ở cả cửa và bộ đối chiếu; ngày không đóng", hd, tong, tong)
}

// --- cửa đóng ngày: ngày chưa đủ điều kiện thì chưa xong (ADR-037 · ADR-079 · U-072) --------------

func TestI021_CuaDongNgayTuChoiNgayChuaXong(t *testing.T) {
	n := dungTien(t)
	dau := []xap{{10000, 100000}}

	n.datNgay(t, 17) // có tiền đầu két, chưa đếm
	canDat(t, n.khaiDauKet(t, n.quay, dau), http.StatusCreated)
	canMa(t, n.doiSoatXong(t, n.quay, 17), http.StatusConflict, "cash_day_incomplete", "")
	canMa(t, n.docDoiSoat(t, n.quay, 17), http.StatusConflict, "cash_day_incomplete", "")

	n.datNgay(t, 18) // đã đếm, không có tiền đầu két
	canDat(t, n.demKet(t, n.quay, dau), http.StatusCreated)
	canMa(t, n.doiSoatXong(t, n.quay, 18), http.StatusConflict, "cash_day_incomplete", "")

	n.datNgay(t, 19) // khớp, nhưng sổ giấy còn một lượt chưa nhập
	canDat(t, n.khaiDauKet(t, n.quay, dau), http.StatusCreated)
	canDat(t, n.demKet(t, n.quay, dau), http.StatusCreated)
	n.id(t, "INSERT INTO shop.paper_ledger (sale_date, entry_count, person_id) VALUES ($1::date, 1, $2) RETURNING id", ngayChu(19), n.quay)
	canMa(t, n.doiSoatXong(t, n.quay, 19), http.StatusConflict, "paper_entries_pending", "")

	n.datNgay(t, 21) // khoản tạm ứng khai ngày 21, ghi vào máy ngày khác ⇒ chờ U-072
	canDat(t, n.khaiDauKet(t, n.quay, dau), http.StatusCreated)
	canDat(t, n.demKet(t, n.quay, dau), http.StatusCreated)
	n.id(t, `INSERT INTO shop.staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id, person_id)
		VALUES ($1, 5000, $2::date, $3, $3) RETURNING id`, n.quay, ngayChu(21), n.chu)
	canMa(t, n.doiSoatXong(t, n.quay, 21), http.StatusConflict, "cash_day_expense_date_undecided", "")

	n.datNgay(t, 22) // ngày không bán gì, két khớp ⇒ đóng được, một lần
	canDat(t, n.khaiDauKet(t, n.quay, dau), http.StatusCreated)
	canDat(t, n.demKet(t, n.quay, dau), http.StatusCreated)
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)
	canMa(t, n.doiSoatXong(t, khac, 22), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.doiSoatXong(t, 0, 22), http.StatusUnauthorized, "unauthenticated", "")
	canDat(t, n.doiSoatXong(t, n.quay, 22), http.StatusCreated)
	truoc := n.demTien(t)
	canMa(t, n.doiSoatXong(t, n.chu, 22), http.StatusConflict, "sale_day_already_reconciled", "")
	n.khongDoi(t, truoc, "đóng ngày hai lần")
	if got := n.docSo(t, "SELECT count(*) FROM shop.reconciled_day WHERE sale_date IN ($1::date, $2::date, $3::date, $4::date)",
		ngayChu(17), ngayChu(18), ngayChu(19), ngayChu(21)); got != 0 {
		t.Fatalf("ngày chưa xong mà có dấu: %d", got)
	}
}

// --- mọi cửa ghi tiền cần một người; cửa lớp quay cần người đang đứng quầy -----------------------

func TestI012_CuaTienCanNguoiCoTen(t *testing.T) {
	n := dungTien(t)
	n.datNgay(t, 20)
	khac := n.nguoi(t, "phục vụ, không đứng quầy", false)
	truoc := n.demTien(t)
	cua := []struct {
		path string
		body map[string]any
		quay bool // lớp quay: người không đứng quầy bị từ chối
	}{
		{"/orders/1/handover", thu(1000, 0), true},
		{"/orders/1/delivered", thu(1000, 0), false},
		{"/orders/1/prepayment", thu(1000, 0), true},
		{"/prepayments/1/returns", map[string]any{"method_code": "cash", "take_cash_vnd": 1000, "take_transfer_vnd": 0, "reason": "x"}, true},
		{"/bills/1/refunds", map[string]any{"amount_vnd": 1000, "method_code": "cash", "source_method_code": "cash", "reason": "x"}, true},
		{"/bills/1/debt-collections", thu(1000, 0), true},
		{"/opening-floats", cacXap(dauKetMau()), true},
		{"/cash-counts", cacXap(dauKetMau()), true},
		{"/sale-days/" + ngayChu(20) + "/reconciliation", map[string]any{}, true},
	}
	for _, c := range cua {
		canMa(t, n.post(t, c.path, 0, c.body), http.StatusUnauthorized, "unauthenticated", "")
		if c.quay {
			canMa(t, n.post(t, c.path, khac, c.body), http.StatusForbidden, "not_on_counter_duty", "")
		}
	}
	n.khongDoi(t, truoc, "cửa tiền không người")
}
