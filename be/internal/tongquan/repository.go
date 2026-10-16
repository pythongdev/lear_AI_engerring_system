package tongquan

import (
	"banhcuon/be/internal/tongquan/internal/sqlcgen"
	"context"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"time"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func (r repository) ngay(ctx context.Context, moc time.Time) (string, error) {
	return r.q.Ngay(ctx, pgtype.Timestamptz{Time: moc, Valid: true})
}
