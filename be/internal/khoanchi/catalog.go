package khoanchi

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/nguyenlieu"
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
var ChuyenMuc = authz.Door{Code: "khoanchi/chuyen_muc", Need: authz.NeedOwner}

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
func (s *Service) TaoKhoanCon(ctx context.Context, actor, category int64, name *string, supply *int64) (out KhoanCon, err error) {
	err = authz.Run(ctx, s.pool, actor, ThemKhoanCon, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		loai, e := repo.timLoai(ctx, category)
		if e != nil {
			return notFound(e, apierr.CodeExpenseCategoryNotFound)
		}
		if loai.TracksSupply && supply == nil || !loai.TracksSupply && supply != nil {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "supply_item_id"}
		}
		if loai.TracksSupply && name != nil {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "name"}
		}
		if !loai.TracksSupply && (name == nil || *name == "") {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "name"}
		}
		actualName := ""
		if name != nil {
			actualName = *name
		}
		if supply != nil {
			var stopped, linked bool
			actualName, stopped, linked, e = nguyenlieu.XemThu(ctx, tx, *supply)
			if e != nil {
				return e
			}
			// Báo "đã nối" trước khi khoá duy nhất tên khoản con trong mục kịp nói "trùng tên" (KC-06).
			if linked {
				return apierr.Error{Code: apierr.CodeSupplyItemAlreadyLinked}
			}
			if stopped {
				return apierr.Error{Code: apierr.CodeSupplyItemStopped}
			}
		}
		out, e = repo.themCon(ctx, category, actualName, supply)
		return e
	})
	return
}
func (s *Service) DoiTenKhoanCon(ctx context.Context, actor, id int64, name, reason string) (out KhoanCon, err error) {
	err = authz.Run(ctx, s.pool, actor, SuaKhoanCon, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		con, e := repo.khoaCon(ctx, id)
		if e != nil {
			return notFound(e, apierr.CodeExpenseItemNotFound)
		}
		if con.Stopped {
			return apierr.Error{Code: apierr.CodeExpenseItemNotFound}
		}
		return vongdoi.CoVet(ctx, tx, reason, func() error {
			out, e = repo.doiTenCon(ctx, id, name)
			if e != nil {
				return e
			}
			if con.SupplyItemID.Valid {
				return nguyenlieu.DoiTenTrongGiaoDich(ctx, tx, con.SupplyItemID.Int64, name)
			}
			return nil
		})
	})
	return
}
func (s *Service) XoaCon(ctx context.Context, actor, id int64, reason string) error {
	return authz.Run(ctx, s.pool, actor, XoaDanhMuc, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		con, err := repo.khoaCon(ctx, id)
		if err != nil {
			return notFound(err, apierr.CodeExpenseItemNotFound)
		}
		if con.Stopped {
			return apierr.Error{Code: apierr.CodeExpenseItemNotFound}
		}
		if con.SupplyItemID.Valid {
			return vongdoi.CoVet(ctx, tx, reason, func() error {
				if err := repo.xoaCon(ctx, id); err != nil {
					return err
				}
				return nguyenlieu.NgungTrongGiaoDich(ctx, tx, con.SupplyItemID.Int64)
			})
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

func (s *Service) MoKhoanCon(ctx context.Context, actor, id int64, reason string) (out KhoanCon, err error) {
	err = authz.Run(ctx, s.pool, actor, XoaDanhMuc, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		con, e := repo.khoaCon(ctx, id)
		if e != nil {
			return notFound(e, apierr.CodeExpenseItemNotFound)
		}
		if !con.Stopped || !con.SupplyItemID.Valid {
			return apierr.Error{Code: apierr.CodeExpenseItemNotStopped}
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error {
			if err := repo.moCon(ctx, id); err != nil {
				return err
			}
			return nguyenlieu.MoTrongGiaoDich(ctx, tx, con.SupplyItemID.Int64)
		}); e != nil {
			return e
		}
		out, e = repo.docCon(ctx, id)
		return e
	})
	return
}

func (s *Service) ChuyenKhoanCon(ctx context.Context, actor, id, dest int64, reason string) (out KhoanCon, err error) {
	err = authz.Run(ctx, s.pool, actor, ChuyenMuc, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		con, e := repo.khoaCon(ctx, id)
		if e != nil {
			return notFound(e, apierr.CodeExpenseItemNotFound)
		}
		if con.Stopped {
			return apierr.Error{Code: apierr.CodeExpenseItemNotFound}
		}
		to, e := repo.timLoai(ctx, dest)
		if e != nil {
			return notFound(e, apierr.CodeExpenseCategoryNotFound)
		}
		from, e := repo.timLoai(ctx, con.ExpenseCategoryID)
		if e != nil {
			return e
		}
		if !con.SupplyItemID.Valid || !to.TracksSupply || !from.TracksSupply || to.PaidFromTill != from.PaidFromTill {
			return apierr.Error{Code: apierr.CodeExpenseItemMoveNotAllowed}
		}
		rows, e := repo.khoaCacKhoan(ctx, id)
		if e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error {
			if err := repo.chuyenMuc(ctx, id, dest); err != nil {
				return err
			}
			for _, row := range rows {
				date := ngayHoacNil(row.ReceivedDate)
				if err := repo.sua(ctx, row.ID, YeuCau{CategoryID: dest, ItemID: &id, Amount: row.AmountVnd, PaidDate: row.PaidDate, ReceivedDate: date}); err != nil {
					return err
				}
			}
			return nil
		}); e != nil {
			return e
		}
		out, e = repo.docCon(ctx, id)
		return e
	})
	return
}

type KetQuaThemThu struct {
	SupplyItem  nguyenlieu.Thu `json:"supply_item"`
	ExpenseItem KhoanCon       `json:"expense_item"`
	Expense     *Khoan         `json:"expense"`
}

func (s *Service) ThemThuKemTien(ctx context.Context, actor, category int64, name, unit string, expense *YeuCau, measure *string) (out KetQuaThemThu, err error) {
	err = authz.Run(ctx, s.pool, actor, ThemKhoanCon, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		loai, e := repo.timLoai(ctx, category)
		if e != nil {
			return notFound(e, apierr.CodeExpenseCategoryNotFound)
		}
		if !loai.TracksSupply {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "expense_category_id"}
		}
		if measure != nil && expense == nil {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "purchased_measure"}
		}
		out.SupplyItem, e = nguyenlieu.TaoThu(ctx, tx, name, unit)
		if e != nil {
			return e
		}
		id := out.SupplyItem.ID
		out.ExpenseItem, e = repo.themCon(ctx, category, name, &id)
		if e != nil {
			return e
		}
		if expense != nil {
			expense.CategoryID = category
			expense.ItemID = &out.ExpenseItem.ID
			expense.PurchasedMeasure = measure
			var k Khoan
			k, e = ghiTrongGiaoDich(ctx, tx, *expense)
			if e != nil {
				return e
			}
			out.Expense = &k
		}
		out.SupplyItem, e = nguyenlieu.DocThuTrongGiaoDich(ctx, tx, id)
		return e
	})
	return
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
