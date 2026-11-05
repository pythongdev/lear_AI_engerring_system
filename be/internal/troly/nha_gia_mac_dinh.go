package troly

import (
	"context"
	"encoding/json"
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
		return PhanHoi{GoiCongCu: &LoiGoi{Ten: "doc_menu", ThamSo: json.RawMessage(`{}`)}}, nil
	}
	return PhanHoi{Chu: "Đây là model giả. Bạn hãy mở trang menu để xem món và giá hiện tại."}, nil
}
