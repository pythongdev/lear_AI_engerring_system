// Lùi mẻ khi một đơn vị của mẻ thuộc đơn đã huỷ (P3-10, ADR-090 Sửa đổi 2026-10-09; I-019 · I-020).
// Lùi mẻ nghĩa là mẻ ấy không có thật: giữ đơn vị của đơn huỷ ở "đã làm" để lại một cái bánh không ai
// tráng, mà cửa chuyển sẽ đem cộng cho bàn khác. Ghi chú bánh làm sai còn hiệu lực vẫn chặn lùi (ADR-077).
package don_test

import (
	"net/http"
	"testing"
)

func TestI020_LuiMeTraCaDonViCuaDonDaHuy(t *testing.T) {
	c := dungBan(t)
	_, _, donHuy, _ := c.phienDangPhucVu(t, "lùi huỷ A")
	banB, _, donB, _ := c.phienDangPhucVu(t, "lùi huỷ B")
	a, b := c.viec(t, donHuy, "pending"), c.viec(t, donB, "pending")
	kB := c.khoaCua(t, b[0])
	truocB := phanCua(c.bang(t, ""), kB, banB, 0)
	r := c.bamMe(t, c.quay, a[0], b[0])
	canDat(t, r, http.StatusCreated)
	me := r.so(t, "production_batch_id")
	canDat(t, c.huyDon(t, c.quay, donHuy), http.StatusOK)

	canDat(t, c.luiMe(t, c.quay, me), http.StatusOK)
	if len(c.viecCua(t, donHuy, "made")) != 0 {
		t.Fatal("lùi mẻ phải trả cả đơn vị của đơn đã huỷ về chưa làm — mẻ không có thật")
	}
	if p := phanCua(c.bang(t, ""), kB, banB, 0); p != truocB {
		t.Fatalf("bàn B phải về đúng như trước lúc bấm: trước %+v, sau %+v", truocB, p)
	}
	// Đơn vị vừa lùi không còn là nguồn chuyển: không có bánh thật nào để đem cho bàn khác.
	canMa(t, c.chuyen(t, c.quay, [2]int64{a[0], b[1]}), http.StatusConflict, "transfer_source_not_available", "")

	// Ghi chú bánh làm sai còn hiệu lực vẫn chặn lùi, kể cả khi đơn đã huỷ (ADR-077).
	r2 := c.bamMe(t, c.quay, a[1])
	if r2.status == http.StatusCreated {
		t.Fatal("đơn đã huỷ không được bấm mẻ mới")
	}
	_, _, donHuy2, _ := c.phienDangPhucVu(t, "lùi huỷ C")
	a2 := c.viec(t, donHuy2, "pending")
	r3 := c.bamMe(t, c.quay, a2[0])
	canDat(t, r3, http.StatusCreated)
	canDat(t, c.huyDon(t, c.quay, donHuy2), http.StatusOK)
	canDat(t, c.ghiLamSai(t, c.quay, a2[0], nil), http.StatusCreated)
	truoc := c.anhSanXuat(t, a2[0])
	canMa(t, c.luiMe(t, c.quay, r3.so(t, "production_batch_id")), http.StatusConflict, "station_job_has_wrong_make_note", "")
	if s := c.anhSanXuat(t, a2[0]); s != truoc {
		t.Fatalf("lùi bị từ chối mà vẫn đổi: %s → %s", truoc, s)
	}
	t.Logf("mẻ %d có đơn vị của đơn huỷ %d ⇒ lùi trả cả hai về chưa làm; có ghi chú làm sai ⇒ từ chối", me, donHuy)
}
