// Package giaoviec giữ việc giao và các sự kiện đánh dấu (P3A-03, I-030).
package giaoviec

import (
	"context"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var Tao = authz.Door{Code: "giaoviec/tao", Need: authz.NeedCounterOrOwner}
var Sua = authz.Door{Code: "giaoviec/sua", Need: authz.NeedCounterOrOwner}
var An = authz.Door{Code: "giaoviec/an", Need: authz.NeedCounterOrOwner}
var DanhDau = authz.Door{Code: "giaoviec/danh_dau", Need: authz.NeedCounterOrOwner}

type Dau struct {
	ID         int64     `json:"assigned_task_mark_id"`
	Mark       string    `json:"mark"`
	PersonID   int64     `json:"person_id"`
	PersonName string    `json:"person_name"`
	CreatedAt  time.Time `json:"created_at"`
}
type Viec struct {
	ID           int64      `json:"assigned_task_id"`
	Content      string     `json:"content"`
	AssigneeID   int64      `json:"assignee_person_id"`
	AssigneeName string     `json:"assignee_name"`
	PersonID     int64      `json:"person_id"`
	PersonName   string     `json:"person_name"`
	CreatedAt    time.Time  `json:"created_at"`
	Done         bool       `json:"done"`
	Marks        []Dau      `json:"marks"`
	HiddenAt     *time.Time `json:"hidden_at"`
	HiddenBy     *int64     `json:"hidden_by_person_id"`
	HiddenByName *string    `json:"hidden_by_name"`
}
type YeuCau struct {
	Content    string `json:"content"`
	AssigneeID int64  `json:"assignee_person_id"`
	Reason     string `json:"reason"`
}
type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }
func (s *Service) Tao(ctx context.Context, nguoi int64, p YeuCau) (out Viec, err error) {
	err = authz.Run(ctx, s.pool, nguoi, Tao, func(tx pgx.Tx) error {
		r := newRepository(tx)
		// Khoá ngoại kiểm người nhận trong chính giao dịch, dịch thành person_not_found.
		id, e := r.tao(ctx, p)
		if e != nil {
			return e
		}
		out, e = r.docViec(ctx, id)
		return e
	})
	return
}
func (s *Service) Sua(ctx context.Context, nguoi, id int64, p YeuCau) (out Viec, err error) {
	err = authz.Run(ctx, s.pool, nguoi, Sua, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, p.Reason, func() error { return r.sua(ctx, id, p) }); e != nil {
			return e
		}
		var e error
		out, e = r.docViec(ctx, id)
		return e
	})
	return
}
func (s *Service) An(ctx context.Context, nguoi, id int64, reason string) (out Viec, err error) {
	err = authz.Run(ctx, s.pool, nguoi, An, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.an(ctx, id) }); e != nil {
			return e
		}
		var e error
		out, e = r.docViec(ctx, id)
		return e
	})
	return
}
func (s *Service) DanhDau(ctx context.Context, nguoi, id int64, mark string) (out Viec, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DanhDau, func(tx pgx.Tx) error {
		r := newRepository(tx)
		// Khoá việc trước khi đọc sự kiện: hai lần bấm cùng việc phải xét lần lượt.
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		v, e := r.docViec(ctx, id)
		if e != nil {
			return e
		}
		if mark == "done" && v.Done {
			return apierr.Error{Code: apierr.CodeAssignedTaskAlreadyDone}
		}
		if mark == "undone" && !v.Done {
			return apierr.Error{Code: apierr.CodeAssignedTaskNotDone}
		}
		if e = r.danhDau(ctx, id, mark); e != nil {
			return e
		}
		out, e = r.docViec(ctx, id)
		return e
	})
	return
}
func (s *Service) Doc(ctx context.Context, nguoi, nhan int64, kemAn bool) (out []Viec, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedCounterOrOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).doc(ctx, 0, nhan, kemAn)
		return e
	})
	return
}
func (s *Service) ChiTiet(ctx context.Context, nguoi, id int64) (out Viec, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedCounterOrOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).docViec(ctx, id)
		return e
	})
	return
}
