// Package phien giữ cửa tính tiền và phép cộng duy nhất của một phiên.
package phien

import (
	"context"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var TinhTien = authz.Door{Code: "phien/tinh_tien", Need: authz.NeedCounter}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

// TongTien cộng suất đã ra hết theo ADR-125, dùng chung cho tính tiền và đóng phiên.
func TongTien(ctx context.Context, tx pgx.Tx, id int64) (int64, error) {
	return newRepository(tx).tongTien(ctx, id)
}

func (s *Service) TinhTien(ctx context.Context, nguoi, id int64) (int64, error) {
	var due int64
	err := authz.Run(ctx, s.pool, nguoi, TinhTien, func(tx pgx.Tx) error {
		if _, err := newRepository(tx).khoa(ctx, id); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeTableSessionNotFound}
			}
			return err
		}
		if err := vongdoi.ChuyenPhien(ctx, tx, id, "awaiting_payment"); err != nil {
			return err
		}
		var err error
		due, err = TongTien(ctx, tx, id)
		return err
	})
	return due, err
}

// DonCoSuatDaRa đọc số suất (không dùng tiền > 0), nên suất miễn phí cũng hoàn thành đơn.
// Cùng đoạn SQL đánh dấu với TongTien; cửa đóng đã khoá phiên và mọi đơn/việc.
func DonCoSuatDaRa(ctx context.Context, tx pgx.Tx, id int64) ([]int64, error) {
	return newRepository(tx).donCoSuatDaRa(ctx, id)
}
