package tongquan

import (
	"context"
	_ "embed"
	"os"
	"strings"
	"testing"

	"banhcuon/be/internal/phien"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

// T-225 (ADR-124): Claude viết trước khi giao; Codex làm cho xanh, không sửa kỳ vọng.

//go:embed testdata/service_board.sql
var serviceBoardFixture string

// bangFixture dựng fixture trong giao dịch rollback và đọc bảng của ngày bán hiện tại (now() theo múi giờ quán).
func bangFixture(t *testing.T) (context.Context, pgx.Tx, BangVanHanh, BangVanHanh, soTong, soTong) {
	t.Helper()
	ctx := context.Background()
	conn, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { conn.Close(ctx) })
	tx, err := conn.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { tx.Rollback(ctx) })
	if _, err = tx.Exec(ctx, `SELECT set_config('search_path','shop,public',true),set_config('TimeZone',$1,true)`, testhelper.ShopTZ(t)); err != nil {
		t.Fatal(err)
	}
	var ngay string
	if err = tx.QueryRow(ctx, `SELECT now()::date::text`).Scan(&ngay); err != nil {
		t.Fatal(err)
	}
	tongTruoc, err := newRepository(tx).tong(ctx, ngay)
	if err != nil {
		t.Fatal(err)
	}
	truoc, err := docBang(ctx, tx, ngay)
	if err != nil {
		t.Fatal(err)
	}
	if _, err = tx.Exec(ctx, serviceBoardFixture); err != nil {
		t.Fatal(err)
	}
	sau, err := docBang(ctx, tx, ngay)
	if err != nil {
		t.Fatal(err)
	}
	tongSau, err := newRepository(tx).tong(ctx, ngay)
	if err != nil {
		t.Fatal(err)
	}
	if sau.SaleDate != ngay {
		t.Fatalf("sale_date %q, muốn %q", sau.SaleDate, ngay)
	}
	return ctx, tx, truoc, sau, tongTruoc, tongSau
}

func phienCuaBan(t *testing.T, b BangVanHanh, nhan string) PhienBan {
	t.Helper()
	for _, s := range b.Sessions {
		for _, x := range s.Tables {
			if x.Label == nhan {
				return s
			}
		}
	}
	t.Fatalf("không thấy phiên của bàn %s: %+v", nhan, b.Sessions)
	return PhienBan{}
}

func thuCua(t *testing.T, s PhienBan, ten string, nhieu bool) ThuCuaBan {
	t.Helper()
	for _, x := range s.Items {
		if x.ComponentName == ten && x.ExtraFilling == nhieu {
			return x
		}
	}
	t.Fatalf("phiên %d không có %s (nhiều=%v): %+v", s.TableSessionID, ten, nhieu, s.Items)
	return ThuCuaBan{}
}

// I-019: đếm theo ĐƠN VỊ — một cái bánh có việc ở tráng và gấp là một; ra = mọi trạm served; đơn huỷ không vào.
func TestI019_BangVanHanhDemTheoDonViVaNhom(t *testing.T) {
	_, _, _, b, _, _ := bangFixture(t)
	a := phienCuaBan(t, b, "test-t225-A")
	if a.ServiceGroup != "serving" || a.SessionStatus != "serving" {
		t.Fatalf("bàn A có phần đã ra ⇒ serving: %+v", a)
	}
	if x := thuCua(t, a, "test-t225-banh", true); x.Ordered != 2 || x.Served != 1 || x.Missing != 1 {
		t.Fatalf("bánh nhiều ×2: vị trí 1 ra hết, vị trí 2 gấp chưa ra ⇒ 2/1/1, không đếm theo trạm: %+v", x)
	} else if len(x.FillingOptionIDs) != 2 || len(x.Options) != 2 {
		t.Fatalf("thiếu tuỳ chọn đã chụp: %+v", x)
	}
	if x := thuCua(t, a, "test-t225-banh", false); x.Ordered != 1 || x.Served != 1 || x.Missing != 0 || len(x.FillingOptionIDs) != 1 {
		t.Fatalf("bánh thịt thường ×1 ra hết; đơn huỷ cùng khoá không được cộng: %+v", x)
	}
	if x := thuCua(t, a, "test-t225-canh", false); x.Ordered != 1 || x.Served != 1 || len(x.FillingOptionIDs) != 0 {
		t.Fatalf("canh ×1 đã ra: %+v", x)
	}
	sauce := false
	for _, x := range a.Items {
		if x.MenuComponentID == nil {
			sauce = true
			if x.Ordered != 1 || x.Served != 0 || x.Missing != 1 {
				t.Fatalf("nước chấm cấp đơn là một đơn vị, đã làm chưa ra: %+v", x)
			}
		}
	}
	if !sauce {
		t.Fatalf("mất việc không thành phần: %+v", a.Items)
	}

	bb := phienCuaBan(t, b, "test-t225-B1")
	if bb.TableSessionID != phienCuaBan(t, b, "test-t225-B2").TableSessionID || len(bb.Tables) != 2 {
		t.Fatalf("bàn ghép phải là một phiên mang đủ hai bàn: %+v", bb)
	}
	if bb.ServiceGroup != "waiting" {
		t.Fatalf("đã gửi lượt gọi, chưa phần nào ra (tráng đã làm, gấp chưa) ⇒ waiting: %+v", bb)
	}
	if x := thuCua(t, bb, "test-t225-banh", false); x.Ordered != 1 || x.Served != 0 || x.Missing != 1 {
		t.Fatalf("bàn ghép: %+v", x)
	}
	if c := phienCuaBan(t, b, "test-t225-C"); c.ServiceGroup != "no_order" || c.SessionStatus != "open" || len(c.Items) != 0 {
		t.Fatalf("phiên chưa gửi đơn ⇒ no_order, không items: %+v", c)
	}
	for _, s := range b.Sessions {
		for _, x := range s.Tables {
			if x.Label == "test-t225-E" || x.Label == "test-t225-D" {
				t.Fatalf("phiên đóng hay bàn không phiên không vào sessions: %+v", s)
			}
		}
	}
	trong := map[string]bool{}
	for _, x := range b.EmptyTables {
		trong[x.Label] = true
	}
	if !trong["test-t225-D"] || !trong["test-t225-E"] || trong["test-t225-A"] || trong["test-t225-B1"] || trong["test-t225-C"] {
		t.Fatalf("bàn trống = không thuộc phiên chưa đóng nào: %+v", b.EmptyTables)
	}
}

// I-002: tiền đơn của phiên là đúng một chỗ cộng tiền phiên (phien.TongTien), bỏ đơn huỷ.
func TestI002_BangVanHanhTienDonBangTongTienPhien(t *testing.T) {
	ctx, tx, _, b, _, _ := bangFixture(t)
	for _, nhan := range []string{"test-t225-A", "test-t225-B1", "test-t225-C"} {
		s := phienCuaBan(t, b, nhan)
		want, err := phien.TongTien(ctx, tx, s.TableSessionID)
		if err != nil {
			t.Fatal(err)
		}
		if s.OrderTotalVnd != want {
			t.Fatalf("bàn %s: order_total_vnd %d, phien.TongTien %d", nhan, s.OrderTotalVnd, want)
		}
	}
	if a := phienCuaBan(t, b, "test-t225-A"); a.OrderTotalVnd != 6000 {
		t.Fatalf("1000 + 5000, bỏ suất chưa ra hết và đơn huỷ 99999: %d", a.OrderTotalVnd)
	}
}

// I-014: tiền đã ra là tạm tính của ADR-118 trên đơn của phiên — cùng một phép cộng với tổng quan.
func TestI014_BangVanHanhTienDaRaBangTamTinh(t *testing.T) {
	_, _, _, b, tongTruoc, tongSau := bangFixture(t)
	a := phienCuaBan(t, b, "test-t225-A")
	if a.ServedAmountVnd != 6000 {
		t.Fatalf("canh 1000 + bánh thường 5000; suất bánh nhiều gồm hai cái chưa ra hết: %d", a.ServedAmountVnd)
	}
	if s := phienCuaBan(t, b, "test-t225-B1"); s.ServedAmountVnd != 0 {
		t.Fatalf("chưa phần nào ra ⇒ 0: %d", s.ServedAmountVnd)
	}
	// Cùng dữ liệu: tổng quan cộng S1 (6000) + phiên đã đóng S4 (3000) của ngày bán.
	if d := tongSau.AmountVnd - tongTruoc.AmountVnd; d != a.ServedAmountVnd+3000 {
		t.Fatalf("tạm tính tổng quan tăng %d, bảng vận hành bàn A %d + bàn E 3000 — hai phép cộng lệch", d, a.ServedAmountVnd)
	}
}

// I-019: lịch sử đem ra đọc từ vết made → served; một lần bấm cho một bàn và một khoá gom của một trạm là một mục.
func TestI019_LichSuDemRaDocTuVet(t *testing.T) {
	ctx, tx, truoc, b, _, _ := bangFixture(t)
	cua := func(bang BangVanHanh) []LanDemRa {
		out := []LanDemRa{}
		for _, x := range bang.ServeHistory {
			if strings.HasPrefix(x.TableLabel, "test-t225-") {
				out = append(out, x)
			}
		}
		return out
	}
	if len(cua(truoc)) != 0 {
		t.Fatal("lịch sử có mục trước fixture")
	}
	got := cua(b)
	type khoa struct {
		ban, tram, ten string
		nhan           int
	}
	dem := map[khoa]int64{}
	for _, x := range got {
		if x.PersonName != "test-t225-quay" || x.PersonID <= 0 || x.ServedAt.IsZero() || x.DiningTableID <= 0 {
			t.Fatalf("mục lịch sử thiếu người, giờ hay bàn: %+v", x)
		}
		dem[khoa{x.TableLabel, x.StationCode, x.ComponentName, len(x.FillingOptionIDs)}] += x.Quantity
	}
	want := map[khoa]int64{
		{"test-t225-A", "gap_banh", "test-t225-banh", 2}: 1,
		{"test-t225-A", "gap_banh", "test-t225-banh", 1}: 1,
		{"test-t225-A", "canh", "test-t225-canh", 0}:     1,
		{"test-t225-E", "canh", "test-t225-canh", 0}:     2,
	}
	if len(got) != len(want) || len(dem) != len(want) {
		t.Fatalf("muốn %d mục (canh ×2 của bàn E cùng lần bấm là MỘT mục), có %d: %+v", len(want), len(got), got)
	}
	for k, q := range want {
		if dem[k] != q {
			t.Fatalf("%+v: quantity %d, muốn %d — có %+v", k, dem[k], q, got)
		}
	}
	// Vết khác ngày bán hay không phải made → served thì không vào.
	if _, err := tx.Exec(ctx, `
INSERT INTO record_revision(target_table_code,target_row,before_image,after_image,reason,person_id,created_at)
SELECT 'station_job', j.id, to_jsonb(j) || '{"status":"made"}', to_jsonb(j), 'test-t225-hom-qua', r.person_id, now() - interval '1 day'
FROM station_job j JOIN record_revision r ON r.target_table_code='station_job' AND r.target_row=j.id AND r.reason='test-t225-fixture'
LIMIT 1;
INSERT INTO record_revision(target_table_code,target_row,before_image,after_image,reason,person_id)
SELECT 'station_job', j.id, to_jsonb(j) || '{"status":"made"}', to_jsonb(j) || '{"status":"pending"}', 'test-t225-lui', r.person_id
FROM station_job j JOIN record_revision r ON r.target_table_code='station_job' AND r.target_row=j.id AND r.reason='test-t225-fixture'
LIMIT 1;`); err != nil {
		t.Fatal(err)
	}
	ngay := b.SaleDate
	lai, err := docBang(ctx, tx, ngay)
	if err != nil {
		t.Fatal(err)
	}
	if n := len(cua(lai)); n != len(got) {
		t.Fatalf("vết hôm qua hay made → pending lọt vào lịch sử: %d mục, muốn %d", n, len(got))
	}
	for i := 1; i < len(lai.ServeHistory); i++ {
		if lai.ServeHistory[i].ServedAt.After(lai.ServeHistory[i-1].ServedAt) {
			t.Fatal("lịch sử phải mới nhất trước")
		}
	}
}

// đoạn trả phần giữa hai dấu, cùng cách TestI019_KhoaGomMotDinhNghia đọc khoá gom.
func doanTamTinh(t *testing.T, file string) string {
	t.Helper()
	b, err := os.ReadFile(file)
	if err != nil {
		t.Fatal(err)
	}
	s := string(b)
	dau, cuoi := "-- tạm tính: đầu", "-- tạm tính: cuối"
	i, j := strings.Index(s, dau), strings.Index(s, cuoi)
	if i < 0 || j < i || strings.Count(s, dau) != 1 || strings.Count(s, cuoi) != 1 {
		t.Fatalf("%s phải có đúng một cặp dấu %q … %q", file, dau, cuoi)
	}
	return s[i : j+len(cuoi)]
}

// I-014 (ADR-124 điểm 5): phép cộng tạm tính có một định nghĩa — giống từng byte ở tổng quan và bảng vận hành.
func TestI014_TamTinhMotDinhNghia(t *testing.T) {
	tong := doanTamTinh(t, "sql/tong.sql")
	if ban := doanTamTinh(t, "sql/bang_van_hanh.sql"); ban != tong {
		t.Fatalf("đoạn tạm tính lệch giữa sql/tong.sql và sql/bang_van_hanh.sql:\n--- tong.sql\n%s\n--- bang_van_hanh.sql\n%s", tong, ban)
	}
	if phien := doanTamTinh(t, "../phien/sql/tong_tien.sql"); phien != tong {
		t.Fatal("đoạn tiền phiên lệch tổng quan")
	}
	if don := doanTamTinh(t, "../phien/sql/don_co_suat_da_ra.sql"); don != tong {
		t.Fatal("đoạn đếm suất lệch tổng quan")
	}
	for _, phan := range []string{"line_total_vnd", "parent_order_line_id", "bool_and(j.status = 'served')", "min(c.so_suat)", "floor("} {
		if !strings.Contains(tong, phan) {
			t.Fatalf("đoạn tạm tính thiếu %s — đơn vị bán = dòng gốc + dòng con, ra hết = mọi việc served", phan)
		}
	}
}
