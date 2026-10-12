package tratruoc

import (
	"context"
	"errors"
	"time"

	"banhcuon/be/internal/tratruoc/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service hoặc của cửa gọi; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) khoaDon(ctx context.Context, id int64) (*int64, string, error) {
	row, err := r.q.KhoaDon(ctx, id)
	return soCoTheRong(row.TableSessionID), row.Status, err
}

func (r repository) themKhoan(ctx context.Context, id, cash, transfer int64, moc time.Time) (int64, error) {
	return r.q.ThemKhoan(ctx, sqlcgen.ThemKhoanParams{SalesOrderID: id, CashVnd: cash, TransferVnd: transfer,
		BookedAt: pgtype.Timestamptz{Time: moc, Valid: true}})
}

func (r repository) khoaKhoan(ctx context.Context, id int64) (int64, int64, int64, error) {
	row, err := r.q.KhoaKhoan(ctx, id)
	return row.SalesOrderID, row.CashVnd, row.TransferVnd, err
}

// Mắt cuối luôn có số dư; NULL là lỗi hệ thống như khi đọc thẳng vào int64.
func (r repository) docDu(ctx context.Context, id int64) (int, int64, int64, error) {
	row, err := r.q.DocDu(ctx, id)
	if err != nil {
		return 0, 0, 0, err
	}
	if !row.CashAfterVnd.Valid || !row.TransferAfterVnd.Valid {
		return 0, 0, 0, errors.New("tratruoc: mắt cuối không có số dư")
	}
	return int(row.UseNo), row.CashAfterVnd.Int64, row.TransferAfterVnd.Int64, nil
}

func (r repository) themMat(ctx context.Context, id, don int64, useNo int, cash, transfer, takeCash, takeTransfer int64, bill, refund *int64) error {
	return r.q.ThemMat(ctx, sqlcgen.ThemMatParams{PrepaymentID: id, SalesOrderID: don, UseNo: int32(useNo),
		CashBeforeVnd: cash, TransferBeforeVnd: transfer, TakeCashVnd: takeCash, TakeTransferVnd: takeTransfer,
		BillID: soNull(bill), RefundID: soNull(refund)})
}

func soCoTheRong(v pgtype.Int8) *int64 {
	if !v.Valid {
		return nil
	}
	return &v.Int64
}

func soNull(v *int64) pgtype.Int8 {
	if v == nil {
		return pgtype.Int8{}
	}
	return pgtype.Int8{Int64: *v, Valid: true}
}
