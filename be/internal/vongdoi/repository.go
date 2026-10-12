package vongdoi

import (
	"context"

	"banhcuon/be/internal/vongdoi/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
)

// repository nhận giao dịch của bên gọi; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) coNguoi(ctx context.Context) (bool, error) {
	return r.q.CoNguoi(ctx)
}
func (r repository) khaiLyDo(ctx context.Context, reason string) error {
	return r.q.KhaiLyDo(ctx, reason)
}
func (r repository) goLyDo(ctx context.Context) error {
	return r.q.GoLyDo(ctx)
}
func (r repository) khoaDon(ctx context.Context, id int64) (string, string, *string, error) {
	row, err := r.q.KhoaDon(ctx, id)
	var trao *string
	if row.HandoverCode.Valid {
		trao = &row.HandoverCode.String
	}
	return row.Status, row.ChannelCode, trao, err
}
func (r repository) khoaPhien(ctx context.Context, id int64) (string, error) {
	return r.q.KhoaPhien(ctx, id)
}
func (r repository) khoaViec(ctx context.Context, id int64) (string, string, error) {
	row, err := r.q.KhoaViec(ctx, id)
	return row.Status, row.Status_2, err
}
func (r repository) chuyenDon(ctx context.Context, id int64, den string) error {
	return r.q.ChuyenDon(ctx, sqlcgen.ChuyenDonParams{ID: id, Status: den})
}
func (r repository) chuyenPhien(ctx context.Context, id int64, den string) error {
	return r.q.ChuyenPhien(ctx, sqlcgen.ChuyenPhienParams{ID: id, Status: den})
}
func (r repository) dongBan(ctx context.Context, id int64) error {
	return r.q.DongBan(ctx, id)
}
func (r repository) chuyenViec(ctx context.Context, id int64, den string) error {
	return r.q.ChuyenViec(ctx, sqlcgen.ChuyenViecParams{ID: id, Status: den})
}
func (r repository) coVetChuyen(ctx context.Context, transferID, id int64) (bool, error) {
	return r.q.CoVetChuyen(ctx, sqlcgen.CoVetChuyenParams{ID: transferID, FromStationJobID: id})
}
