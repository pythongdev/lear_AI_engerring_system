package gia

import (
	"context"
	"encoding/json"
	"time"

	"banhcuon/be/internal/gia/internal/sqlcgen"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của bên gọi; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(q Querier) repository { return repository{q: sqlcgen.New(q)} }

// Một câu đọc giữ tên, thành phần, nhóm và lựa chọn cùng phiên bản của dòng menu.
// Mốc nil dùng now() của giao dịch; mọi bảng menu đọc cùng mốc. Bảng vết không có chỉ mục theo dòng,
// nên câu quét nó MỘT lần (CTE vet) rồi nối — quét theo từng dòng làm GET /menu quá hạn (T-174).
func (r repository) docMon(ctx context.Context, id int64, ids []int64, moc *time.Time) (string, bool, []byte, []byte, []byte, error) {
	var at pgtype.Timestamptz
	if moc != nil {
		at = pgtype.Timestamptz{Time: *moc, Valid: true}
	}
	row, err := r.q.DocMon(ctx, sqlcgen.DocMonParams{Column1: id, Column2: ids, Column3: at})
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

type comboDaDoc struct {
	Name     string
	PriceVnd int64
	An       bool
	Mon      []struct {
		MenuItemID int64 `json:"menu_item_id"`
		Quantity   int64 `json:"quantity"`
	}
	Muc []struct {
		MenuItemID   int64 `json:"menu_item_id"`
		MenuOptionID int64 `json:"menu_option_id"`
		SurchargeVnd int64 `json:"surcharge_vnd"`
	}
}

// docCombo đọc combo, món và mức tại cùng mốc với menu (ADR-117 điểm 4).
func (r repository) docCombo(ctx context.Context, id int64, moc *time.Time) (comboDaDoc, error) {
	var at pgtype.Timestamptz
	if moc != nil {
		at = pgtype.Timestamptz{Time: *moc, Valid: true}
	}
	row, err := r.q.DocCombo(ctx, sqlcgen.DocComboParams{Column1: id, Column2: at})
	if err != nil {
		return comboDaDoc{}, err
	}
	c := comboDaDoc{Name: row.Name, PriceVnd: row.PriceVnd, An: row.An}
	if err := json.Unmarshal(row.Mon, &c.Mon); err != nil {
		return comboDaDoc{}, err
	}
	err = json.Unmarshal(row.Muc, &c.Muc)
	return c, err
}

func (r repository) docComboDangBan(ctx context.Context) ([]comboMenu, error) {
	raw, err := r.q.DocComboDangBan(ctx)
	if err != nil {
		return nil, err
	}
	out := []comboMenu{}
	err = json.Unmarshal(raw, &out)
	return out, err
}
