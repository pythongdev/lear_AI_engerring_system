package nhandon

import (
	"banhcuon/be/internal/nhandon/internal/sqlcgen"
	"banhcuon/be/internal/platform/realtime"
	"context"
	"encoding/json"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"time"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository                    { return repository{sqlcgen.New(tx)} }
func (r repository) khoa(ctx context.Context) error         { return r.q.Khoa(ctx) }
func (r repository) daMu(ctx context.Context) (bool, error) { return r.q.DaMu(ctx) }
func (r repository) dongHo(ctx context.Context) (time.Time, error) {
	at, err := r.q.DongHo(ctx)
	return at.Time, err
}
func (r repository) ghiMu(ctx context.Context, since time.Time, person int64) (json.RawMessage, error) {
	return r.q.GhiMu(ctx, sqlcgen.GhiMuParams{Column1: pgtype.Timestamptz{Time: since, Valid: true}, Column2: person})
}
func (r repository) tamDung(ctx context.Context) (json.RawMessage, error) { return r.q.TamDung(ctx) }
func (r repository) tiepTuc(ctx context.Context) (json.RawMessage, error) { return r.q.TiepTuc(ctx) }
func (r repository) moLai(ctx context.Context) (json.RawMessage, error)   { return r.q.MoLai(ctx) }
func (r repository) hangCho(ctx context.Context) (json.RawMessage, error) {
	return r.q.HangCho(ctx, realtime.PollIntervalSeconds)
}
