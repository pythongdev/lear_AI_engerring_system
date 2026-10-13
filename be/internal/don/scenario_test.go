// P3-13: diễn §8 qua router thật. SQL chỉ dựng menu/người/quầy/bàn và đọc bằng chứng;
// không UPDATE trạng thái đơn, phiên, việc hay tiền. Tháng 7/2031 dành riêng cho file này.
package don_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"
	"reflect"
	"sort"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

type dienScenario struct {
	tien
	ngay string
	moc  time.Time
	cas  map[int]caGia
	banh int64
}

type luotScenario struct {
	path  string
	nguoi int64
	body  map[string]any
	out   traLoi
}

type ketScenario struct {
	mat, tong               int64
	bills, orders, sessions []int64
	combo                   luotScenario
}

func dungScenario(t *testing.T, day int) *dienScenario {
	t.Helper()
	n := dungTien(t)
	s := &dienScenario{tien: n, cas: map[int]caGia{}}
	s.moc = time.Date(2031, 7, day, 0, 0, 0, 0, n.loc).Add(n.gioMo + time.Hour)
	s.ngay = s.moc.Format("2006-01-02")
	s.gio(t, s.moc)
	if _, err := n.owner.Exec(n.ctx, "SELECT set_config('TimeZone', $1, false)", testhelper.ShopTZ(t)); err != nil {
		t.Fatal(err)
	}
	// Cùng thành phần riêng được chia sẻ giữa các món riêng: đổi giá bánh tác động
	// cả suất giò lẫn combo, nhưng không làm hỏng menu của test chạy sau.
	thanhPhan := map[int64]int64{}
	monMoi := map[int64]int64{}
	for _, c := range n.caCoMa(t) {
		if c.tuChoi {
			continue
		}
		cu := c.monID
		moi, co := monMoi[cu]
		if !co {
			moi = n.id(t, "INSERT INTO shop.menu_item(name) SELECT name || $2 FROM shop.menu_item WHERE id=$1 RETURNING id", cu, " · "+t.Name())
			monMoi[cu] = moi
			rows, err := n.owner.Query(n.ctx, "SELECT menu_component_id, quantity FROM shop.menu_item_component WHERE menu_item_id=$1 ORDER BY id", cu)
			if err != nil {
				t.Fatal(err)
			}
			type tp struct {
				id int64
				so int
			}
			var ds []tp
			for rows.Next() {
				var x tp
				if err := rows.Scan(&x.id, &x.so); err != nil {
					t.Fatal(err)
				}
				ds = append(ds, x)
			}
			rows.Close()
			if rows.Err() != nil {
				t.Fatal(rows.Err())
			}
			for _, x := range ds {
				id, co := thanhPhan[x.id]
				if !co {
					id = n.id(t, `INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling)
       SELECT name || $2,base_price_vnd,takes_filling FROM shop.menu_component WHERE id=$1 RETURNING id`, x.id, " · "+t.Name())
					thanhPhan[x.id] = id
					if err := n.coVet(func(tx pgx.Tx) error {
						_, err := tx.Exec(n.ctx, `INSERT INTO shop.menu_component_station(menu_component_id,station_code)
       SELECT $2,station_code FROM shop.menu_component_station WHERE menu_component_id=$1`, x.id, id)
						return err
					}); err != nil {
						t.Fatal(err)
					}
				}
				n.id(t, "INSERT INTO shop.menu_item_component(menu_item_id,menu_component_id,quantity) VALUES($1,$2,$3) RETURNING id", moi, id, x.so)
			}
			if err := n.coVet(func(tx pgx.Tx) error {
				_, err := tx.Exec(n.ctx, `INSERT INTO shop.menu_item_option_group(menu_item_id,option_group_id)
      SELECT $2,option_group_id FROM shop.menu_item_option_group WHERE menu_item_id=$1`, cu, moi)
				return err
			}); err != nil {
				t.Fatal(err)
			}
		}
		c.monID = moi
		s.cas[c.so] = c
	}
	gio := s.ca(t, 8)
	gio.chonIDs = append([]int64(nil), s.ca(t, 2).chonIDs...)
	gio.kyVong -= 4 * (giaScenario(s.ca(t, 3), 1) - giaScenario(s.ca(t, 2), 1))
	s.cas[14] = gio // suất giò nhân thường; §4.8 chỉ có ca giò nhiều nhân.
	s.banh = n.docSo(t, "SELECT menu_component_id FROM shop.menu_item_component WHERE menu_item_id=$1", s.ca(t, 1).monID)
	return s
}

func (s *dienScenario) gio(t *testing.T, moc time.Time) {
	t.Helper()
	goc := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil }
	t.Cleanup(func() { ngayban.DongHo = goc })
	datDongHo(t, moc)
}
func (s *dienScenario) ca(t *testing.T, so int) caGia {
	t.Helper()
	c, ok := s.cas[so]
	if !ok {
		t.Fatalf("thiếu ca giá %d", so)
	}
	return c
}
func dongScenario(c caGia, so int) map[string]any {
	ids := c.chonIDs
	if ids == nil {
		ids = []int64{}
	}
	return map[string]any{"menu_item_id": c.monID, "quantity": so, "option_ids": ids, "is_takeaway": false}
}
func giaScenario(c caGia, so int) int64 { return c.kyVong / int64(c.soSuat) * int64(so) }

// Một bước BA có thể chứa nhiều giao dịch (duyệt, bấm mẻ, bưng); từng HTTP
// đều có dòng log riêng mang đúng số bước BA, không giấu lời gọi trong helper.
func (s *dienScenario) goiBuoc(t *testing.T, sc string, buoc int, method, path string, nguoi int64, body any, want int) traLoi {
	t.Helper()
	status, out := s.goi(t, method, path, nguoi, body)
	r := traLoi{status, out}
	raw, err := json.Marshal(out)
	if err != nil {
		t.Fatal(err)
	}
	tom := string(raw)
	if len(tom) > 900 {
		tom = tom[:900] + "…}"
	}
	t.Logf("%s bước %d: %s %s ⇒ %d %s", sc, buoc, method, path, status, tom)
	canDat(t, r, want)
	return r
}
func (s *dienScenario) postBuoc(t *testing.T, sc string, b int, path string, nguoi int64, body any, want int) traLoi {
	return s.goiBuoc(t, sc, b, "POST", path, nguoi, body, want)
}
func (s *dienScenario) dat(t *testing.T, sc string, b int, path string, nguoi int64, body map[string]any) luotScenario {
	t.Helper()
	return luotScenario{path, nguoi, body, s.postBuoc(t, sc, b, path, nguoi, body, http.StatusCreated)}
}
func (s *dienScenario) docLai(t *testing.T, sc string, b int, l luotScenario) traLoi {
	t.Helper()
	r := s.postBuoc(t, sc, b, l.path, l.nguoi, l.body, http.StatusOK)
	if r.so(t, "sales_order_id") != l.out.so(t, "sales_order_id") || r.so(t, "total_vnd") != l.out.so(t, "total_vnd") || !reflect.DeepEqual(r.body["lines"], l.out.body["lines"]) {
		t.Fatalf("ảnh chụp đơn đổi: trước %v sau %v", l.out.body, r.body)
	}
	return r
}
func canSoScenario(t *testing.T, co, muon int64, ten string) {
	t.Helper()
	if co != muon {
		t.Fatalf("%s: có %d muốn %d", ten, co, muon)
	}
}
func (s *dienScenario) trangThai(t *testing.T, sc string, b int, ban int64, want string) {
	t.Helper()
	r := s.goiBuoc(t, sc, b, "GET", "/dining-tables", 0, nil, http.StatusOK)
	for _, v := range r.body["tables"].([]any) {
		m := v.(map[string]any)
		if int64(m["dining_table_id"].(float64)) == ban {
			if m["state"] != want {
				t.Fatalf("bàn %d: %v, muốn %s", ban, m, want)
			}
			return
		}
	}
	t.Fatalf("không có bàn %d", ban)
}
func (s *dienScenario) lam(t *testing.T, sc string, b int, don int64) {
	t.Helper()
	ids := s.viecCua(t, don, "pending")
	if len(ids) == 0 {
		t.Fatal("đơn chưa nổ việc")
	}
	s.postBuoc(t, sc, b, "/production-batches", s.quay, map[string]any{"station_job_ids": ids}, http.StatusCreated)
	canSoScenario(t, int64(len(s.viecCua(t, don, "made"))), int64(len(ids)), "đã làm đủ")
}
func (s *dienScenario) trao(t *testing.T, sc string, b int, don int64) {
	t.Helper()
	ids := s.viecCua(t, don, "made")
	if len(ids) == 0 {
		t.Fatal("không có việc đã làm để trao")
	}
	for _, p := range s.phanRaCua(t, ids...) {
		items := []map[string]any{}
		for _, m := range p.muc {
			var tp any
			if m.thanhPhan != 0 {
				tp = m.thanhPhan
			}
			nhan := m.nhan
			if nhan == nil {
				nhan = []int64{}
			}
			items = append(items, map[string]any{"station_code": m.tram, "menu_component_id": tp, "filling_option_ids": nhan, "quantity": m.so})
		}
		body := map[string]any{"items": items}
		if p.ban != 0 {
			body["dining_table_id"] = p.ban
		} else {
			body["sales_order_id"] = p.don
		}
		s.postBuoc(t, sc, b, "/served-marks", s.quay, body, http.StatusOK)
	}
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.station_job WHERE sales_order_id=$1 AND status <> 'served'", don), 0, "mọi việc đã trao")
}
func (s *dienScenario) duyetBuoc(t *testing.T, sc string, b int, don int64) {
	t.Helper()
	r := s.postBuoc(t, sc, b, fmt.Sprintf("/orders/%d/approval", don), s.quay, map[string]any{}, http.StatusOK)
	if r.chu("status") != "in_progress" {
		t.Fatalf("duyệt không nổ việc: %v", r.body)
	}
}
func (s *dienScenario) tinhBuoc(t *testing.T, sc string, b int, phien, tong int64) {
	t.Helper()
	r := s.postBuoc(t, sc, b, fmt.Sprintf("/table-sessions/%d/bill-request", phien), s.quay, map[string]any{}, http.StatusOK)
	canSoScenario(t, r.so(t, "due_vnd"), tong, "tổng phiên")
}

func (s *dienScenario) scenario1(t *testing.T) ketScenario {
	t.Helper()
	const sc = "S1"
	ban := s.banMoi(t, "S1 bàn 5")
	ma := s.capMaQR(t, ban)
	s.trangThai(t, sc, 0, ban, "empty")
	a, b, c := s.ca(t, 10), s.ca(t, 14), s.ca(t, 1)
	// Ca giò thường suy từ ca giò nhiều và chênh phụ thu đọc từ owner.
	if !strings.Contains(strings.ToLower(b.mon), "giò") {
		t.Fatalf("ca suất giò không còn là suất giò: %s", b.mon)
	}
	ta, tb, tc := giaScenario(a, 2), giaScenario(b, 1), giaScenario(c, 1)
	l1 := s.dat(t, sc, 1, "/qr-codes/"+ma+"/orders", 0, voiDong(nil, dauLanGui(t), dongScenario(a, 2)))
	ph, d1 := l1.out.so(t, "table_session_id"), l1.out.so(t, "sales_order_id")
	if l1.out.chu("status") != "pending_confirmation" || s.trangThaiPhien(t, ph) != "open" {
		t.Fatal("lượt QR đầu phải mở phiên, chờ duyệt")
	}
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.station_job WHERE sales_order_id=$1", d1), 0, "trước duyệt chưa sinh việc")
	r := s.docLai(t, sc, 2, l1)
	canSoScenario(t, r.so(t, "total_vnd"), ta, "giá lượt 1")
	s.duyetBuoc(t, sc, 3, d1)
	s.goiBuoc(t, sc, 4, "GET", "/production-board", 0, nil, http.StatusOK)
	parts := s.phanRaCua(t, s.viecCua(t, d1, "pending")...)
	if len(parts) != 1 || len(parts[0].muc) != 6 {
		t.Fatalf("lượt 1 phải sáu nhóm việc: %+v", parts)
	}
	byStation := map[string][]int64{}
	for _, m := range parts[0].muc {
		byStation[m.tram] = append(byStation[m.tram], m.so)
	}
	for k := range byStation {
		sort.Slice(byStation[k], func(i, j int) bool { return byStation[k][i] < byStation[k][j] })
	}
	if !reflect.DeepEqual(byStation, map[string][]int64{"trang_banh": {2, 6}, "gap_banh": {2, 2, 6}, "canh": {1}}) {
		t.Fatalf("sai sáu nhóm × số cái: %v", byStation)
	}
	canSoScenario(t, s.docSo(t, `SELECT count(*) FROM shop.station_job j JOIN shop.order_line_component c
 ON c.id=j.order_line_component_id WHERE j.sales_order_id=$1 AND c.menu_component_id=$2 AND j.station_code='trang_banh'`, d1, s.banh), 6, "sáu bánh ở trạm tráng")
	canSoScenario(t, s.docSo(t, `SELECT count(*) FROM shop.station_job j JOIN shop.order_line_component c
 ON c.id=j.order_line_component_id WHERE j.sales_order_id=$1 AND c.takes_filling AND c.menu_component_id<>$2 AND j.station_code='trang_banh'`, d1, s.banh), 2, "hai trứng ở trạm tráng")
	canSoScenario(t, s.docSo(t, `SELECT count(*) FROM shop.station_job j JOIN shop.order_line_component c
 ON c.id=j.order_line_component_id WHERE j.sales_order_id=$1 AND NOT c.takes_filling AND j.station_code='gap_banh'`, d1), 2, "hai giò ở trạm gấp")
	s.lam(t, sc, 5, d1)
	s.trao(t, sc, 5, d1)
	if s.docLai(t, sc, 6, l1).chu("status") != "completed" {
		t.Fatal("lượt 1 chưa xong")
	}
	l2 := s.dat(t, sc, 7, "/table-orders", s.quay, voiDong(map[string]any{"dining_table_id": ban}, dauLanGui(t), dongScenario(b, 1)))
	d2 := l2.out.so(t, "sales_order_id")
	canSoScenario(t, l2.out.so(t, "total_vnd"), tb, "giá lượt 2")
	if l2.out.chu("status") != "in_progress" || l2.out.chu("channel_code") != "staff_pos" {
		t.Fatal("đặt hộ phải nổ ngay")
	}
	r = s.docLai(t, sc, 8, l2)
	canSoScenario(t, r.so(t, "table_session_id"), ph, "lượt 2 cùng phiên")
	s.lam(t, sc, 9, d2)
	s.trao(t, sc, 9, d2)
	s.tinhBuoc(t, sc, 10, ph, ta+tb)
	s.trangThai(t, sc, 10, ban, "in_session")
	if s.trangThaiPhien(t, ph) != "awaiting_payment" {
		t.Fatal("chưa chờ thanh toán")
	}
	l3 := s.dat(t, sc, 11, "/qr-codes/"+ma+"/orders", 0, voiDong(nil, dauLanGui(t), dongScenario(c, 1)))
	d3 := l3.out.so(t, "sales_order_id")
	canSoScenario(t, l3.out.so(t, "table_session_id"), ph, "lượt 3 cùng phiên")
	canSoScenario(t, l3.out.so(t, "total_vnd"), tc, "giá lượt 3")
	if s.trangThaiPhien(t, ph) != "serving" {
		t.Fatal("gọi thêm phải quay về phục vụ")
	}
	s.duyetBuoc(t, sc, 12, d3)
	s.lam(t, sc, 12, d3)
	s.trao(t, sc, 12, d3)
	tong := ta + tb + tc
	s.tinhBuoc(t, sc, 13, ph, tong)
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE table_session_id=$1", ph), 0, "chưa thu chưa có hoá đơn")
	// Giữ tỷ lệ tiền mặt 5/8 của ví dụ BA, tiền lấy từ giá đọc lúc chạy.
	mat := nghin(tong * 5 / 8)
	r = s.postBuoc(t, sc, 14, fmt.Sprintf("/table-sessions/%d/closing", ph), s.quay, map[string]any{"cash_vnd": mat, "transfer_vnd": tong - mat, "debt_vnd": 0}, http.StatusCreated)
	hd := r.so(t, "bill_id")
	s.trangThai(t, sc, 15, ban, "needs_cleaning")
	if s.trangThaiPhien(t, ph) != "closed" {
		t.Fatal("thu và đóng phải cùng giao dịch")
	}
	s.postBuoc(t, sc, 16, fmt.Sprintf("/dining-tables/%d/cleaning", ban), s.nguoi(t, "S1 dọn bàn", false), map[string]any{}, http.StatusOK)
	s.trangThai(t, sc, 17, ban, "empty")
	canSoScenario(t, s.soDongCuaBan(t, ban), 1, "một phiên suốt scenario")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE table_session_id=$1 AND due_vnd=$2 AND cash_vnd=$3 AND transfer_vnd=$4", ph, tong, mat, tong-mat), 1, "một hoá đơn đủ ba lượt và hai phần trả")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.sales_order WHERE table_session_id=$1 AND status='completed'", ph), 3, "ba lượt hoàn thành")
	return ketScenario{mat: mat, tong: tong, bills: []int64{hd}, orders: []int64{d1, d2, d3}, sessions: []int64{ph}, combo: l1}
}

func (s *dienScenario) scenario2(t *testing.T) ketScenario {
	t.Helper()
	const sc = "S2"
	s.gio(t, s.moc)
	a, b, c := s.ca(t, 6), s.ca(t, 9), s.ca(t, 3)
	ta, tb, tc := giaScenario(a, 2), giaScenario(b, 1), giaScenario(c, 3)
	lay := time.Date(2031, 7, s.moc.Day(), 8, 30, 0, 0, s.loc)
	hen := lay.Add(30 * time.Minute)
	lA := s.dat(t, sc, 1, "/online-orders", 0, voiDong(lienHeGiao(), dauLanGui(t), dongScenario(a, 2)))
	lB := s.dat(t, sc, 2, "/online-orders", 0, voiDong(voi(lienHeLay(), map[string]any{"customer_needed_at": lay.Format(time.RFC3339)}), dauLanGui(t), dongScenario(b, 1)))
	// Khách chọn trả trước không tạo khoản tiền; chỉ cửa bước 6 ghi nhận.
	dA, dB := lA.out.so(t, "sales_order_id"), lB.out.so(t, "sales_order_id")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.prepayment WHERE sales_order_id=$1", dB), 0, "chưa nhận tiền")
	s.gio(t, s.moc.Add(10*time.Minute))
	lC := s.dat(t, sc, 3, "/phone-orders", s.quay, voiDong(voi(lienHeHotlineLay(), map[string]any{"customer_needed_at": hen.Format(time.RFC3339)}), dauLanGui(t), dongScenario(c, 3)))
	dC := lC.out.so(t, "sales_order_id")
	ids := []int64{dA, dB, dC}
	for i, l := range []luotScenario{lA, lB, lC} {
		r := s.docLai(t, sc, 4, l)
		canSoScenario(t, r.so(t, "total_vnd"), []int64{ta, tb, tc}[i], "giá đơn mang đi")
		if r.body["table_session_id"] != nil || r.body["dining_table_id"] != nil {
			t.Fatalf("đơn lẻ gắn bàn: %v", r.body)
		}
		want := []string{"pending_confirmation", "pending_confirmation", "confirmed"}[i]
		if r.chu("status") != want {
			t.Fatalf("đơn %d: muốn %s, nhận %v", i, want, r.body)
		}
	}
	canSoScenario(t, s.docSo(t, "SELECT count(DISTINCT id) FROM shop.sales_order WHERE id=ANY($1) AND table_session_id IS NULL AND dining_table_id IS NULL", ids), 3, "ba đơn độc lập cùng khách")
	s.duyetBuoc(t, sc, 5, dA)
	s.duyetBuoc(t, sc, 5, dB)
	s.postBuoc(t, sc, 6, fmt.Sprintf("/orders/%d/prepayment", dB), s.quay, thu(0, tb), http.StatusCreated)
	s.gio(t, hen.Add(-20*time.Minute))
	released := s.postBuoc(t, sc, 7, "/preorder-releases", s.quay, map[string]any{}, http.StatusOK)
	found := false
	for _, v := range released.body["released_order_ids"].([]any) {
		if int64(v.(float64)) == dC {
			found = true
		}
	}
	if !found {
		t.Fatalf("hotline tới mốc chưa nhả: %v", released.body)
	}
	s.goiBuoc(t, sc, 7, "GET", "/production-board", 0, nil, http.StatusOK)
	for _, id := range ids {
		canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.station_job WHERE sales_order_id=$1 AND order_line_id IS NULL AND station_code='canh'", id), 1, "mỗi đơn một nước chấm")
		s.lam(t, sc, 8, id)
	}
	// Đóng gói là thao tác ngoài máy; đọc lại chứng minh chưa tự hoàn thành.
	for _, l := range []luotScenario{lA, lB, lC} {
		if s.docLai(t, sc, 9, l).chu("status") != "in_progress" {
			t.Fatal("đóng gói chưa được hoàn thành")
		}
	}
	dep := fmt.Sprintf("/orders/%d/departure", dA)
	r := s.postBuoc(t, sc, 10, dep, s.quay, map[string]any{}, http.StatusConflict)
	canMa(t, r, http.StatusConflict, "delivery_served_mark_undecided", "")
	// ADR-088: cửa hiện có đòi quầy ghi served trước departure. Ghi rõ lời
	// từ chối của đường BA, rồi dùng đúng cửa công khai như donGiao; không SQL lách.
	s.trao(t, sc, 10, dA)
	r = s.postBuoc(t, sc, 10, dep, s.quay, map[string]any{}, http.StatusOK)
	if r.chu("status") != "delivering" {
		t.Fatalf("A không đang giao: %v", r.body)
	}
	giao := s.nguoi(t, "S2 người giao", false)
	r = s.postBuoc(t, sc, 11, fmt.Sprintf("/orders/%d/delivered", dA), giao, thu(ta, 0), http.StatusCreated)
	hdA := r.so(t, "bill_id")
	s.trao(t, sc, 12, dB)
	r = s.postBuoc(t, sc, 12, fmt.Sprintf("/orders/%d/handover", dB), s.quay, voi(thu(0, 0), map[string]any{"prepaid_transfer_vnd": tb}), http.StatusCreated)
	hdB := r.so(t, "bill_id")
	s.gio(t, hen)
	s.trao(t, sc, 13, dC)
	r = s.postBuoc(t, sc, 13, fmt.Sprintf("/orders/%d/handover", dC), s.quay, thu(tc, 0), http.StatusCreated)
	hdC := r.so(t, "bill_id")
	for _, l := range []luotScenario{lA, lB, lC} {
		if s.docLai(t, sc, 14, l).chu("status") != "completed" {
			t.Fatal("đơn mang đi chưa hoàn thành")
		}
	}
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE sales_order_id=ANY($1)", ids), 3, "ba đơn vị thanh toán")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE id=$1 AND cash_vnd=0 AND transfer_vnd=0 AND prepaid_transfer_vnd=$2 AND due_vnd=$2", hdB, tb), 1, "B không thu lại")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.prepayment WHERE sales_order_id=ANY($1)", ids), 1, "chỉ một lần trả trước")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE id=$1 AND due_vnd=$2 AND cash_vnd=$2 AND transfer_vnd=0 AND person_id=$3", hdA, ta, giao), 1, "A thu tại chỗ khách bởi người giao")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE id=$1 AND due_vnd=$2 AND cash_vnd=$2 AND transfer_vnd=0 AND person_id=$3", hdC, tc, s.quay), 1, "C thu tại quầy")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE sales_order_id=ANY($1) AND cash_vnd>0", ids), 2, "hai lần thu lúc trao, cộng trả trước là ba")
	canSoScenario(t, s.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='sales_order'
  AND target_row=ANY($1) AND after_image->>'status'='delivering'`, []int64{dB, dC}), 0, "B C không đi qua đang giao")
	return ketScenario{mat: ta + tc, tong: ta + tb + tc, bills: []int64{hdA, hdB, hdC}, orders: ids}
}

func (s *dienScenario) scenario3(t *testing.T, combo luotScenario) ketScenario {
	t.Helper()
	const sc = "S3"
	ban := s.banMoi(t, "S3 bàn 3")
	c := s.ca(t, 14)
	cu := giaScenario(c, 1)
	s.gio(t, time.Date(2031, 7, s.moc.Day(), 8, 0, 0, 0, s.loc))
	body := func() map[string]any {
		return voiDong(map[string]any{"dining_table_id": ban}, dauLanGui(t), dongScenario(c, 1))
	}
	l1 := s.dat(t, sc, 1, "/table-orders", s.quay, body())
	ph, d1 := l1.out.so(t, "table_session_id"), l1.out.so(t, "sales_order_id")
	canSoScenario(t, l1.out.so(t, "total_vnd"), cu, "giá cũ suất giò")
	base := s.docSo(t, "SELECT base_price_vnd FROM shop.menu_component WHERE id=$1", s.banh)
	delta := giaScenario(s.ca(t, 2), 1) - giaScenario(s.ca(t, 1), 1)
	s.gio(t, time.Date(2031, 7, s.moc.Day(), 8, 30, 0, 0, s.loc))
	// Bước 2 chọn giá, bước 3 lưu là một PUT; GET xác nhận lưu có hiệu lực ngay.
	r := s.goiBuoc(t, sc, 2, "PUT", fmt.Sprintf("/menu-components/%d/base-price", s.banh), s.chu, map[string]any{"base_price_vnd": base + delta, "reason": "P3-13 nâng giá chay giữa buổi"}, http.StatusOK)
	canSoScenario(t, r.so(t, "base_price_vnd"), base+delta, "giá chay mới")
	s.goiBuoc(t, sc, 3, "GET", "/menu", 0, nil, http.StatusOK)
	moi := cu + 4*delta
	// /menu là một đường đọc dùng chung cho cả năm kênh, không nhận channel.
	menu := s.goiBuoc(t, sc, 4, "GET", "/menu", 0, nil, http.StatusOK)
	s.canGiaMenu(t, menu, c.monID, c.chonIDs, moi)
	s.gio(t, time.Date(2031, 7, s.moc.Day(), 9, 0, 0, 0, s.loc))
	l2 := s.dat(t, sc, 5, "/table-orders", s.quay, body())
	d2 := l2.out.so(t, "sales_order_id")
	canSoScenario(t, l2.out.so(t, "table_session_id"), ph, "hai mức giá cùng phiên")
	canSoScenario(t, l2.out.so(t, "total_vnd"), moi, "giá mới suất giò")
	s.docLai(t, sc, 6, l1)
	for _, d := range []int64{d1, d2} {
		s.lam(t, sc, 7, d)
		s.trao(t, sc, 7, d)
	}
	s.tinhBuoc(t, sc, 7, ph, cu+moi)
	r = s.postBuoc(t, sc, 7, fmt.Sprintf("/table-sessions/%d/closing", ph), s.quay, map[string]any{"cash_vnd": cu + moi, "transfer_vnd": 0, "debt_vnd": 0}, http.StatusCreated)
	hd := r.so(t, "bill_id")
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE table_session_id=$1 AND due_vnd=$2", ph, cu+moi), 1, "một hoá đơn hai mức giá")
	s.gio(t, time.Date(2031, 7, s.moc.Day(), 10, 0, 0, 0, s.loc))
	s.postBuoc(t, sc, 8, fmt.Sprintf("/menu-items/%d/discontinuation", c.monID), s.chu, map[string]any{"reason": "P3-13 ngừng suất giò"}, http.StatusOK)
	s.docLai(t, sc, 8, l1)
	// Cả năm đường vào đều từ chối đặt mới, nhưng replay đơn cũ vẫn đọc được.
	ma := s.capMaQR(t, s.banMoi(t, "S3 QR ngừng bán"))
	for _, x := range []struct {
		path   string
		nguoi  int64
		lienHe map[string]any
	}{
		{"/table-orders", s.quay, map[string]any{"dining_table_id": s.banMoi(t, "S3 thử ngừng")}},
		{"/qr-codes/" + ma + "/orders", 0, nil},
		{"/online-orders", 0, lienHeGiao()},
		{"/online-orders", 0, voi(lienHeLay(), map[string]any{"customer_needed_at": s.moc.Add(4 * time.Hour).Format(time.RFC3339)})},
		{"/phone-orders", s.quay, voi(lienHeHotlineLay(), map[string]any{"customer_needed_at": s.moc.Add(4 * time.Hour).Format(time.RFC3339)})},
	} {
		r = s.postBuoc(t, sc, 8, x.path, x.nguoi, voiDong(x.lienHe, dauLanGui(t), dongScenario(c, 1)), http.StatusConflict)
		canMa(t, r, http.StatusConflict, "menu_item_discontinued", "")
	}
	reason := "P3-13 sửa combo giữa buổi có vết"
	r = s.goiBuoc(t, sc, 9, "PUT", fmt.Sprintf("/menu-items/%d/components/%d", s.ca(t, 10).monID, s.banh), s.chu, map[string]any{"quantity": 2, "reason": reason}, http.StatusOK)
	canSoScenario(t, r.so(t, "quantity"), 2, "đổi thành phần vẫn cho lưu")
	canSoScenario(t, s.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_item_component'
  AND before_image->>'quantity'='3' AND after_image->>'quantity'='2' AND reason=$1 AND person_id=$2`, reason, s.chu), 1, "vết sửa thành phần có người và lý do")
	// Hợp đồng ItemComponent không có trường nhắc; không tự bịa một trường để ký đạt phần UI.
	t.Logf("S3 bước 9: hợp đồng ItemComponent chưa có lời nhắc trước khi lưu; cần Claude chấm riêng yêu cầu ấy")
	s.docLai(t, sc, 10, combo)
	dCombo := combo.out.so(t, "sales_order_id")
	canSoScenario(t, s.docSo(t, `SELECT sum(j.n) FROM (SELECT count(*) n FROM shop.station_job j
  JOIN shop.order_line_component lc ON lc.id=j.order_line_component_id
  WHERE j.sales_order_id=$1 AND lc.menu_component_id=$2 AND j.station_code='trang_banh') j`, dCombo, s.banh), 6, "combo cũ vẫn sáu bánh")
	s.docLai(t, sc, 10, l1)
	s.postBuoc(t, sc, 10, fmt.Sprintf("/dining-tables/%d/cleaning", ban), s.quay, map[string]any{}, http.StatusOK)
	return ketScenario{mat: cu + moi, tong: cu + moi, bills: []int64{hd}, orders: []int64{d1, d2}, sessions: []int64{ph}}
}

func (s *dienScenario) canGiaMenu(t *testing.T, r traLoi, mon int64, ids []int64, want int64) {
	t.Helper()
	wantIDs := append([]int64(nil), ids...)
	sort.Slice(wantIDs, func(i, j int) bool { return wantIDs[i] < wantIDs[j] })
	for _, v := range r.body["items"].([]any) {
		m := v.(map[string]any)
		if int64(m["menu_item_id"].(float64)) != mon {
			continue
		}
		for _, v := range m["prices"].([]any) {
			p := v.(map[string]any)
			co := []int64{}
			for _, id := range p["option_ids"].([]any) {
				co = append(co, int64(id.(float64)))
			}
			sort.Slice(co, func(i, j int) bool { return co[i] < co[j] })
			if reflect.DeepEqual(co, wantIDs) {
				canSoScenario(t, int64(p["unit_price_vnd"].(float64)), want, "giá menu chung năm kênh")
				return
			}
		}
	}
	t.Fatalf("menu thiếu món %d tổ hợp %v", mon, ids)
}

func TestI002_Scenario1_QRTaiBanBaLuotMotHoaDon(t *testing.T) { dungScenario(t, 1).scenario1(t) }
func TestI007_Scenario2_BaDonMangDiBaKenh(t *testing.T)       { dungScenario(t, 2).scenario2(t) }
func TestI009_Scenario3_DoiGiaGiuaBuoi(t *testing.T) {
	s := dungScenario(t, 3)
	mot := s.scenario1(t)
	s.scenario3(t, mot.combo)
}

func TestI021_MotNgayDienQuaCuaRa0dLech(t *testing.T) {
	s := dungScenario(t, 4)
	canSoScenario(t, s.docSo(t, "SELECT count(*) FROM shop.bill WHERE sale_date=$1::date", s.ngay), 0, "ngày sạch")
	dau := dauKetMau()
	var dauTien int64
	for _, x := range dau {
		dauTien += x.soTien
	}
	s.postBuoc(t, "Ngày", 1, "/opening-floats", s.quay, cacXap(dau), http.StatusCreated)
	mot := s.scenario1(t)
	hai := s.scenario2(t)
	ba := s.scenario3(t, mot.combo)
	mat, tong := mot.mat+hai.mat+ba.mat, mot.tong+hai.tong+ba.tong
	dem := dauKetMau()
	dem[len(dem)-1].soTien += mat
	s.postBuoc(t, "Ngày", 2, "/cash-counts", s.quay, cacXap(dem), http.StatusCreated)
	path := "/sale-days/" + s.ngay + "/cash-reconciliation"
	r := s.goiBuoc(t, "Ngày", 3, "GET", path, s.chu, nil, http.StatusOK)
	canSoScenario(t, r.so(t, "counted_vnd"), dauTien+mat, "đếm tiền mặt thực")
	canSoScenario(t, r.so(t, "opening_float_vnd"), dauTien, "đầu két")
	canSoScenario(t, r.so(t, "expected_vnd"), mat, "vế phải độc lập")
	canSoScenario(t, r.so(t, "gap_vnd"), 0, "lệch két")
	doanhThu := func() int64 {
		return s.docSo(t, "SELECT coalesce(sum(due_vnd-discount_vnd),0) FROM shop.bill WHERE sale_date=$1::date", s.ngay)
	}
	canSoScenario(t, doanhThu(), tong, "doanh thu cả ba scenario")
	r = s.postBuoc(t, "Ngày", 4, "/sale-days/"+s.ngay+"/reconciliation", s.chu, map[string]any{}, http.StatusCreated)
	canSoScenario(t, r.so(t, "gap_vnd"), 0, "chủ ký ngày lệch không")
	// Đổi menu SAU ký không được kéo lại doanh thu của ngày đã ký.
	base := s.docSo(t, "SELECT base_price_vnd FROM shop.menu_component WHERE id=$1", s.banh)
	s.goiBuoc(t, "Ngày", 5, "PUT", fmt.Sprintf("/menu-components/%d/base-price", s.banh), s.chu, map[string]any{"base_price_vnd": base + giaScenario(s.ca(t, 1), 1), "reason": "P3-13 kiểm doanh thu ngày đã ký"}, http.StatusOK)
	r = s.goiBuoc(t, "Ngày", 6, "GET", path, s.chu, nil, http.StatusOK)
	canSoScenario(t, r.so(t, "gap_vnd"), 0, "đọc lại ngày đã ký")
	canSoScenario(t, r.so(t, "expected_vnd"), mat, "tiền ngày ký không đổi theo menu")
	canSoScenario(t, doanhThu(), tong, "doanh thu sau ký và đổi menu")
	s.docLai(t, "Ngày", 6, mot.combo)
	bills := append(append(mot.bills, hai.bills...), ba.bills...)
	orders := append(append(mot.orders, hai.orders...), ba.orders...)
	sessions := append(mot.sessions, ba.sessions...)
	s.doiChieuScenario(t, dauTien+mat, dauTien, mat, bills, orders, sessions)
}

// Cùng nguồn với ketNgayDoiChieu; helper cũ cố định tháng 3 nên bản này nhận
// ngày tháng 7. Các tập đối chiếu lọc đúng ngày/đơn/phiên do bài diễn tạo,
// vì database chung chứa cả lỗi cài có chủ ý của test khác.
func (s *dienScenario) doiChieuScenario(t *testing.T, dem, dau, ve int64, bills, orders, sessions []int64) {
	t.Helper()
	root, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	emit := func(arg string) string {
		t.Helper()
		cmd := exec.Command("./scripts/reconcile.sh", arg)
		cmd.Dir = strings.TrimSpace(string(root))
		out, err := cmd.Output()
		if err != nil {
			t.Fatalf("reconcile %s: %v", arg, err)
		}
		return string(out)
	}
	conn, err := pgx.Connect(s.ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(context.Background())
	if _, err = conn.Exec(s.ctx, "SET search_path TO shop, public"); err != nil {
		t.Fatal(err)
	}
	if _, err = conn.Exec(s.ctx, "SELECT set_config('TimeZone',$1,false)", testhelper.ShopTZ(t)); err != nil {
		t.Fatal(err)
	}
	if _, err = conn.Exec(s.ctx, emit("--emit-prelude")); err != nil {
		t.Fatal(err)
	}
	var a, b, c int64
	if err = conn.QueryRow(s.ctx, "SELECT dem_duoc,dau_ket,ve_phai FROM pg_temp.ket_ngay($1) WHERE ngay=$2::date", testhelper.ShopTZ(t), s.ngay).Scan(&a, &b, &c); err != nil {
		t.Fatal(err)
	}
	canSoScenario(t, a, dem, "đối chiếu số đếm")
	canSoScenario(t, b, dau, "đối chiếu đầu két")
	canSoScenario(t, c, ve, "đối chiếu vế phải")
	toStrings := func(ids []int64) []string {
		out := []string{}
		for _, id := range ids {
			out = append(out, fmt.Sprint(id))
		}
		return out
	}
	checked := 0
	for _, block := range strings.Split(emit("--emit-queries"), "\\echo ") {
		if !strings.HasPrefix(block, "'@@@|I-0") {
			continue
		}
		switch strings.SplitN(block, "\n", 2)[0] {
		case "'@@@|I-008/1'", "'@@@|I-008/2'", "'@@@|I-008/3'":
			t.Logf("bỏ qua đối chiếu %s: sales_order.created_at dùng giờ database thật, còn don.DongHo và ngayban.DongHo dùng đồng hồ giả; vế I-008 đã có test qua cửa TestI008_*", strings.SplitN(block, "\n", 2)[0])
			continue
		}
		begin, end := strings.Index(block, "FROM (\n"), strings.LastIndex(block, "\n) q;")
		if begin < 0 || end < 0 {
			t.Fatalf("không đọc được tập đối chiếu: %s", block)
		}
		query := block[begin+len("FROM (\n") : end]
		var count int64
		err = conn.QueryRow(s.ctx, `SELECT count(*) FROM (`+query+`) q WHERE to_jsonb(q)->>'ngay'=$1
   OR to_jsonb(q)->>'hoa_don'=ANY($2::text[]) OR to_jsonb(q)->>'don'=ANY($3::text[])
   OR to_jsonb(q)->>'phien'=ANY($4::text[])`, s.ngay, toStrings(bills), toStrings(orders), toStrings(sessions)).Scan(&count)
		if err != nil || count != 0 {
			t.Fatalf("%s: %d dòng lệch, %v", strings.SplitN(block, "\n", 2)[0], count, err)
		}
		t.Logf("đối chiếu %s: 0 dòng của ngày/đơn/phiên bài diễn", strings.SplitN(block, "\n", 2)[0])
		checked++
	}
	if checked < 6 {
		t.Fatalf("chỉ chạy %d tập đối chiếu", checked)
	}
}
