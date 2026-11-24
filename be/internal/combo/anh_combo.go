package combo

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/anh"
	"banhcuon/be/internal/vongdoi"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
	"os"
	"strings"
)

var CapNhatAnh = authz.Door{Code: "combo/cap_nhat_anh", Need: authz.NeedOwner}

func (s *Service) WithFileDir(dir string) *Service { s.kho = dir; return s }

func (s *Service) CapNhatAnh(ctx context.Context, actor, id int64, reason string, data []byte, ext string) (out MenuCombo, err error) {
	var moi string
	err = authz.Run(ctx, s.pool, actor, CapNhatAnh, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if err := r.khoa(ctx, id); err != nil {
			return err
		}
		var err error
		moi, err = anh.Cat(s.kho, "menu-combos", data, ext)
		if err != nil {
			return err
		}
		if err = vongdoi.CoVet(ctx, tx, strings.TrimSpace(reason), func() error { return r.capNhatAnh(ctx, id, moi) }); err != nil {
			return err
		}
		out, err = r.docMenuCombo(ctx, id)
		return err
	})
	if err != nil && moi != "" {
		err = errors.Join(err, os.Remove(anh.Duong(s.kho, moi)))
	}
	return
}

func (s *Service) DocAnh(ctx context.Context, id int64) (*os.File, string, error) {
	key, err := s.docMaAnh(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, "", apierr.Error{Code: apierr.CodeMenuComboNotFound}
	}
	if err != nil {
		return nil, "", err
	}
	return anh.Doc(s.kho, "menu-combos", key, apierr.CodeMenuComboImageMissing)
}
