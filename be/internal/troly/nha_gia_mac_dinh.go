package troly

import (
	"bytes"
	"context"
	"encoding/json"
	"slices"
	"strings"
)

// Nhà giả mặc định không giữ hội thoại hay kết quả giữa các lượt.
type nhaGiaMacDinh struct{}

func MoiNhaGiaMacDinh() NhaCungCap              { return nhaGiaMacDinh{} }
func (nhaGiaMacDinh) Ma() string                { return "gia" }
func (nhaGiaMacDinh) Model() string             { return "gia-1" }
func (nhaGiaMacDinh) Gia() (int64, int64, bool) { return (&NhaGia{}).Gia() }
func (nhaGiaMacDinh) Goi(ctx context.Context, g GoiModel) (PhanHoi, error) {
	if err := ctx.Err(); err != nil {
		return PhanHoi{}, err
	}
	if len(g.Buoc) == 0 {
		var cau string
		for i := len(g.LichSu) - 1; i >= 0; i-- {
			if g.LichSu[i].Vai == "user" {
				cau = strings.ToLower(g.LichSu[i].Chu)
				break
			}
		}
		ten := "doc_menu"
		for _, luat := range []struct{ ten, chuA, chuB string }{
			{"doc_tong_quan", "tổng quan", "hôm nay"},
			{"doc_bang_phuc_vu", "bàn", "phục vụ"},
			{"doc_bang_tram", "trạm", "bếp"},
		} {
			if (strings.Contains(cau, luat.chuA) || strings.Contains(cau, luat.chuB)) && slices.Contains(g.CongCu, luat.ten) {
				ten = luat.ten
				break
			}
		}
		return PhanHoi{GoiCongCu: &LoiGoi{Ten: ten, ThamSo: json.RawMessage(`{}`)}}, nil
	}
	buoc := g.Buoc[len(g.Buoc)-1]
	switch buoc.LoiGoi.Ten {
	case "doc_tong_quan", "doc_bang_phuc_vu", "doc_bang_tram":
		if buoc.Loi != "" {
			return PhanHoi{Chu: "Đây là model giả, chưa đọc được " + buoc.LoiGoi.Ten + "."}, nil
		}
		ketQua := string(buoc.KetQua)
		var gon bytes.Buffer
		if err := json.Compact(&gon, buoc.KetQua); err == nil {
			ketQua = gon.String()
		}
		return PhanHoi{Chu: "Đây là model giả. Kết quả " + buoc.LoiGoi.Ten + ": " + ketQua}, nil
	}
	return PhanHoi{Chu: "Đây là model giả. Bạn hãy mở trang menu để xem món và giá hiện tại."}, nil
}
