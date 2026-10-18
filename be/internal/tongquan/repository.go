package tongquan

import (
	"banhcuon/be/internal/tongquan/internal/sqlcgen"
	"context"
	"encoding/json"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"time"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func (r repository) ngay(ctx context.Context, moc time.Time) (string, error) {
	return r.q.Ngay(ctx, pgtype.Timestamptz{Time: moc, Valid: true})
}

func (r repository) dat(ctx context.Context, ngay string, p ToiThieuInput) (ToiThieu, error) {
	row, err := r.q.DatToiThieu(ctx, sqlcgen.DatToiThieuParams{Column1: ngay, MinimumBanh: p.MinimumBanh, MinimumWorkers: p.MinimumWorkers})
	return ToiThieu{ToiThieuInput: ToiThieuInput{row.MinimumBanh, row.MinimumWorkers}, SaleDate: row.SaleDate, PersonID: row.PersonID, CreatedAt: row.CreatedAt.Time}, err
}

func (r repository) tong(ctx context.Context, ngay string) (out soTong, err error) {
	raw, err := r.q.Tong(ctx, ngay)
	if err != nil {
		return out, err
	}
	err = json.Unmarshal(raw, &out)
	return
}
