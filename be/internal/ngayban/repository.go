package ngayban

import (
	"context"
	"time"

	"banhcuon/be/internal/ngayban/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của bên gọi; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) dongHo(ctx context.Context) (time.Time, error) {
	moc, err := r.q.DongHo(ctx)
	return moc.Time, err
}

func (r repository) quyNgay(ctx context.Context, moc time.Time) (string, error) {
	return r.q.QuyNgay(ctx, pgtype.Timestamptz{Time: moc, Valid: true})
}

func (r repository) khoaChung(ctx context.Context, ngay string) error {
	return r.q.KhoaChung(ctx, ngay)
}

func (r repository) khoaRieng(ctx context.Context, ngay string) error {
	return r.q.KhoaRieng(ctx, ngay)
}

func (r repository) daKy(ctx context.Context, ngay string) (bool, error) {
	return r.q.DaKy(ctx, ngay)
}

func (r repository) ngoaiGio(ctx context.Context, moc time.Time) (bool, error) {
	return r.q.NgoaiGio(ctx, pgtype.Timestamptz{Time: moc, Valid: true})
}
