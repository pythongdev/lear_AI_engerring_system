// Package nguoi giữ danh sách tên và mốc đổi người ở quầy: C36 đòi một mốc có cả ai vào,
// ai ra, nên khép khoảng cũ và mở khoảng mới phải dùng cùng giao dịch của cửa gọi.
package nguoi

import (
	"context"
	"errors"
	"fmt"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var VaoQuay = authz.Door{Code: "nguoi/vao_quay", Need: authz.NeedPerson}
var RoiQuay = authz.Door{Code: "nguoi/roi_quay", Need: authz.NeedCounter}
var CuaKhepQuay = authz.Door{Code: "nguoi/khep_quay", Need: authz.NeedCallingDoor}

type person struct {
	PersonID    int64  `json:"person_id"`
	DisplayName string `json:"display_name"`
	IsOwner     bool   `json:"is_owner"`
}

type currentDuty struct {
	PersonID      *int64     `json:"person_id"`
	DisplayName   *string    `json:"display_name"`
	CounterDutyID *int64     `json:"counter_duty_id"`
	StartedAt     *time.Time `json:"started_at"`
}

type enteredDuty struct {
	CounterDutyID    int64     `json:"counter_duty_id"`
	PersonID         int64     `json:"person_id"`
	StartedAt        time.Time `json:"started_at"`
	ReplacedPersonID *int64    `json:"replaced_person_id"`
}

type endedDuty struct {
	CounterDutyID int64     `json:"counter_duty_id"`
	PersonID      int64     `json:"person_id"`
	StartedAt     time.Time `json:"started_at"`
	EndedAt       time.Time `json:"ended_at"`
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func (s *Service) DanhSach(ctx context.Context) ([]person, error) {
	var result []person
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		result, err = newRepository(tx).danhSach(ctx)
		return err
	})
	return result, err
}

func (s *Service) HienTai(ctx context.Context) (currentDuty, error) {
	var result currentDuty
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		result, err = newRepository(tx).hienTai(ctx)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		return err
	})
	return result, err
}

func (s *Service) VaoQuay(ctx context.Context, personID int64) (enteredDuty, bool, error) {
	var result enteredDuty
	created := true
	err := authz.Run(ctx, s.pool, personID, VaoQuay, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		current, changed, err := repo.khoaQuay(ctx)
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		if err == nil {
			if current.PersonID == personID {
				result = current
				created = false
				return nil
			}
			if changed {
				return apierr.Error{Code: apierr.CodeCounterDutyChanged}
			}
			reason := fmt.Sprintf("%s: %d thay %d", VaoQuay.Code, personID, current.PersonID)
			if _, err := khepQuay(ctx, tx, current.CounterDutyID, reason); err != nil {
				return err
			}
			result.ReplacedPersonID = &current.PersonID
		}
		added, err := repo.themKhoang(ctx, personID)
		result.CounterDutyID, result.PersonID, result.StartedAt = added.CounterDutyID, added.PersonID, added.StartedAt
		return err
	})
	return result, created, err
}

func (s *Service) RoiQuay(ctx context.Context, personID int64) (endedDuty, error) {
	var result endedDuty
	err := authz.Run(ctx, s.pool, personID, RoiQuay, func(tx pgx.Tx) error {
		dutyID, err := newRepository(tx).khoaNguoi(ctx, personID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeNotOnCounterDuty}
			}
			return err
		}
		result, err = khepQuay(ctx, tx, dutyID, fmt.Sprintf("%s: %d rời quầy", RoiQuay.Code, personID))
		return err
	})
	return result, err
}

// khepQuay là thân cửa nguoi/khep_quay, chủ duy nhất của ô counter_duty.ended_at.
// Cửa gọi đã kiểm quyền và khoá khoảng; dùng giao dịch và lý do của nó để giữ cùng mốc và vết.
func khepQuay(ctx context.Context, tx pgx.Tx, dutyID int64, reason string) (endedDuty, error) {
	var result endedDuty
	err := vongdoi.CoVet(ctx, tx, reason, func() error {
		var err error
		result, err = newRepository(tx).khepKhoang(ctx, dutyID)
		return err
	})
	return result, err
}
