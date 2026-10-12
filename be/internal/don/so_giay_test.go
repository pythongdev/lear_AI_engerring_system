package don_test

import (
	"context"
	"fmt"
	"net/http"
	"testing"
	"time"

	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

// Các ngày tháng 4 riêng cho lát sổ giấy; đồng hồ vẫn qua ngayban.DongHo.
func ngayGiay(t *testing.T, n tien, day int) string {
	t.Helper()
	moc := time.Date(2031, 4, day, 12, 0, 0, 0, n.loc)
	goc := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil }
	t.Cleanup(func() { ngayban.DongHo = goc })
	return moc.Format("2006-01-02")
}
func khaiGiay(t *testing.T, n tien, person int64, day string, count int) traLoi {
	t.Helper()
	return n.post(t, "/sale-days/"+day+"/paper-ledger", person, map[string]any{"entry_count": count})
}
func ketGiay(t *testing.T, n tien, day string) traLoi {
	t.Helper()
	status, body := n.goi(t, "GET", "/sale-days/"+day+"/cash-reconciliation", n.chu, nil)
	return traLoi{status: status, body: body}
}
func duKetGiay(t *testing.T, n tien) {
	t.Helper()
	canDat(t, n.khaiDauKet(t, n.quay, []xap{{1000, 1000}}), http.StatusCreated)
	canDat(t, n.demKet(t, n.quay, []xap{{1000, 1000}}), http.StatusCreated)
}
func TestYC08_KhaiSoGiayQuaCua(t *testing.T) {
	n := dungTien(t)
	day := ngayGiay(t, n, 1)
	for i, who := range []int64{n.quay, n.chu} {
		d := fmt.Sprintf("2031-03-%02d", 30+i)
		r := khaiGiay(t, n, who, d, 3)
		canDat(t, r, http.StatusCreated)
		if r.so(t, "entry_count") != 3 || r.chu("sale_date") != d {
			t.Fatalf("sổ: %v", r.body)
		}
		if got := n.docSo(t, "SELECT person_id FROM shop.paper_ledger WHERE id = $1", r.so(t, "paper_ledger_id")); got != who {
			t.Fatalf("người khai = %d, cần %d", got, who)
		}
	}
	canDat(t, khaiGiay(t, n, n.quay, day, 2), http.StatusCreated)
	canMa(t, khaiGiay(t, n, n.chu, day, 2), http.StatusConflict, "paper_ledger_already_declared", "")
	canMa(t, khaiGiay(t, n, n.quay, "2031-04-02", 1), http.StatusBadRequest, "invalid_request", "sale_date")
	for _, count := range []int{0, -1} {
		canMa(t, khaiGiay(t, n, n.quay, "2031-03-29", count), http.StatusBadRequest, "invalid_request", "entry_count")
	}
	khac := n.nguoi(t, "ngoài quầy", false)
	canMa(t, khaiGiay(t, n, khac, "2031-03-29", 1), http.StatusForbidden, "not_on_counter_duty", "")
	canMa(t, khaiGiay(t, n, 0, "2031-03-29", 1), http.StatusUnauthorized, "unauthenticated", "")
	if got := n.docSo(t, "SELECT count(*) FROM shop.paper_ledger WHERE sale_date IN ('2031-04-02','2031-03-29')"); got != 0 {
		t.Fatalf("từ chối vẫn ghi %d sổ", got)
	}
}
func TestYC08_KhaiSoGiayNgayDaKy(t *testing.T) {
	n := dungTien(t)
	day := ngayGiay(t, n, 2)
	duKetGiay(t, n)
	r := ketGiay(t, n, day)
	canDat(t, r, http.StatusOK)
	if v, ok := r.body["paper_entries_declared"]; !ok || v != nil || r.so(t, "paper_entries_pending") != 0 {
		t.Fatalf("ngày không sổ: %v", r.body)
	}
	canDat(t, n.post(t, "/sale-days/"+day+"/reconciliation", n.chu, map[string]any{}), http.StatusCreated)
	canMa(t, khaiGiay(t, n, n.quay, day, 1), http.StatusConflict, "sale_day_reconciled", "")
	if got := n.docSo(t, "SELECT count(*) FROM shop.paper_ledger WHERE sale_date = $1::date", day); got != 0 {
		t.Fatal("ngày ký vẫn thêm sổ")
	}
}
func TestI014_KyNgayConLuotGiayBiTuChoi(t *testing.T) {
	n := dungTien(t)
	day := ngayGiay(t, n, 3)
	duKetGiay(t, n)
	canDat(t, khaiGiay(t, n, n.quay, day, 3), http.StatusCreated)
	r := ketGiay(t, n, day)
	canDat(t, r, http.StatusOK)
	if r.so(t, "paper_entries_declared") != 3 || r.so(t, "paper_entries_pending") != 3 {
		t.Fatalf("số giấy: %v", r.body)
	}
	canMa(t, n.post(t, "/sale-days/"+day+"/reconciliation", n.chu, map[string]any{}), http.StatusConflict, "paper_entries_pending", "")
	if n.docSo(t, "SELECT count(*) FROM shop.reconciled_day WHERE sale_date = $1::date", day) != 0 {
		t.Fatal("còn giấy vẫn có dấu")
	}
}
func TestI014_KhaiSoChenLucKyNgay(t *testing.T) {
	n := dungTien(t)
	day := ngayGiay(t, n, 4)
	duKetGiay(t, n)
	giu, err := pgx.Connect(n.ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer giu.Close(context.Background())
	tx, err := giu.Begin(n.ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(context.Background())
	if _, err := tx.Exec(n.ctx, "LOCK TABLE shop.paper_ledger IN SHARE MODE"); err != nil {
		t.Fatal(err)
	}
	var khai, ky traLoi
	khaiXong, kyXong := make(chan struct{}), make(chan struct{})
	go func() { defer close(khaiXong); khai = khaiGiay(t, n, n.quay, day, 2) }()
	if !n.choDen(t, "relation", "INSERT INTO paper_ledger", khaiXong) {
		t.Fatalf("khai xong trước khoá: %v", khai.body)
	}
	go func() {
		defer close(kyXong)
		ky = n.post(t, "/sale-days/"+day+"/reconciliation", n.chu, map[string]any{})
	}()
	cho := n.choDen(t, "advisory", "", kyXong)
	if err := tx.Commit(n.ctx); err != nil {
		t.Fatal(err)
	}
	<-khaiXong
	<-kyXong
	canDat(t, khai, http.StatusCreated)
	canMa(t, ky, http.StatusConflict, "paper_entries_pending", "")
	if !cho {
		t.Fatal("ký không đợi khoá ngày của cửa khai giấy")
	}
	if n.docSo(t, "SELECT count(*) FROM shop.reconciled_day WHERE sale_date = $1::date", day) != 0 {
		t.Fatal("ký lọt khi còn giấy")
	}
}
