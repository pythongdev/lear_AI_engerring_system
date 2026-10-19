package tongket

import (
	"banhcuon/be/internal/testhelper"
	"context"
	_ "embed"
	"encoding/json"
	"github.com/jackc/pgx/v5"
	"testing"
)

//go:embed testdata/summary.sql
var revenueFixture string

//go:embed testdata/best_staff.sql
var bestStaffFixture string

func fixtureTx(t *testing.T) pgx.Tx {
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
	return tx
}
func runFixture(t *testing.T, tx pgx.Tx, sql string) {
	t.Helper()
	if _, err := tx.Exec(context.Background(), sql); err != nil {
		t.Fatal(err)
	}
}
func readSummary(t *testing.T, tx pgx.Tx, day string) Summary {
	t.Helper()
	out, err := newRepository(tx).doc(context.Background(), day)
	if err != nil {
		t.Fatal(err)
	}
	return out
}
func assertRevenue(t *testing.T, got Revenue, table, alone, refunds int64) {
	t.Helper()
	if got.TableSessionVnd != table || got.StandaloneVnd != alone || got.RefundsVnd != refunds || got.TotalVnd != table+alone-refunds {
		t.Fatalf("sai doanh thu: %+v; cần %d + %d - %d", got, table, alone, refunds)
	}
}
func TestI014_HaiNguonVaBaKenhMangDi(t *testing.T) {
	tx := fixtureTx(t)
	runFixture(t, tx, revenueFixture)
	assertRevenue(t, readSummary(t, tx, "2186-01-01").Revenue, 10000, 9000, 0)
}
func TestI014_NoNgayDThuNgaySauKhongTang(t *testing.T) {
	tx := fixtureTx(t)
	runFixture(t, tx, revenueFixture)
	assertRevenue(t, readSummary(t, tx, "2186-02-01").Revenue, 7000, 0, 0)
	assertRevenue(t, readSummary(t, tx, "2186-02-02").Revenue, 0, 0, 0)
}
func TestI014_BanThuHaiHoanThuTu(t *testing.T) {
	tx := fixtureTx(t)
	// So chênh với dữ liệu có sẵn của các package khác trong be-check.
	mon := readSummary(t, tx, "2186-03-06").Revenue
	wed := readSummary(t, tx, "2186-03-08").Revenue
	runFixture(t, tx, revenueFixture)
	a := readSummary(t, tx, "2186-03-06").Revenue
	b := readSummary(t, tx, "2186-03-08").Revenue
	assertRevenue(t, a, mon.TableSessionVnd, mon.StandaloneVnd+11000, mon.RefundsVnd)
	assertRevenue(t, b, wed.TableSessionVnd, wed.StandaloneVnd, wed.RefundsVnd+2500)
	if a.TotalVnd-mon.TotalVnd != 11000 || b.TotalVnd-wed.TotalVnd != -2500 {
		t.Fatal("hoàn phải trừ đúng ngày hoàn")
	}
}
func TestI014_TraTruocVaTraLaiKhongLaDoanhThu(t *testing.T) {
	tx := fixtureTx(t)
	runFixture(t, tx, revenueFixture)
	assertRevenue(t, readSummary(t, tx, "2186-04-01").Revenue, 0, 0, 0)
	assertRevenue(t, readSummary(t, tx, "2186-04-02").Revenue, 0, 6000, 0)
}
func TestQC14_BanChayComboSuatConHuyChuaHoaDonVaThuTu(t *testing.T) {
	tx := fixtureTx(t)
	runFixture(t, tx, revenueFixture)
	runFixture(t, tx, bestStaffFixture)
	out := readSummary(t, tx, "2186-05-01")
	if len(out.BestSellers.Items) != 3 || len(out.BestSellers.Combos) != 3 {
		t.Fatalf("sai tập: %+v", out.BestSellers)
	}
	for i, want := range []int64{8, 3, 3} {
		if out.BestSellers.Items[i].Quantity != want {
			t.Fatalf("suất con không nhân cha: %+v", out.BestSellers)
		}
	}
	for i, want := range []int64{4, 2, 2} {
		if out.BestSellers.Combos[i].Quantity != want {
			t.Fatalf("combo riêng: %+v", out.BestSellers)
		}
	}
	if out.BestSellers.Items[1].MenuItemID >= out.BestSellers.Items[2].MenuItemID || out.BestSellers.Combos[1].MenuComboID >= out.BestSellers.Combos[2].MenuComboID {
		t.Fatal("hoà số lượng phải mã tăng")
	}
	if out.BestSellers.Items[0].Name != "test-current-item" || out.BestSellers.Combos[0].Name != "test-current-combo" {
		t.Fatal("phải đọc tên hiện hành")
	}
}
func TestQC14_StaffBayTruongKhoangTrucVaNguoiBam(t *testing.T) {
	tx := fixtureTx(t)
	runFixture(t, tx, revenueFixture)
	runFixture(t, tx, bestStaffFixture)
	out := readSummary(t, tx, "2186-05-02")
	if len(out.Staff) != 2 {
		t.Fatalf("người toàn 0 không xuất hiện: %+v", out.Staff)
	}
	a, b := out.Staff[0], out.Staff[1]
	if a.PersonID >= b.PersonID || a.DisplayName != "test-worker-a" || !a.Worked || a.CounterOrders != 2 || a.Deliveries != 1 || a.Cancellations != 1 || a.Refunds != 2 {
		t.Fatalf("người a: %+v", a)
	}
	if b.DisplayName != "test-worker-b" || b.Worked || b.CounterOrders != 2 || b.Deliveries != 0 || b.Cancellations != 0 || b.Refunds != 0 {
		t.Fatalf("người b: %+v", b)
	}
	raw, err := json.Marshal(out.Staff)
	if err != nil {
		t.Fatal(err)
	}
	var rows []map[string]json.RawMessage
	if err = json.Unmarshal(raw, &rows); err != nil {
		t.Fatal(err)
	}
	for _, row := range rows {
		if len(row) != 7 {
			t.Fatalf("thêm trường ngoài hợp đồng: %s", raw)
		}
		for _, key := range []string{"person_id", "display_name", "worked", "counter_orders", "deliveries", "cancellations", "refunds"} {
			if _, ok := row[key]; !ok {
				t.Fatalf("thiếu %s", key)
			}
		}
	}
}
