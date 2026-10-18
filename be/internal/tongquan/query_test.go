package tongquan

import (
	"context"
	_ "embed"
	"testing"

	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

//go:embed testdata/overview.sql
var overviewFixture string

//go:embed testdata/finish_unit.sql
var finishUnitFixture string

// PostgreSQL thật, không skip khi thiếu DB. Giao dịch rollback cô lập fixture.
func TestQC14_ComboNgayHuyVaThieuMon(t *testing.T) {
	ctx := context.Background()
	conn, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(ctx)
	tx, err := conn.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(ctx)
	if _, err = tx.Exec(ctx, `SELECT set_config('search_path','shop,public',true),set_config('TimeZone',$1,true)`, testhelper.ShopTZ(t)); err != nil {
		t.Fatal(err)
	}
	repo := newRepository(tx)
	before, err := repo.tong(ctx, "2089-01-02")
	if err != nil {
		t.Fatal(err)
	}
	if _, err = tx.Exec(ctx, overviewFixture); err != nil {
		t.Fatal(err)
	}
	got, err := repo.tong(ctx, "2089-01-02")
	if err != nil {
		t.Fatal(err)
	}
	if got.Serving-before.Serving != 3 {
		t.Fatalf("phải đếm cả open/serving/awaiting_payment: %+v", got)
	}
	if got.AmountVnd-before.AmountVnd != 6400 {
		t.Fatalf("full combo 5800 + món 600; bỏ partial/cancelled/yesterday/no jobs: %+v", got)
	}
	if got.ServedBanh-before.ServedBanh != 2 {
		t.Fatalf("2 full; partial chỉ một trạm served chưa tính; bỏ huỷ/khác ngày/không nhận nhân: %+v", got)
	}
	if got.MinimumBanh != nil || got.MinimumWorkers != nil {
		t.Fatalf("lấy số ngày trước: %+v", got)
	}
	found := false
	for _, m := range got.MenuItems {
		if m.Name != "test-t199-combo" {
			continue
		}
		found = true
		if m.MenuComboID == nil || m.MenuItemID != nil || m.Ordered != 4 || m.Served != 2 {
			t.Fatalf("thiếu combo theo đơn vị thành phần, bỏ đơn huỷ: %+v", m)
		}
	}
	if !found {
		t.Fatal("thiếu combo ra dở")
	}
	// Cho trạm thứ hai của đúng một cái bánh ra: tăng 1, không phải 2.
	if _, err = tx.Exec(ctx, finishUnitFixture); err != nil {
		t.Fatal(err)
	}
	after, err := repo.tong(ctx, "2089-01-02")
	if err != nil {
		t.Fatal(err)
	}
	if after.ServedBanh-got.ServedBanh != 1 || after.ServedBanh-before.ServedBanh != 3 {
		t.Fatalf("hai trạm đã ra phải đếm đúng một cái bánh: trước=%+v sau=%+v", got, after)
	}
	if after.AmountVnd != got.AmountVnd {
		t.Fatal("combo vẫn ra dở không được cộng tiền")
	}
	found = false
	for _, m := range after.MenuItems {
		if m.Name == "test-t199-combo" {
			found = true
			if m.Ordered != 4 || m.Served != 3 {
				t.Fatalf("đếm trùng đơn vị theo trạm: %+v", m)
			}
		}
	}
	if !found {
		t.Fatal("mất combo vẫn còn một đơn vị chưa ra")
	}

	if _, err = tx.Exec(ctx, `INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers) VALUES ('2089-01-02',100,4)`); err != nil {
		t.Fatal(err)
	}
	got, err = repo.tong(ctx, "2089-01-02")
	if err != nil || got.MinimumBanh == nil || *got.MinimumBanh != 100 || got.MinimumWorkers == nil || *got.MinimumWorkers != 4 {
		t.Fatalf("tối thiểu đúng ngày: %+v %v", got, err)
	}
}
