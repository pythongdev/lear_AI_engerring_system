package danhmuc

import (
	"context"
	"encoding/json"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/danhmuc/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository                                 { return repository{sqlcgen.New(tx)} }
func (r repository) them(ctx context.Context, ten string) (int64, error) { return r.q.Them(ctx, ten) }
func (r repository) doiTen(ctx context.Context, id int64, ten string) error {
	return r.q.DoiTen(ctx, sqlcgen.DoiTenParams{ID: id, Name: ten})
}
func (r repository) an(ctx context.Context, id int64) error { return r.q.An(ctx, id) }
func (r repository) xep(ctx context.Context, mon, dm int64) error {
	return r.q.Xep(ctx, sqlcgen.XepParams{MenuItemID: mon, MenuCategoryID: dm})
}
func (r repository) chuyen(ctx context.Context, mon, dm int64) error {
	return r.q.Chuyen(ctx, sqlcgen.ChuyenParams{MenuItemID: mon, MenuCategoryID: dm})
}
func (r repository) docXep(ctx context.Context, mon int64) (int64, error) {
	return r.q.DocXep(ctx, mon)
}
func (r repository) khoaMon(ctx context.Context, id int64) error {
	_, e := r.q.KhoaMon(ctx, id)
	if errors.Is(e, pgx.ErrNoRows) {
		return apierr.Error{Code: apierr.CodeMenuItemNotFound}
	}
	return e
}
func (r repository) khoa(ctx context.Context, id int64) error {
	hidden, e := r.q.Khoa(ctx, id)
	if errors.Is(e, pgx.ErrNoRows) {
		return apierr.Error{Code: apierr.CodeMenuCategoryNotFound}
	}
	if e != nil {
		return e
	}
	if hidden.Valid {
		return apierr.Error{Code: apierr.CodeMenuCategoryHidden}
	}
	return nil
}

// Một câu đọc giữ danh mục và toàn bộ món trên cùng ảnh dữ liệu, kể cả lúc có người chuyển món.
func (r repository) doc(ctx context.Context, id int64, kemAn bool) (out DanhSach, err error) {
	raw, err := r.q.Doc(ctx, sqlcgen.DocParams{Column1: id, Column2: kemAn})
	if err != nil {
		return out, err
	}
	err = json.Unmarshal(raw, &out)
	return
}
func (r repository) docDanhMuc(ctx context.Context, id int64) (DanhMuc, error) {
	out, e := r.doc(ctx, id, true)
	if e != nil {
		return DanhMuc{}, e
	}
	if len(out.Categories) == 0 {
		return DanhMuc{}, apierr.Error{Code: apierr.CodeMenuCategoryNotFound}
	}
	return out.Categories[0], nil
}
