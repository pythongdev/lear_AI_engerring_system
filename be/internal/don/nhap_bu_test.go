// Cửa nhập bù hoá đơn từ sổ giấy (T-174, ADR-099; lời U-079 ở shop-facts.md §6 quy tắc 11).
// Viết bởi Claude Code khi Codex đã thi công cửa — Codex không sửa điều kiện kiểm nào ở đây.
//
// Ngày bán: tháng 6/2031 là của file này (ngày 1…5); không test nào khác của gói dùng tháng ấy.
// Đồng hồ của cửa đặt về 20:00 ngày ấy, nên một sold_at trong giờ bán là "trước now()".
// Riêng ca đổi giá dùng GIỜ THẬT: vết sửa giá mang revised_at thật (clock_timestamp), nên một mốc
// bán giả ở năm 2031 luôn đứng SAU mọi lần sửa và không phân biệt được giá cũ với giá mới.
package don_test

import (
	"context"
	"fmt"
	"net/http"
	"os/exec"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

// ngayNhapBu: đặt đồng hồ của cửa tiền và cửa đơn về 20:00 ngày `day` tháng 6/2031; trả ngày và mốc
// 07:00 (giờ mở + 1 giờ) của ngày ấy làm giờ ghi trên giấy.
func ngayNhapBu(t *testing.T, n tien, day int) (string, time.Time) {
	t.Helper()
	nua := time.Date(2031, 6, day, 0, 0, 0, 0, n.loc)
	bayGio := nua.Add(20 * time.Hour)
	goc := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return bayGio, nil }
	t.Cleanup(func() { ngayban.DongHo = goc })
	datDongHo(t, bayGio)
	return nua.Format("2006-01-02"), nua.Add(n.gioMo + time.Hour)
}

func (n tien) nhapBu(t *testing.T, nguoi int64, ngay string, body map[string]any) traLoi {
	t.Helper()
	return n.post(t, "/sale-days/"+ngay+"/paper-entries", nguoi, body)
}

// luotBan: một lượt tại bàn trên giấy, trả đủ tiền mặt.
func (n tien) luotBan(viTri int, luc time.Time, ban int64, tienMat int64) map[string]any {
	return map[string]any{"paper_position": viTri, "sold_at": luc.Format(time.RFC3339Nano), "kind": "table",
		"dining_table_id": ban, "items": []any{n.dong(false)}, "cash_vnd": tienMat, "transfer_vnd": 0, "debt_vnd": 0}
}

// luotMangDi: một lượt mang đi trên giấy (đơn hotline tới lấy), trả đủ chuyển khoản.
func (n tien) luotMangDi(viTri int, luc time.Time, chuyenKhoan int64) map[string]any {
	body := map[string]any{"paper_position": viTri, "sold_at": luc.Format(time.RFC3339Nano), "kind": "takeaway",
		"items": []any{n.monMangDi()}, "cash_vnd": 0, "transfer_vnd": chuyenKhoan, "debt_vnd": 0}
	for k, v := range lienHeHotlineLay() {
		body[k] = v
	}
	return body
}

func (n tien) conGiay(t *testing.T, ngay string) (khai, con int64) {
	t.Helper()
	r := ketGiay(t, n, ngay)
	canDat(t, r, http.StatusOK)
	return r.so(t, "paper_entries_declared"), r.so(t, "paper_entries_pending")
}

func TestYC08_NhapBuTaiBanQuaCua(t *testing.T) {
	n := dungTien(t)
	ngay, luc := ngayNhapBu(t, n, 1)
	duKetGiay(t, n) // đường đọc "còn N" là đường đối soát két: cần đầu két và số đếm
	canDat(t, khaiGiay(t, n, n.quay, ngay, 2), http.StatusCreated)
	ban := n.banMoi(t, "giấy")
	tong := n.mon.kyVong

	r := n.nhapBu(t, n.quay, ngay, n.luotBan(1, luc, ban, tong))
	canDat(t, r, http.StatusCreated)
	hd, don, phien := r.so(t, "bill_id"), r.so(t, "sales_order_id"), r.so(t, "table_session_id")
	if r.so(t, "due_vnd") != tong {
		t.Fatalf("tiền lượt giấy %d, ca §4.8 là %d", r.so(t, "due_vnd"), tong)
	}
	// Hoá đơn: mốc bán và ngày bán là của giấy; lúc gõ là hôm nay; người là người bấm; sổ · vị trí.
	n.canHoaDon(t, hd, fmt.Sprintf("phiên=%d đơn=- phải=%d mặt=%d ck=0 ttmặt=0 ttck=0 nợ=0 người=%d ngày=%s lúc=%d",
		phien, tong, tong, n.quay, ngay, luc.Unix()))
	if got := n.docChu(t, `SELECT format('%s/%s/%s go_hom_nay=%s', paper_position, paper_entry_count,
		(paper_ledger_id = (SELECT id FROM shop.paper_ledger WHERE sale_date = $2::date)),
		created_at > now() - interval '1 hour') FROM shop.bill WHERE id = $1`, hd, ngay); got != "1/2/t go_hom_nay=t" {
		t.Fatalf("cột sổ giấy của hoá đơn: %s", got)
	}
	// Đơn staff_pos Hoàn thành trong phiên đã đóng; bàn đã dọn ở sold_at; không một việc trạm nào.
	if got := n.docChu(t, `SELECT format('%s %s phiên=%s dọn=%s', o.channel_code, o.status, s.status,
		extract(epoch FROM m.cleaned_at)::bigint)
		FROM shop.sales_order o JOIN shop.table_session s ON s.id = o.table_session_id
		JOIN shop.table_session_member m ON m.table_session_id = s.id AND m.dining_table_id = o.dining_table_id
		WHERE o.id = $1`, don); got != fmt.Sprintf("staff_pos completed phiên=closed dọn=%d", luc.Unix()) {
		t.Fatalf("đơn và phiên giấy: %s", got)
	}
	if got := n.docSo(t, "SELECT count(*) FROM shop.station_job WHERE sales_order_id = $1", don); got != 0 {
		t.Fatalf("nhập bù sinh %d việc trạm", got)
	}
	// Phiên giấy sinh ra đã đóng và bàn đã dọn: bàn đứng y như một bàn chưa ai ngồi.
	if s, moi := n.trangThaiBan(t, ban), n.trangThaiBan(t, n.banMoi(t, "chưa ai ngồi")); s != moi || n.soPhienChuaDong(t, ban) != 0 {
		t.Fatalf("bàn sau lượt giấy: %s, bàn mới: %s", s, moi)
	}
	if khai, con := n.conGiay(t, ngay); khai != 2 || con != 1 {
		t.Fatalf("còn N: khai %d còn %d, muốn 2 còn 1", khai, con)
	}
}

func TestYC08_NhapBuMangDiQuaCua(t *testing.T) {
	n := dungTien(t)
	ngay, luc := ngayNhapBu(t, n, 2)
	canDat(t, khaiGiay(t, n, n.chu, ngay, 2), http.StatusCreated)
	tong := n.mon.kyVong

	thieu := n.luotMangDi(1, luc, tong)
	delete(thieu, "customer_phone")
	truoc := n.demTien(t)
	canMa(t, n.nhapBu(t, n.quay, ngay, thieu), http.StatusBadRequest, "invalid_request", "customer_phone")
	n.khongDoi(t, truoc, "lượt mang đi thiếu điện thoại")

	r := n.nhapBu(t, n.quay, ngay, n.luotMangDi(1, luc, tong))
	canDat(t, r, http.StatusCreated)
	hd, don := r.so(t, "bill_id"), r.so(t, "sales_order_id")
	if _, co := r.body["table_session_id"]; co && r.body["table_session_id"] != nil {
		t.Fatalf("mang đi không có phiên: %v", r.body)
	}
	n.canHoaDon(t, hd, fmt.Sprintf("phiên=- đơn=%d phải=%d mặt=0 ck=%d ttmặt=0 ttck=0 nợ=0 người=%d ngày=%s lúc=%d",
		don, tong, tong, n.quay, ngay, luc.Unix()))
	if got := n.docChu(t, `SELECT format('%s %s %s %s', channel_code, status, handover_code, customer_phone)
		FROM shop.sales_order WHERE id = $1`, don); got != "phone_preorder completed shop_pickup "+soGoi {
		t.Fatalf("đơn mang đi trên giấy: %s", got)
	}
	if got := n.docSo(t, "SELECT count(*) FROM shop.station_job WHERE sales_order_id = $1", don); got != 0 {
		t.Fatalf("nhập bù sinh %d việc trạm", got)
	}
}

// Giá ở mốc bán, qua cửa: mốc lấy GIỜ THẬT (xem đầu file), ngày bán là hôm nay theo múi giờ quán.
func TestI009_NhapBuTinhGiaLucBan(t *testing.T) {
	n := dungTien(t)
	tp := n.id(t, "INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,1000,false) RETURNING id", t.Name())
	mon := n.id(t, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", t.Name())
	n.id(t, "INSERT INTO shop.menu_item_component(menu_item_id,menu_component_id,quantity) VALUES ($1,$2,2) RETURNING id", mon, tp)
	var luc time.Time
	var ngay string
	if err := n.owner.QueryRow(n.ctx, "SELECT clock_timestamp(), (clock_timestamp() AT TIME ZONE $1)::date::text",
		testhelper.ShopTZ(t)).Scan(&luc, &ngay); err != nil {
		t.Fatal(err)
	}
	if n.docSo(t, "SELECT count(*) FROM shop.paper_ledger WHERE sale_date = $1::date", ngay) == 0 {
		canDat(t, khaiGiay(t, n, n.quay, ngay, 50), http.StatusCreated)
	}
	viTri := n.docSo(t, `SELECT coalesce(max(b.paper_position), 0) + 1 FROM shop.bill b
		JOIN shop.paper_ledger l ON l.id = b.paper_ledger_id WHERE l.sale_date = $1::date`, ngay)
	n.suaMenu(t, n.chu, "PUT", fmt.Sprintf("/menu-components/%d/base-price", tp), map[string]any{"base_price_vnd": 2000, "reason": "đổi giá sau mốc bán"})
	n.suaMenu(t, n.chu, "POST", fmt.Sprintf("/menu-items/%d/discontinuation", mon), map[string]any{"reason": "ngừng sau mốc bán"})

	mot := map[string]any{"menu_item_id": mon, "quantity": 1, "option_ids": []int64{}, "is_takeaway": false}
	body := map[string]any{"paper_position": viTri, "sold_at": luc.Format(time.RFC3339Nano), "kind": "table",
		"dining_table_id": n.banMoi(t, "giá cũ"), "items": []any{mot}, "cash_vnd": 2000, "transfer_vnd": 0, "debt_vnd": 0}
	r := n.nhapBu(t, n.quay, ngay, body)
	canDat(t, r, http.StatusCreated)
	if r.so(t, "due_vnd") != 2000 {
		t.Fatalf("lượt giấy trước lần đổi giá phải tính giá cũ 2 × 1000, nhận %v", r.body)
	}
	// Đơn mới cùng món: món đã ngừng ⇒ từ chối; đơn mới của một món còn bán dùng giá mới — cùng gia.Tinh.
	ban := n.banMoi(t, "giá mới")
	canMa(t, n.datHo(t, n.quay, ban, dauLanGui(t), mot), http.StatusConflict, "menu_item_discontinued", "")
	mon2 := n.id(t, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", t.Name()+" còn bán")
	n.id(t, "INSERT INTO shop.menu_item_component(menu_item_id,menu_component_id,quantity) VALUES ($1,$2,2) RETURNING id", mon2, tp)
	r = n.datHo(t, n.quay, ban, dauLanGui(t), map[string]any{"menu_item_id": mon2, "quantity": 1, "option_ids": []int64{}})
	canDat(t, r, http.StatusCreated)
	if r.so(t, "total_vnd") != 4000 {
		t.Fatalf("đơn mới phải tính giá mới 2 × 2000: %v", r.body)
	}
	// Một đường tính giá: chỉ gia.Tinh cộng giá; cửa nhập bù gọi nó, không tự cộng.
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	out, _ := exec.Command("grep", "-rln", "--include=*.go", "gia.Tinh(", noiDuong(strings.TrimSpace(string(goc)), "be/internal")).Output()
	co := map[string]bool{}
	for _, f := range strings.Fields(string(out)) {
		if !strings.HasSuffix(f, "_test.go") {
			co[f[strings.Index(f, "be/internal/"):]] = true
		}
	}
	if !co["be/internal/hoadon/nhap_bu.go"] {
		t.Fatalf("cửa nhập bù không gọi gia.Tinh: %v", co)
	}
	if out, _ := exec.Command("grep", "-rn", "--include=*.go", "-E", "base_price_vnd *\\+|SurchargeVnd *\\+|BasePriceVnd *\\*",
		noiDuong(strings.TrimSpace(string(goc)), "be/internal/hoadon")).Output(); len(out) != 0 {
		t.Fatalf("hoadon tự cộng giá:\n%s", out)
	}
}

func noiDuong(a, b string) string { return strings.TrimSuffix(a, "/") + "/" + b }

func TestYC08_NhapBuTuChoi(t *testing.T) {
	n := dungTien(t)
	// Ngày đã ký: ký một ngày không sổ (đủ đầu két, đếm khớp), rồi nhập bù vào nó.
	daKy, lucKy := ngayNhapBu(t, n, 3)
	duKetGiay(t, n)
	canDat(t, n.post(t, "/sale-days/"+daKy+"/reconciliation", n.chu, map[string]any{}), http.StatusCreated)
	ban := n.banMoi(t, "từ chối")
	tong := n.mon.kyVong
	truoc := n.demTien(t)
	canMa(t, n.nhapBu(t, n.quay, daKy, n.luotBan(1, lucKy, ban, tong)), http.StatusConflict, "sale_day_reconciled", "")
	n.khongDoi(t, truoc, "ngày đã ký")

	ngay, luc := ngayNhapBu(t, n, 4)
	duKetGiay(t, n)
	truoc = n.demTien(t)
	canMa(t, n.nhapBu(t, n.quay, ngay, n.luotBan(1, luc, ban, tong)), http.StatusConflict, "paper_ledger_missing", "")
	n.khongDoi(t, truoc, "ngày chưa khai sổ")
	canDat(t, khaiGiay(t, n, n.quay, ngay, 2), http.StatusCreated)
	truoc = n.demTien(t)
	for _, viTri := range []int{0, 3} {
		canMa(t, n.nhapBu(t, n.quay, ngay, n.luotBan(viTri, luc, ban, tong)), http.StatusBadRequest, "invalid_request", "paper_position")
	}
	for ten, moc := range map[string]time.Time{"hôm trước": luc.Add(-24 * time.Hour), "hôm sau": luc.Add(24 * time.Hour),
		"sau giờ cửa": luc.Add(14 * time.Hour)} {
		r := n.nhapBu(t, n.quay, ngay, n.luotBan(1, moc, ban, tong))
		if r.status != http.StatusBadRequest || r.chu("field") != "sold_at" {
			t.Fatalf("sold_at %s: %d %v", ten, r.status, r.body)
		}
	}
	khac := n.nguoi(t, "ngoài quầy", false)
	canMa(t, n.nhapBu(t, khac, ngay, n.luotBan(1, luc, ban, tong)), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, n.nhapBu(t, 0, ngay, n.luotBan(1, luc, ban, tong)), http.StatusUnauthorized, "unauthenticated", "")
	giam := n.luotBan(1, luc, ban, tong-1000)
	giam["discount_vnd"], giam["discount_customer_name"] = 1000, "Khách quen"
	canMa(t, n.nhapBu(t, n.quay, ngay, giam), http.StatusForbidden, "owner_only", "")
	n.khongDoi(t, truoc, "lượt giấy bị từ chối")

	canDat(t, n.nhapBu(t, n.quay, ngay, n.luotBan(1, luc, ban, tong)), http.StatusCreated)
	truoc = n.demTien(t)
	canMa(t, n.nhapBu(t, n.chu, ngay, n.luotBan(1, luc, n.banMoi(t, "trùng"), tong)), http.StatusConflict, "paper_position_already_entered", "")
	n.khongDoi(t, truoc, "vị trí đã nhập")
	if khai, con := n.conGiay(t, ngay); khai != 2 || con != 1 {
		t.Fatalf("còn N sau lời từ chối: khai %d còn %d", khai, con)
	}
}

func TestI021_NgayGiayNhapDuRa0dLech(t *testing.T) {
	n := dungTien(t)
	ngay, luc := ngayNhapBu(t, n, 5)
	canDat(t, n.khaiDauKet(t, n.quay, dauKetMau()), http.StatusCreated)
	canDat(t, khaiGiay(t, n, n.quay, ngay, 2), http.StatusCreated)
	tong := n.mon.kyVong
	r := n.nhapBu(t, n.quay, ngay, n.luotBan(1, luc, n.banMoi(t, "ngày giấy"), tong))
	canDat(t, r, http.StatusCreated)
	hdBan := r.so(t, "bill_id")
	r = n.nhapBu(t, n.chu, ngay, n.luotMangDi(2, luc.Add(time.Hour), tong))
	canDat(t, r, http.StatusCreated)
	hdMang := r.so(t, "bill_id")

	xaps := dauKetMau()
	xaps[len(xaps)-1].soTien += tong
	canDat(t, n.demKet(t, n.quay, xaps), http.StatusCreated)
	if khai, con := n.conGiay(t, ngay); khai != 2 || con != 0 {
		t.Fatalf("nhập đủ mà còn %d/%d", con, khai)
	}
	r = ketGiay(t, n, ngay)
	if r.so(t, "gap_vnd") != 0 || r.so(t, "expected_vnd") != tong {
		t.Fatalf("đối soát ngày giấy: %v", r.body)
	}
	canDat(t, n.post(t, "/sale-days/"+ngay+"/reconciliation", n.chu, map[string]any{}), http.StatusCreated)
	if got := n.docSo(t, "SELECT gap_vnd FROM shop.reconciled_day WHERE sale_date = $1::date", ngay); got != 0 {
		t.Fatalf("ký lệch %d", got)
	}
	// Bộ đối chiếu của scripts/reconcile.sh trên ngày ấy, hai hoá đơn ấy và phiên giấy: rỗng.
	root, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command("./scripts/reconcile.sh", "--emit-queries")
	cmd.Dir = strings.TrimSpace(string(root))
	queries, err := cmd.Output()
	if err != nil {
		t.Fatal(err)
	}
	conn, err := pgx.Connect(n.ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(context.Background())
	if _, err = conn.Exec(n.ctx, "SET search_path TO shop, public"); err != nil {
		t.Fatal(err)
	}
	pre := exec.Command("./scripts/reconcile.sh", "--emit-prelude")
	pre.Dir = cmd.Dir
	prelude, err := pre.Output()
	if err != nil {
		t.Fatal(err)
	}
	if _, err = conn.Exec(n.ctx, string(prelude)); err != nil {
		t.Fatalf("nạp prelude của bộ đối chiếu: %v", err)
	}
	phien := n.docChu(t, "SELECT table_session_id::text FROM shop.bill WHERE id = $1", hdBan)
	checked := 0
	for _, block := range strings.Split(string(queries), "\\echo ") {
		if !strings.HasPrefix(block, "'@@@|I-0") {
			continue
		}
		begin := strings.Index(block, "FROM (\n")
		end := strings.LastIndex(block, "\n) q;")
		if begin < 0 || end < 0 {
			continue
		}
		query := block[begin+len("FROM (\n") : end]
		var count int64
		err = conn.QueryRow(n.ctx, `SELECT count(*) FROM (`+query+`) q WHERE to_jsonb(q)->>'ngay' = $1
			OR to_jsonb(q)->>'hoa_don' IN ($2, $3) OR to_jsonb(q)->>'phien' = $4`,
			ngay, fmt.Sprint(hdBan), fmt.Sprint(hdMang), phien).Scan(&count)
		if err != nil || count != 0 {
			t.Fatalf("đối chiếu %s: %d dòng, %v", strings.SplitN(block, "\n", 2)[0], count, err)
		}
		checked++
	}
	if checked < 6 {
		t.Fatalf("chỉ chạy %d tập đối chiếu", checked)
	}
}
