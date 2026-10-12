package don_test

import (
	"net/http"
	"strconv"
	"testing"
)

// Phần đọc/ký lại độc lập với cửa sửa: dòng mở lại là dữ liệu mồi của test.
func TestI021_DocChuoiVaKyLai(t *testing.T) {
	n := dungTien(t)
	day := ngayGiay(t, n, 12)
	duKetGiay(t, n)
	r := ketGiay(t, n, day)
	canDat(t, r, http.StatusOK)
	if r.body["status"] != nil || len(r.body["reconciliations"].([]any)) != 0 {
		t.Fatalf("ngày chưa ký: %v", r.body)
	}
	ky := func(body map[string]any) traLoi { return n.post(t, "/sale-days/"+day+"/reconciliation", n.chu, body) }
	first := ky(map[string]any{})
	canDat(t, first, http.StatusCreated)
	a := first.so(t, "reconciled_day_id")
	canMa(t, ky(map[string]any{}), http.StatusConflict, "sale_day_already_reconciled", "")
	if _, err := n.owner.Exec(n.ctx, `INSERT INTO shop.reconciled_day_reopening (reconciled_day_id,sale_date,reason,person_id) VALUES ($1,$2::date,'đếm lại', $3)`, a, day, n.chu); err != nil {
		t.Fatal(err)
	}
	r = ketGiay(t, n, day)
	canDat(t, r, http.StatusOK)
	if r.chu("status") != "reopened" {
		t.Fatalf("ngày mở lại: %v", r.body)
	}
	// Lệch thì ký lại cũng cần giải thích; dữ liệu mồi sửa với người và lý do.
	if _, err := n.owner.Exec(n.ctx, `SELECT set_config('shop.actor_person_id',$1,false),set_config('shop.revision_reason','test ký lại',false)`, strconv.FormatInt(n.chu, 10)); err != nil {
		t.Fatal(err)
	}
	if _, err := n.owner.Exec(n.ctx, `UPDATE shop.cash_count_line SET amount_vnd=2000 WHERE cash_count_id=(SELECT id FROM shop.cash_count WHERE sale_date=$1::date)`, day); err != nil {
		t.Fatal(err)
	}
	canMa(t, ky(map[string]any{}), http.StatusUnprocessableEntity, "gap_explanation_required", "")
	second := ky(map[string]any{"gap_explanation": "đếm lại thấy dư"})
	canDat(t, second, http.StatusCreated)
	b := second.so(t, "reconciled_day_id")
	if got := n.docSo(t, "SELECT previous_reconciled_day_id FROM shop.reconciled_day WHERE id=$1", b); got != a {
		t.Fatalf("dấu trước = %d, cần %d", got, a)
	}
	r = ketGiay(t, n, day)
	canDat(t, r, http.StatusOK)
	stamps := r.body["reconciliations"].([]any)
	if r.chu("status") != "reconciled" || len(stamps) != 2 {
		t.Fatalf("chuỗi ký lại: %v", r.body)
	}
	old, current := stamps[0].(map[string]any), stamps[1].(map[string]any)
	opening := old["reopening"].(map[string]any)
	if old["reconciled_day_id"] != float64(a) || old["previous_reconciled_day_id"] != nil || old["gap_vnd"] != float64(0) ||
		old["person_id"] != float64(n.chu) || old["created_at"] == "" ||
		opening["reason"] != "đếm lại" || opening["person_id"] != float64(n.chu) || opening["created_at"] == "" ||
		current["previous_reconciled_day_id"] != float64(a) || current["reopening"] != nil ||
		current["gap_vnd"] != float64(1000) || current["gap_explanation"] != "đếm lại thấy dư" {
		t.Fatalf("lịch sử mất dữ liệu: %v", stamps)
	}
	// Lần mở lại thứ hai giữ lịch sử, nhưng còn giấy vẫn không ký được.
	if _, err := n.owner.Exec(n.ctx, `INSERT INTO shop.reconciled_day_reopening (reconciled_day_id,sale_date,reason,person_id) VALUES ($1,$2::date,'kiểm tra tiếp',$3)`, b, day, n.chu); err != nil {
		t.Fatal(err)
	}
	if _, err := n.owner.Exec(n.ctx, `INSERT INTO shop.paper_ledger(sale_date,entry_count,person_id) VALUES ($1::date,1,$2)`, day, n.chu); err != nil {
		t.Fatal(err)
	}
	canMa(t, ky(map[string]any{"gap_explanation": "đã biết lệch"}), http.StatusConflict, "paper_entries_pending", "")
	if n.docSo(t, "SELECT count(*) FROM shop.reconciled_day WHERE sale_date=$1::date", day) != 2 {
		t.Fatal("từ chối vẫn thêm dấu")
	}
}
