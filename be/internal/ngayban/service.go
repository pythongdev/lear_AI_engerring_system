// Package ngayban dùng đồng hồ giao dịch và múi giờ kết nối của quán (ADR-089 điểm 3).
package ngayban

import (
	"context"
	"time"

	"banhcuon/be/internal/apierr"
	"github.com/jackc/pgx/v5"
)

var DongHo func(context.Context, pgx.Tx) (time.Time, error) = func(ctx context.Context, tx pgx.Tx) (time.Time, error) {
	return newRepository(tx).dongHo(ctx)
}

// Khoa giữ ngày trong suốt giao dịch: cửa tiền dùng khoá chung, cửa ký dùng khoá riêng.
// Nhờ vậy không lần ghi nào lọt giữa phép tính két và lần ký. 309 là namespace của lát.
func Khoa(ctx context.Context, tx pgx.Tx, ngay string, ky bool) error {
	repo := newRepository(tx)
	if ky {
		return repo.khoaRieng(ctx, ngay)
	}
	return repo.khoaChung(ctx, ngay)
}

func DaKy(ctx context.Context, tx pgx.Tx, ngay string) (bool, error) {
	return newRepository(tx).daKy(ctx, ngay)
}

// ChoGhi đọc một mốc, quy ngày bằng PostgreSQL, rồi giữ ngày chưa ký cho tới COMMIT.
func ChoGhi(ctx context.Context, tx pgx.Tx) (time.Time, string, error) {
	moc, err := DongHo(ctx, tx)
	if err != nil {
		return moc, "", err
	}
	ngay, err := newRepository(tx).quyNgay(ctx, moc)
	if err != nil {
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

// NgoaiGio dùng múi giờ phiên kết nối; cả hai đầu giờ bán đều ở trong giờ.
func NgoaiGio(ctx context.Context, tx pgx.Tx, moc time.Time) (bool, error) {
	return newRepository(tx).ngoaiGio(ctx, moc)
}
