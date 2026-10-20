package sanxuat

import (
	"banhcuon/be/internal/platform/realtime"
	"context"
	"encoding/json"

	"banhcuon/be/internal/sanxuat/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func conTro(v pgtype.Int8) *int64 {
	if !v.Valid {
		return nil
	}
	return &v.Int64
}

// gom đọc bảng nhu cầu (nguon nil) hoặc ứng viên chuyển của nguon, từ một câu (ADR-090 điểm 8).
// Câu đọc mã 0 là không nguồn: mã việc là identity từ 1 và handler từ chối mã ≤ 0.
func (r repository) gom(ctx context.Context, tram string, nguon *int64) (co, hop bool, out json.RawMessage, err error) {
	var ma int64
	if nguon != nil {
		ma = *nguon
	}
	row, err := r.q.Gom(ctx, sqlcgen.GomParams{Column1: tram, Column2: ma, Column3: realtime.PollIntervalSeconds})
	return row.CoNguon, row.NguonHop, row.KetQua, err
}

func (r repository) khoaPhienCuaViec(ctx context.Context, ids []int64) error {
	_, err := r.q.KhoaPhienCuaViec(ctx, ids)
	return err
}

func (r repository) khoaDonCuaViec(ctx context.Context, ids []int64) error {
	_, err := r.q.KhoaDonCuaViec(ctx, ids)
	return err
}

func (r repository) khoaViec(ctx context.Context, ids []int64) ([]viec, error) {
	rows, err := r.q.KhoaViec(ctx, ids)
	if err != nil {
		return nil, err
	}
	out := make([]viec, 0, len(rows))
	for _, v := range rows {
		out = append(out, viec{ID: v.ID, DonID: v.SalesOrderID, PhienID: conTro(v.TableSessionID),
			TrangThai: v.Status, TrangThaiDon: v.OrderStatus, LamSai: v.LamSai})
	}
	return out, nil
}

func (r repository) khoaMeNguon(ctx context.Context, ids []int64) error {
	_, err := r.q.KhoaMeNguon(ctx, ids)
	return err
}

func (r repository) khoaPhanSong(ctx context.Context, viecID int64) (int64, error) {
	return r.q.KhoaPhanSong(ctx, pgtype.Int8{Int64: viecID, Valid: true})
}

func (r repository) khoaMe(ctx context.Context, id int64) (bool, error) {
	daLui, err := r.q.KhoaMe(ctx, id)
	return daLui.Bool, err
}

func (r repository) viecCuaMe(ctx context.Context, id int64) ([]int64, error) {
	ids, err := r.q.ViecCuaMe(ctx, id)
	if ids == nil {
		ids = []int64{}
	}
	return ids, err
}

func (r repository) khoaGhiLamSai(ctx context.Context, id int64) (bool, error) {
	return r.q.KhoaGhiLamSai(ctx, id)
}

func (r repository) coBan(ctx context.Context, id int64) (bool, error) {
	return r.q.CoBan(ctx, id)
}

func (r repository) donDangLamCuaBan(ctx context.Context, ban int64) ([]int64, error) {
	return r.q.DonDangLamCuaBan(ctx, pgtype.Int8{Int64: ban, Valid: true})
}

func (r repository) banCuaDon(ctx context.Context, id int64) (*int64, error) {
	ban, err := r.q.BanCuaDon(ctx, id)
	return conTro(ban), err
}

func (r repository) khoaPhienCuaDon(ctx context.Context, dons []int64) error {
	_, err := r.q.KhoaPhienCuaDon(ctx, dons)
	return err
}

func (r repository) khoaDonDangLam(ctx context.Context, dons []int64) ([]int64, error) {
	return r.q.KhoaDonDangLam(ctx, dons)
}

func (r repository) chonDaLam(ctx context.Context, dons []int64, m mucRa) ([]int64, error) {
	// MenuComponentID nil là nước chấm; câu đọc nhận cờ thay cho tham số null (sqlc không sinh được).
	var thanhPhan int64
	if m.MenuComponentID != nil {
		thanhPhan = *m.MenuComponentID
	}
	return r.q.ChonDaLam(ctx, sqlcgen.ChonDaLamParams{Column1: dons, StationCode: m.StationCode,
		Column3: m.MenuComponentID == nil, Column4: thanhPhan, Column5: m.FillingOptionIDs, Column6: m.Quantity})
}

func (r repository) daRaHet(ctx context.Context, donID int64) (bool, error) {
	return r.q.DaRaHet(ctx, donID)
}

func (r repository) themMe(ctx context.Context) (int64, json.RawMessage, error) {
	row, err := r.q.ThemMe(ctx)
	return row.ID, row.ToJsonb, err
}

func (r repository) themPhanMe(ctx context.Context, me int64, ids []int64) error {
	return r.q.ThemPhanMe(ctx, sqlcgen.ThemPhanMeParams{ProductionBatchID: me, Column2: ids})
}

func (r repository) luiMe(ctx context.Context, id int64) (json.RawMessage, error) {
	return r.q.LuiMe(ctx, id)
}

func (r repository) luiPhanMe(ctx context.Context, id int64) error {
	return r.q.LuiPhanMe(ctx, id)
}

func (r repository) themChuyen(ctx context.Context, vat, tu, den int64) (int64, error) {
	return r.q.ThemChuyen(ctx, sqlcgen.ThemChuyenParams{ProductionBatchItemID: vat, FromStationJobID: tu, ToStationJobID: den})
}

func (r repository) doiChu(ctx context.Context, vat, den int64) error {
	return r.q.DoiChu(ctx, sqlcgen.DoiChuParams{ID: vat, StationJobID: den})
}

func (r repository) themLamSai(ctx context.Context, viecID, donID int64, note *string) (int64, error) {
	var ghi pgtype.Text
	if note != nil {
		ghi = pgtype.Text{String: *note, Valid: true}
	}
	return r.q.ThemLamSai(ctx, sqlcgen.ThemLamSaiParams{StationJobID: viecID, SalesOrderID: donID, Note: ghi})
}

func (r repository) huyLamSai(ctx context.Context, id int64) (json.RawMessage, error) {
	return r.q.HuyLamSai(ctx, id)
}

func (r repository) noThanhPhan(ctx context.Context, donID int64) error {
	return r.q.NoThanhPhan(ctx, donID)
}

func (r repository) noNuocCham(ctx context.Context, donID int64) error {
	return r.q.NoNuocCham(ctx, donID)
}

func (r repository) viecQuay(ctx context.Context) (json.RawMessage, error) {
	return r.q.ViecQuay(ctx, realtime.PollIntervalSeconds)
}
