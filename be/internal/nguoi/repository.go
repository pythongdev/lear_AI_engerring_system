package nguoi

import (
	"context"
	"time"

	"banhcuon/be/internal/nguoi/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) danhSach(ctx context.Context) ([]person, error) {
	rows, err := r.q.DanhSach(ctx)
	if err != nil {
		return nil, err
	}
	result := make([]person, 0, len(rows))
	for _, row := range rows {
		result = append(result, person{PersonID: row.ID, DisplayName: row.DisplayName, IsOwner: row.IsOwner})
	}
	return result, nil
}

func (r repository) hienTai(ctx context.Context) (currentDuty, error) {
	row, err := r.q.HienTai(ctx)
	if err != nil {
		return currentDuty{}, err
	}
	return currentDuty{PersonID: &row.PersonID, DisplayName: &row.DisplayName, CounterDutyID: &row.ID, StartedAt: mocThoiGian(row.StartedAt)}, nil
}

func (r repository) khoaQuay(ctx context.Context) (enteredDuty, bool, error) {
	row, err := r.q.KhoaQuay(ctx)
	return enteredDuty{CounterDutyID: row.ID, PersonID: row.PersonID, StartedAt: row.StartedAt.Time}, row.Column4, err
}

func (r repository) themKhoang(ctx context.Context, personID int64) (enteredDuty, error) {
	row, err := r.q.ThemKhoang(ctx, personID)
	return enteredDuty{CounterDutyID: row.ID, PersonID: row.PersonID, StartedAt: row.StartedAt.Time}, err
}

func (r repository) khoaNguoi(ctx context.Context, personID int64) (int64, error) {
	return r.q.KhoaNguoi(ctx, personID)
}

func (r repository) khepKhoang(ctx context.Context, id int64) (endedDuty, error) {
	row, err := r.q.KhepKhoang(ctx, id)
	// Câu UPDATE đặt ended_at = now(), nên kết quả thành công luôn có mốc khép.
	return endedDuty{CounterDutyID: row.ID, PersonID: row.PersonID, StartedAt: row.StartedAt.Time, EndedAt: row.EndedAt.Time}, err
}

func mocThoiGian(v pgtype.Timestamptz) *time.Time {
	if !v.Valid {
		return nil
	}
	return &v.Time
}

func (r repository) taoNguoi(ctx context.Context, name string, owner bool) (int64, error) {
	return r.q.TaoNguoi(ctx, sqlcgen.TaoNguoiParams{DisplayName: name, IsOwner: owner})
}
func (r repository) khoaKhoang(ctx context.Context, id, person int64) (int64, error) {
	return r.q.KhoaKhoang(ctx, sqlcgen.KhoaKhoangParams{ID: id, PersonID: person})
}
