// Package hoptin giữ tin báo, không ghi tiến độ (ADR-137, I-038).
package hoptin

import (
	"context"
	"errors"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/realtime"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var QuayGui = authz.Door{Code: "hoptin/quay_gui", Need: authz.NeedCounter}
var GuiVeQuay = authz.Door{Code: "hoptin/gui_ve_quay", Need: authz.NeedPerson}
var CuaGhi = authz.Door{Code: "hoptin/ghi", Need: authz.NeedCallingDoor}
var submissionPattern = regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

type YeuCau struct {
	SubmissionCode string `json:"submission_code"`
	RecipientID    *int64 `json:"recipient_person_id"`
	WorkCode       string `json:"work_code"`
	Body           string `json:"body"`
	DiningTableID  *int64 `json:"dining_table_id"`
	ReplyToID      *int64 `json:"reply_to_message_id"`
}
type Tin struct {
	ID            int64     `json:"station_message_id"`
	SenderID      int64     `json:"sender_person_id"`
	SenderName    string    `json:"sender_name"`
	RecipientID   *int64    `json:"recipient_person_id"`
	RecipientName *string   `json:"recipient_name"`
	WorkCode      string    `json:"work_code"`
	Body          string    `json:"body"`
	DiningTableID *int64    `json:"dining_table_id"`
	ReplyToID     *int64    `json:"reply_to_message_id"`
	CreatedAt     time.Time `json:"created_at"`
}
type Trang struct {
	Messages            []Tin     `json:"messages"`
	NextBeforeID        *int64    `json:"next_before_id"`
	ReadAt              time.Time `json:"read_at"`
	PollIntervalSeconds int       `json:"poll_interval_seconds"`
}
type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool} }

func (p YeuCau) kiemHinh(toCounter bool) error {
	field := ""
	switch {
	case !submissionPattern.MatchString(p.SubmissionCode):
		field = "submission_code"
	case !toCounter && (p.RecipientID == nil || *p.RecipientID <= 0):
		field = "recipient_person_id"
	case p.WorkCode != "canh" && p.WorkCode != "don_ban" && p.WorkCode != "trang_banh" && p.WorkCode != "gap_banh" && p.WorkCode != "khac":
		field = "work_code"
	case !utf8.ValidString(p.Body) || strings.TrimSpace(p.Body) == "" || utf8.RuneCountInString(p.Body) > 500:
		field = "body"
	case p.DiningTableID != nil && *p.DiningTableID <= 0:
		field = "dining_table_id"
	case p.ReplyToID != nil && *p.ReplyToID <= 0:
		field = "reply_to_message_id"
	}
	if field != "" {
		return apierr.Error{Code: apierr.CodeInvalidRequest, Field: field}
	}
	return nil
}
func cungID(a, b *int64) bool { return a == nil && b == nil || a != nil && b != nil && *a == *b }

// Ghi là chủ duy nhất của INSERT, nhận giao dịch và nội dung đã kiểm ở cửa gọi.
func Ghi(ctx context.Context, tx pgx.Tx, p YeuCau) (Tin, error) {
	r := newRepository(tx)
	id, err := r.ghi(ctx, p)
	if err != nil {
		return Tin{}, err
	}
	return r.tin(ctx, id)
}
func (s *Service) Gui(ctx context.Context, personID int64, p YeuCau, toCounter bool) (out Tin, replay bool, err error) {
	if toCounter {
		p.RecipientID = nil
	}
	if err = p.kiemHinh(toCounter); err != nil {
		return
	}
	door := QuayGui
	if toCounter {
		door = GuiVeQuay
	}
	for attempt := 0; attempt < 4; attempt++ {
		replay = false
		err = authz.RunAs(ctx, s.pool, authz.Caller{PersonID: personID}, door, func(tx pgx.Tx, g authz.Granted) error {
			r := newRepository(tx)
			id, e := r.dau(ctx, p.SubmissionCode)
			if e == nil {
				saved, e := r.tin(ctx, id)
				if e != nil {
					return e
				}
				if saved.SenderID != g.PersonID || !cungID(saved.RecipientID, p.RecipientID) || saved.WorkCode != p.WorkCode || saved.Body != p.Body || !cungID(saved.DiningTableID, p.DiningTableID) || !cungID(saved.ReplyToID, p.ReplyToID) {
					return apierr.Error{Code: apierr.CodeSubmissionCodeConflict}
				}
				out, replay = saved, true
				return nil
			}
			if !errors.Is(e, pgx.ErrNoRows) {
				return e
			}
			if p.RecipientID != nil {
				valid, e := r.nguoiNhan(ctx, *p.RecipientID)
				if e != nil {
					return e
				}
				if !valid || *p.RecipientID == g.PersonID {
					return apierr.Error{Code: apierr.CodeMessageRecipientInvalid}
				}
			}
			if p.DiningTableID != nil {
				valid, e := r.ban(ctx, *p.DiningTableID)
				if e != nil {
					return e
				}
				if !valid {
					return apierr.Error{Code: apierr.CodeDiningTableNotFound}
				}
			}
			if p.ReplyToID != nil {
				valid, e := r.tinTraLoi(ctx, *p.ReplyToID, g.PersonID, !toCounter)
				if e != nil {
					return e
				}
				if !valid {
					return apierr.Error{Code: apierr.CodeStationMessageNotFound}
				}
			}
			out, e = Ghi(ctx, tx, p)
			return e
		})
		var pg *pgconn.PgError
		if !errors.As(err, &pg) || pg.ConstraintName != "station_message_submission_code_key" {
			return
		}
	}
	return
}
func (s *Service) Doc(ctx context.Context, personID, beforeID int64, limit int32, counter bool) (out Trang, err error) {
	need := authz.NeedPerson
	if counter {
		need = authz.NeedCounterOrOwner
	}
	err = authz.Read(ctx, s.pool, personID, need, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).doc(ctx, personID, beforeID, limit, counter)
		return e
	})
	out.PollIntervalSeconds = realtime.PollIntervalSeconds
	return
}
