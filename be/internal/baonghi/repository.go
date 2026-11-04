package baonghi

import (
	"context"
	"encoding/json"
	"time"

	"banhcuon/be/internal/baonghi/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository                                 { return repository{sqlcgen.New(tx)} }
func (r repository) dau(ctx context.Context, code string) (int64, error) { return r.q.Dau(ctx, code) }
func (r repository) bao(ctx context.Context, date time.Time, code string) (int64, error) {
	return r.q.Bao(ctx, sqlcgen.BaoParams{LeaveDate: pgtype.Date{Time: date, Valid: true}, SubmissionCode: code})
}
func (r repository) khoa(ctx context.Context, id int64) error {
	_, err := r.q.Khoa(ctx, id)
	return err
}
func (r repository) dong(ctx context.Context, id int64) (out Dong, err error) {
	data, err := r.q.Dong(ctx, id)
	if err != nil {
		return out, err
	}
	err = json.Unmarshal(data, &out)
	return
}
func (r repository) ghiDau(ctx context.Context, id int64, acknowledge bool) error {
	reason := "baonghi/huy"
	if acknowledge {
		reason = "baonghi/da_biet"
	}
	if err := r.q.KhaiLyDo(ctx, reason); err != nil {
		return err
	}
	if acknowledge {
		return r.q.DaBiet(ctx, id)
	}
	return r.q.Huy(ctx, id)
}
func (r repository) cuaToi(ctx context.Context, beforeID int64, limit int32) (out TrangCuaToi, err error) {
	data, err := r.q.CuaToi(ctx, sqlcgen.CuaToiParams{Column2: beforeID, Column1: limit})
	if err != nil {
		return out, err
	}
	err = json.Unmarshal(data, &out)
	return
}
func (r repository) theoKhoang(ctx context.Context, from, to time.Time) (out Trang, err error) {
	data, err := r.q.TheoKhoang(ctx, sqlcgen.TheoKhoangParams{Column1: pgtype.Date{Time: from, Valid: true}, Column2: pgtype.Date{Time: to, Valid: true}})
	if err != nil {
		return out, err
	}
	err = json.Unmarshal(data, &out)
	return
}
