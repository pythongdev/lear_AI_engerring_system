// Package nhandon giữ khoảng tạm dừng, quán mù và đường đọc của quầy (ADR-097).
package nhandon

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/platform/realtime"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var TamDung = authz.Door{Code: "nhandon/tam_dung", Need: authz.NeedOwner}
var TiepTuc = authz.Door{Code: "nhandon/tiep_tuc", Need: authz.NeedOwner}
var BaoMu = authz.Door{Code: "nhandon/bao_mu", Need: authz.NeedCounterOrOwner}
var MoLai = authz.Door{Code: "nhandon/mo_lai", Need: authz.NeedCounterOrOwner}
var CuaGhiMu = authz.Door{Code: "nhandon/ghi_mu", Need: authz.NeedCallingDoor}

type Service struct {
	pool   *pgxpool.Pool
	broker *realtime.Broker
}

func NewService(pool *pgxpool.Pool, broker *realtime.Broker) *Service { return &Service{pool, broker} }

// GhiMu là chủ duy nhất của INSERT, nhận giao dịch đã kiểm quyền của cửa gọi.
// Máy dùng personID = 0. Khoá chung với mở lại; khoảng cũ đã khép là chặn dưới (sửa ADR-097 điểm 5).
func GhiMu(ctx context.Context, tx pgx.Tx, since time.Time, personID int64) (json.RawMessage, error) {
	r := newRepository(tx)
	if err := r.khoa(ctx); err != nil {
		return nil, err
	}
	return r.ghiMu(ctx, since, personID)
}
func (s *Service) Bam(ctx context.Context, personID int64, door authz.Door) (json.RawMessage, error) {
	var out json.RawMessage
	err := authz.Run(ctx, s.pool, personID, door, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if err := r.khoa(ctx); err != nil {
			return err
		}
		var err error
		switch door {
		case TamDung:
			out, err = r.tamDung(ctx)
		case BaoMu:
			var at time.Time
			at, err = r.dongHo(ctx)
			if err == nil {
				out, err = GhiMu(ctx, tx, at, personID)
			}
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeShopAlreadyBlind}
			}
		case TiepTuc, MoLai:
			err = vongdoi.CoVet(ctx, tx, door.Code, func() error {
				if door == TiepTuc {
					out, err = r.tiepTuc(ctx)
				} else {
					out, err = r.moLai(ctx)
				}
				return err
			})
			if errors.Is(err, pgx.ErrNoRows) {
				if door == TiepTuc {
					return apierr.Error{Code: apierr.CodeOrderIntakeNotPaused}
				}
				return apierr.Error{Code: apierr.CodeShopNotBlind}
			}
		default:
			return apierr.Error{Code: apierr.CodeInvalidRequest}
		}
		return err
	})
	return out, err
}
func (s *Service) HangCho(ctx context.Context, personID int64) (json.RawMessage, error) {
	var out json.RawMessage
	err := authz.Read(ctx, s.pool, personID, authz.NeedCounter, func(tx pgx.Tx) error {
		var err error
		out, err = newRepository(tx).hangCho(ctx)
		return err
	})
	return out, err
}
func (s *Service) MoLuong(ctx context.Context, personID int64) (time.Time, bool, error) {
	var at time.Time
	var blind bool
	err := authz.Read(ctx, s.pool, personID, authz.NeedCounter, func(tx pgx.Tx) error {
		r := newRepository(tx)
		var err error
		if at, err = r.dongHo(ctx); err != nil {
			return err
		}
		blind, err = r.daMu(ctx)
		return err
	})
	return at, blind, err
}
func (s *Service) Moc(ctx context.Context) (time.Time, error) { return postgres.ReadTime(ctx, s.pool) }
