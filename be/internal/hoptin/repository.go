package hoptin

import (
	"banhcuon/be/internal/hoptin/internal/sqlcgen"
	"context"
	"encoding/json"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func nullableID(id *int64) pgtype.Int8 {
	if id == nil {
		return pgtype.Int8{}
	}
	return pgtype.Int8{Int64: *id, Valid: true}
}
func (r repository) ghi(ctx context.Context, p YeuCau) (int64, error) {
	return r.q.Ghi(ctx, sqlcgen.GhiParams{RecipientPersonID: nullableID(p.RecipientID), WorkCode: p.WorkCode, Body: p.Body, DiningTableID: nullableID(p.DiningTableID), ReplyToMessageID: nullableID(p.ReplyToID), SubmissionCode: p.SubmissionCode})
}
func (r repository) dau(ctx context.Context, code string) (int64, error) { return r.q.Dau(ctx, code) }
func (r repository) nguoiNhan(ctx context.Context, id int64) (bool, error) {
	return r.q.NguoiNhan(ctx, nullableID(&id))
}
func (r repository) ban(ctx context.Context, id int64) (bool, error) { return r.q.Ban(ctx, id) }
func (r repository) tinTraLoi(ctx context.Context, id, personID int64, all bool) (bool, error) {
	return r.q.TinTraLoi(ctx, sqlcgen.TinTraLoiParams{ID: id, SenderPersonID: personID, Column2: all})
}
func (r repository) tin(ctx context.Context, id int64) (out Tin, err error) {
	raw, err := r.q.Tin(ctx, id)
	if err == nil {
		err = json.Unmarshal(raw, &out)
	}
	return
}
func (r repository) doc(ctx context.Context, personID, beforeID int64, limit int32, all bool) (out Trang, err error) {
	raw, err := r.q.Doc(ctx, sqlcgen.DocParams{SenderPersonID: personID, Column4: beforeID, Column1: limit, Column2: all})
	if err == nil {
		err = json.Unmarshal(raw, &out)
	}
	return
}
