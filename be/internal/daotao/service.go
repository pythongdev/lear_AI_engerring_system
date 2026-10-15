// Package daotao giữ hướng dẫn và ghi nhận đào tạo (P3A-04, I-031).
package daotao

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"io"
	"os"
	"path/filepath"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var GanHuongDan = authz.Door{Code: "daotao/gan_huong_dan", Need: authz.NeedCounterOrOwner}
var SuaHuongDan = authz.Door{Code: "daotao/sua_huong_dan", Need: authz.NeedCounterOrOwner}
var AnHuongDan = authz.Door{Code: "daotao/an_huong_dan", Need: authz.NeedCounterOrOwner}
var GhiNhan = authz.Door{Code: "daotao/ghi_nhan", Need: authz.NeedCounterOrOwner}
var SuaGhiNhan = authz.Door{Code: "daotao/sua_ghi_nhan", Need: authz.NeedCounterOrOwner}
var AnGhiNhan = authz.Door{Code: "daotao/an_ghi_nhan", Need: authz.NeedCounterOrOwner}

type HuongDan struct {
	ID           int64      `json:"assigned_task_guide_id"`
	TaskID       int64      `json:"assigned_task_id"`
	Kind         string     `json:"kind"`
	Body         *string    `json:"body"`
	FileCode     *string    `json:"-"`
	PersonID     int64      `json:"person_id"`
	PersonName   string     `json:"person_name"`
	CreatedAt    time.Time  `json:"created_at"`
	HiddenAt     *time.Time `json:"hidden_at"`
	HiddenBy     *int64     `json:"hidden_by_person_id"`
	HiddenByName *string    `json:"hidden_by_name"`
}
type GhiNhanDaoTao struct {
	ID           int64      `json:"training_record_id"`
	TraineeID    int64      `json:"trainee_person_id"`
	TraineeName  string     `json:"trainee_name"`
	Remark       *string    `json:"remark"`
	Rating       *string    `json:"rating"`
	PersonID     int64      `json:"person_id"`
	PersonName   string     `json:"person_name"`
	CreatedAt    time.Time  `json:"created_at"`
	HiddenAt     *time.Time `json:"hidden_at"`
	HiddenBy     *int64     `json:"hidden_by_person_id"`
	HiddenByName *string    `json:"hidden_by_name"`
}
type YeuCau struct {
	TraineeID      int64
	Remark, Rating *string
	Reason         string
}
type Service struct {
	pool *pgxpool.Pool
	kho  string
}

func NewService(pool *pgxpool.Pool, kho string) *Service { return &Service{pool: pool, kho: kho} }

// Tệp đã được kiểm hình ở handler. Ghi tạm cùng thư mục, đóng rồi đổi tên trước giao dịch.
func (s *Service) catTep(src io.Reader, ext string) (key string, err error) {
	var random [16]byte
	if _, err = rand.Read(random[:]); err != nil {
		return
	}
	key = "guides/" + hex.EncodeToString(random[:]) + ext
	dir := filepath.Join(s.kho, "guides")
	if err = os.MkdirAll(dir, 0700); err != nil {
		return
	}
	f, e := os.CreateTemp(dir, ".upload-")
	if e != nil {
		return "", e
	}
	defer os.Remove(f.Name())
	_, err = io.Copy(f, src)
	closeErr := f.Close()
	if err != nil {
		return "", err
	}
	if closeErr != nil {
		return "", closeErr
	}
	err = os.Rename(f.Name(), s.duongTep(key))
	return
}
func (s *Service) duongTep(key string) string { return filepath.Join(s.kho, filepath.FromSlash(key)) }
func (s *Service) Gan(ctx context.Context, actor, task int64, kind string, body *string, src io.Reader, ext string) (out HuongDan, err error) {
	var key *string
	if src != nil {
		k, e := s.catTep(src, ext)
		if e != nil {
			return out, e
		}
		key = &k
	}
	err = authz.Run(ctx, s.pool, actor, GanHuongDan, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoaViec(ctx, task); e != nil {
			return e
		}
		id, e := r.gan(ctx, task, kind, body, key)
		if e != nil {
			return e
		}
		out, e = r.huongDan(ctx, id)
		return e
	})
	if err != nil && key != nil {
		err = errors.Join(err, os.Remove(s.duongTep(*key)))
	}
	return
}
func (s *Service) SuaHuongDan(ctx context.Context, actor, id int64, body, reason string) (out HuongDan, err error) {
	err = authz.Run(ctx, s.pool, actor, SuaHuongDan, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoaHuongDan(ctx, id, true); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.suaHuongDan(ctx, id, body) }); e != nil {
			return e
		}
		var e error
		out, e = r.huongDan(ctx, id)
		return e
	})
	return
}
func (s *Service) AnHuongDan(ctx context.Context, actor, id int64, reason string) (out HuongDan, err error) {
	err = authz.Run(ctx, s.pool, actor, AnHuongDan, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoaHuongDan(ctx, id, false); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.anHuongDan(ctx, id) }); e != nil {
			return e
		}
		var e error
		out, e = r.huongDan(ctx, id)
		return e
	})
	return
}
func (s *Service) DocHuongDan(ctx context.Context, actor, task int64, hidden bool) (out []HuongDan, err error) {
	err = authz.Read(ctx, s.pool, actor, authz.NeedCounterOrOwner, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.timViec(ctx, task); e != nil {
			return e
		}
		var e error
		out, e = r.docHuongDan(ctx, 0, task, hidden)
		return e
	})
	return
}
func (s *Service) Tep(ctx context.Context, actor, id int64) (out *os.File, err error) {
	var guide HuongDan
	err = authz.Read(ctx, s.pool, actor, authz.NeedCounterOrOwner, func(tx pgx.Tx) error {
		var e error
		guide, e = newRepository(tx).huongDan(ctx, id)
		return e
	})
	if err != nil {
		return
	}
	if guide.FileCode == nil {
		return nil, apierr.Error{Code: apierr.CodeAssignedTaskGuideFileMissing}
	}
	out, err = os.Open(s.duongTep(*guide.FileCode))
	if os.IsNotExist(err) {
		err = apierr.Error{Code: apierr.CodeAssignedTaskGuideFileMissing}
	}
	return
}
func (s *Service) Ghi(ctx context.Context, actor int64, p YeuCau) (out GhiNhanDaoTao, err error) {
	err = authz.Run(ctx, s.pool, actor, GhiNhan, func(tx pgx.Tx) error {
		r := newRepository(tx)
		id, e := r.ghi(ctx, p)
		if e != nil {
			return e
		}
		out, e = r.ghiNhan(ctx, id)
		return e
	})
	return
}
func (s *Service) SuaGhiNhan(ctx context.Context, actor, id int64, p YeuCau) (out GhiNhanDaoTao, err error) {
	err = authz.Run(ctx, s.pool, actor, SuaGhiNhan, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoaGhiNhan(ctx, id); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, p.Reason, func() error { return r.suaGhiNhan(ctx, id, p) }); e != nil {
			return e
		}
		var e error
		out, e = r.ghiNhan(ctx, id)
		return e
	})
	return
}
func (s *Service) AnGhiNhan(ctx context.Context, actor, id int64, reason string) (out GhiNhanDaoTao, err error) {
	err = authz.Run(ctx, s.pool, actor, AnGhiNhan, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoaGhiNhan(ctx, id); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.anGhiNhan(ctx, id) }); e != nil {
			return e
		}
		var e error
		out, e = r.ghiNhan(ctx, id)
		return e
	})
	return
}
func (s *Service) DocGhiNhan(ctx context.Context, actor, trainee int64, hidden bool) (out []GhiNhanDaoTao, err error) {
	err = authz.Read(ctx, s.pool, actor, authz.NeedCounterOrOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).docGhiNhan(ctx, 0, trainee, hidden)
		return e
	})
	return
}
