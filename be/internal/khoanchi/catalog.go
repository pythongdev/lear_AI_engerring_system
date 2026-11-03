package khoanchi

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
)

var SuaLoai = authz.Door{Code: "khoanchi/sua_loai", Need: authz.NeedOwner}
var XoaDanhMuc = authz.Door{Code: "khoanchi/xoa_danh_muc", Need: authz.NeedOwner}
var ThemKhoanCon = authz.Door{Code: "khoanchi/them_khoan_con", Need: authz.NeedOwner}
var SuaKhoanCon = authz.Door{Code: "khoanchi/sua_khoan_con", Need: authz.NeedOwner}
var Xoa = authz.Door{Code: "khoanchi/xoa", Need: authz.NeedOwner}

func notFound(err error, code apierr.Code) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.Error{Code: code}
	}
	return err
}
func (s *Service) DoiTenLoai(ctx context.Context, actor, id int64, name, reason string) (out Loai, err error) {
	err = authz.Run(ctx, s.pool, actor, SuaLoai, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		return vongdoi.CoVet(ctx, tx, reason, func() error {
			var e error
			out, e = repo.doiTenLoai(ctx, id, name)
			return notFound(e, apierr.CodeExpenseCategoryNotFound)
		})
	})
	return
}
func (s *Service) XoaLoaiChi(ctx context.Context, actor, id int64, reason string) error {
	return authz.Run(ctx, s.pool, actor, XoaDanhMuc, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		if err := repo.khoaLoai(ctx, id); err != nil {
			return notFound(err, apierr.CodeExpenseCategoryNotFound)
		}
		used, err := repo.loaiDangDung(ctx, id)
		if err != nil {
			return err
		}
		if used {
			return apierr.Error{Code: apierr.CodeExpenseCategoryInUse}
		}
		return vongdoi.CoVet(ctx, tx, reason, func() error {
			return repo.xoaLoai(ctx, id)
		})
	})
}
func (s *Service) TaoKhoanCon(ctx context.Context, actor, category int64, name string) (out KhoanCon, err error) {
	err = authz.Run(ctx, s.pool, actor, ThemKhoanCon, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		if _, e := repo.timLoai(ctx, category); e != nil {
			return notFound(e, apierr.CodeExpenseCategoryNotFound)
		}
		var e error
		out, e = repo.themCon(ctx, category, name)
		return e
	})
	return
}
func (s *Service) DoiTenKhoanCon(ctx context.Context, actor, id int64, name, reason string) (out KhoanCon, err error) {
	err = authz.Run(ctx, s.pool, actor, SuaKhoanCon, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		return vongdoi.CoVet(ctx, tx, reason, func() error {
			var e error
			out, e = repo.doiTenCon(ctx, id, name)
			return notFound(e, apierr.CodeExpenseItemNotFound)
		})
	})
	return
}
func (s *Service) XoaCon(ctx context.Context, actor, id int64, reason string) error {
	return authz.Run(ctx, s.pool, actor, XoaDanhMuc, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		if err := repo.khoaCon(ctx, id); err != nil {
			return notFound(err, apierr.CodeExpenseItemNotFound)
		}
		used, err := repo.conDangDung(ctx, id)
		if err != nil {
			return err
		}
		if used {
			return apierr.Error{Code: apierr.CodeExpenseItemInUse}
		}
		return vongdoi.CoVet(ctx, tx, reason, func() error { return repo.xoaCon(ctx, id) })
	})
}
func (s *Service) XoaKhoan(ctx context.Context, actor, id int64, reason string) error {
	return authz.Run(ctx, s.pool, actor, Xoa, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		date, _, err := repo.khoaKhoan(ctx, id)
		if err != nil {
			return notFound(err, apierr.CodeExpenseNotFound)
		}
		// Chủ repo 2026-10-24: cả tiền riêng cũng không xoá ngày đã đối soát.
		if err = khoaNgay(ctx, tx, []string{date}); err != nil {
			return err
		}
		return vongdoi.CoVet(ctx, tx, reason, func() error { return repo.xoa(ctx, id) })
	})
}
