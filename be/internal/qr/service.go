// Package qr giữ mã QR của bàn: khách vào bàn qua mã HIỆN HÀNH (I-023), chủ quán đổi mã (U-062).
package qr

import (
	"context"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// DoiMa — cấp mã mới cho một bàn; mã cũ hết hiện hành cùng mốc. Chỉ chủ quán (U-062).
var DoiMa = authz.Door{Code: "qr/doi_ma", Need: authz.NeedOwner}

// Một bản câu tra mã ở authz, tránh vòng import với lớp quay_hoac_khach.
type Querier = authz.Querier
type Seat = authz.Seat

func CurrentTable(ctx context.Context, q Querier, code string) (Seat, error) {
	return authz.CurrentTable(ctx, q, code)
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

type maVuaCap struct {
	Code          string `json:"code"`
	DiningTableID int64  `json:"dining_table_id"`
	IssuedAt      string `json:"issued_at"`
}

func (s *Service) BanCuaKhach(ctx context.Context, code string) (Seat, error) {
	var out Seat
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		out, err = authz.CurrentTable(ctx, tx, code)
		return err
	})
	return out, err
}

func (s *Service) DoiMa(ctx context.Context, nguoi, banID int64) (maVuaCap, error) {
	var out maVuaCap
	err := authz.Run(ctx, s.pool, nguoi, DoiMa, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		id, err := repo.capMa(ctx, banID)
		if err != nil {
			return err
		}
		out, err = repo.docMaVuaCap(ctx, id)
		return err
	})
	return out, err
}
