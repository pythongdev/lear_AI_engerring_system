// Test bốn công cụ ghi giao việc của chat (CHAT-15, ADR-140 điểm 2 · 3 · 4 · 7; I-030 · I-043 · I-044). Claude viết TRƯỚC khi có
// code; Codex làm cho xanh, không sửa điều kiện kiểm. Cần PostgreSQL thật: chạy qua ./scripts/be-check.sh.
//
// Hợp đồng Claude chốt trong test này (2026-11-09, trong khung ADR-140; các lựa chọn là *phiên chọn*, ghi ở entry CHAT-15):
//   - (*troly.NguonNoiBo).CongCuGhi(ctx, nguoi): receiver nil, nguoi <= 0, người không có thật, người ngoài quầy ⇒ rỗng, không lỗi.
//     Qua lớp quay_hoac_chu_quan (đọc bằng authz.ReadAs như CongCu) ⇒ đúng bốn công cụ, thứ tự cố định:
//     giao_viec → createAssignedTask · sua_viec → updateAssignedTask · an_viec → hideAssignedTask · danh_dau_viec → markAssignedTask.
//     MoTa không rỗng. Lỗi database khác ⇒ trả lỗi.
//   - Mọi hàm DeXuat: tham số là đối tượng JSON chỉ gồm các khoá kể dưới đây; khoá lạ (kể cả assignee_person_id, assigned_task_id),
//     sai kiểu, thiếu khoá bắt buộc ⇒ lỗi. Kiểm lại lớp lúc dựng, dưới chính người của phiên: rời quầy giữa lượt ⇒ lỗi.
//     KHÔNG gọi service ghi nào; chỉ đọc qua giaoviec.Service (không câu SQL riêng của troly). Chuỗi cắt khoảng trắng hai đầu,
//     rỗng sau khi cắt ⇒ lỗi.
//   - Hạn ("han", "han_moi"): chuỗi "YYYY-MM-DDTHH:MM" theo giờ quán Asia/Ho_Chi_Minh; sai khuôn hay ngày không có thật ⇒ lỗi.
//     Thân mang due_at RFC3339 có offset, ví dụ "2030-01-02T07:30:00+07:00"; dòng hiện "07:30 ngày 02/01/2030".
//   - Tham chiếu việc ("viec"): từ 2 ký tự trở lên sau khi cắt. So khớp không phân biệt hoa thường, khoảng trắng liền nhau gộp làm
//     một, ở cả hai phía; tìm trong nội dung các việc CHƯA ẨN đọc bằng giaoviec.Service.Doc(ctx, nguoi, 0, false). Đúng một việc chứa
//     chuỗi ⇒ dùng việc ấy; không việc nào, hay từ hai việc trở lên ⇒ lỗi. Không đoán gần giống.
//   - giao_viec {"noi_dung", "han"} (cả hai bắt buộc): ThamSoDuong nil hoặc {}; Than đúng {"content", "due_at"} — KHÔNG có khoá
//     assignee_person_id; CanChon ["assignee_person_id"]; Dong: Nội dung · Hạn.
//   - sua_viec {"viec", "ly_do"} bắt buộc, {"noi_dung_moi", "han_moi"} tuỳ chọn nhưng phải có ít nhất một: ThamSoDuong
//     {"assigned_task_id": id}; Than {"content": nội dung mới hoặc hiện tại, "assignee_person_id": người nhận hiện tại (đọc từ việc,
//     không từ model), "reason"} cộng "due_at" chỉ khi có han_moi; CanChon rỗng; Dong: Việc · Người nhận · [Nội dung mới] · [Hạn mới] · Lý do.
//   - an_viec {"viec", "ly_do"}: ThamSoDuong {"assigned_task_id"}; Than {"reason"}; Dong: Việc · Người nhận · Lý do.
//   - danh_dau_viec {"viec", "danh_dau": "done" | "undone"}: ThamSoDuong {"assigned_task_id"}; Than {"mark"}; Dong: Việc · Người nhận ·
//     Hiện tại · Đổi thành, giá trị "Đã xong" / "Chưa xong". Không xét trước trạng thái — cửa markAssignedTask từ chối khi bấm.
//   - Mọi dòng: CongCu = tên công cụ; DocLuc khác 0 và là cùng một mốc cho mọi dòng của một đề xuất.
//   - Qua POST /chat/turns với nguồn bản chạy: người đứng quầy được kể bốn tên ghi sau tên đọc; đề xuất không ghi gì; nội dung việc và
//     tên người nhận không bao giờ có trong gói tới model, kể cả khi tham chiếu nhập nhằng (I-043).
package troly_test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"banhcuon/be/internal/troly"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

var dsGhiGiaoViec = []string{"giao_viec", "sua_viec", "an_viec", "danh_dau_viec"}
var opGhiGiaoViec = []string{"createAssignedTask", "updateAssignedTask", "hideAssignedTask", "markAssignedTask"}

type viecThu struct {
	nguoiThu
	tag      string
	nhanTen  string
	rua      int64 // "Rửa NỒI   lớn <tag>", chưa ẩn, chưa xong
	lau1     int64 // "Lau bàn sáng <tag>", chưa ẩn
	lau2     int64 // "Lau bàn chiều <tag>", chưa ẩn; cùng lau1 chứa "Lau bàn" ⇒ nhập nhằng
	anRieng  int64 // "Quét sân <tag>", ĐÃ ẨN
	xongRoi  int64 // "Phơi khăn <tag>", chưa ẩn, đã xong
	ghiTruoc string
}

// moViec tạo năm việc giao cho người ngoài quầy, nội dung mang tag riêng để không vướng việc của test khác.
func moViec(t *testing.T) viecThu {
	t.Helper()
	v := viecThu{nguoiThu: moNguoi(t), tag: fmt.Sprintf("c15-%d", time.Now().UnixNano())}
	if err := v.owner.QueryRow(v.ctx, `SELECT display_name FROM shop.person WHERE id=$1`, v.ngoai).Scan(&v.nhanTen); err != nil {
		t.Fatal(err)
	}
	han := time.Date(2030, 1, 1, 9, 0, 0, 0, time.FixedZone("ICT", 7*3600))
	err := pgx.BeginFunc(v.ctx, v.owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(v.ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-chat15',true)`, fmt.Sprint(v.chu)); e != nil {
			return e
		}
		tao := func(noiDung string, id *int64) error {
			return tx.QueryRow(v.ctx, `INSERT INTO shop.assigned_task(content,assignee_person_id,due_at) VALUES ($1,$2,$3) RETURNING id`,
				noiDung, v.ngoai, han).Scan(id)
		}
		for _, x := range []struct {
			noiDung string
			id      *int64
		}{
			{"Rửa NỒI   lớn " + v.tag, &v.rua},
			{"Lau bàn sáng " + v.tag, &v.lau1},
			{"Lau bàn chiều " + v.tag, &v.lau2},
			{"Quét sân " + v.tag, &v.anRieng},
			{"Phơi khăn " + v.tag, &v.xongRoi},
		} {
			if e := tao(x.noiDung, x.id); e != nil {
				return e
			}
		}
		if _, e := tx.Exec(v.ctx, `UPDATE shop.assigned_task SET hidden_at=now(), hidden_by_person_id=$1 WHERE id=$2`, v.chu, v.anRieng); e != nil {
			return e
		}
		_, e := tx.Exec(v.ctx, `INSERT INTO shop.assigned_task_mark(assigned_task_id,mark_code) VALUES ($1,'done')`, v.xongRoi)
		return e
	})
	if err != nil {
		t.Fatal(err)
	}
	v.ghiTruoc = v.chup(t)
	return v
}

// chup là ảnh chụp mọi dòng việc và dấu, để chứng minh dựng đề xuất không ghi gì (I-044).
func (v viecThu) chup(t *testing.T) string {
	t.Helper()
	var a, b string
	if err := v.owner.QueryRow(v.ctx, `SELECT coalesce(json_agg(x ORDER BY x.id),'[]')::text FROM shop.assigned_task x`).Scan(&a); err != nil {
		t.Fatal(err)
	}
	if err := v.owner.QueryRow(v.ctx, `SELECT coalesce(json_agg(x ORDER BY x.id),'[]')::text FROM shop.assigned_task_mark x`).Scan(&b); err != nil {
		t.Fatal(err)
	}
	return a + "|" + b
}

func (v viecThu) khongGhi(t *testing.T, luc string) {
	t.Helper()
	if v.chup(t) != v.ghiTruoc {
		t.Fatalf("%s: dựng đề xuất đã đổi bảng assigned_task hay assigned_task_mark (I-044)", luc)
	}
}

func timGhi(t *testing.T, cc []troly.CongCuGhi, ten string) troly.CongCuGhi {
	t.Helper()
	for _, c := range cc {
		if c.Ten == ten {
			return c
		}
	}
	t.Fatalf("không có công cụ ghi %s", ten)
	return troly.CongCuGhi{}
}

// dung lấy danh sách của người rồi chạy hàm dựng của công cụ tên ten với tham số thamSo.
func (v viecThu) dung(t *testing.T, nguoi int64, ten, thamSo string) (troly.DeXuat, error) {
	t.Helper()
	cc, err := troly.MoiNguonNoiBo(v.pool).CongCuGhi(v.ctx, nguoi)
	if err != nil {
		t.Fatal(err)
	}
	c := timGhi(t, cc, ten)
	if c.DeXuat == nil {
		t.Fatalf("%s không có hàm dựng", ten)
	}
	return c.DeXuat(v.ctx, json.RawMessage(thamSo))
}

type dongMuon struct{ nhan, giaTri string }

func kiemDong(t *testing.T, ten string, d troly.DeXuat, muon []dongMuon) {
	t.Helper()
	if len(d.Dong) != len(muon) {
		t.Fatalf("%s: muốn %d dòng %v, được %+v", ten, len(muon), muon, d.Dong)
	}
	for i, m := range muon {
		g := d.Dong[i]
		if g.Nhan != m.nhan || g.GiaTri != m.giaTri {
			t.Fatalf("%s dòng %d: muốn %q = %q, được %q = %q", ten, i, m.nhan, m.giaTri, g.Nhan, g.GiaTri)
		}
		if g.CongCu != ten {
			t.Fatalf("%s dòng %d: nguồn phải là %s, được %q", ten, i, ten, g.CongCu)
		}
		if g.DocLuc.IsZero() || !g.DocLuc.Equal(d.Dong[0].DocLuc) {
			t.Fatalf("%s dòng %d: mốc đọc phải khác 0 và chung cho mọi dòng: %v", ten, i, d.Dong)
		}
	}
}

func duongId(t *testing.T, d troly.DeXuat, id int64) {
	t.Helper()
	if !cungJSON(t, d.ThamSoDuong, []byte(fmt.Sprintf(`{"assigned_task_id":%d}`, id))) {
		t.Fatalf("tham số đường phải là assigned_task_id %d, được %s", id, d.ThamSoDuong)
	}
}

// ADR-140 điểm 7, I-030: chỉ lớp quay_hoac_chu_quan có bốn công cụ ghi, theo thứ tự, mỗi cái trỏ đúng operationId của cửa màn tay.
func TestI044_GiaoViecChiMoChoQuayVaChuQuan(t *testing.T) {
	n := moNguoi(t)
	nb := troly.MoiNguonNoiBo(n.pool)
	var rong *troly.NguonNoiBo
	for _, ca := range []struct {
		ten   string
		nb    *troly.NguonNoiBo
		nguoi int64
		muon  []string
	}{
		{"không phiên", nb, 0, nil},
		{"không nguồn nội bộ", rong, n.chu, nil},
		{"người không có thật", nb, 999_999_999, nil},
		{"người ngoài quầy", nb, n.ngoai, nil},
		{"người đứng quầy", nb, n.quay, dsGhiGiaoViec},
		{"chủ quán", nb, n.chu, dsGhiGiaoViec},
	} {
		cc, err := ca.nb.CongCuGhi(n.ctx, ca.nguoi)
		if err != nil {
			t.Fatalf("%s: lỗi %v", ca.ten, err)
		}
		var ten, op []string
		for _, c := range cc {
			ten = append(ten, c.Ten)
			op = append(op, c.OperationID)
			if strings.TrimSpace(c.MoTa) == "" || c.DeXuat == nil {
				t.Fatalf("%s: %s thiếu mô tả hay hàm dựng", ca.ten, c.Ten)
			}
		}
		if !reflect.DeepEqual(ten, ca.muon) {
			t.Fatalf("%s: muốn %v, được %v", ca.ten, ca.muon, ten)
		}
		if ca.muon != nil && !reflect.DeepEqual(op, opGhiGiaoViec) {
			t.Fatalf("%s: operationId muốn %v, được %v", ca.ten, opGhiGiaoViec, op)
		}
	}
}

// ADR-140 điểm 4: giao việc không bao giờ mang người nhận do model điền; hạn đổi từ giờ quán sang RFC3339 có offset.
func TestI044_GiaoViecDeTrongNguoiNhan(t *testing.T) {
	v := moViec(t)
	d, err := v.dung(t, v.quay, "giao_viec", `{"noi_dung":"  Rửa bát trưa  ","han":"2030-01-02T07:30"}`)
	if err != nil {
		t.Fatalf("giao_viec hợp lệ phải có đề xuất: %v", err)
	}
	if len(d.ThamSoDuong) != 0 && !cungJSON(t, d.ThamSoDuong, []byte(`{}`)) {
		t.Fatalf("giao_viec không có tham số đường: %s", d.ThamSoDuong)
	}
	if !cungJSON(t, d.Than, []byte(`{"content":"Rửa bát trưa","due_at":"2030-01-02T07:30:00+07:00"}`)) {
		t.Fatalf("thân giao_viec sai: %s", d.Than)
	}
	if !reflect.DeepEqual(d.CanChon, []string{"assignee_person_id"}) {
		t.Fatalf("giao_viec phải để người nhận cần chọn: %v", d.CanChon)
	}
	kiemDong(t, "giao_viec", d, []dongMuon{{"Nội dung", "Rửa bát trưa"}, {"Hạn", "07:30 ngày 02/01/2030"}})

	for _, sai := range []string{
		`{"noi_dung":"Rửa bát","han":"2030-01-02T07:30","assignee_person_id":1}`,
		`{"noi_dung":"   ","han":"2030-01-02T07:30"}`,
		`{"noi_dung":"Rửa bát"}`,
		`{"han":"2030-01-02T07:30"}`,
		`{"noi_dung":7,"han":"2030-01-02T07:30"}`,
		`{"noi_dung":"Rửa bát","han":"2030-02-30T07:30"}`,
		`{"noi_dung":"Rửa bát","han":"2030-01-02 07:30"}`,
		`{"noi_dung":"Rửa bát","han":"2030-01-02T07:30:00+07:00"}`,
		`{"noi_dung":"Rửa bát","han":"chiều mai"}`,
		`[]`,
		`null`,
	} {
		if _, err := v.dung(t, v.quay, "giao_viec", sai); err == nil {
			t.Fatalf("giao_viec phải từ chối tham số %s", sai)
		}
	}
	v.khongGhi(t, "giao_viec")
}

// Tham chiếu việc: đúng một việc chưa ẩn chứa chuỗi thì dùng; không có, nhập nhằng, hay chỉ khớp việc đã ẩn thì lỗi.
func TestI044_ThamChieuViecPhaiRaDungMot(t *testing.T) {
	v := moViec(t)
	d, err := v.dung(t, v.quay, "danh_dau_viec", fmt.Sprintf(`{"viec":"  rửa  nồi LỚN %s ","danh_dau":"done"}`, v.tag))
	if err != nil {
		t.Fatalf("tham chiếu khớp đúng một việc (khác hoa thường, khoảng trắng) phải có đề xuất: %v", err)
	}
	duongId(t, d, v.rua)

	for _, viec := range []string{
		"lau bàn " + v.tag,  // không việc nào chứa nguyên chuỗi này
		"Lau bàn",           // hai việc của test này cùng chứa
		"Quét sân " + v.tag, // chỉ khớp việc đã ẩn
		"chưa có việc nào tên thế này " + v.tag,
		"a",
		"   ",
	} {
		if _, err := v.dung(t, v.quay, "danh_dau_viec", fmt.Sprintf(`{"viec":%q,"danh_dau":"done"}`, viec)); err == nil {
			t.Fatalf("tham chiếu %q phải bị từ chối", viec)
		}
	}
	for _, sai := range []string{
		fmt.Sprintf(`{"viec":"Phơi khăn %s","danh_dau":"xong"}`, v.tag),
		fmt.Sprintf(`{"viec":"Phơi khăn %s"}`, v.tag),
		fmt.Sprintf(`{"viec":"Phơi khăn %s","danh_dau":"done","assigned_task_id":%d}`, v.tag, v.rua),
		`{"danh_dau":"done"}`,
		`{"viec":12,"danh_dau":"done"}`,
	} {
		if _, err := v.dung(t, v.quay, "danh_dau_viec", sai); err == nil {
			t.Fatalf("danh_dau_viec phải từ chối tham số %s", sai)
		}
	}
	v.khongGhi(t, "tham chiếu việc")
}

// Ba công cụ trên việc có sẵn: người nhận và nội dung hiện tại đọc từ việc, không từ model.
func TestI044_SuaAnDanhDauDungThanCuaCua(t *testing.T) {
	v := moViec(t)
	rua := "Rửa NỒI   lớn " + v.tag
	phoi := "Phơi khăn " + v.tag

	d, err := v.dung(t, v.chu, "danh_dau_viec", fmt.Sprintf(`{"viec":"Phơi khăn %s","danh_dau":"undone"}`, v.tag))
	if err != nil {
		t.Fatalf("danh_dau_viec: %v", err)
	}
	duongId(t, d, v.xongRoi)
	if !cungJSON(t, d.Than, []byte(`{"mark":"undone"}`)) || len(d.CanChon) != 0 {
		t.Fatalf("thân danh_dau_viec sai: %s %v", d.Than, d.CanChon)
	}
	kiemDong(t, "danh_dau_viec", d, []dongMuon{{"Việc", phoi}, {"Người nhận", v.nhanTen}, {"Hiện tại", "Đã xong"}, {"Đổi thành", "Chưa xong"}})

	d, err = v.dung(t, v.quay, "danh_dau_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","danh_dau":"done"}`, v.tag))
	if err != nil {
		t.Fatalf("danh_dau_viec: %v", err)
	}
	kiemDong(t, "danh_dau_viec", d, []dongMuon{{"Việc", rua}, {"Người nhận", v.nhanTen}, {"Hiện tại", "Chưa xong"}, {"Đổi thành", "Đã xong"}})

	d, err = v.dung(t, v.quay, "an_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","ly_do":"  Trùng việc  "}`, v.tag))
	if err != nil {
		t.Fatalf("an_viec: %v", err)
	}
	duongId(t, d, v.rua)
	if !cungJSON(t, d.Than, []byte(`{"reason":"Trùng việc"}`)) || len(d.CanChon) != 0 {
		t.Fatalf("thân an_viec sai: %s %v", d.Than, d.CanChon)
	}
	kiemDong(t, "an_viec", d, []dongMuon{{"Việc", rua}, {"Người nhận", v.nhanTen}, {"Lý do", "Trùng việc"}})

	// Sửa chỉ nội dung: giữ người nhận hiện tại, không khoá due_at.
	d, err = v.dung(t, v.quay, "sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","noi_dung_moi":"Rửa nồi to","ly_do":"Ghi rõ hơn"}`, v.tag))
	if err != nil {
		t.Fatalf("sua_viec nội dung: %v", err)
	}
	duongId(t, d, v.rua)
	if !cungJSON(t, d.Than, []byte(fmt.Sprintf(`{"content":"Rửa nồi to","assignee_person_id":%d,"reason":"Ghi rõ hơn"}`, v.ngoai))) || len(d.CanChon) != 0 {
		t.Fatalf("thân sua_viec chỉ nội dung sai: %s %v", d.Than, d.CanChon)
	}
	kiemDong(t, "sua_viec", d, []dongMuon{{"Việc", rua}, {"Người nhận", v.nhanTen}, {"Nội dung mới", "Rửa nồi to"}, {"Lý do", "Ghi rõ hơn"}})

	// Sửa chỉ hạn: nội dung giữ nguyên như hiện tại.
	d, err = v.dung(t, v.quay, "sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","han_moi":"2030-03-04T16:05","ly_do":"Lùi hạn"}`, v.tag))
	if err != nil {
		t.Fatalf("sua_viec hạn: %v", err)
	}
	if !cungJSON(t, d.Than, []byte(fmt.Sprintf(`{"content":%q,"assignee_person_id":%d,"reason":"Lùi hạn","due_at":"2030-03-04T16:05:00+07:00"}`, rua, v.ngoai))) {
		t.Fatalf("thân sua_viec chỉ hạn sai: %s", d.Than)
	}
	kiemDong(t, "sua_viec", d, []dongMuon{{"Việc", rua}, {"Người nhận", v.nhanTen}, {"Hạn mới", "16:05 ngày 04/03/2030"}, {"Lý do", "Lùi hạn"}})

	// Cả hai.
	d, err = v.dung(t, v.quay, "sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","noi_dung_moi":"Rửa nồi to","han_moi":"2030-03-04T16:05","ly_do":"Cả hai"}`, v.tag))
	if err != nil {
		t.Fatalf("sua_viec cả hai: %v", err)
	}
	kiemDong(t, "sua_viec", d, []dongMuon{{"Việc", rua}, {"Người nhận", v.nhanTen}, {"Nội dung mới", "Rửa nồi to"}, {"Hạn mới", "16:05 ngày 04/03/2030"}, {"Lý do", "Cả hai"}})

	for _, ca := range []struct{ ten, thamSo string }{
		{"sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","ly_do":"Không đổi gì"}`, v.tag)},
		{"sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","noi_dung_moi":"Rửa nồi to"}`, v.tag)},
		{"sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","noi_dung_moi":"Rửa nồi to","ly_do":"  "}`, v.tag)},
		{"sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","noi_dung_moi":"  ","ly_do":"x"}`, v.tag)},
		{"sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","han_moi":"2030-13-01T10:00","ly_do":"x"}`, v.tag)},
		{"sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","noi_dung_moi":"Rửa","ly_do":"x","assignee_person_id":%d}`, v.tag, v.chu)},
		{"an_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s"}`, v.tag)},
		{"an_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","ly_do":""}`, v.tag)},
		{"an_viec", fmt.Sprintf(`{"viec":"Quét sân %s","ly_do":"Đã ẩn rồi"}`, v.tag)},
	} {
		if _, err := v.dung(t, v.quay, ca.ten, ca.thamSo); err == nil {
			t.Fatalf("%s phải từ chối tham số %s", ca.ten, ca.thamSo)
		}
	}
	v.khongGhi(t, "sửa · ẩn · đánh dấu")
}

// G2, I-043: quyền kiểm lại lúc dựng — người rời quầy sau khi lượt đã có danh sách thì mọi hàm dựng lỗi.
func TestI044_RoiQuayGiuaLuotThiKhongDeXuat(t *testing.T) {
	v := moViec(t)
	cc, err := troly.MoiNguonNoiBo(v.pool).CongCuGhi(v.ctx, v.quay)
	if err != nil || len(cc) != len(dsGhiGiaoViec) {
		t.Fatalf("người đứng quầy phải có bốn công cụ ghi: %d %v", len(cc), err)
	}
	v.dungQuay(t, 0)
	defer v.dungQuay(t, v.quay)
	for _, ca := range []struct{ ten, thamSo string }{
		{"giao_viec", `{"noi_dung":"Rửa bát","han":"2030-01-02T07:30"}`},
		{"sua_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","noi_dung_moi":"Rửa nồi to","ly_do":"x"}`, v.tag)},
		{"an_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","ly_do":"x"}`, v.tag)},
		{"danh_dau_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","danh_dau":"done"}`, v.tag)},
	} {
		if _, err := timGhi(t, cc, ca.ten).DeXuat(v.ctx, json.RawMessage(ca.thamSo)); err == nil {
			t.Fatalf("%s: người đã rời quầy thì hàm dựng phải lỗi", ca.ten)
		}
	}
	v.khongGhi(t, "rời quầy")
}

// I-044 · I-043 qua đường hỏi với nguồn bản chạy: đề xuất đúng hình, không ghi, gói tới model không mang nội dung việc hay tên người.
func TestI044_DuongHoiGiaoViecKhongGhiKhongLo(t *testing.T) {
	v := moViec(t)
	gin.SetMode(gin.TestMode)
	menu := gia.NewService(v.pool)
	hoi := func(nha *troly.NhaGia, nguoi int64) map[string]json.RawMessage {
		t.Helper()
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(v.pool)))
		troly.Routes(r, troly.MoiLop(v.pool, cauHinh(t, "gia", 0), nha), menu, troly.MoiNguonNoiBo(v.pool))
		req := httptest.NewRequest("POST", "/chat/turns", strings.NewReader(`{"question":"Đánh dấu xong việc rửa nồi"}`))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "banhcuon_phien", Value: testhelper.Session(t, nguoi)})
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusOK {
			t.Fatalf("%d %s", w.Code, w.Body.String())
		}
		var out map[string]json.RawMessage
		if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
			t.Fatal(err)
		}
		return out
	}
	loRa := func(g []troly.GoiModel) {
		t.Helper()
		raw, err := json.Marshal(g)
		if err != nil {
			t.Fatal(err)
		}
		s := string(raw)
		for _, bi := range []string{"Rửa NỒI", "Lau bàn sáng", "Lau bàn chiều", "Phơi khăn", v.nhanTen} {
			if strings.Contains(s, bi) {
				t.Fatalf("gói tới model mang %q (I-043)", bi)
			}
		}
	}

	// Khớp đúng một việc: lượt dừng với câu cố định và đề xuất đúng hình; danh sách tới model kể bốn tên ghi sau tên đọc.
	nha := troly.MoiNhaGia(goiTool("danh_dau_viec", fmt.Sprintf(`{"viec":"rửa nồi lớn %s","danh_dau":"done"}`, v.tag)), traLoi("Đã ghi xong!"))
	out := hoi(nha, v.quay)
	var ans string
	if err := json.Unmarshal(out["answer"], &ans); err != nil || ans != troly.CauDeXuat {
		t.Fatalf("lượt có đề xuất phải trả câu cố định: %s", out)
	}
	var p struct {
		Tool        string           `json:"tool"`
		OperationID string           `json:"operation_id"`
		PathParams  json.RawMessage  `json:"path_params"`
		Body        json.RawMessage  `json:"body"`
		Lines       []map[string]any `json:"lines"`
		NeedsChoice []string         `json:"needs_choice"`
	}
	if err := json.Unmarshal(out["proposal"], &p); err != nil || p.Tool != "danh_dau_viec" || p.OperationID != "markAssignedTask" {
		t.Fatalf("proposal sai tool hay operation_id: %s", out["proposal"])
	}
	if !cungJSON(t, p.PathParams, []byte(fmt.Sprintf(`{"assigned_task_id":%d}`, v.rua))) || !cungJSON(t, p.Body, []byte(`{"mark":"done"}`)) ||
		len(p.NeedsChoice) != 0 || len(p.Lines) != 4 {
		t.Fatalf("proposal sai path_params, body, needs_choice hay lines: %s", out["proposal"])
	}
	g := nha.DaNhan()
	if len(g) != 1 {
		t.Fatalf("lượt có đề xuất không gọi model thêm: %d lần", len(g))
	}
	if !reflect.DeepEqual(g[0].CongCu, append(append([]string{}, dsQuay...), dsGhiGiaoViec...)) {
		t.Fatalf("gói tới model của người đứng quầy phải kể %v rồi %v, được %v", dsQuay, dsGhiGiaoViec, g[0].CongCu)
	}
	loRa(g)
	v.khongGhi(t, "đường hỏi có đề xuất")

	// Nhập nhằng: không đề xuất, bước công cụ mang lỗi chung, kết quả rỗng, gói tới model vẫn không có nội dung việc.
	nha = troly.MoiNhaGia(goiTool("danh_dau_viec", `{"viec":"Lau bàn","danh_dau":"done"}`), traLoi("Chưa tìm được việc."))
	out = hoi(nha, v.chu)
	if string(out["proposal"]) != "null" {
		t.Fatalf("tham chiếu nhập nhằng thì proposal phải null: %s", out["proposal"])
	}
	g = nha.DaNhan()
	if len(g) != 2 || len(g[1].Buoc) != 1 || g[1].Buoc[0].Loi != "loi_cong_cu" || len(g[1].Buoc[0].KetQua) != 0 {
		t.Fatalf("tham chiếu nhập nhằng phải là bước lỗi công cụ không kết quả: %+v", g)
	}
	loRa(g)
	v.khongGhi(t, "đường hỏi nhập nhằng")

	// Người ngoài quầy: không có tên ghi nào trong gói tới model.
	nha = troly.MoiNhaGia(traLoi("ok"))
	hoi(nha, v.ngoai)
	if g = nha.DaNhan(); len(g) != 1 || !reflect.DeepEqual(g[0].CongCu, dsNguoiLam) {
		t.Fatalf("người ngoài quầy chỉ có công cụ đọc %v, được %+v", dsNguoiLam, g)
	}
}
