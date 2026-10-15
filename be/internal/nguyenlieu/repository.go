package nguyenlieu

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/nguyenlieu/internal/sqlcgen"
	"context"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"time"
)

type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }
func (r repository) them(ctx context.Context, ten, donVi string) (int64, error) {
	return r.q.ThemThu(ctx, sqlcgen.ThemThuParams{Name: ten, Column2: donVi})
}
func (r repository) dat(ctx context.Context, id int64, donVi string) error {
	return r.q.DatDonVi(ctx, sqlcgen.DatDonViParams{ID: id, Column2: donVi})
}
func (r repository) khoaThu(ctx context.Context, id int64) (bool, error) {
	unit, err := r.q.KhoaThu(ctx, id)
	return unit.Valid, err
}
func (r repository) khoaSo(ctx context.Context, id int64) error {
	_, err := r.q.KhoaSo(ctx, id)
	return err
}
func (r repository) ngayTuongLai(ctx context.Context, ngay string, moc time.Time) (bool, error) {
	return r.q.NgayTuongLai(ctx, sqlcgen.NgayTuongLaiParams{Column1: ngay, Column2: pgtype.Timestamptz{Time: moc, Valid: true}})
}
func (r repository) ghi(ctx context.Context, p YeuCau) (int64, error) {
	return r.q.GhiSo(ctx, sqlcgen.GhiSoParams{SupplyItemID: p.ItemID, Column2: p.EntryDate, KindCode: p.Kind, Column4: p.Measure})
}
func (r repository) sua(ctx context.Context, id int64, measure string) error {
	return r.q.SuaSo(ctx, sqlcgen.SuaSoParams{ID: id, Column2: measure})
}

// Cả danh sách lẫn chi tiết dùng Doc: chỉ SQL này tính tổng và hiệu số (I-026).
func (r repository) doc(ctx context.Context, id int64) ([]Thu, error) {
	rows, err := r.q.Doc(ctx, id)
	if err != nil {
		return nil, err
	}
	out := make([]Thu, 0, len(rows))
	for _, v := range rows {
		var unit *string
		if v.PurchaseUnit.Valid {
			u := v.PurchaseUnit.String
			unit = &u
		}
		out = append(out, Thu{ID: v.ID, Name: v.Name, PurchaseUnit: unit, PurchasedTotal: v.PurchasedTotal, UsedTotal: v.UsedTotal, Balance: v.Balance})
	}
	return out, nil
}
func (r repository) docThu(ctx context.Context, id int64) (Thu, error) {
	rows, err := r.doc(ctx, id)
	if err != nil {
		return Thu{}, err
	}
	if len(rows) == 0 {
		return Thu{}, apierr.Error{Code: apierr.CodeSupplyItemNotFound}
	}
	return rows[0], nil
}
func (r repository) docSo(ctx context.Context, thu, id int64) ([]ConSo, error) {
	rows, err := r.q.DocSo(ctx, sqlcgen.DocSoParams{Column1: thu, Column2: id})
	if err != nil {
		return nil, err
	}
	out := make([]ConSo, 0, len(rows))
	for _, v := range rows {
		out = append(out, ConSo{ID: v.ID, ItemID: v.SupplyItemID, EntryDate: v.EEntryDate, Kind: v.KindCode, Measure: v.Measure, PersonID: v.PersonID, PersonName: v.PersonName, CreatedAt: v.CreatedAt.Time})
	}
	return out, nil
}
func (r repository) docConSo(ctx context.Context, id int64) (ConSo, error) {
	rows, err := r.docSo(ctx, 0, id)
	if err != nil {
		return ConSo{}, err
	}
	if len(rows) == 0 {
		return ConSo{}, apierr.Error{Code: apierr.CodeSupplyDayEntryNotFound}
	}
	return rows[0], nil
}
