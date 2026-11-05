package troly

import (
	"context"
	"encoding/json"

	"banhcuon/be/internal/gia"
)

func CongCuCongKhai(menu *gia.Service) []CongCu {
	return []CongCu{
		{Ten: "doc_menu", MoTa: "Đọc menu đang bán.", Chay: func(ctx context.Context, _ json.RawMessage) (json.RawMessage, error) {
			out, err := menu.DocMenu(ctx)
			if err != nil {
				return nil, err
			}
			return json.Marshal(out)
		}},
		{Ten: "tinh_gia", MoTa: "Tính thử giá các dòng món đã chọn.", Chay: func(ctx context.Context, raw json.RawMessage) (json.RawMessage, error) {
			var body struct {
				Lines []gia.DongYeuCau `json:"lines"`
			}
			if err := json.Unmarshal(raw, &body); err != nil {
				return nil, err
			}
			out, err := menu.TinhThu(ctx, body.Lines)
			if err != nil {
				return nil, err
			}
			return json.Marshal(out)
		}},
	}
}
