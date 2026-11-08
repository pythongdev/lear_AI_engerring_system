package don_test

import (
	"net/http"
	"testing"
)

// Chủ quán điều hành đơn chờ và ghi đem ra trên cùng cửa có vết; người ngoài quầy không được nâng quyền.
func TestI012_ChuQuanVanHanhDuyetTuChoiVaGhiDemRa(t *testing.T) {
	c := dungBan(t)
	ngoai := c.nguoi(t, "ngoài quầy", false)
	ban := c.banMoi(t, "chủ quán duyệt")
	ma := c.capMaQR(t, ban)

	q := c.goiQR(t, ma, dauLanGui(t), c.dong(false))
	canDat(t, q, http.StatusCreated)
	canMa(t, c.duyet(t, ngoai, q.so(t, "sales_order_id")), http.StatusForbidden, "not_on_counter_duty", "")
	canDat(t, c.duyet(t, c.chu, q.so(t, "sales_order_id")), http.StatusOK)
	if got := c.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'sales_order'
		AND target_row = $1 AND after_image ->> 'status' = 'confirmed' AND person_id = $2`, q.so(t, "sales_order_id"), c.chu); got != 1 {
		t.Fatal("chủ quán duyệt phải để vết mang đúng người")
	}

	q2 := c.goiQR(t, ma, dauLanGui(t), c.dong(false))
	canDat(t, q2, http.StatusCreated)
	canMa(t, c.tuChoi(t, ngoai, q2.so(t, "sales_order_id")), http.StatusForbidden, "not_on_counter_duty", "")
	canDat(t, c.tuChoi(t, c.chu, q2.so(t, "sales_order_id")), http.StatusOK)
	if got := c.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'sales_order'
		AND target_row = $1 AND after_image ->> 'status' = 'cancelled' AND person_id = $2`, q2.so(t, "sales_order_id"), c.chu); got != 1 {
		t.Fatal("chủ quán từ chối phải để vết mang đúng người")
	}

	ban2, _, don, _ := c.phienDangPhucVu(t, "chủ quán đem ra")
	viec := c.viec(t, don, "pending")
	canDat(t, c.bamMe(t, c.quay, viec...), http.StatusCreated)
	muc := c.mucCua(t, viec[0], 1)
	canMa(t, c.raBanSo(t, ngoai, ban2, 0, muc), http.StatusForbidden, "not_on_counter_duty", "")
	canDat(t, c.raBanSo(t, c.chu, ban2, 0, muc), http.StatusOK)
	if got := c.docSo(t, "SELECT count(*) FROM shop.station_job WHERE id = $1 AND status = 'served'", viec[0]); got != 1 {
		t.Fatalf("chủ quán ghi đem ra nhưng việc %d chưa served", viec[0])
	}
	if got := c.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE target_table_code = 'station_job'
		AND target_row = $1 AND after_image ->> 'status' = 'served' AND person_id = $2`, viec[0], c.chu); got != 1 {
		t.Fatal("chủ quán ghi đem ra phải để vết mang đúng người")
	}
}
