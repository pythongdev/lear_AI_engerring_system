package troly

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"
	"unicode/utf8"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/giaoviec"
	"github.com/jackc/pgx/v5"
)

// Không kèm tham số, nội dung việc hay tên người trong lỗi của hàm dựng.
var loiDeXuatGiaoViec = errors.New("không dựng được đề xuất giao việc")

func (n *NguonNoiBo) congCuGhiGiaoViec(nguoi int64) []CongCuGhi {
	congCu := func(ten, op, moTa string, dung func(context.Context, json.RawMessage) (DeXuat, error)) CongCuGhi {
		return CongCuGhi{Ten: ten, OperationID: op, MoTa: moTa, DeXuat: func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
			// Buộc vào người lúc dựng danh sách và kiểm lại quyền khi model gọi.
			if err := authz.ReadAs(ctx, n.pool, authz.Caller{PersonID: nguoi}, authz.NeedCounterOrOwner,
				func(pgx.Tx, authz.Granted) error { return nil }); err != nil {
				return DeXuat{}, loiDeXuatGiaoViec
			}
			d, err := dung(ctx, raw)
			if err != nil {
				return DeXuat{}, loiDeXuatGiaoViec
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
		congCu("giao_viec", "createAssignedTask", "Đề xuất giao việc với nội dung và hạn; người bấm chọn người nhận.",
			func(_ context.Context, raw json.RawMessage) (DeXuat, error) { return n.deXuatGiaoViec(raw) }),
		congCu("sua_viec", "updateAssignedTask", "Đề xuất sửa nội dung hoặc hạn của một việc, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatSuaViec(ctx, nguoi, raw)
			}),
		congCu("an_viec", "hideAssignedTask", "Đề xuất ẩn một việc, kèm lý do.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) { return n.deXuatAnViec(ctx, nguoi, raw) }),
		congCu("danh_dau_viec", "markAssignedTask", "Đề xuất đánh dấu xong hoặc bỏ đánh dấu một việc.",
			func(ctx context.Context, raw json.RawMessage) (DeXuat, error) {
				return n.deXuatDanhDauViec(ctx, nguoi, raw)
			}),
	}
}

// Mọi tham số của nhóm này là chuỗi không rỗng; khoá phải khớp đúng hợp đồng.
func thamSoGiaoViec(raw json.RawMessage, batBuoc []string, tuyChon ...string) (map[string]string, error) {
	var body map[string]json.RawMessage
	if err := json.Unmarshal(raw, &body); err != nil || body == nil {
		return nil, loiDeXuatGiaoViec
	}
	choPhep := make(map[string]bool, len(batBuoc)+len(tuyChon))
	for _, k := range batBuoc {
		choPhep[k] = true
		if _, co := body[k]; !co {
			return nil, loiDeXuatGiaoViec
		}
	}
	for _, k := range tuyChon {
		choPhep[k] = true
	}
	out := make(map[string]string, len(body))
	for k, v := range body {
		var chu *string
		if !choPhep[k] || json.Unmarshal(v, &chu) != nil || chu == nil {
			return nil, loiDeXuatGiaoViec
		}
		out[k] = strings.TrimSpace(*chu)
		if out[k] == "" {
			return nil, loiDeXuatGiaoViec
		}
	}
	return out, nil
}

func (n *NguonNoiBo) hanGiaoViec(chu string) (time.Time, error) {
	// postgres.Open đặt múi giờ quán từ BANHCUON_SHOP_TZ vào kết nối (QC-15).
	tz := n.pool.Config().ConnConfig.RuntimeParams["timezone"]
	if tz == "" {
		return time.Time{}, loiDeXuatGiaoViec
	}
	loc, err := time.LoadLocation(tz)
	if err != nil {
		return time.Time{}, loiDeXuatGiaoViec
	}
	const khuon = "2006-01-02T15:04"
	han, err := time.ParseInLocation(khuon, chu, loc)
	if err != nil || han.Format(khuon) != chu {
		return time.Time{}, loiDeXuatGiaoViec
	}
	return han, nil
}

func chuanThamChieu(s string) string {
	return strings.ToLower(strings.Join(strings.Fields(s), " "))
}

func (n *NguonNoiBo) timViecDeXuat(ctx context.Context, nguoi int64, chu string) (giaoviec.Viec, error) {
	if utf8.RuneCountInString(chu) < 2 {
		return giaoviec.Viec{}, loiDeXuatGiaoViec
	}
	ds, err := n.giaoViec.Doc(ctx, nguoi, 0, false)
	if err != nil {
		return giaoviec.Viec{}, loiDeXuatGiaoViec
	}
	chu = chuanThamChieu(chu)
	var viec giaoviec.Viec
	dem := 0
	for _, v := range ds {
		if strings.Contains(chuanThamChieu(v.Content), chu) {
			viec = v
			dem++
		}
	}
	if dem != 1 {
		return giaoviec.Viec{}, loiDeXuatGiaoViec
	}
	return viec, nil
}

func deXuatViec(id int64, than map[string]any, dong []DongDeXuat) (DeXuat, error) {
	d := DeXuat{Dong: dong}
	var err error
	if id > 0 {
		d.ThamSoDuong, err = json.Marshal(map[string]int64{"assigned_task_id": id})
		if err != nil {
			return DeXuat{}, loiDeXuatGiaoViec
		}
	}
	d.Than, err = json.Marshal(than)
	return d, err
}

func (n *NguonNoiBo) deXuatGiaoViec(raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"noi_dung", "han"})
	if err != nil {
		return DeXuat{}, err
	}
	han, err := n.hanGiaoViec(p["han"])
	if err != nil {
		return DeXuat{}, err
	}
	d, err := deXuatViec(0, map[string]any{"content": p["noi_dung"], "due_at": han.Format(time.RFC3339)}, []DongDeXuat{
		{Nhan: "Nội dung", GiaTri: p["noi_dung"]},
		{Nhan: "Hạn", GiaTri: han.Format("15:04 ngày 02/01/2006")},
	})
	d.CanChon = []string{"assignee_person_id"}
	return d, err
}

func (n *NguonNoiBo) deXuatSuaViec(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"viec", "ly_do"}, "noi_dung_moi", "han_moi")
	if err != nil || (p["noi_dung_moi"] == "" && p["han_moi"] == "") {
		return DeXuat{}, loiDeXuatGiaoViec
	}
	v, err := n.timViecDeXuat(ctx, nguoi, p["viec"])
	if err != nil {
		return DeXuat{}, err
	}
	than := map[string]any{"content": v.Content, "assignee_person_id": v.AssigneeID, "reason": p["ly_do"]}
	dong := []DongDeXuat{{Nhan: "Việc", GiaTri: v.Content}, {Nhan: "Người nhận", GiaTri: v.AssigneeName}}
	if moi, co := p["noi_dung_moi"]; co {
		than["content"] = moi
		dong = append(dong, DongDeXuat{Nhan: "Nội dung mới", GiaTri: moi})
	}
	if moi, co := p["han_moi"]; co {
		han, err := n.hanGiaoViec(moi)
		if err != nil {
			return DeXuat{}, err
		}
		than["due_at"] = han.Format(time.RFC3339)
		dong = append(dong, DongDeXuat{Nhan: "Hạn mới", GiaTri: han.Format("15:04 ngày 02/01/2006")})
	}
	dong = append(dong, DongDeXuat{Nhan: "Lý do", GiaTri: p["ly_do"]})
	return deXuatViec(v.ID, than, dong)
}

func (n *NguonNoiBo) deXuatAnViec(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"viec", "ly_do"})
	if err != nil {
		return DeXuat{}, err
	}
	v, err := n.timViecDeXuat(ctx, nguoi, p["viec"])
	if err != nil {
		return DeXuat{}, err
	}
	return deXuatViec(v.ID, map[string]any{"reason": p["ly_do"]}, []DongDeXuat{
		{Nhan: "Việc", GiaTri: v.Content}, {Nhan: "Người nhận", GiaTri: v.AssigneeName}, {Nhan: "Lý do", GiaTri: p["ly_do"]},
	})
}

func (n *NguonNoiBo) deXuatDanhDauViec(ctx context.Context, nguoi int64, raw json.RawMessage) (DeXuat, error) {
	p, err := thamSoGiaoViec(raw, []string{"viec", "danh_dau"})
	if err != nil || (p["danh_dau"] != "done" && p["danh_dau"] != "undone") {
		return DeXuat{}, loiDeXuatGiaoViec
	}
	v, err := n.timViecDeXuat(ctx, nguoi, p["viec"])
	if err != nil {
		return DeXuat{}, err
	}
	trangThai := func(xong bool) string {
		if xong {
			return "Đã xong"
		}
		return "Chưa xong"
	}
	return deXuatViec(v.ID, map[string]any{"mark": p["danh_dau"]}, []DongDeXuat{
		{Nhan: "Việc", GiaTri: v.Content}, {Nhan: "Người nhận", GiaTri: v.AssigneeName},
		{Nhan: "Hiện tại", GiaTri: trangThai(v.Done)}, {Nhan: "Đổi thành", GiaTri: trangThai(p["danh_dau"] == "done")},
	})
}
