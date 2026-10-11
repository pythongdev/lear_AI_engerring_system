package qr

import (
	"context"

	"banhcuon/be/internal/qr/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
)

// repository nhận giao dịch của service; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) capMa(ctx context.Context, banID int64) (int64, error) {
	return r.q.CapMa(ctx, banID)
}

func (r repository) docMaVuaCap(ctx context.Context, id int64) (maVuaCap, error) {
	row, err := r.q.DocMaVuaCap(ctx, id)
	return maVuaCap{Code: row.Code, DiningTableID: row.DiningTableID, IssuedAt: row.ToChar}, err
}
