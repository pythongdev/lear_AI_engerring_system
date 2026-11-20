package menu

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"io"
	"os"
	"path/filepath"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
)

var CapNhatAnh = authz.Door{Code: "menu/cap_nhat_anh", Need: authz.NeedOwner}

// WithFileDir dùng cùng kho tệp bền vững với hướng dẫn đào tạo.
func (s *Service) WithFileDir(dir string) *Service { s.kho = dir; return s }

func (s *Service) duongAnh(code string) string {
	return filepath.Join(s.kho, filepath.FromSlash(code))
}

func (s *Service) catAnh(data []byte, ext string) (string, error) {
	if s.kho == "" {
		return "", errors.New("thiếu kho tệp ảnh")
	}
	var random [16]byte
	if _, err := rand.Read(random[:]); err != nil {
		return "", err
	}
	code := "images/menu-items/" + hex.EncodeToString(random[:]) + ext
	dir := filepath.Join(s.kho, "images", "menu-items")
	if err := os.MkdirAll(dir, 0700); err != nil {
		return "", err
	}
	f, err := os.CreateTemp(dir, ".upload-")
	if err != nil {
		return "", err
	}
	defer os.Remove(f.Name())
	if _, err = io.Copy(f, bytes.NewReader(data)); err != nil {
		f.Close()
		return "", err
	}
	if err = f.Close(); err != nil {
		return "", err
	}
	if err = os.Rename(f.Name(), s.duongAnh(code)); err != nil {
		return "", err
	}
	return code, nil
}

func (s *Service) CapNhatAnh(ctx context.Context, actor, id int64, reason string, data []byte, ext string) error {
	var moi string
	err := authz.Run(ctx, s.pool, actor, CapNhatAnh, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		if err := khongThay(repo.timMon(ctx, id), apierr.CodeMenuItemNotFound); err != nil {
			return err
		}
		var err error
		moi, err = s.catAnh(data, ext)
		if err != nil {
			return err
		}
		if err = repo.khaiLyDo(ctx, strings.TrimSpace(reason)); err != nil {
			return err
		}
		return khongThay(repo.capNhatAnh(ctx, id, moi), apierr.CodeMenuItemNotFound)
	})
	if err != nil && moi != "" {
		err = errors.Join(err, os.Remove(s.duongAnh(moi)))
	}
	return err
}

func (s *Service) DocAnh(ctx context.Context, id int64) (*os.File, string, error) {
	code, err := s.docMaAnh(ctx, id)
	if err != nil {
		return nil, "", khongThay(err, apierr.CodeMenuItemNotFound)
	}
	if code == nil || *code == "" {
		return nil, "", apierr.Error{Code: apierr.CodeMenuItemImageMissing}
	}
	// Khoá do máy phát, ràng buộc DB cũng giới hạn định dạng đường dẫn.
	if !strings.HasPrefix(*code, "images/menu-items/") {
		return nil, "", errors.New("khoá ảnh không hợp lệ")
	}
	f, err := os.Open(s.duongAnh(*code))
	if errors.Is(err, os.ErrNotExist) {
		return nil, "", apierr.Error{Code: apierr.CodeMenuItemImageMissing}
	}
	if err != nil {
		return nil, "", err
	}
	switch filepath.Ext(*code) {
	case ".jpg":
		return f, "image/jpeg", nil
	case ".png":
		return f, "image/png", nil
	case ".webp":
		return f, "image/webp", nil
	default:
		f.Close()
		return nil, "", errors.New("đuôi ảnh không hợp lệ")
	}
}
