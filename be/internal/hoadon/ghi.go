package hoadon

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/tratruoc"
	"context"
	_ "embed"
	"errors"
	"github.com/jackc/pgx/v5"
	"time"
)

var CuaGhi = authz.Door{Code: "hoadon/ghi", Need: authz.NeedCallingDoor}
var CuaGhiHoan = authz.Door{Code: "hoadon/ghi_hoan", Need: authz.NeedCallingDoor}

//go:embed sql/ghi/them.sql
var ghiSQL string

//go:embed sql/ghi/khoan.sql
var khoanSQL string

//go:embed sql/ghi_hoan/them.sql
var ghiHoanSQL string

type NoiDung struct {
	Phien, Don                                              *int64
	Due, Cash, Transfer, PrepaidCash, PrepaidTransfer, Debt int64
	Debtor                                                  *string
	Moc                                                     time.Time
}

// Ghi là ô thêm bill duy nhất; cửa gọi giữ khoá đơn/phiên và ngày chưa ký.
func Ghi(ctx context.Context, tx pgx.Tx, b NoiDung) (int64, error) {
	// Trừ dần để tránh tràn bigint khi yêu cầu có nhiều phần tiền rất lớn.
	con := b.Due
	for _, v := range []int64{b.Cash, b.Transfer, b.PrepaidCash, b.PrepaidTransfer, b.Debt} {
		if v < 0 || v > con {
			return 0, apierr.Error{Code: apierr.CodePaymentPartsMismatch}
		}
		con -= v
	}
	if con != 0 {
		return 0, apierr.Error{Code: apierr.CodePaymentPartsMismatch}
	}
	if (b.Debt > 0) != (b.Debtor != nil) {
		return 0, apierr.Error{Code: apierr.CodeDebtorNameMismatch}
	}
	var khoan, id int64
	if b.PrepaidCash > 0 || b.PrepaidTransfer > 0 {
		err := tx.QueryRow(ctx, khoanSQL, b.Don).Scan(&khoan)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, apierr.Error{Code: apierr.CodePrepaymentBalanceExceeded}
		}
		if err != nil {
			return 0, err
		}
	}
	if khoan != 0 {
		if _, err := tratruoc.KiemSoDu(ctx, tx, khoan, b.PrepaidCash, b.PrepaidTransfer); err != nil {
			return 0, err
		}
	}
	err := tx.QueryRow(ctx, ghiSQL, b.Phien, b.Don, b.Due, b.Cash, b.Transfer, b.PrepaidCash, b.PrepaidTransfer, b.Debt, b.Debtor, b.Moc).Scan(&id)
	if err != nil {
		return 0, err
	}
	if khoan != 0 {
		err = tratruoc.Dung(ctx, tx, khoan, b.PrepaidCash, b.PrepaidTransfer, &id, nil)
	}
	return id, err
}

// GhiHoan là ô thêm refund duy nhất; trả lại trả trước nối mắt trong cùng giao dịch ở cửa gọi.
func GhiHoan(ctx context.Context, tx pgx.Tx, bill, prepayment *int64, amount int64, method string, source *string, reason string, moc time.Time) (int64, error) {
	var id int64
	err := tx.QueryRow(ctx, ghiHoanSQL, bill, prepayment, amount, method, source, reason, moc).Scan(&id)
	return id, err
}
