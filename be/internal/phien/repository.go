package phien

import (
	"context"

	"banhcuon/be/internal/phien/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) khoa(ctx context.Context, id int64) (string, error) {
	return r.q.Khoa(ctx, id)
}

func (r repository) tongTien(ctx context.Context, id int64) (int64, error) {
	return r.q.TongTien(ctx, pgtype.Int8{Int64: id, Valid: true})
}
