package troly

import (
	"context"
	"encoding/json"
	"errors"
	"sync"
)

type NhaGia struct {
	mu      sync.Mutex
	kichBan []func(context.Context, GoiModel) (PhanHoi, error)
	daNhan  []GoiModel
}

func MoiNhaGia(kichBan ...func(context.Context, GoiModel) (PhanHoi, error)) *NhaGia {
	return &NhaGia{kichBan: append([]func(context.Context, GoiModel) (PhanHoi, error){}, kichBan...)}
}
func (*NhaGia) Ma() string                { return "gia" }
func (*NhaGia) Model() string             { return "gia-1" }
func (*NhaGia) Gia() (int64, int64, bool) { return 1_000_000, 4_000_000, true }

func saoGoi(g GoiModel) GoiModel {
	g.LichSu = append([]Tin(nil), g.LichSu...)
	g.CongCu = append([]string(nil), g.CongCu...)
	g.Buoc = append([]BuocCongCu(nil), g.Buoc...)
	for i := range g.Buoc {
		g.Buoc[i].LoiGoi.ThamSo = append(json.RawMessage(nil), g.Buoc[i].LoiGoi.ThamSo...)
		g.Buoc[i].KetQua = append(json.RawMessage(nil), g.Buoc[i].KetQua...)
	}
	return g
}
func (n *NhaGia) DaNhan() []GoiModel {
	n.mu.Lock()
	defer n.mu.Unlock()
	out := make([]GoiModel, len(n.daNhan))
	for i, g := range n.daNhan {
		out[i] = saoGoi(g)
	}
	return out
}
func (n *NhaGia) Goi(ctx context.Context, g GoiModel) (PhanHoi, error) {
	n.mu.Lock()
	i := len(n.daNhan)
	n.daNhan = append(n.daNhan, saoGoi(g))
	if len(n.kichBan) == 0 {
		n.mu.Unlock()
		return PhanHoi{}, errors.New("nhà giả chưa có kịch bản")
	}
	if i >= len(n.kichBan) {
		i = len(n.kichBan) - 1
	}
	f := n.kichBan[i]
	n.mu.Unlock()
	if err := ctx.Err(); err != nil {
		return PhanHoi{}, err
	}
	if f == nil {
		return PhanHoi{}, errors.New("kịch bản nhà giả rỗng")
	}
	return f(ctx, saoGoi(g))
}
