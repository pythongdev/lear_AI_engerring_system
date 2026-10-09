// Package ngayban dùng đồng hồ giao dịch và múi giờ kết nối của quán (ADR-089 điểm 3).
package ngayban

import (
	"banhcuon/be/internal/apierr"
	"context"
	"github.com/jackc/pgx/v5"
	"time"
)

var DongHo func(context.Context, pgx.Tx) (time.Time, error) = func(ctx context.Context, tx pgx.Tx) (time.Time, error) {
	var moc time.Time
	err := tx.QueryRow(ctx, "SELECT now()").Scan(&moc)
	return moc, err
}

// Khoa giữ ngày trong suốt giao dịch: cửa tiền dùng khoá chung, cửa ký dùng khoá riêng.
// Nhờ vậy không lần ghi nào lọt giữa phép tính két và lần ký. 309 là namespace của lát.
func Khoa(ctx context.Context, tx pgx.Tx, ngay string, ky bool) error {
	sql := "SELECT pg_advisory_xact_lock_shared(309, $1::date - DATE '2000-01-01')"
	if ky {
		sql = "SELECT pg_advisory_xact_lock(309, $1::date - DATE '2000-01-01')"
	}
	_, err := tx.Exec(ctx, sql, ngay)
	return err
}

func DaKy(ctx context.Context, tx pgx.Tx, ngay string) (bool, error) {
	var co bool
	err := tx.QueryRow(ctx, "SELECT EXISTS (SELECT 1 FROM reconciled_day WHERE sale_date = $1::date)", ngay).Scan(&co)
	return co, err
}

// ChoGhi đọc một mốc, quy ngày bằng PostgreSQL, rồi giữ ngày chưa ký cho tới COMMIT.
func ChoGhi(ctx context.Context, tx pgx.Tx) (time.Time, string, error) {
	moc, err := DongHo(ctx, tx)
	if err != nil {
		return moc, "", err
	}
	var ngay string
	if err = tx.QueryRow(ctx, "SELECT $1::timestamptz::date::text", moc).Scan(&ngay); err != nil {
		return moc, "", err
	}
	if err = Khoa(ctx, tx, ngay, false); err != nil {
		return moc, ngay, err
	}
	co, err := DaKy(ctx, tx, ngay)
	if err == nil && co {
		err = apierr.Error{Code: apierr.CodeSaleDayReconciled}
	}
	return moc, ngay, err
}
