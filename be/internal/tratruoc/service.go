// Package tratruoc nhận trả trước và nối chuỗi số dư trong giao dịch của cửa gọi.
package tratruoc

import (
	"context"
	"errors"
	"math"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var Nhan = authz.Door{Code: "tratruoc/nhan", Need: authz.NeedCounter}
var CuaDung = authz.Door{Code: "tratruoc/dung", Need: authz.NeedCallingDoor}

// PhanTien là hai phần bắt buộc của một lần nhận tiền.
type PhanTien struct {
	Cash     *int64 `json:"cash_vnd"`
	Transfer *int64 `json:"transfer_vnd"`
}

func (p PhanTien) Kiem() error {
	for _, f := range []struct {
		name string
		v    *int64
	}{{"cash_vnd", p.Cash}, {"transfer_vnd", p.Transfer}} {
		if f.v == nil || *f.v < 0 {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: f.name}
		}
	}
	if *p.Cash > math.MaxInt64-*p.Transfer || *p.Cash+*p.Transfer == 0 {
		return apierr.Error{Code: apierr.CodeInvalidRequest}
	}
	return nil
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

// NhanTien chạy cửa tratruoc/nhan; p đã qua Kiem ở handler.
func (s *Service) NhanTien(ctx context.Context, nguoi, id int64, p PhanTien) (int64, error) {
	var out int64
	err := authz.Run(ctx, s.pool, nguoi, Nhan, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		phien, status, err := repo.khoaDon(ctx, id)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		moc, _, err := ngayban.ChoGhi(ctx, tx)
		if err != nil {
			return err
		}
		if phien != nil || (status != "pending_confirmation" && status != "confirmed" && status != "in_progress") {
			return apierr.Error{Code: apierr.CodeOrderNotPrepayable}
		}
		out, err = repo.themKhoan(ctx, id, *p.Cash, *p.Transfer, moc)
		return err
	})
	return out, err
}

// SoDu là mắt cuối đã khoá của một khoản; mắt đầu dùng số đã nhận.
type SoDu struct {
	Don, Cash, Transfer int64
	UseNo               int
}

func KiemSoDu(ctx context.Context, tx pgx.Tx, id, cash, transfer int64) (SoDu, error) {
	repo := newRepository(tx)
	var s SoDu
	var err error
	if s.Don, s.Cash, s.Transfer, err = repo.khoaKhoan(ctx, id); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return s, apierr.Error{Code: apierr.CodePrepaymentNotFound}
		}
		return s, err
	}
	useNo, du, chuyen, err := repo.docDu(ctx, id)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return s, err
	}
	if err == nil {
		s.UseNo, s.Cash, s.Transfer = useNo, du, chuyen
	}
	if cash > s.Cash || transfer > s.Transfer {
		return s, apierr.Error{Code: apierr.CodePrepaymentBalanceExceeded}
	}
	return s, nil
}

// Dung chỉ nhận giao dịch đã kiểm quyền. Khoá khoản trước khi đọc mắt cuối; không tự chia tiền.
func Dung(ctx context.Context, tx pgx.Tx, id, cash, transfer int64, bill, refund *int64) error {
	s, err := KiemSoDu(ctx, tx, id, cash, transfer)
	if err != nil {
		return err
	}
	return newRepository(tx).themMat(ctx, id, s.Don, s.UseNo+1, s.Cash, s.Transfer, cash, transfer, bill, refund)
}
