package don_test

import (
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
)

func TestI016_KhoangHoQRQuaCua(t *testing.T) {
	c := dungBan(t)
	ban, phien, don, _ := c.phienDangPhucVu(t, "QR khoảng hở")
	c.xong(t, don)
	canDat(t, c.tinhTien(t, c.quay, phien), 200)
	r := c.goiQR(t, c.capMaQR(t, ban), dauLanGui(t), c.dong(false))
	canDat(t, r, 201)
	canDat(t, c.tuChoi(t, c.quay, r.so(t, "sales_order_id")), 200)
	canDat(t, c.tinhTien(t, c.quay, phien), 200)
	root, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command("./scripts/reconcile.sh", "--emit-prelude")
	cmd.Dir = strings.TrimSpace(string(root))
	prelude, err := cmd.Output()
	if err != nil {
		t.Fatal(err)
	}
	query, err := os.ReadFile(filepath.Join(cmd.Dir, "db/reconcile/i016.sql"))
	if err != nil {
		t.Fatal(err)
	}
	tx, err := c.owner.Begin(c.ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(c.ctx)
	if _, err := tx.Exec(c.ctx, "SET LOCAL search_path TO shop, public"); err != nil {
		t.Fatal(err)
	}
	if _, err := tx.Exec(c.ctx, string(prelude)); err != nil {
		t.Fatal(err)
	}
	dem := func(want int) {
		t.Helper()
		var got int
		if err := tx.QueryRow(c.ctx, "SELECT count(*) FROM ("+string(query)+") q WHERE bang='table_session' AND dong=$1", phien).Scan(&got); err != nil {
			t.Fatal(err)
		}
		if got != want {
			t.Fatalf("I-016/1 phiên %d: có %d dòng, cần %d", phien, got, want)
		}
		t.Logf("I-016/1 phiên %d: %d dòng", phien, got)
	}
	dem(0)
	// Bỏ chứng cứ QR khỏi khoảng bằng lỗi cài trong giao dịch sẽ lùi; không sửa vết.
	// Lệch created_at còn bị câu khác bắt; ở đây chỉ chấm đúng I-016/1.
	if _, err := tx.Exec(c.ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test F060: đẩy QR ngoài khoảng',true)`, strconv.FormatInt(c.quay, 10)); err != nil {
		t.Fatal(err)
	}
	// Cùng khoảng hở, đơn trong khoảng nhưng không phải kênh qr_table (Claude thêm 2026-10-12: lỗi cài bỏ điều
	// kiện kênh từng lọt) ⇒ khoảng hở không được tha.
	if _, err := tx.Exec(c.ctx, "SAVEPOINT kenh"); err != nil {
		t.Fatal(err)
	}
	if _, err := tx.Exec(c.ctx, "UPDATE shop.sales_order SET channel_code='staff_pos', qr_code_id=NULL WHERE id=$1", r.so(t, "sales_order_id")); err != nil {
		t.Fatal(err)
	}
	dem(1)
	if _, err := tx.Exec(c.ctx, "ROLLBACK TO SAVEPOINT kenh"); err != nil {
		t.Fatal(err)
	}
	dem(0)
	if _, err := tx.Exec(c.ctx, "UPDATE shop.sales_order SET created_at=created_at-interval '1 day' WHERE id=$1", r.so(t, "sales_order_id")); err != nil {
		t.Fatal(err)
	}
	dem(1)
}
