package giaoviec

import (
	"context"
	"encoding/json"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/giaoviec/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func (r repository) tao(ctx context.Context, p YeuCau) (int64, error) {
	return r.q.Tao(ctx, sqlcgen.TaoParams{Content: p.Content, AssigneePersonID: p.AssigneeID})
}
func (r repository) sua(ctx context.Context, id int64, p YeuCau) error {
	return r.q.Sua(ctx, sqlcgen.SuaParams{ID: id, Content: p.Content, AssigneePersonID: p.AssigneeID})
}
func (r repository) an(ctx context.Context, id int64) error { return r.q.An(ctx, id) }
func (r repository) danhDau(ctx context.Context, id int64, mark string) error {
	return r.q.DanhDau(ctx, sqlcgen.DanhDauParams{AssignedTaskID: id, MarkCode: mark})
}
func (r repository) khoa(ctx context.Context, id int64) error {
	hidden, e := r.q.Khoa(ctx, id)
	if errors.Is(e, pgx.ErrNoRows) {
		return apierr.Error{Code: apierr.CodeAssignedTaskNotFound}
	}
	if e != nil {
		return e
	}
	if hidden.Valid {
		return apierr.Error{Code: apierr.CodeAssignedTaskHidden}
	}
	return nil
}

// Danh sách và chi tiết cùng dùng Doc; chỉ câu này suy ra done từ sự kiện mới nhất.
func (r repository) doc(ctx context.Context, id, nhan int64, kemAn bool) ([]Viec, error) {
	rows, e := r.q.Doc(ctx, sqlcgen.DocParams{Column1: id, Column2: nhan, Column3: kemAn})
	if e != nil {
		return nil, e
	}
	out := make([]Viec, 0, len(rows))
	for _, v := range rows {
		x := Viec{ID: v.ID, Content: v.Content, AssigneeID: v.AssigneePersonID, AssigneeName: v.AssigneeName, PersonID: v.PersonID, PersonName: v.PersonName, CreatedAt: v.CreatedAt.Time, Done: v.Done, Marks: []Dau{}}
		if e = json.Unmarshal(v.Marks, &x.Marks); e != nil {
			return nil, e
		}
		if v.HiddenAt.Valid {
			x.HiddenAt = &v.HiddenAt.Time
		}
		if v.HiddenByPersonID.Valid {
			x.HiddenBy = &v.HiddenByPersonID.Int64
		}
		if v.HiddenByName.Valid {
			x.HiddenByName = &v.HiddenByName.String
		}
		out = append(out, x)
	}
	return out, nil
}
func (r repository) docViec(ctx context.Context, id int64) (Viec, error) {
	rows, e := r.doc(ctx, id, 0, true)
	if e != nil {
		return Viec{}, e
	}
	if len(rows) == 0 {
		return Viec{}, apierr.Error{Code: apierr.CodeAssignedTaskNotFound}
	}
	return rows[0], nil
}
