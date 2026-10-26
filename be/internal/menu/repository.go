package menu

import (
	"context"
	"encoding/json"

	"banhcuon/be/internal/menu/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
)

// repository chạy câu của menu qua code sqlc sinh, trên giao dịch service nhận từ authz.Run;
// không mở, không commit giao dịch (QC-13).
type repository struct {
	q *sqlcgen.Queries
}

func newRepository(tx pgx.Tx) repository {
	return repository{q: sqlcgen.New(tx)}
}

func (r repository) khaiLyDo(ctx context.Context, lyDo string) error {
	return r.q.KhaiLyDo(ctx, lyDo)
}

func (r repository) khoaThanhPhan(ctx context.Context, id int64) error {
	_, err := r.q.KhoaThanhPhan(ctx, id)
	return err
}

func (r repository) khoaLuaChon(ctx context.Context, id int64) error {
	_, err := r.q.KhoaLuaChon(ctx, id)
	return err
}

func (r repository) timMon(ctx context.Context, id int64) error {
	_, err := r.q.TimMon(ctx, id)
	return err
}

func (r repository) timThanhPhan(ctx context.Context, id int64) error {
	_, err := r.q.TimThanhPhan(ctx, id)
	return err
}

func (r repository) khoaMonThanhPhan(ctx context.Context, monID, tpID int64) error {
	_, err := r.q.KhoaMonThanhPhan(ctx, sqlcgen.KhoaMonThanhPhanParams{MenuItemID: monID, MenuComponentID: tpID})
	return err
}

func (r repository) khoaMonNgungBan(ctx context.Context, id int64) (bool, error) {
	return r.q.KhoaMonNgungBan(ctx, id)
}

func (r repository) doiGia(ctx context.Context, id, gia int64) (sqlcgen.DoiGiaRow, error) {
	return r.q.DoiGia(ctx, sqlcgen.DoiGiaParams{ID: id, BasePriceVnd: gia})
}

func (r repository) doiPhuThu(ctx context.Context, id, phuThu int64) (sqlcgen.DoiPhuThuRow, error) {
	return r.q.DoiPhuThu(ctx, sqlcgen.DoiPhuThuParams{ID: id, SurchargeVnd: phuThu})
}

func (r repository) suaSoLuong(ctx context.Context, monID, tpID int64, soLuong int32) (sqlcgen.SuaSoLuongRow, error) {
	return r.q.SuaSoLuong(ctx, sqlcgen.SuaSoLuongParams{MenuItemID: monID, MenuComponentID: tpID, Quantity: soLuong})
}

func (r repository) ngungBan(ctx context.Context, id int64) (sqlcgen.NgungBanRow, error) {
	return r.q.NgungBan(ctx, id)
}

func (r repository) themMon(ctx context.Context, ten string) (Mon, error) {
	row, e := r.q.ThemMon(ctx, ten)
	return Mon{row.ID, row.Name}, e
}
func (r repository) themThanhPhan(ctx context.Context, mon int64, tp ThanhPhanMoi) error {
	id, e := r.q.ThemThanhPhan(ctx, sqlcgen.ThemThanhPhanParams{Name: tp.Name, BasePriceVnd: *tp.BasePriceVnd, TakesFilling: *tp.TakesFilling})
	if e != nil {
		return e
	}
	return r.q.GanThanhPhan(ctx, sqlcgen.GanThanhPhanParams{MenuItemID: mon, MenuComponentID: id, Quantity: tp.Quantity})
}
func (r repository) doiTenMon(ctx context.Context, id int64, ten string) (Mon, error) {
	row, e := r.q.DoiTenMon(ctx, sqlcgen.DoiTenMonParams{ID: id, Name: ten})
	return Mon{row.ID, row.Name}, e
}

// --- T-210: topping ---------------------------------------------------------------------------

type LuaChonNhom struct {
	MenuOptionID int64   `json:"menu_option_id"`
	Name         string  `json:"name"`
	SurchargeVnd int64   `json:"surcharge_vnd"`
	IsDefault    bool    `json:"is_default"`
	HiddenAt     *string `json:"hidden_at"`
}

type NhomLuaChon struct {
	OptionGroupID         int64         `json:"option_group_id"`
	Name                  string        `json:"name"`
	MenuItemIDs           []int64       `json:"menu_item_ids"`
	PrerequisiteOptionIDs []int64       `json:"prerequisite_option_ids"`
	Options               []LuaChonNhom `json:"options"`
}

func (r repository) docNhom(ctx context.Context) ([]NhomLuaChon, error) {
	raw, err := r.q.DocNhomLuaChon(ctx)
	if err != nil {
		return nil, err
	}
	out := []NhomLuaChon{}
	return out, json.Unmarshal(raw, &out)
}

func (r repository) khoaNhom(ctx context.Context, id int64) error {
	_, err := r.q.KhoaNhom(ctx, id)
	return err
}

func (r repository) khoaLuaChonAn(ctx context.Context, id int64) (sqlcgen.KhoaLuaChonAnRow, error) {
	return r.q.KhoaLuaChonAn(ctx, id)
}

func (r repository) themLuaChon(ctx context.Context, nhom int64, ten string, phuThu int64) (sqlcgen.ThemLuaChonRow, error) {
	return r.q.ThemLuaChon(ctx, sqlcgen.ThemLuaChonParams{OptionGroupID: nhom, Name: ten, SurchargeVnd: phuThu})
}

func (r repository) themDieuKien(ctx context.Context, nhom, luaChon int64) error {
	return r.q.ThemDieuKien(ctx, sqlcgen.ThemDieuKienParams{OptionGroupID: nhom, MenuOptionID: luaChon})
}

func (r repository) datAnLuaChon(ctx context.Context, id int64, an bool) error {
	_, err := r.q.DatAnLuaChon(ctx, sqlcgen.DatAnLuaChonParams{ID: id, Column2: an})
	return err
}

func (r repository) taoThanhPhanCoTram(ctx context.Context, tp ThanhPhanGanMoi) (int64, error) {
	id, err := r.q.ThemThanhPhan(ctx, sqlcgen.ThemThanhPhanParams{Name: tp.Name, BasePriceVnd: *tp.BasePriceVnd, TakesFilling: *tp.TakesFilling})
	if err != nil {
		return 0, err
	}
	err = r.q.GanTramThanhPhan(ctx, sqlcgen.GanTramThanhPhanParams{MenuComponentID: id, StationCode: tp.StationCode})
	return id, err
}
func (r repository) ganThanhPhan(ctx context.Context, mon, tp int64, quantity int32) error {
	return r.q.GanThanhPhan(ctx, sqlcgen.GanThanhPhanParams{MenuItemID: mon, MenuComponentID: tp, Quantity: quantity})
}
