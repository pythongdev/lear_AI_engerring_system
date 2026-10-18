package tongquan

import (
	"context"
	"time"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var DatToiThieu = authz.Door{Code: "tongquan/dat_toi_thieu", Need: authz.NeedOwner}

type ToiThieuInput struct {
	MinimumBanh    int32 `json:"minimum_banh"`
	MinimumWorkers int32 `json:"minimum_workers"`
}
type ToiThieu struct {
	ToiThieuInput
	SaleDate  string    `json:"sale_date"`
	PersonID  int64     `json:"person_id"`
	CreatedAt time.Time `json:"created_at"`
}

func (s *Service) Dat(ctx context.Context, nguoi int64, ngay string, p ToiThieuInput) (out ToiThieu, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DatToiThieu, func(tx pgx.Tx) error {
		return vongdoi.CoVet(ctx, tx, "tongquan/dat_toi_thieu", func() error {
			var e error
			out, e = newRepository(tx).dat(ctx, ngay, p)
			return e
		})
	})
	return
}
