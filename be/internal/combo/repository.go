package combo

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/combo/internal/sqlcgen"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/jackc/pgx/v5"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func (r repository) them(ctx context.Context, ten string, gia int64) (int64, error) {
	return r.q.Them(ctx, sqlcgen.ThemParams{Name: ten, PriceVnd: gia})
}
func (r repository) themMon(ctx context.Context, id int64, item ThanhPhan) error {
	return r.q.ThemMon(ctx, sqlcgen.ThemMonParams{MenuComboID: id, MenuItemID: item.MenuItemID, Quantity: item.Quantity})
}
func (r repository) doiGia(ctx context.Context, id, gia int64) error {
	return r.q.DoiGia(ctx, sqlcgen.DoiGiaParams{ID: id, PriceVnd: gia})
}
func (r repository) an(ctx context.Context, id int64) error { return r.q.An(ctx, id) }
func (r repository) kiemMon(ctx context.Context, id int64, i int) error {
	ngung, e := r.q.KhoaMon(ctx, id)
	field := fmt.Sprintf("items[%d].menu_item_id", i)
	if errors.Is(e, pgx.ErrNoRows) {
		return apierr.Error{Code: apierr.CodeMenuItemNotFound, Field: field}
	}
	if e != nil {
		return e
	}
	if ngung.Valid {
		return apierr.Error{Code: apierr.CodeMenuItemDiscontinued, Field: field}
	}
	return nil
}
func (r repository) khoa(ctx context.Context, id int64) error {
	hidden, e := r.q.Khoa(ctx, id)
	if errors.Is(e, pgx.ErrNoRows) {
		return apierr.Error{Code: apierr.CodeMenuComboNotFound}
	}
	if e != nil {
		return e
	}
	if hidden.Valid {
		return apierr.Error{Code: apierr.CodeMenuComboHidden}
	}
	return nil
}

// Một câu đọc giữ combo và các thành phần trên cùng ảnh dữ liệu.
func (r repository) doc(ctx context.Context, id int64, kemAn bool) (out DanhSach, err error) {
	raw, err := r.q.Doc(ctx, sqlcgen.DocParams{Column1: id, Column2: kemAn})
	if err != nil {
		return out, err
	}
	err = json.Unmarshal(raw, &out)
	return
}
func (r repository) docMenuCombo(ctx context.Context, id int64) (MenuCombo, error) {
	out, e := r.doc(ctx, id, true)
	if e != nil {
		return MenuCombo{}, e
	}
	if len(out.Combos) == 0 {
		return MenuCombo{}, apierr.Error{Code: apierr.CodeMenuComboNotFound}
	}
	return out.Combos[0], nil
}
