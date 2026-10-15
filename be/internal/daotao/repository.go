package daotao

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/daotao/internal/sqlcgen"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func text(p *string) pgtype.Text {
	if p == nil {
		return pgtype.Text{}
	}
	return pgtype.Text{String: *p, Valid: true}
}
func textPtr(p pgtype.Text) *string {
	if !p.Valid {
		return nil
	}
	return &p.String
}
func missing(e error, code apierr.Code) error {
	if errors.Is(e, pgx.ErrNoRows) {
		return apierr.Error{Code: code}
	}
	return e
}
func locked(e error, hidden pgtype.Timestamptz, absent, gone apierr.Code) error {
	if e != nil {
		return missing(e, absent)
	}
	if hidden.Valid {
		return apierr.Error{Code: gone}
	}
	return nil
}
func (r repository) khoaViec(ctx context.Context, id int64) error {
	h, e := r.q.KhoaViec(ctx, id)
	return locked(e, h, apierr.CodeAssignedTaskNotFound, apierr.CodeAssignedTaskHidden)
}
func (r repository) timViec(ctx context.Context, id int64) error {
	_, e := r.q.TimViec(ctx, id)
	return missing(e, apierr.CodeAssignedTaskNotFound)
}
func (r repository) khoaHuongDan(ctx context.Context, id int64, sua bool) error {
	h, e := r.q.KhoaHuongDan(ctx, id)
	if e = locked(e, h.HiddenAt, apierr.CodeAssignedTaskGuideNotFound, apierr.CodeAssignedTaskGuideHidden); e != nil {
		return e
	}
	if sua && h.GuideKindCode != "text" {
		return apierr.Error{Code: apierr.CodeAssignedTaskGuideNotText}
	}
	return nil
}
func (r repository) khoaGhiNhan(ctx context.Context, id int64) error {
	h, e := r.q.KhoaGhiNhan(ctx, id)
	return locked(e, h, apierr.CodeTrainingRecordNotFound, apierr.CodeTrainingRecordHidden)
}
func (r repository) gan(ctx context.Context, task int64, kind string, body, key *string) (int64, error) {
	return r.q.GanHuongDan(ctx, sqlcgen.GanHuongDanParams{AssignedTaskID: task, GuideKindCode: kind, Body: text(body), FileCode: text(key)})
}
func (r repository) suaHuongDan(ctx context.Context, id int64, body string) error {
	return r.q.SuaHuongDan(ctx, sqlcgen.SuaHuongDanParams{ID: id, Body: text(&body)})
}
func (r repository) anHuongDan(ctx context.Context, id int64) error { return r.q.AnHuongDan(ctx, id) }
func (r repository) ghi(ctx context.Context, p YeuCau) (int64, error) {
	return r.q.GhiNhan(ctx, sqlcgen.GhiNhanParams{TraineePersonID: p.TraineeID, Remark: text(p.Remark), RatingCode: text(p.Rating)})
}
func (r repository) suaGhiNhan(ctx context.Context, id int64, p YeuCau) error {
	return r.q.SuaGhiNhan(ctx, sqlcgen.SuaGhiNhanParams{ID: id, Remark: text(p.Remark), RatingCode: text(p.Rating)})
}
func (r repository) anGhiNhan(ctx context.Context, id int64) error { return r.q.AnGhiNhan(ctx, id) }
func (r repository) docHuongDan(ctx context.Context, id, task int64, hidden bool) ([]HuongDan, error) {
	rows, e := r.q.DocHuongDan(ctx, sqlcgen.DocHuongDanParams{Column1: id, Column2: task, Column3: hidden})
	if e != nil {
		return nil, e
	}
	out := make([]HuongDan, 0, len(rows))
	for _, v := range rows {
		x := HuongDan{ID: v.ID, TaskID: v.AssignedTaskID, Kind: v.GuideKindCode, Body: textPtr(v.Body), FileCode: textPtr(v.FileCode), PersonID: v.PersonID, PersonName: v.PersonName, CreatedAt: v.CreatedAt.Time, HiddenByName: textPtr(v.HiddenByName)}
		if v.HiddenAt.Valid {
			x.HiddenAt = &v.HiddenAt.Time
		}
		if v.HiddenByPersonID.Valid {
			x.HiddenBy = &v.HiddenByPersonID.Int64
		}
		out = append(out, x)
	}
	return out, nil
}
func (r repository) huongDan(ctx context.Context, id int64) (HuongDan, error) {
	rows, e := r.docHuongDan(ctx, id, 0, true)
	if e != nil {
		return HuongDan{}, e
	}
	if len(rows) == 0 {
		return HuongDan{}, apierr.Error{Code: apierr.CodeAssignedTaskGuideNotFound}
	}
	return rows[0], nil
}
func (r repository) docGhiNhan(ctx context.Context, id, trainee int64, hidden bool) ([]GhiNhanDaoTao, error) {
	rows, e := r.q.DocGhiNhan(ctx, sqlcgen.DocGhiNhanParams{Column1: id, Column2: trainee, Column3: hidden})
	if e != nil {
		return nil, e
	}
	out := make([]GhiNhanDaoTao, 0, len(rows))
	for _, v := range rows {
		x := GhiNhanDaoTao{ID: v.ID, TraineeID: v.TraineePersonID, TraineeName: v.TraineeName, Remark: textPtr(v.Remark), Rating: textPtr(v.RatingCode), PersonID: v.PersonID, PersonName: v.PersonName, CreatedAt: v.CreatedAt.Time, HiddenByName: textPtr(v.HiddenByName)}
		if v.HiddenAt.Valid {
			x.HiddenAt = &v.HiddenAt.Time
		}
		if v.HiddenByPersonID.Valid {
			x.HiddenBy = &v.HiddenByPersonID.Int64
		}
		out = append(out, x)
	}
	return out, nil
}
func (r repository) ghiNhan(ctx context.Context, id int64) (GhiNhanDaoTao, error) {
	rows, e := r.docGhiNhan(ctx, id, 0, true)
	if e != nil {
		return GhiNhanDaoTao{}, e
	}
	if len(rows) == 0 {
		return GhiNhanDaoTao{}, apierr.Error{Code: apierr.CodeTrainingRecordNotFound}
	}
	return rows[0], nil
}
