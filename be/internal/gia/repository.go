package gia

import (
	"context"

	"banhcuon/be/internal/gia/internal/sqlcgen"
)

// repository nhận giao dịch của bên gọi; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(q Querier) repository { return repository{q: sqlcgen.New(q)} }

// Một câu đọc giữ tên, thành phần, nhóm và lựa chọn cùng phiên bản của dòng menu.
// Mốc ngừng bán là now() của giao dịch đang mở.
func (r repository) docMon(ctx context.Context, id int64, ids []int64) (string, bool, []byte, []byte, []byte, error) {
	row, err := r.q.DocMon(ctx, sqlcgen.DocMonParams{MenuItemID: id, Column2: ids})
	return row.Name, row.Ngung, row.ThanhPhan, row.Nhom, row.LuaChon, err
}

func (r repository) docNhom(ctx context.Context, id int64) ([]byte, error) {
	return r.q.DocNhom(ctx, id)
}

func (r repository) docMonDangBan(ctx context.Context) ([]monMenu, error) {
	rows, err := r.q.DocMonDangBan(ctx)
	if err != nil {
		return nil, err
	}
	items := make([]monMenu, 0, len(rows))
	for _, row := range rows {
		items = append(items, monMenu{MenuItemID: row.ID, ItemName: row.Name, OptionGroups: []nhomMenu{}, Prices: []giaMenu{}})
	}
	return items, nil
}
