// Package khoanchi giữ cửa khoản chi của chủ quán (P3A-01, I-029 · I-021).
package khoanchi

import (
	"context"
	"errors"
	"math"
	"sort"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ThemLoai = authz.Door{Code: "khoanchi/them_loai", Need: authz.NeedOwner}
var Ghi = authz.Door{Code: "khoanchi/ghi", Need: authz.NeedOwner}
var Sua = authz.Door{Code: "khoanchi/sua", Need: authz.NeedOwner}

type Loai struct {
	ID           int64  `json:"expense_category_id"`
	Name         string `json:"name"`
	PaidFromTill bool   `json:"paid_from_till"`
}
type Khoan struct {
	ID           int64     `json:"expense_id"`
	CategoryID   int64     `json:"expense_category_id"`
	CategoryName string    `json:"category_name"`
	PaidFromTill bool      `json:"paid_from_till"`
	Amount       int64     `json:"amount_vnd"`
	PaidDate     string    `json:"paid_date"`
	PersonID     int64     `json:"person_id"`
	PersonName   string    `json:"person_name"`
	CreatedAt    time.Time `json:"created_at"`
}
type YeuCau struct {
	CategoryID int64  `json:"expense_category_id"`
	Amount     int64  `json:"amount_vnd"`
	PaidDate   string `json:"paid_date"`
	Reason     string `json:"reason"`
}
type BoLoc struct {
	From, To     string
	CategoryID   *int64
	PaidFromTill *bool
}
type DanhSach struct {
	From     string  `json:"from"`
	To       string  `json:"to"`
	Expenses []Khoan `json:"expenses"`
	Total    int64   `json:"total_vnd"`
}
type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func (s *Service) ThemLoai(ctx context.Context, nguoi int64, ten string, tuKet bool) (out Loai, err error) {
	err = authz.Run(ctx, s.pool, nguoi, ThemLoai, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).themLoai(ctx, ten, tuKet)
		return e
	})
	return
}
func (s *Service) DocLoai(ctx context.Context, nguoi int64) (out []Loai, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).docLoai(ctx)
		return e
	})
	return
}

// GhiKhoan nhận hình đã kiểm; ngày của quán luôn quy bằng PostgreSQL.
func (s *Service) GhiKhoan(ctx context.Context, nguoi int64, p YeuCau) (out Khoan, err error) {
	err = authz.Run(ctx, s.pool, nguoi, Ghi, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		tuKet, err := kiemKhoan(ctx, tx, repo, p)
		if err != nil {
			return err
		}
		if tuKet {
			if err := khoaNgay(ctx, tx, []string{p.PaidDate}); err != nil {
				return err
			}
		}
		id, err := repo.ghi(ctx, p)
		if err != nil {
			return err
		}
		out, err = repo.docKhoan(ctx, id)
		return err
	})
	return
}
func (s *Service) SuaKhoan(ctx context.Context, nguoi, id int64, p YeuCau) (out Khoan, err error) {
	err = authz.Run(ctx, s.pool, nguoi, Sua, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		ngayCu, ketCu, err := repo.khoaKhoan(ctx, id)
		if errors.Is(err, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodeExpenseNotFound}
		}
		if err != nil {
			return err
		}
		ketMoi, err := kiemKhoan(ctx, tx, repo, p)
		if err != nil {
			return err
		}
		var ngay []string
		if ketCu {
			ngay = append(ngay, ngayCu)
		}
		if ketMoi {
			ngay = append(ngay, p.PaidDate)
		}
		if err := khoaNgay(ctx, tx, ngay); err != nil {
			return err
		}
		if err := vongdoi.CoVet(ctx, tx, p.Reason, func() error { return repo.sua(ctx, id, p) }); err != nil {
			return err
		}
		out, err = repo.docKhoan(ctx, id)
		return err
	})
	return
}
func kiemKhoan(ctx context.Context, tx pgx.Tx, repo repository, p YeuCau) (bool, error) {
	moc, err := ngayban.DongHo(ctx, tx)
	if err != nil {
		return false, err
	}
	future, err := repo.ngayTuongLai(ctx, p.PaidDate, moc)
	if err != nil {
		return false, err
	}
	if future {
		return false, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "paid_date"}
	}
	ket, err := repo.timLoai(ctx, p.CategoryID)
	if errors.Is(err, pgx.ErrNoRows) {
		return false, apierr.Error{Code: apierr.CodeExpenseCategoryNotFound}
	}
	return ket, err
}

// Khoá chung theo thứ tự ngày, bỏ ngày trùng; cửa ký dùng khoá riêng cùng ngày.
func khoaNgay(ctx context.Context, tx pgx.Tx, ngay []string) error {
	sort.Strings(ngay)
	for i, d := range ngay {
		if i > 0 && d == ngay[i-1] {
			continue
		}
		if err := ngayban.Khoa(ctx, tx, d, false); err != nil {
			return err
		}
		ky, err := ngayban.DaKy(ctx, tx, d)
		if err != nil {
			return err
		}
		if ky {
			return apierr.Error{Code: apierr.CodeSaleDayReconciled}
		}
	}
	return nil
}
func (s *Service) Doc(ctx context.Context, nguoi int64, loc BoLoc) (out DanhSach, err error) {
	out = DanhSach{From: loc.From, To: loc.To}
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var err error
		out.Expenses, err = newRepository(tx).doc(ctx, loc)
		if err != nil {
			return err
		}
		for _, k := range out.Expenses {
			if k.Amount > math.MaxInt64-out.Total {
				return apierr.Error{Code: apierr.CodeInternalError}
			}
			out.Total += k.Amount
		}
		return nil
	})
	return
}
