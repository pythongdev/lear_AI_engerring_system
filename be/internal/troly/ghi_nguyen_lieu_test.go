// Test năm công cụ ghi sổ nguyên liệu của chat (CHAT-17, ADR-140 điểm 2 · 3 · 4 · 7; I-025 · I-026 · I-043 · I-044). Claude viết
// TRƯỚC khi có code; Codex làm cho xanh, không sửa điều kiện kiểm. Cần PostgreSQL thật: chạy qua ./scripts/be-check.sh.
//
// Hợp đồng Claude chốt trong test này (2026-11-10, trong khung ADR-140; các lựa chọn là *phiên chọn*, ghi ở entry CHAT-17):
//   - Năm cửa C07 thuộc lớp chu_quan, nên (*troly.NguonNoiBo).CongCuGhi(ctx, nguoi) của chủ quán trả mười công cụ của lớp
//     quay_hoac_chu_quan (CHAT-15 · CHAT-16) rồi đúng năm công cụ nguyên liệu, thứ tự cố định:
//     them_nguyen_lieu → createSupplyItem · dat_don_vi → setSupplyItemPurchaseUnit · ghi_so_nguyen_lieu → createSupplyDayEntry ·
//     sua_so_nguyen_lieu → updateSupplyDayEntry · dat_ti_le_nhac → setSupplyItemReminderRatio.
//     Người đứng quầy không phải chủ quán vẫn đúng mười công cụ cũ; người ngoài quầy vẫn rỗng. Lớp chu_quan đọc bằng authz.ReadAs như CongCu.
//   - Luật chung như CHAT-15: tham số là đối tượng JSON chỉ gồm khoá kể dưới đây, mọi giá trị là chuỗi (số JSON cũng là lỗi), cắt khoảng
//     trắng hai đầu, rỗng sau khi cắt ⇒ lỗi; khoá lạ (kể cả supply_item_id, supply_day_entry_id, person_id) ⇒ lỗi; mỗi hàm dựng kiểm lại
//     lớp chu_quan dưới chính người của phiên; KHÔNG gọi service ghi nào, không câu SQL riêng của troly — chỉ đọc qua
//     nguyenlieu.Service.Doc và DocChiTiet; lỗi là một lỗi chung không mang tên nguyên liệu hay con số.
//   - Chuẩn so khớp: không phân biệt hoa thường, khoảng trắng liền nhau gộp làm một — đúng hàm chuẩn của timViecDeXuat.
//   - Tham chiếu nguyên liệu ("nguyen_lieu"): từ 2 ký tự trở lên. Có đúng một thứ mà tên chuẩn BẰNG chuỗi chuẩn ⇒ dùng thứ ấy; không
//     có thứ bằng thì đúng một thứ mà tên chuẩn CHỨA chuỗi ⇒ dùng; còn lại (không có, từ hai) ⇒ lỗi. Đọc bằng Doc(ctx, nguoi).
//   - Đơn vị ("don_vi") ở ghi_so_nguyen_lieu và sua_so_nguyen_lieu: bắt buộc, phải bằng (theo chuẩn so khớp) đơn vị đã đặt của thứ ấy;
//     thứ chưa có đơn vị ⇒ lỗi (đặt đơn vị trước). Dòng hiện con số kèm đơn vị đã lưu, ví dụ "2.5 bao".
//   - Ngày ("ngay"): đúng khuôn "YYYY-MM-DD" và là ngày có thật; không đổi chữ như "hôm qua". Dòng hiện "01/11/2026". Ngày sau hôm nay
//     của quán do cửa createSupplyDayEntry từ chối khi bấm, hàm dựng không xét.
//   - Loại ("loai"): chỉ "purchased" hoặc "used"; dòng hiện "Mua vào" / "Đã dùng" — cùng chữ màn Nguyên liệu.
//   - Con số ("so", "so_moi"): đúng khuôn Measure của hợp đồng ^(0|[1-9][0-9]{0,8})(\.[0-9]{1,3})?$; không dấu phẩy, không đơn vị dính.
//   - Tỉ lệ ("ti_le"): đúng khuôn của SetSupplyItemReminderRatio ^(0(\.[0-9]{1,6})?|1(\.0{1,6})?)$.
//   - them_nguyen_lieu {"ten"} bắt buộc, {"don_vi"} tuỳ chọn: ThamSoDuong nil hoặc {}; Than {"name"} cộng "purchase_unit" chỉ khi có;
//     tên bằng (theo chuẩn so khớp) tên một thứ đã có ⇒ lỗi; Dong: Tên · [Đơn vị].
//   - dat_don_vi {"nguyen_lieu", "don_vi"}: ThamSoDuong {"supply_item_id"}; Than {"purchase_unit"}; thứ đã có đơn vị ⇒ lỗi (cửa cũng từ
//     chối khi bấm); Dong: Nguyên liệu · Đơn vị.
//   - ghi_so_nguyen_lieu {"nguyen_lieu", "ngay", "loai", "so", "don_vi"}: ThamSoDuong nil hoặc {}; Than {"supply_item_id": id đọc từ
//     backend, "entry_date", "kind", "measure"}; đã có con số cùng thứ, ngày, loại ⇒ lỗi (dùng sua_so_nguyen_lieu); Dong: Nguyên liệu ·
//     Ngày · Loại · Con số.
//   - sua_so_nguyen_lieu {"nguyen_lieu", "ngay", "loai", "so_moi", "don_vi", "ly_do"}: tìm con số cùng thứ, ngày, loại bằng
//     DocChiTiet; không có ⇒ lỗi. ThamSoDuong {"supply_day_entry_id"}; Than {"measure", "reason"}; Dong: Nguyên liệu · Ngày · Loại ·
//     Con số hiện tại · Con số mới · Lý do.
//   - dat_ti_le_nhac {"nguyen_lieu", "ti_le", "ly_do"}: ThamSoDuong {"supply_item_id"}; Than {"reminder_ratio", "reason"}; Dong:
//     Nguyên liệu · Tỉ lệ nhắc hiện tại (đúng chuỗi backend trả) · Tỉ lệ nhắc mới · Lý do.
//   - Mọi dòng: CongCu = tên công cụ; DocLuc khác 0, chung cho mọi dòng của một đề xuất.
//   - Qua POST /chat/turns: lượt dừng ngay sau đề xuất, gói tới model không mang tên nguyên liệu hay con số đã đọc; dựng không ghi gì.
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

var dsGhiNguyenLieu = []string{"them_nguyen_lieu", "dat_don_vi", "ghi_so_nguyen_lieu", "sua_so_nguyen_lieu", "dat_ti_le_nhac"}
var opGhiNguyenLieu = []string{"createSupplyItem", "setSupplyItemPurchaseUnit", "createSupplyDayEntry", "updateSupplyDayEntry",
	"setSupplyItemReminderRatio"}

// Danh sách ghi đầy đủ của chủ quán: lớp quay_hoac_chu_quan rồi nguyên liệu (CHAT-17).
var dsGhiChuQuan = append(append([]string{}, dsGhiQuayChu...), dsGhiNguyenLieu...)
var opGhiChuQuan = append(append([]string{}, opGhiQuayChu...), opGhiNguyenLieu...)

type nguyenLieuThu struct {
	nguoiThu
	tag string
	// gao "Gạo TẺ   <tag>" (bao, có hai con số ngày 2026-11-01) · hanhPhi "Hành phi <tag>" (kg) · hanhLa "Hành lá <tag>" (bó) ·
	// ot "Ớt <tag>" (quả) · otKho "Ớt <tag> khô" (gói) · mocNhi "Mộc nhĩ <tag>" (chưa có đơn vị).
	gao, hanhPhi, hanhLa, ot, otKho, mocNhi int64
	gaoMua, gaoDung                         int64
	truoc                                   string
}

func moNguyenLieu(t *testing.T) nguyenLieuThu {
	t.Helper()
	d := nguyenLieuThu{nguoiThu: moNguoi(t), tag: fmt.Sprintf("c17-%d", time.Now().UnixNano())}
	err := pgx.BeginFunc(d.ctx, d.owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(d.ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-chat17',true)`, fmt.Sprint(d.chu)); e != nil {
			return e
		}
		for _, x := range []struct {
			ten  string
			unit any
			id   *int64
		}{
			{"Gạo TẺ   " + d.tag, "bao", &d.gao},
			{"Hành phi " + d.tag, "kg", &d.hanhPhi},
			{"Hành lá " + d.tag, "bó", &d.hanhLa},
			{"Ớt " + d.tag, "quả", &d.ot},
			{"Ớt " + d.tag + " khô", "gói", &d.otKho},
			{"Mộc nhĩ " + d.tag, nil, &d.mocNhi},
		} {
			if e := tx.QueryRow(d.ctx, `INSERT INTO shop.supply_item(name,purchase_unit) VALUES ($1,$2) RETURNING id`, x.ten, x.unit).Scan(x.id); e != nil {
				return e
			}
		}
		for _, x := range []struct {
			kind, measure string
			id            *int64
		}{{"purchased", "2", &d.gaoMua}, {"used", "0.5", &d.gaoDung}} {
			if e := tx.QueryRow(d.ctx, `INSERT INTO shop.supply_day_entry(supply_item_id,entry_date,kind_code,entered_measure) VALUES ($1,'2026-11-01',$2,$3) RETURNING id`,
				d.gao, x.kind, x.measure).Scan(x.id); e != nil {
				return e
			}
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	d.truoc = d.chupNguyenLieu(t)
	return d
}

// chupNguyenLieu chụp mọi thứ mang tag của test (kể cả thứ lẽ ra không được tạo) và mọi con số ngày của chúng.
func (d nguyenLieuThu) chupNguyenLieu(t *testing.T) string {
	t.Helper()
	var a, b string
	if err := d.owner.QueryRow(d.ctx, `SELECT coalesce(json_agg(x ORDER BY x.id),'[]')::text FROM shop.supply_item x WHERE x.name LIKE '%'||$1||'%'`, d.tag).Scan(&a); err != nil {
		t.Fatal(err)
	}
	if err := d.owner.QueryRow(d.ctx, `SELECT coalesce(json_agg(e ORDER BY e.id),'[]')::text FROM shop.supply_day_entry e
		JOIN shop.supply_item i ON i.id=e.supply_item_id WHERE i.name LIKE '%'||$1||'%'`, d.tag).Scan(&b); err != nil {
		t.Fatal(err)
	}
	return a + "|" + b
}

func (d nguyenLieuThu) khongGhiNguyenLieu(t *testing.T, luc string) {
	t.Helper()
	if d.chupNguyenLieu(t) != d.truoc {
		t.Fatalf("%s: dựng đề xuất đã đổi sổ nguyên liệu (I-044)", luc)
	}
}

func (d nguyenLieuThu) dung(t *testing.T, nguoi int64, ten, thamSo string) (troly.DeXuat, error) {
	t.Helper()
	cc, err := troly.MoiNguonNoiBo(d.pool).CongCuGhi(d.ctx, nguoi)
	if err != nil {
		t.Fatal(err)
	}
	c := timGhi(t, cc, ten)
	if c.DeXuat == nil {
		t.Fatalf("%s không có hàm dựng", ten)
	}
	return c.DeXuat(d.ctx, json.RawMessage(thamSo))
}

// datChuQuan bật hay tắt cờ chủ quán của người chủ trong test.
func (d nguyenLieuThu) datChuQuan(t *testing.T, la bool) {
	t.Helper()
	err := pgx.BeginFunc(d.ctx, d.owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(d.ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-chat17-owner',true)`, fmt.Sprint(d.chu)); e != nil {
			return e
		}
		_, e := tx.Exec(d.ctx, `UPDATE shop.person SET is_owner=$2 WHERE id=$1`, d.chu, la)
		return e
	})
	if err != nil {
		t.Fatal(err)
	}
}

func tuyChonRong(t *testing.T, ten string, d troly.DeXuat) {
	t.Helper()
	if len(d.ThamSoDuong) != 0 && !cungJSON(t, d.ThamSoDuong, []byte(`{}`)) {
		t.Fatalf("%s không có tham số đường: %s", ten, d.ThamSoDuong)
	}
	if len(d.CanChon) != 0 {
		t.Fatalf("%s không có trường cần chọn: %v", ten, d.CanChon)
	}
}

// ADR-140 điểm 7: năm cửa C07 thuộc lớp chu_quan — chỉ chủ quán có năm công cụ nguyên liệu, sau mười công cụ của lớp quầy.
func TestI044_NguyenLieuChiMoChoChuQuan(t *testing.T) {
	n := moNguoi(t)
	nb := troly.MoiNguonNoiBo(n.pool)
	for _, ca := range []struct {
		ten      string
		nguoi    int64
		muon, op []string
	}{
		{"người ngoài quầy", n.ngoai, nil, nil},
		{"người đứng quầy", n.quay, dsGhiQuayChu, opGhiQuayChu},
		{"chủ quán", n.chu, dsGhiChuQuan, opGhiChuQuan},
	} {
		cc, err := nb.CongCuGhi(n.ctx, ca.nguoi)
		if err != nil {
			t.Fatalf("%s: lỗi %v", ca.ten, err)
		}
		var ten, op []string
		for _, c := range cc {
			ten, op = append(ten, c.Ten), append(op, c.OperationID)
			if strings.TrimSpace(c.MoTa) == "" || c.DeXuat == nil {
				t.Fatalf("%s: %s thiếu mô tả hay hàm dựng", ca.ten, c.Ten)
			}
		}
		if !reflect.DeepEqual(ten, ca.muon) || !reflect.DeepEqual(op, ca.op) {
			t.Fatalf("%s: muốn %v %v, được %v %v", ca.ten, ca.muon, ca.op, ten, op)
		}
	}
}

// I-025: thêm thứ mới chỉ mang tên và đơn vị người nói; tên trùng thứ đã có thì không có thẻ.
func TestI044_ThemNguyenLieuTenMoi(t *testing.T) {
	d := moNguyenLieu(t)
	dx, err := d.dung(t, d.chu, "them_nguyen_lieu", fmt.Sprintf(`{"ten":"  Nấm hương %s ","don_vi":" gói "}`, d.tag))
	if err != nil {
		t.Fatalf("them_nguyen_lieu có đơn vị: %v", err)
	}
	tuyChonRong(t, "them_nguyen_lieu", dx)
	if !cungJSON(t, dx.Than, []byte(fmt.Sprintf(`{"name":"Nấm hương %s","purchase_unit":"gói"}`, d.tag))) {
		t.Fatalf("thân them_nguyen_lieu sai: %s", dx.Than)
	}
	kiemDong(t, "them_nguyen_lieu", dx, []dongMuon{{"Tên", "Nấm hương " + d.tag}, {"Đơn vị", "gói"}})

	dx, err = d.dung(t, d.chu, "them_nguyen_lieu", fmt.Sprintf(`{"ten":"Tiêu %s"}`, d.tag))
	if err != nil {
		t.Fatalf("them_nguyen_lieu không đơn vị: %v", err)
	}
	if !cungJSON(t, dx.Than, []byte(fmt.Sprintf(`{"name":"Tiêu %s"}`, d.tag))) {
		t.Fatalf("thân them_nguyen_lieu không đơn vị sai: %s", dx.Than)
	}
	kiemDong(t, "them_nguyen_lieu", dx, []dongMuon{{"Tên", "Tiêu " + d.tag}})

	for _, sai := range []string{
		fmt.Sprintf(`{"ten":"gạo tẻ %s"}`, d.tag), // trùng tên theo chuẩn so khớp
		fmt.Sprintf(`{"ten":"Tiêu %s","don_vi":"  "}`, d.tag),
		fmt.Sprintf(`{"ten":"Tiêu %s","don_vi":null}`, d.tag),
		fmt.Sprintf(`{"ten":"Tiêu %s","supply_item_id":1}`, d.tag),
		`{"ten":"   "}`,
		`{"don_vi":"kg"}`,
		`{"ten":5}`,
		`[]`,
	} {
		if _, err := d.dung(t, d.chu, "them_nguyen_lieu", sai); err == nil {
			t.Fatalf("them_nguyen_lieu phải từ chối tham số %s", sai)
		}
	}
	d.khongGhiNguyenLieu(t, "thêm nguyên liệu")
}

// I-026 vế đơn vị: đặt đơn vị lần đầu cho đúng một thứ chưa có đơn vị.
func TestI044_DatDonViLanDauDungMotThu(t *testing.T) {
	d := moNguyenLieu(t)
	dx, err := d.dung(t, d.chu, "dat_don_vi", fmt.Sprintf(`{"nguyen_lieu":"mộc NHĨ %s","don_vi":"kg"}`, d.tag))
	if err != nil {
		t.Fatalf("dat_don_vi: %v", err)
	}
	if !cungJSON(t, dx.ThamSoDuong, []byte(fmt.Sprintf(`{"supply_item_id":%d}`, d.mocNhi))) ||
		!cungJSON(t, dx.Than, []byte(`{"purchase_unit":"kg"}`)) || len(dx.CanChon) != 0 {
		t.Fatalf("dat_don_vi sai: %s %s %v", dx.ThamSoDuong, dx.Than, dx.CanChon)
	}
	kiemDong(t, "dat_don_vi", dx, []dongMuon{{"Nguyên liệu", "Mộc nhĩ " + d.tag}, {"Đơn vị", "kg"}})

	for _, sai := range []string{
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","don_vi":"kg"}`, d.tag), // đã có đơn vị
		fmt.Sprintf(`{"nguyen_lieu":"mộc nhĩ %s"}`, d.tag),
		fmt.Sprintf(`{"nguyen_lieu":"mộc nhĩ %s","don_vi":"  "}`, d.tag),
		fmt.Sprintf(`{"nguyen_lieu":"mộc nhĩ %s","don_vi":"kg","supply_item_id":%d}`, d.tag, d.mocNhi),
		`{"nguyen_lieu":"Hành","don_vi":"kg"}`, // nhập nhằng
		`{"nguyen_lieu":"M","don_vi":"kg"}`,
		fmt.Sprintf(`{"nguyen_lieu":"chưa có thứ này %s","don_vi":"kg"}`, d.tag),
	} {
		if _, err := d.dung(t, d.chu, "dat_don_vi", sai); err == nil {
			t.Fatalf("dat_don_vi phải từ chối tham số %s", sai)
		}
	}
	d.khongGhiNguyenLieu(t, "đặt đơn vị")
}

// Tham chiếu nguyên liệu: tên bằng hẳn được ưu tiên; không có thì phải chứa đúng một; nhập nhằng hay không có thì lỗi.
func TestI044_ThamChieuNguyenLieuBangTruocChuaSau(t *testing.T) {
	d := moNguyenLieu(t)
	// "ớt <tag>" nằm trong cả "Ớt <tag>" và "Ớt <tag> khô", nhưng bằng hẳn "Ớt <tag>".
	dx, err := d.dung(t, d.chu, "dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":"ớt %s","ti_le":"0.5","ly_do":"x"}`, d.tag))
	if err != nil {
		t.Fatalf("tên bằng hẳn phải tìm được: %v", err)
	}
	if !cungJSON(t, dx.ThamSoDuong, []byte(fmt.Sprintf(`{"supply_item_id":%d}`, d.ot))) {
		t.Fatalf("tên bằng hẳn phải chọn Ớt, được %s", dx.ThamSoDuong)
	}
	// Chứa đúng một.
	dx, err = d.dung(t, d.chu, "dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":"%s khô","ti_le":"0.5","ly_do":"x"}`, d.tag))
	if err != nil {
		t.Fatalf("chuỗi nằm trong đúng một tên phải tìm được: %v", err)
	}
	if !cungJSON(t, dx.ThamSoDuong, []byte(fmt.Sprintf(`{"supply_item_id":%d}`, d.otKho))) {
		t.Fatalf("phải chọn Ớt khô, được %s", dx.ThamSoDuong)
	}
	for _, sai := range []string{
		"HÀNH", // nhập nhằng Hành phi · Hành lá
		"Hành",
		d.tag, // chứa trong mọi thứ của test, không bằng thứ nào
		"x",
		"gạo nếp " + d.tag,
	} {
		if _, err := d.dung(t, d.chu, "dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":%q,"ti_le":"0.5","ly_do":"x"}`, sai)); err == nil {
			t.Fatalf("tham chiếu %q phải lỗi", sai)
		}
	}
	d.khongGhiNguyenLieu(t, "tham chiếu")
}

// I-025 · I-026: ghi con số ngày đúng số, đơn vị, ngày, loại người nói; mơ hồ về ngày hay đơn vị thì không có thẻ.
func TestI044_GhiSoNguyenLieuDungSoDonViNgay(t *testing.T) {
	d := moNguyenLieu(t)
	gao := "Gạo TẺ   " + d.tag
	for _, ca := range []struct {
		thamSo, than string
		dong         []dongMuon
	}{
		{fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"purchased","so":" 2.5 ","don_vi":"BAO"}`, d.tag),
			fmt.Sprintf(`{"supply_item_id":%d,"entry_date":"2026-11-02","kind":"purchased","measure":"2.5"}`, d.gao),
			[]dongMuon{{"Nguyên liệu", gao}, {"Ngày", "02/11/2026"}, {"Loại", "Mua vào"}, {"Con số", "2.5 bao"}}},
		{fmt.Sprintf(`{"nguyen_lieu":"hành phi %s","ngay":"2026-10-31","loai":"used","so":"0.125","don_vi":"kg"}`, d.tag),
			fmt.Sprintf(`{"supply_item_id":%d,"entry_date":"2026-10-31","kind":"used","measure":"0.125"}`, d.hanhPhi),
			[]dongMuon{{"Nguyên liệu", "Hành phi " + d.tag}, {"Ngày", "31/10/2026"}, {"Loại", "Đã dùng"}, {"Con số", "0.125 kg"}}},
		{fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"used","so":"0","don_vi":"bao"}`, d.tag),
			fmt.Sprintf(`{"supply_item_id":%d,"entry_date":"2026-11-02","kind":"used","measure":"0"}`, d.gao),
			[]dongMuon{{"Nguyên liệu", gao}, {"Ngày", "02/11/2026"}, {"Loại", "Đã dùng"}, {"Con số", "0 bao"}}},
	} {
		dx, err := d.dung(t, d.chu, "ghi_so_nguyen_lieu", ca.thamSo)
		if err != nil {
			t.Fatalf("ghi_so_nguyen_lieu %s: %v", ca.thamSo, err)
		}
		tuyChonRong(t, "ghi_so_nguyen_lieu", dx)
		if !cungJSON(t, dx.Than, []byte(ca.than)) {
			t.Fatalf("thân ghi_so_nguyen_lieu: muốn %s, được %s", ca.than, dx.Than)
		}
		kiemDong(t, "ghi_so_nguyen_lieu", dx, ca.dong)
	}

	tot := func(ngay, loai, so, donVi string) string {
		return fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":%q,"loai":%q,"so":%q,"don_vi":%q}`, d.tag, ngay, loai, so, donVi)
	}
	for _, sai := range []string{
		tot("2026-11-01", "purchased", "3", "bao"), // đã có con số cùng ngày, cùng loại
		tot("hôm qua", "purchased", "3", "bao"),
		tot("2026-11-31", "purchased", "3", "bao"),
		tot("2026-11-2", "purchased", "3", "bao"),
		tot("02/11/2026", "purchased", "3", "bao"),
		tot("2026-11-02", "mua", "3", "bao"),
		tot("2026-11-02", "Mua vào", "3", "bao"),
		tot("2026-11-02", "purchased", "2,5", "bao"),
		tot("2026-11-02", "purchased", "-1", "bao"),
		tot("2026-11-02", "purchased", "2.5bao", "bao"),
		tot("2026-11-02", "purchased", "1.2345", "bao"),
		tot("2026-11-02", "purchased", "01", "bao"),
		tot("2026-11-02", "purchased", "2", "kg"),                                                         // khác đơn vị đã đặt
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"purchased","so":"2"}`, d.tag), // thiếu đơn vị
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"purchased","so":2,"don_vi":"bao"}`, d.tag),   // số JSON
		fmt.Sprintf(`{"nguyen_lieu":"mộc nhĩ %s","ngay":"2026-11-02","loai":"purchased","so":"2","don_vi":"kg"}`, d.tag), // chưa có đơn vị
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"purchased","so":"2","don_vi":"bao","supply_item_id":%d}`, d.tag, d.gao),
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"purchased","so":"2","don_vi":"bao","person_id":%d}`, d.tag, d.quay),
		`{"nguyen_lieu":"Hành","ngay":"2026-11-02","loai":"used","so":"1","don_vi":"kg"}`,
	} {
		if _, err := d.dung(t, d.chu, "ghi_so_nguyen_lieu", sai); err == nil {
			t.Fatalf("ghi_so_nguyen_lieu phải từ chối tham số %s", sai)
		}
	}
	d.khongGhiNguyenLieu(t, "ghi con số")
}

// I-025 vế sửa: sửa đúng một con số có sẵn, có lý do; chỉ đổi measure.
func TestI044_SuaSoNguyenLieuCoLyDo(t *testing.T) {
	d := moNguyenLieu(t)
	gao := "Gạo TẺ   " + d.tag
	dx, err := d.dung(t, d.chu, "sua_so_nguyen_lieu",
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-01","loai":"used","so_moi":"0.75","don_vi":"bao","ly_do":" Đếm lại "}`, d.tag))
	if err != nil {
		t.Fatalf("sua_so_nguyen_lieu: %v", err)
	}
	if !cungJSON(t, dx.ThamSoDuong, []byte(fmt.Sprintf(`{"supply_day_entry_id":%d}`, d.gaoDung))) ||
		!cungJSON(t, dx.Than, []byte(`{"measure":"0.75","reason":"Đếm lại"}`)) || len(dx.CanChon) != 0 {
		t.Fatalf("sua_so_nguyen_lieu sai: %s %s %v", dx.ThamSoDuong, dx.Than, dx.CanChon)
	}
	kiemDong(t, "sua_so_nguyen_lieu", dx, []dongMuon{{"Nguyên liệu", gao}, {"Ngày", "01/11/2026"}, {"Loại", "Đã dùng"},
		{"Con số hiện tại", "0.5 bao"}, {"Con số mới", "0.75 bao"}, {"Lý do", "Đếm lại"}})

	tot := func(ngay, loai, so, donVi, lyDo string) string {
		return fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":%q,"loai":%q,"so_moi":%q,"don_vi":%q,"ly_do":%q}`, d.tag, ngay, loai, so, donVi, lyDo)
	}
	for _, sai := range []string{
		tot("2026-11-02", "used", "1", "bao", "x"), // không có con số ngày ấy
		tot("2026-11-01", "used", "1", "bao", "  "),
		tot("2026-11-01", "used", "1,5", "bao", "x"),
		tot("2026-11-01", "used", "1", "kg", "x"),
		tot("2026-11-01", "dung", "1", "bao", "x"),
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-01","loai":"used","so_moi":"1","don_vi":"bao"}`, d.tag),
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-01","loai":"used","so_moi":"1","don_vi":"bao","ly_do":"x","supply_day_entry_id":%d}`, d.tag, d.gaoDung),
		fmt.Sprintf(`{"nguyen_lieu":"hành phi %s","ngay":"2026-11-01","loai":"used","so_moi":"1","don_vi":"kg","ly_do":"x"}`, d.tag),
	} {
		if _, err := d.dung(t, d.chu, "sua_so_nguyen_lieu", sai); err == nil {
			t.Fatalf("sua_so_nguyen_lieu phải từ chối tham số %s", sai)
		}
	}
	d.khongGhiNguyenLieu(t, "sửa con số")
}

// I-025: đặt tỉ lệ nhắc đúng khuôn của cửa, có lý do; dòng hiện tỉ lệ hiện tại backend trả.
func TestI044_DatTiLeNhacDungKhuon(t *testing.T) {
	d := moNguyenLieu(t)
	dx, err := d.dung(t, d.chu, "dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":"0.35","ly_do":"Mùa mưa khó mua"}`, d.tag))
	if err != nil {
		t.Fatalf("dat_ti_le_nhac: %v", err)
	}
	if !cungJSON(t, dx.ThamSoDuong, []byte(fmt.Sprintf(`{"supply_item_id":%d}`, d.gao))) ||
		!cungJSON(t, dx.Than, []byte(`{"reminder_ratio":"0.35","reason":"Mùa mưa khó mua"}`)) || len(dx.CanChon) != 0 {
		t.Fatalf("dat_ti_le_nhac sai: %s %s %v", dx.ThamSoDuong, dx.Than, dx.CanChon)
	}
	kiemDong(t, "dat_ti_le_nhac", dx, []dongMuon{{"Nguyên liệu", "Gạo TẺ   " + d.tag}, {"Tỉ lệ nhắc hiện tại", "0.2"},
		{"Tỉ lệ nhắc mới", "0.35"}, {"Lý do", "Mùa mưa khó mua"}})

	for _, ok := range []string{"0", "1", "1.000000", "0.123456"} {
		if _, err := d.dung(t, d.chu, "dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":%q,"ly_do":"x"}`, d.tag, ok)); err != nil {
			t.Fatalf("tỉ lệ %s đúng khuôn phải có thẻ: %v", ok, err)
		}
	}
	for _, sai := range []string{"20%", "1.1", "1.5", "0,2", "-0.1", ".2", "0.1234567", "2"} {
		if _, err := d.dung(t, d.chu, "dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":%q,"ly_do":"x"}`, d.tag, sai)); err == nil {
			t.Fatalf("tỉ lệ %s phải bị từ chối", sai)
		}
	}
	for _, sai := range []string{
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":"0.3"}`, d.tag),
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":0.3,"ly_do":"x"}`, d.tag),
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":"0.3","ly_do":"x","supply_item_id":%d}`, d.tag, d.gao),
	} {
		if _, err := d.dung(t, d.chu, "dat_ti_le_nhac", sai); err == nil {
			t.Fatalf("dat_ti_le_nhac phải từ chối tham số %s", sai)
		}
	}
	d.khongGhiNguyenLieu(t, "đặt tỉ lệ")
}

// G2, ADR-140 điểm 7: người mất cờ chủ quán sau khi lượt đã có danh sách thì mọi hàm dựng nguyên liệu lỗi.
func TestI044_NguyenLieuMatCoChuQuanGiuaLuotThiKhongDeXuat(t *testing.T) {
	d := moNguyenLieu(t)
	cc, err := troly.MoiNguonNoiBo(d.pool).CongCuGhi(d.ctx, d.chu)
	if err != nil || len(cc) != len(dsGhiChuQuan) {
		t.Fatalf("chủ quán phải có %d công cụ ghi: %d %v", len(dsGhiChuQuan), len(cc), err)
	}
	d.datChuQuan(t, false)
	defer d.datChuQuan(t, true)
	for _, ca := range []struct{ ten, thamSo string }{
		{"them_nguyen_lieu", fmt.Sprintf(`{"ten":"Tiêu %s"}`, d.tag)},
		{"dat_don_vi", fmt.Sprintf(`{"nguyen_lieu":"mộc nhĩ %s","don_vi":"kg"}`, d.tag)},
		{"ghi_so_nguyen_lieu", fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"used","so":"1","don_vi":"bao"}`, d.tag)},
		{"sua_so_nguyen_lieu", fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-01","loai":"used","so_moi":"1","don_vi":"bao","ly_do":"x"}`, d.tag)},
		{"dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":"0.3","ly_do":"x"}`, d.tag)},
	} {
		if _, err := timGhi(t, cc, ca.ten).DeXuat(d.ctx, json.RawMessage(ca.thamSo)); err == nil {
			t.Fatalf("%s: người đã mất cờ chủ quán thì hàm dựng phải lỗi", ca.ten)
		}
	}
	d.khongGhiNguyenLieu(t, "mất cờ chủ quán")
}

// I-044 · I-043 qua đường hỏi: chủ quán được kể năm tên mới; đề xuất đúng hình, không ghi; tên và số đã đọc không tới model.
func TestI044_DuongHoiNguyenLieuKhongGhiKhongLo(t *testing.T) {
	d := moNguyenLieu(t)
	gin.SetMode(gin.TestMode)
	menu := gia.NewService(d.pool)
	hoi := func(nha *troly.NhaGia, nguoi int64) map[string]json.RawMessage {
		t.Helper()
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(d.pool)))
		troly.Routes(r, troly.MoiLop(d.pool, cauHinh(t, "gia", 0), nha), menu, troly.MoiNguonNoiBo(d.pool))
		req := httptest.NewRequest("POST", "/chat/turns", strings.NewReader(`{"question":"Hôm qua dùng nửa bao gạo"}`))
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
		for _, bi := range []string{"Gạo TẺ", "Hành phi", "Hành lá", "Mộc nhĩ", "0.5 bao", "2 bao"} {
			if strings.Contains(s, bi) {
				t.Fatalf("gói tới model mang %q (I-043)", bi)
			}
		}
	}

	nha := troly.MoiNhaGia(goiTool("ghi_so_nguyen_lieu",
		fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ngay":"2026-11-02","loai":"used","so":"0.5","don_vi":"bao"}`, d.tag)), traLoi("Đã ghi!"))
	out := hoi(nha, d.chu)
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
	if err := json.Unmarshal(out["proposal"], &p); err != nil || p.Tool != "ghi_so_nguyen_lieu" || p.OperationID != "createSupplyDayEntry" ||
		!cungJSON(t, p.Body, []byte(fmt.Sprintf(`{"supply_item_id":%d,"entry_date":"2026-11-02","kind":"used","measure":"0.5"}`, d.gao))) ||
		len(p.NeedsChoice) != 0 || len(p.Lines) != 4 {
		t.Fatalf("proposal ghi_so_nguyen_lieu sai: %s", out["proposal"])
	}
	g := nha.DaNhan()
	if len(g) != 1 || !reflect.DeepEqual(g[0].CongCu, append(append([]string{}, dsChuQuan...), dsGhiChuQuan...)) {
		t.Fatalf("gói tới model của chủ quán phải kể %v rồi %v, được %+v", dsChuQuan, dsGhiChuQuan, g)
	}
	loRa(g)
	d.khongGhiNguyenLieu(t, "đường hỏi ghi con số")

	// Tham chiếu nhập nhằng: lỗi công cụ chung, không kết quả, không lộ tên thứ nào.
	nha = troly.MoiNhaGia(goiTool("dat_ti_le_nhac", `{"nguyen_lieu":"Hành","ti_le":"0.3","ly_do":"x"}`), traLoi("Chưa tìm được nguyên liệu."))
	out = hoi(nha, d.chu)
	if string(out["proposal"]) != "null" {
		t.Fatalf("tham chiếu nhập nhằng thì proposal phải null: %s", out["proposal"])
	}
	g = nha.DaNhan()
	if len(g) != 2 || len(g[1].Buoc) != 1 || g[1].Buoc[0].Loi != "loi_cong_cu" || len(g[1].Buoc[0].KetQua) != 0 {
		t.Fatalf("tham chiếu nhập nhằng phải là bước lỗi công cụ không kết quả: %+v", g)
	}
	loRa(g)

	// Người đứng quầy gọi tên nguyên liệu: không có trong danh sách của phiên ⇒ không đề xuất.
	nha = troly.MoiNhaGia(goiTool("dat_ti_le_nhac", fmt.Sprintf(`{"nguyen_lieu":"gạo tẻ %s","ti_le":"0.3","ly_do":"x"}`, d.tag)), traLoi("Không làm được."))
	out = hoi(nha, d.quay)
	if string(out["proposal"]) != "null" {
		t.Fatalf("người đứng quầy không có công cụ nguyên liệu: %s", out["proposal"])
	}
	if g = nha.DaNhan(); len(g) == 0 || !reflect.DeepEqual(g[0].CongCu, append(append([]string{}, dsQuay...), dsGhiQuayChu...)) {
		t.Fatalf("gói tới model của người đứng quầy không có tên nguyên liệu: %+v", g)
	}
	d.khongGhiNguyenLieu(t, "đường hỏi")
}
