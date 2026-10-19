package tongket

import (
	"banhcuon/be/internal/tongket/internal/sqlcgen"
	"context"
	"encoding/json"
	"github.com/jackc/pgx/v5"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }
func (r repository) doc(ctx context.Context, ngay string) (out Summary, err error) {
	raw, err := r.q.DocTongKet(ctx, ngay)
	if err != nil {
		return out, err
	}
	err = json.Unmarshal(raw, &out)
	return out, err
}
