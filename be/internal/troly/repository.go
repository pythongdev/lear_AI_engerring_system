package troly

import (
	"banhcuon/be/internal/troly/internal/sqlcgen"
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func (r repository) giuCho(ctx context.Context, nha, model string, tien int64) (int64, error) {
	return r.q.GiuCho(ctx, sqlcgen.GiuChoParams{ProviderCode: nha, ModelCode: model, ReservedMicrousd: tien})
}
func (r repository) tongThang(ctx context.Context) (int64, error) { return r.q.TongThang(ctx) }

// chot khai lý do sát câu sửa rồi gỡ, như cửa khách: chốt do máy ghi, không có người (ADR-139 điểm 5, QD-52).
func (r repository) chot(ctx context.Context, id, tien int64, ph PhanHoi) error {
	if err := r.q.KhaiLyDo(ctx, "troly/chot: chốt lần gọi model"); err != nil {
		return err
	}
	n, err := r.q.Chot(ctx, sqlcgen.ChotParams{ID: id, Column2: ph.BietMucDung, Column3: int32(ph.TokenVao), Column4: int32(ph.TokenRa), Column5: tien})
	if err != nil {
		return err
	}
	if n != 1 {
		return fmt.Errorf("không tìm thấy dòng giữ chỗ")
	}
	return r.q.KhaiLyDo(ctx, "")
}
