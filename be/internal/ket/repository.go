package ket

import (
	"context"
	"time"

	"banhcuon/be/internal/ket/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

// ghiSo thêm phiếu tiền đầu két (dem = false) hoặc phiếu đếm (dem = true) cùng các dòng mệnh giá.
func (r repository) ghiSo(ctx context.Context, dem bool, moc time.Time, lines []Dong) (int64, error) {
	ngay := pgtype.Timestamptz{Time: moc, Valid: true}
	var id int64
	var err error
	if dem {
		id, err = r.q.ThemDem(ctx, ngay)
	} else {
		id, err = r.q.ThemDauKet(ctx, ngay)
	}
	if err != nil {
		return 0, err
	}
	for _, l := range lines {
		if !dem {
			err = r.q.ThemDongDauKet(ctx, sqlcgen.ThemDongDauKetParams{OpeningFloatID: id, DenominationVnd: *l.Denomination, AmountVnd: *l.Amount})
		}
		if err != nil {
			return 0, err
		}
	}
	return id, nil
}

// ketNgay trả số đếm, tiền đầu két và vế phải của ngày (ADR-089 điểm 6).
func (r repository) ketNgay(ctx context.Context, ngay string) (int64, int64, int64, error) {
	row, err := r.q.KetNgay(ctx, ngay)
	return row.Tien, row.Tien_2, row.Column4, err
}

func (r repository) soGiay(ctx context.Context, ngay string) (*int32, int64, error) {
	row, err := r.q.DocSoGiay(ctx, ngay)
	var declared *int32
	if row.EntryCount.Valid {
		declared = &row.EntryCount.Int32
	}
	return declared, row.Pending, err
}

func (r repository) ngayTuongLai(ctx context.Context, ngay string, moc time.Time) (bool, error) {
	return r.q.NgaySoGiayTuongLai(ctx, sqlcgen.NgaySoGiayTuongLaiParams{Column1: ngay, Column2: pgtype.Timestamptz{Time: moc, Valid: true}})
}

func (r repository) themSoGiay(ctx context.Context, ngay string, so int32) (int64, error) {
	return r.q.ThemSoGiay(ctx, sqlcgen.ThemSoGiayParams{Column1: ngay, EntryCount: so})
}

// ngay đã qua docNgay ở handler (YYYY-MM-DD hợp lệ).
func (r repository) themKyNgay(ctx context.Context, ngay string, gap int64, explanation *string, previous *int64) (int64, error) {
	d, err := time.Parse("2006-01-02", ngay)
	if err != nil {
		return 0, err
	}
	var giai pgtype.Text
	if explanation != nil {
		giai = pgtype.Text{String: *explanation, Valid: true}
	}
	var truoc pgtype.Int8
	if previous != nil {
		truoc = pgtype.Int8{Int64: *previous, Valid: true}
	}
	return r.q.ThemKyNgay(ctx, sqlcgen.ThemKyNgayParams{Column1: pgtype.Date{Time: d, Valid: true}, GapVnd: gap, GapExplanation: giai, PreviousReconciledDayID: truoc})
}

func (r repository) docDau(ctx context.Context, ngay string) ([]Dau, error) {
	rows, err := r.q.DocDauNgay(ctx, ngay)
	if err != nil {
		return nil, err
	}
	out := make([]Dau, 0, len(rows))
	for _, row := range rows {
		d := Dau{ID: row.ID, PersonID: row.PersonID, CreatedAt: row.CreatedAt.Time, Gap: row.GapVnd}
		if row.PreviousReconciledDayID.Valid {
			v := row.PreviousReconciledDayID.Int64
			d.PreviousID = &v
		}
		if row.GapExplanation.Valid {
			v := row.GapExplanation.String
			d.Explanation = &v
		}
		if row.Reason.Valid {
			d.Reopening = &MoLai{Reason: row.Reason.String, PersonID: row.ReopeningPersonID.Int64, CreatedAt: row.ReopenedAt.Time}
		}
		out = append(out, d)
	}
	return out, nil
}

func (r repository) themDongDem(ctx context.Context, id int64, l Dong) error {
	return r.q.ThemDongDem(ctx, sqlcgen.ThemDongDemParams{CashCountID: id, DenominationVnd: *l.Denomination, AmountVnd: *l.Amount})
}
func (r repository) moLai(ctx context.Context, id int64, ngay, reason string) error {
	return r.q.MoLaiNgay(ctx, sqlcgen.MoLaiNgayParams{ReconciledDayID: id, Column2: ngay, Reason: reason})
}
func (r repository) docDem(ctx context.Context, ngay string) (int64, error) {
	return r.q.DocDem(ctx, ngay)
}

type xapDem struct{ id, menhGia, soTien int64 }

func (r repository) docXap(ctx context.Context, id int64) ([]xapDem, error) {
	rows, err := r.q.DocXapDem(ctx, id)
	if err != nil {
		return nil, err
	}
	out := make([]xapDem, 0, len(rows))
	for _, row := range rows {
		out = append(out, xapDem{row.ID, row.DenominationVnd, row.AmountVnd})
	}
	return out, nil
}
func (r repository) datSo(ctx context.Context, id, amount int64) error {
	return r.q.DatSoDem(ctx, sqlcgen.DatSoDemParams{ID: id, AmountVnd: amount})
}
