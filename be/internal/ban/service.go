// Package ban đọc trạng thái bàn từ chi tiết và giữ cửa xác nhận đã dọn.
package ban

import (
	"context"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var DaDon = authz.Door{Code: "ban/da_don", Need: authz.NeedPerson}

type Ban struct {
	DiningTableID      int64   `json:"dining_table_id"`
	Label              string  `json:"label"`
	State              string  `json:"state"`
	TableSessionID     *int64  `json:"table_session_id,omitempty"`
	TableSessionStatus *string `json:"table_session_status,omitempty"`
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

// Doc dùng giao dịch của cửa gọi, giữ phép đọc bàn cho miền don (I-003).
func Doc(ctx context.Context, tx pgx.Tx, id int64) (Ban, error) {
	b, err := newRepository(tx).docBan(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return Ban{}, apierr.Error{Code: apierr.CodeDiningTableNotFound}
	}
	return b, err
}

func (s *Service) DanhSach(ctx context.Context) ([]Ban, error) {
	var out []Ban
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		out, err = newRepository(tx).docCacBan(ctx)
		return err
	})
	return out, err
}

func (s *Service) DaDon(ctx context.Context, nguoi, id int64) (Ban, error) {
	var b Ban
	err := authz.Run(ctx, s.pool, nguoi, DaDon, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		ids, err := repo.khoaChoDon(ctx, id)
		if err != nil {
			return err
		}
		if len(ids) == 0 {
			if _, err := Doc(ctx, tx, id); err != nil {
				return err
			}
			return apierr.Error{Code: apierr.CodeDiningTableNotNeedingCleaning}
		}
		if err := vongdoi.CoVet(ctx, tx, DaDon.Code+": needs_cleaning → empty", func() error {
			return repo.don(ctx, ids)
		}); err != nil {
			return err
		}
		b, err = Doc(ctx, tx, id)
		return err
	})
	return b, err
}
