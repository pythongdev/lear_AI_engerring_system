package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

// Thân cửa thường giữ context của service. Bọc Tx để cùng hạn I/O áp cho cả
// Begin, các câu trong thân và Commit, kể cả khi kết nối bị cắt giữa giao dịch.
// Hạn này không phải cửa sổ nhận đơn của quán mù.
type boundedTx struct {
	pgx.Tx
	deadline time.Time
}

func (tx boundedTx) Exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error) {
	ctx, cancel := context.WithDeadline(ctx, tx.deadline)
	defer cancel()
	return tx.Tx.Exec(ctx, sql, args...)
}
func (tx boundedTx) Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	ctx, cancel := context.WithDeadline(ctx, tx.deadline)
	rows, err := tx.Tx.Query(ctx, sql, args...)
	if err != nil {
		cancel()
		return nil, err
	}
	return boundedRows{Rows: rows, cancel: cancel}, nil
}
func (tx boundedTx) QueryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	ctx, cancel := context.WithDeadline(ctx, tx.deadline)
	return boundedRow{Row: tx.Tx.QueryRow(ctx, sql, args...), cancel: cancel}
}

type boundedRows struct {
	pgx.Rows
	cancel context.CancelFunc
}

func (r boundedRows) Close() { r.Rows.Close(); r.cancel() }
func (r boundedRows) Next() bool {
	ok := r.Rows.Next()
	if !ok {
		r.cancel()
	}
	return ok
}

type boundedRow struct {
	pgx.Row
	cancel context.CancelFunc
}

func (r boundedRow) Scan(dest ...any) error { defer r.cancel(); return r.Row.Scan(dest...) }
