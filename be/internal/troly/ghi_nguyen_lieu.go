package troly

import (
	"context"
	"encoding/json"
	"errors"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/nguyenlieu"
	"github.com/jackc/pgx/v5"
)

// Không kèm tham số, tên nguyên liệu hay con số trong lỗi của hàm dựng.
var loiDeXuatNguyenLieu = errors.New("không dựng được đề xuất nguyên liệu")

// Đúng pattern của CreateSupplyDayEntry/UpdateSupplyDayEntry và SetSupplyItemReminderRatio.
var khuonSoNguyenLieu = regexp.MustCompile(`^(0|[1-9][0-9]{0,8})(\.[0-9]{1,3})?$`)
var khuonTiLeNhacNguyenLieu = regexp.MustCompile(`^(0(\.[0-9]{1,6})?|1(\.0{1,6})?)$`)

func (n *NguonNoiBo) congCuGhiNguyenLieu(nguoi int64) []CongCuGhi {
	congCu := func(ten, op, moTa string, dung func(context.Context, json.RawMessage) (DeXuat, error)) CongCuGhi {
		return CongCuGhi{Ten: ten, OperationID: op, MoTa: moTa, DeXuat: func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
			// Buộc vào người lúc dựng danh sách và kiểm lại quyền khi model gọi.
			if err := authz.ReadAs(ctx, n.pool, authz.Caller{PersonID: nguoi}, authz.NeedOwner,
				func(pgx.Tx, authz.Granted) error { return nil }); err != nil {
				return DeXuat{}, loiDeXuatNguyenLieu
			}
			d, err := dung(ctx, raw)
			if err != nil {
				return DeXuat{}, loiDeXuatNguyenLieu
			}
			d.CongCu, d.OperationID = ten, op
			luc := time.Now()
			for i := range d.Dong {
				d.Dong[i].CongCu, d.Dong[i].DocLuc = ten, luc
			}
			return d, nil
		}}
	}
	return []CongCuGhi{
		congCu("them_nguyen_lieu", "createSupplyItem", "Đề xuất thêm nguyên liệu với tên và đơn vị tuỳ chọn.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatThemNguyenLieu(ctx, nguoi, raw)
			}),
		congCu("dat_don_vi", "setSupplyItemPurchaseUnit", "Đề xuất đặt đơn vị lần đầu cho một nguyên liệu.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatDatDonVi(ctx, nguoi, raw)
			}),
		congCu("ghi_so_nguyen_lieu", "createSupplyDayEntry", "Đề xuất ghi con số mua vào hoặc đã dùng theo ngày và đơn vị người nói.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatSoNguyenLieu(ctx, nguoi, raw, false)
			}),
		congCu("sua_so_nguyen_lieu", "updateSupplyDayEntry", "Đề xuất sửa một con số nguyên liệu đã ghi, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatSoNguyenLieu(ctx, nguoi, raw, true)
			}),
		congCu("dat_ti_le_nhac", "setSupplyItemReminderRatio", "Đề xuất đặt tỉ lệ nhắc kiểm tra nguyên liệu, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatDatTiLeNhac(ctx, nguoi, raw)
			}),
	}
}

func (n *NguonNoiBo) timNguyenLieuDeXuat(ctx context.Context, nguoi int64, chu string) (nguyenlieu.Thu, error) {
	if utf8.RuneCountInString(chu) < 2 {
		return nguyenlieu.Thu{}, loiDeXuatNguyenLieu
	}
	ds, err := n.nguyenLieu.Doc(ctx, nguoi)
	if err != nil {
		return nguyenlieu.Thu{}, loiDeXuatNguyenLieu
	}
	chu = chuanThamChieu(chu)
	var bang, chua nguyenlieu.Thu
	demBang, demChua := 0, 0
	for _, thu := range ds {
		ten := chuanThamChieu(thu.Name)
		if ten == chu {
			bang = thu
			demBang++
		}
		if strings.Contains(ten, chu) {
			chua = thu
			demChua++
		}
	}
	if demBang == 1 {
		return bang, nil
	}
	if demBang == 0 && demChua == 1 {
		return chua, nil
	}
	return nguyenlieu.Thu{}, loiDeXuatNguyenLieu
}

func deXuatNguyenLieu(duong map[string]int64, than map[string]any, dong []DongDeXuat) (DeXuat, error) {
	d := DeXuat{Dong: dong}
	var err error
	if len(duong) > 0 {
		d.ThamSoDuong, err = json.Marshal(duong)
		if err != nil {
			return DeXuat{}, loiDeXuatNguyenLieu
		}
	}
	d.Than, err = json.Marshal(than)
	if err != nil {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	return d, nil
}

func (n *NguonNoiBo) deXuatThemNguyenLieu(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"ten"}, "don_vi")
	if err != nil {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	ds, err := n.nguyenLieu.Doc(ctx, nguoi)
	if err != nil {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	ten := chuanThamChieu(p["ten"])
	for _, thu := range ds {
		if chuanThamChieu(thu.Name) == ten {
			return DeXuat{}, loiDeXuatNguyenLieu
		}
	}
	than := map[string]any{"name": p["ten"]}
	dong := []DongDeXuat{{Nhan: "Tên", GiaTri: p["ten"]}}
	if donVi, co := p["don_vi"]; co {
		than["purchase_unit"] = donVi
		dong = append(dong, DongDeXuat{Nhan: "Đơn vị", GiaTri: donVi})
	}
	return deXuatNguyenLieu(nil, than, dong)
}

func (n *NguonNoiBo) deXuatDatDonVi(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"nguyen_lieu", "don_vi"})
	if err != nil {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	thu, err := n.timNguyenLieuDeXuat(ctx, nguoi, p["nguyen_lieu"])
	if err != nil || thu.PurchaseUnit != nil {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	return deXuatNguyenLieu(map[string]int64{"supply_item_id": thu.ID}, map[string]any{"purchase_unit": p["don_vi"]}, []DongDeXuat{
		{Nhan: "Nguyên liệu", GiaTri: thu.Name}, {Nhan: "Đơn vị", GiaTri: p["don_vi"]},
	})
}

func (n *NguonNoiBo) deXuatSoNguyenLieu(ctx context.Context, nguoi int64, raw json.RawMessage, sua bool) (DeXuat, error) {
	batBuoc := []string{"nguyen_lieu", "ngay", "loai", "don_vi"}
	khoaSo := "so"
	if sua {
		khoaSo = "so_moi"
		batBuoc = append(batBuoc, "ly_do")
	}
	p, err := thamSoGiaoViec(raw, append(batBuoc, khoaSo))
	if err != nil || !khuonSoNguyenLieu.MatchString(p[khoaSo]) {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	const khuonNgay = "2006-01-02"
	ngay, err := time.Parse(khuonNgay, p["ngay"])
	if err != nil || ngay.Format(khuonNgay) != p["ngay"] {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	var loai string
	switch p["loai"] {
	case "purchased":
		loai = "Mua vào"
	case "used":
		loai = "Đã dùng"
	default:
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	thu, err := n.timNguyenLieuDeXuat(ctx, nguoi, p["nguyen_lieu"])
	if err != nil || thu.PurchaseUnit == nil || chuanThamChieu(*thu.PurchaseUnit) != chuanThamChieu(p["don_vi"]) {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	chiTiet, err := n.nguyenLieu.DocChiTiet(ctx, nguoi, thu.ID)
	if err != nil {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	var cu *nguyenlieu.ConSo
	for i, so := range chiTiet.Entries {
		if so.EntryDate == p["ngay"] && so.Kind == p["loai"] {
			cu = &chiTiet.Entries[i]
			break
		}
	}
	// Ghi mới phải chưa có con số; sửa phải tìm được con số cùng ngày và loại.
	if sua != (cu != nil) {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	dong := []DongDeXuat{
		{Nhan: "Nguyên liệu", GiaTri: thu.Name}, {Nhan: "Ngày", GiaTri: ngay.Format("02/01/2006")}, {Nhan: "Loại", GiaTri: loai},
	}
	conSo := p[khoaSo] + " " + *thu.PurchaseUnit
	if sua {
		dong = append(dong,
			DongDeXuat{Nhan: "Con số hiện tại", GiaTri: cu.Measure + " " + *thu.PurchaseUnit},
			DongDeXuat{Nhan: "Con số mới", GiaTri: conSo}, DongDeXuat{Nhan: "Lý do", GiaTri: p["ly_do"]})
		return deXuatNguyenLieu(map[string]int64{"supply_day_entry_id": cu.ID}, map[string]any{"measure": p[khoaSo], "reason": p["ly_do"]}, dong)
	}
	dong = append(dong, DongDeXuat{Nhan: "Con số", GiaTri: conSo})
	return deXuatNguyenLieu(nil, map[string]any{"supply_item_id": thu.ID, "entry_date": p["ngay"], "kind": p["loai"], "measure": p[khoaSo]}, dong)
}

func (n *NguonNoiBo) deXuatDatTiLeNhac(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"nguyen_lieu", "ti_le", "ly_do"})
	if err != nil || !khuonTiLeNhacNguyenLieu.MatchString(p["ti_le"]) {
		return DeXuat{}, loiDeXuatNguyenLieu
	}
	thu, err := n.timNguyenLieuDeXuat(ctx, nguoi, p["nguyen_lieu"])
	if err != nil {
		return DeXuat{}, err
	}
	return deXuatNguyenLieu(map[string]int64{"supply_item_id": thu.ID}, map[string]any{"reminder_ratio": p["ti_le"], "reason": p["ly_do"]}, []DongDeXuat{
		{Nhan: "Nguyên liệu", GiaTri: thu.Name}, {Nhan: "Tỉ lệ nhắc hiện tại", GiaTri: thu.ReminderRatio},
		{Nhan: "Tỉ lệ nhắc mới", GiaTri: p["ti_le"]}, {Nhan: "Lý do", GiaTri: p["ly_do"]},
	})
}
