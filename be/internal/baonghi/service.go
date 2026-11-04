// Package baonghi giữ báo nghỉ riêng, không ghi chấm công hay tiền (ADR-138, I-039).
package baonghi

import (
	"context"
	"errors"
	"regexp"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var Bao = authz.Door{Code: "baonghi/bao", Need: authz.NeedPerson}
var Huy = authz.Door{Code: "baonghi/huy", Need: authz.NeedPerson}
var DaBiet = authz.Door{Code: "baonghi/da_biet", Need: authz.NeedOwner}
var submissionPattern = regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

type YeuCau struct {
	SubmissionCode string `json:"submission_code"`
	LeaveDate      string `json:"leave_date"`
}
type Dong struct {
	ID             int64      `json:"leave_notice_id"`
	PersonID       int64      `json:"person_id"`
	PersonName     string     `json:"person_name"`
	LeaveDate      string     `json:"leave_date"`
	NoticeKind     string     `json:"notice_kind"`
	CreatedAt      time.Time  `json:"created_at"`
	AcknowledgedAt *time.Time `json:"acknowledged_at"`
	AcknowledgedBy *int64     `json:"acknowledged_by_person_id"`
	CancelledAt    *time.Time `json:"cancelled_at"`
	CancelledBy    *int64     `json:"cancelled_by_person_id"`
	CanCancel      bool       `json:"can_cancel"`
}
type Trang struct {
	Notices []Dong    `json:"leave_notices"`
	ReadAt  time.Time `json:"read_at"`
}
type TrangCuaToi struct {
	Trang
	NextBeforeID *int64 `json:"next_before_id"`
}
type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool} }

func invalid(field string) error { return apierr.Error{Code: apierr.CodeInvalidRequest, Field: field} }
func ngay(raw, field string) (time.Time, error) {
	d, err := time.Parse("2006-01-02", raw)
	if err != nil || len(raw) != 10 || d.Year() < 1 {
		return time.Time{}, invalid(field)
	}
	return d, nil
}
func (s *Service) Bao(ctx context.Context, personID int64, p YeuCau) (out Dong, replay bool, err error) {
	if !submissionPattern.MatchString(p.SubmissionCode) {
		err = invalid("submission_code")
		return
	}
	date, e := ngay(p.LeaveDate, "leave_date")
	if e != nil {
		err = e
		return
	}
	for attempt := 0; attempt < 4; attempt++ {
		replay = false
		err = authz.RunAs(ctx, s.pool, authz.Caller{PersonID: personID}, Bao, func(tx pgx.Tx, _ authz.Granted) error {
			r := newRepository(tx)
			id, e := r.dau(ctx, p.SubmissionCode)
			if e == nil {
				saved, e := r.dong(ctx, id)
				if e != nil {
					return e
				}
				if saved.LeaveDate != p.LeaveDate {
					return apierr.Error{Code: apierr.CodeSubmissionCodeConflict}
				}
				out, replay = saved, true
				return nil
			}
			if !errors.Is(e, pgx.ErrNoRows) {
				return e
			}
			// Trigger xét ngày, ô đi làm và khoá ngày sau khi cửa đã tra dấu.
			id, e = r.bao(ctx, date, p.SubmissionCode)
			if e != nil {
				return e
			}
			out, e = r.dong(ctx, id)
			return e
		})
		var pg *pgconn.PgError
		if !errors.As(err, &pg) || pg.Code != "23505" ||
			(pg.ConstraintName != "leave_notice_person_submission_code_key" && pg.ConstraintName != "leave_notice_one_live_per_person_day_key") {
			return
		}
	}
	return
}

// GhiDau khoá dòng trước khi xét dấu; gửi lại không UPDATE nên không sinh vết mới.
func (s *Service) GhiDau(ctx context.Context, personID, id int64, acknowledge bool) (out Dong, err error) {
	if id <= 0 {
		return out, invalid("leave_notice_id")
	}
	door := Huy
	if acknowledge {
		door = DaBiet
	}
	err = authz.RunAs(ctx, s.pool, authz.Caller{PersonID: personID}, door, func(tx pgx.Tx, _ authz.Granted) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			if errors.Is(e, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeLeaveNoticeNotFound}
			}
			return e
		}
		saved, e := r.dong(ctx, id)
		if e != nil {
			return e
		}
		out = saved
		if acknowledge && saved.AcknowledgedAt != nil || !acknowledge && saved.CancelledAt != nil {
			return nil
		}
		if !acknowledge && !saved.CanCancel {
			return apierr.Error{Code: apierr.CodeLeaveNoticeCancelClosed}
		}
		if e = r.ghiDau(ctx, id, acknowledge); e != nil {
			return e
		}
		out, e = r.dong(ctx, id)
		return e
	})
	return
}
func (s *Service) CuaToi(ctx context.Context, personID, beforeID int64, limit int32) (out TrangCuaToi, err error) {
	if beforeID < 0 {
		return out, invalid("before_id")
	}
	if limit < 1 || limit > 50 {
		return out, invalid("limit")
	}
	err = authz.Read(ctx, s.pool, personID, authz.NeedPerson, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).cuaToi(ctx, beforeID, limit)
		return e
	})
	return
}
func (s *Service) TheoKhoang(ctx context.Context, personID int64, from, to string) (out Trang, err error) {
	start, e := ngay(from, "from")
	if e != nil {
		return out, e
	}
	end, e := ngay(to, "to")
	if e != nil {
		return out, e
	}
	if end.Before(start) || end.After(start.AddDate(0, 0, 92)) {
		return out, invalid("to")
	}
	err = authz.Read(ctx, s.pool, personID, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).theoKhoang(ctx, start, end)
		return e
	})
	return
}
