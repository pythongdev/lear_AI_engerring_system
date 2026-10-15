package khoanchi

import (
	"context"
	"time"

	"banhcuon/be/internal/khoanchi/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository chỉ gọi sqlc trên giao dịch đã qua quyền của service (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }
func (r repository) themLoai(ctx context.Context, ten string, ket bool) (Loai, error) {
	row, err := r.q.ThemLoai(ctx, sqlcgen.ThemLoaiParams{Name: ten, PaidFromTill: ket})
	return Loai{ID: row.ID, Name: row.Name, PaidFromTill: row.PaidFromTill}, err
}
func (r repository) docLoai(ctx context.Context) ([]Loai, error) {
	rows, err := r.q.DocLoai(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]Loai, 0, len(rows))
	for _, row := range rows {
		out = append(out, Loai{ID: row.ID, Name: row.Name, PaidFromTill: row.PaidFromTill})
	}
	return out, nil
}
func (r repository) timLoai(ctx context.Context, id int64) (bool, error) { return r.q.TimLoai(ctx, id) }
func (r repository) khoaKhoan(ctx context.Context, id int64) (string, bool, error) {
	row, err := r.q.KhoaKhoan(ctx, id)
	return row.PaidDate, row.PaidFromTill, err
}
func (r repository) ngayTuongLai(ctx context.Context, ngay string, moc time.Time) (bool, error) {
	return r.q.NgayTuongLai(ctx, sqlcgen.NgayTuongLaiParams{Column1: ngay, Column2: pgtype.Timestamptz{Time: moc, Valid: true}})
}
func (r repository) ghi(ctx context.Context, p YeuCau) (int64, error) {
	return r.q.Ghi(ctx, sqlcgen.GhiParams{ExpenseCategoryID: p.CategoryID, AmountVnd: p.Amount, Column3: p.PaidDate})
}
func (r repository) sua(ctx context.Context, id int64, p YeuCau) error {
	return r.q.Sua(ctx, sqlcgen.SuaParams{ID: id, ExpenseCategoryID: p.CategoryID, AmountVnd: p.Amount, Column4: p.PaidDate})
}
func khoan(row sqlcgen.DocKhoanRow) Khoan {
	return Khoan{ID: row.ID, CategoryID: row.ExpenseCategoryID, CategoryName: row.CategoryName, PaidFromTill: row.PaidFromTill, Amount: row.AmountVnd, PaidDate: row.PaidDate, PersonID: row.PersonID, PersonName: row.PersonName, CreatedAt: row.CreatedAt.Time}
}
func (r repository) docKhoan(ctx context.Context, id int64) (Khoan, error) {
	row, err := r.q.DocKhoan(ctx, id)
	return khoan(row), err
}
func (r repository) doc(ctx context.Context, loc BoLoc) ([]Khoan, error) {
	p := sqlcgen.DocParams{Column1: loc.From, Column2: loc.To}
	if loc.CategoryID != nil {
		p.Column3 = *loc.CategoryID
	}
	if loc.PaidFromTill != nil {
		p.Column4 = true
		p.Column5 = *loc.PaidFromTill
	}
	rows, err := r.q.Doc(ctx, p)
	if err != nil {
		return nil, err
	}
	out := make([]Khoan, 0, len(rows))
	for _, row := range rows {
		out = append(out, khoan(sqlcgen.DocKhoanRow(row)))
	}
	return out, nil
}
