package troly

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"
	"unicode/utf8"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/daotao"
	"github.com/jackc/pgx/v5"
)

// Không kèm tham số, nội dung hướng dẫn, nhận xét hay tên người trong lỗi.
var loiDeXuatDaoTao = errors.New("không dựng được đề xuất đào tạo")

func (n *NguonNoiBo) congCuGhiDaoTao(nguoi int64) []CongCuGhi {
	congCu := func(ten, op, moTa string, dung func(context.Context, json.RawMessage) (DeXuat, error)) CongCuGhi {
		return CongCuGhi{Ten: ten, OperationID: op, MoTa: moTa, DeXuat: func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
			// Buộc vào người lúc dựng danh sách và kiểm lại quyền khi model gọi.
			if err := authz.ReadAs(ctx, n.pool, authz.Caller{PersonID: nguoi}, authz.NeedCounterOrOwner,
				func(pgx.Tx, authz.Granted) error { return nil }); err != nil {
				return DeXuat{}, loiDeXuatDaoTao
			}
			d, err := dung(ctx, raw)
			if err != nil {
				return DeXuat{}, loiDeXuatDaoTao
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
		congCu("gan_huong_dan", "attachAssignedTaskGuide", "Đề xuất gắn hướng dẫn chữ vào một việc.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatGanHuongDan(ctx, nguoi, raw)
			}),
		congCu("sua_huong_dan", "updateAssignedTaskGuide", "Đề xuất sửa hướng dẫn chữ của một việc, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatSuaHuongDan(ctx, nguoi, raw)
			}),
		congCu("an_huong_dan", "hideAssignedTaskGuide", "Đề xuất ẩn hướng dẫn chữ của một việc, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatAnHuongDan(ctx, nguoi, raw)
			}),
		congCu("ghi_nhan_dao_tao", "createTrainingRecord", "Đề xuất ghi nhận nhận xét hoặc đánh giá; người bấm chọn người được ghi.",
			func(_ context.Context, raw json.RawMessage) (DeXuat, error) { return deXuatGhiNhanDaoTao(raw) }),
		congCu("sua_ghi_nhan", "updateTrainingRecord", "Đề xuất sửa nhận xét hoặc đánh giá của một ghi nhận, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatSuaGhiNhan(ctx, nguoi, raw)
			}),
		congCu("an_ghi_nhan", "hideTrainingRecord", "Đề xuất ẩn một ghi nhận đào tạo, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatAnGhiNhan(ctx, nguoi, raw)
			}),
	}
}

// Giữ đúng phép chuẩn hoá của timViecDeXuat: gom khoảng trắng rồi chuyển chữ thường.
func chuanThamChieuDaoTao(s string) string {
	return strings.ToLower(strings.Join(strings.Fields(s), " "))
}

func (n *NguonNoiBo) timHuongDanDeXuat(ctx context.Context, nguoi, viec int64, chu string) (daotao.HuongDan, error) {
	if utf8.RuneCountInString(chu) < 2 {
		return daotao.HuongDan{}, loiDeXuatDaoTao
	}
	ds, err := n.daoTao.DocHuongDan(ctx, nguoi, viec, false)
	if err != nil {
		return daotao.HuongDan{}, loiDeXuatDaoTao
	}
	chu = chuanThamChieuDaoTao(chu)
	var huongDan daotao.HuongDan
	dem := 0
	for _, h := range ds {
		if h.Kind == "text" && h.Body != nil && strings.Contains(chuanThamChieuDaoTao(*h.Body), chu) {
			huongDan = h
			dem++
		}
	}
	if dem != 1 {
		return daotao.HuongDan{}, loiDeXuatDaoTao
	}
	return huongDan, nil
}

func (n *NguonNoiBo) timGhiNhanDeXuat(ctx context.Context, nguoi int64, chu string) (daotao.GhiNhanDaoTao, error) {
	if utf8.RuneCountInString(chu) < 2 {
		return daotao.GhiNhanDaoTao{}, loiDeXuatDaoTao
	}
	ds, err := n.daoTao.DocGhiNhan(ctx, nguoi, 0, false)
	if err != nil {
		return daotao.GhiNhanDaoTao{}, loiDeXuatDaoTao
	}
	chu = chuanThamChieuDaoTao(chu)
	var ghiNhan daotao.GhiNhanDaoTao
	dem := 0
	for _, g := range ds {
		if g.Remark != nil && strings.Contains(chuanThamChieuDaoTao(*g.Remark), chu) {
			ghiNhan = g
			dem++
		}
	}
	if dem != 1 {
		return daotao.GhiNhanDaoTao{}, loiDeXuatDaoTao
	}
	return ghiNhan, nil
}

func deXuatDaoTao(duong map[string]int64, than map[string]string, dong []DongDeXuat) (DeXuat, error) {
	d := DeXuat{Dong: dong}
	var err error
	if len(duong) > 0 {
		d.ThamSoDuong, err = json.Marshal(duong)
		if err != nil {
			return DeXuat{}, loiDeXuatDaoTao
		}
	}
	d.Than, err = json.Marshal(than)
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	return d, nil
}

func (n *NguonNoiBo) deXuatGanHuongDan(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"viec", "noi_dung"})
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	v, err := n.timViecDeXuat(ctx, nguoi, p["viec"])
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	return deXuatDaoTao(map[string]int64{"assigned_task_id": v.ID}, map[string]string{"kind": "text", "body": p["noi_dung"]}, []DongDeXuat{
		{Nhan: "Việc", GiaTri: v.Content}, {Nhan: "Người nhận", GiaTri: v.AssigneeName}, {Nhan: "Hướng dẫn", GiaTri: p["noi_dung"]},
	})
}

func (n *NguonNoiBo) deXuatSuaHuongDan(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"viec", "huong_dan", "noi_dung_moi", "ly_do"})
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	v, err := n.timViecDeXuat(ctx, nguoi, p["viec"])
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	h, err := n.timHuongDanDeXuat(ctx, nguoi, v.ID, p["huong_dan"])
	if err != nil {
		return DeXuat{}, err
	}
	return deXuatDaoTao(map[string]int64{"assigned_task_guide_id": h.ID}, map[string]string{"body": p["noi_dung_moi"], "reason": p["ly_do"]}, []DongDeXuat{
		{Nhan: "Việc", GiaTri: v.Content}, {Nhan: "Hướng dẫn", GiaTri: *h.Body},
		{Nhan: "Nội dung mới", GiaTri: p["noi_dung_moi"]}, {Nhan: "Lý do", GiaTri: p["ly_do"]},
	})
}

func (n *NguonNoiBo) deXuatAnHuongDan(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"viec", "huong_dan", "ly_do"})
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	v, err := n.timViecDeXuat(ctx, nguoi, p["viec"])
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	h, err := n.timHuongDanDeXuat(ctx, nguoi, v.ID, p["huong_dan"])
	if err != nil {
		return DeXuat{}, err
	}
	return deXuatDaoTao(map[string]int64{"assigned_task_guide_id": h.ID}, map[string]string{"reason": p["ly_do"]}, []DongDeXuat{
		{Nhan: "Việc", GiaTri: v.Content}, {Nhan: "Hướng dẫn", GiaTri: *h.Body}, {Nhan: "Lý do", GiaTri: p["ly_do"]},
	})
}

func chuDanhGiaDaoTao(danhGia string) string {
	switch danhGia {
	case "pass":
		return "Làm được"
	case "not_yet":
		return "Chưa làm được"
	default:
		return "Chưa đánh giá"
	}
}

func dongGhiNhanDaoTao(g daotao.GhiNhanDaoTao) []DongDeXuat {
	danhGia := ""
	if g.Rating != nil {
		danhGia = *g.Rating
	}
	// timGhiNhanDeXuat chỉ trả ghi nhận có nhận xét.
	return []DongDeXuat{
		{Nhan: "Về", GiaTri: g.TraineeName}, {Nhan: "Nhận xét", GiaTri: *g.Remark}, {Nhan: "Đánh giá", GiaTri: chuDanhGiaDaoTao(danhGia)},
	}
}

func deXuatGhiNhanDaoTao(raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, nil, "nhan_xet", "danh_gia")
	if err != nil || (p["nhan_xet"] == "" && p["danh_gia"] == "") {
		return DeXuat{}, loiDeXuatDaoTao
	}
	than := make(map[string]string)
	var dong []DongDeXuat
	if nhanXet, co := p["nhan_xet"]; co {
		than["remark"] = nhanXet
		dong = append(dong, DongDeXuat{Nhan: "Nhận xét", GiaTri: nhanXet})
	}
	if danhGia, co := p["danh_gia"]; co {
		if danhGia != "pass" && danhGia != "not_yet" {
			return DeXuat{}, loiDeXuatDaoTao
		}
		than["rating"] = danhGia
		dong = append(dong, DongDeXuat{Nhan: "Đánh giá", GiaTri: chuDanhGiaDaoTao(danhGia)})
	}
	d, err := deXuatDaoTao(nil, than, dong)
	d.CanChon = []string{"trainee_person_id"}
	return d, err
}

func (n *NguonNoiBo) deXuatSuaGhiNhan(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"ghi_nhan", "ly_do"}, "nhan_xet_moi", "danh_gia_moi")
	if err != nil || (p["nhan_xet_moi"] == "" && p["danh_gia_moi"] == "") {
		return DeXuat{}, loiDeXuatDaoTao
	}
	if danhGia, co := p["danh_gia_moi"]; co && danhGia != "pass" && danhGia != "not_yet" {
		return DeXuat{}, loiDeXuatDaoTao
	}
	g, err := n.timGhiNhanDeXuat(ctx, nguoi, p["ghi_nhan"])
	if err != nil {
		return DeXuat{}, err
	}
	// Cửa sửa thay cả hai trường; giữ nguyên trường người dùng không đổi.
	than := map[string]string{"remark": *g.Remark, "reason": p["ly_do"]}
	if g.Rating != nil {
		than["rating"] = *g.Rating
	}
	dong := dongGhiNhanDaoTao(g)
	if nhanXet, co := p["nhan_xet_moi"]; co {
		than["remark"] = nhanXet
		dong = append(dong, DongDeXuat{Nhan: "Nhận xét mới", GiaTri: nhanXet})
	}
	if danhGia, co := p["danh_gia_moi"]; co {
		than["rating"] = danhGia
		dong = append(dong, DongDeXuat{Nhan: "Đánh giá mới", GiaTri: chuDanhGiaDaoTao(danhGia)})
	}
	dong = append(dong, DongDeXuat{Nhan: "Lý do", GiaTri: p["ly_do"]})
	return deXuatDaoTao(map[string]int64{"training_record_id": g.ID}, than, dong)
}

func (n *NguonNoiBo) deXuatAnGhiNhan(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"ghi_nhan", "ly_do"})
	if err != nil {
		return DeXuat{}, loiDeXuatDaoTao
	}
	g, err := n.timGhiNhanDeXuat(ctx, nguoi, p["ghi_nhan"])
	if err != nil {
		return DeXuat{}, err
	}
	dong := append(dongGhiNhanDaoTao(g), DongDeXuat{Nhan: "Lý do", GiaTri: p["ly_do"]})
	return deXuatDaoTao(map[string]int64{"training_record_id": g.ID}, map[string]string{"reason": p["ly_do"]}, dong)
}
