// Package danhmuc giữ danh mục và chỗ xếp món của chủ quán (P3A-05, I-032).
package danhmuc

import (
	"context"
	"errors"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var Them = authz.Door{Code: "danhmuc/them", Need: authz.NeedOwner}
var DoiTen = authz.Door{Code: "danhmuc/doi_ten", Need: authz.NeedOwner}
var An = authz.Door{Code: "danhmuc/an", Need: authz.NeedOwner}
var XepMon = authz.Door{Code: "danhmuc/xep_mon", Need: authz.NeedOwner}

type Mon struct {
	ID           int64  `json:"menu_item_id"`
	Name         string `json:"item_name"`
	Discontinued bool   `json:"discontinued"`
}
type DanhMuc struct {
	ID           int64      `json:"menu_category_id"`
	Name         string     `json:"name"`
	PersonID     int64      `json:"person_id"`
	PersonName   string     `json:"person_name"`
	CreatedAt    time.Time  `json:"created_at"`
	HiddenAt     *time.Time `json:"hidden_at"`
	HiddenBy     *int64     `json:"hidden_by_person_id"`
	HiddenByName *string    `json:"hidden_by_name"`
	Items        []Mon      `json:"items"`
}
type DanhSach struct {
	Categories         []DanhMuc `json:"categories"`
	UncategorizedItems []Mon     `json:"uncategorized_items"`
}
type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }
func (s *Service) Doc(ctx context.Context, nguoi int64, kemAn bool) (out DanhSach, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).doc(ctx, 0, kemAn)
		return e
	})
	return
}
func (s *Service) Them(ctx context.Context, nguoi int64, ten string) (out DanhMuc, err error) {
	err = authz.Run(ctx, s.pool, nguoi, Them, func(tx pgx.Tx) error {
		r := newRepository(tx)
		id, e := r.them(ctx, ten)
		if e != nil {
			return e
		}
		out, e = r.docDanhMuc(ctx, id)
		return e
	})
	return
}
func (s *Service) DoiTen(ctx context.Context, nguoi, id int64, ten, reason string) (out DanhMuc, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DoiTen, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.doiTen(ctx, id, ten) }); e != nil {
			return e
		}
		var e error
		out, e = r.docDanhMuc(ctx, id)
		return e
	})
	return
}
func (s *Service) An(ctx context.Context, nguoi, id int64, reason string) (out DanhMuc, err error) {
	err = authz.Run(ctx, s.pool, nguoi, An, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.an(ctx, id) }); e != nil {
			return e
		}
		var e error
		out, e = r.docDanhMuc(ctx, id)
		return e
	})
	return
}
func (s *Service) XepMon(ctx context.Context, nguoi, mon, dm int64, reason string) (out DanhMuc, err error) {
	err = authz.Run(ctx, s.pool, nguoi, XepMon, func(tx pgx.Tx) error {
		r := newRepository(tx)
		// Khoá món trước danh mục; hai lần xếp cùng món xét lần lượt cả khi chưa có dòng xếp.
		if e := r.khoaMon(ctx, mon); e != nil {
			return e
		}
		if e := r.khoa(ctx, dm); e != nil {
			return e
		}
		cu, e := r.docXep(ctx, mon)
		switch {
		case errors.Is(e, pgx.ErrNoRows):
			e = r.xep(ctx, mon, dm)
		case e != nil:
			return e
		case cu == dm:
			return apierr.Error{Code: apierr.CodeMenuItemAlreadyInCategory}
		default:
			// Ngoại lệ QC-14: chỉ biết reason bắt buộc sau khi đọc dòng xếp hiện có.
			if reason == "" {
				return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "reason"}
			}
			e = vongdoi.CoVet(ctx, tx, reason, func() error { return r.chuyen(ctx, mon, dm) })
		}
		if e != nil {
			return e
		}
		out, e = r.docDanhMuc(ctx, dm)
		return e
	})
	return
}

// XepMonMoiTrongGiaoDich dùng lại cửa xep_mon cho món vừa tạo. Bên gọi phải
// đã kiểm lớp chu_quan; không mở giao dịch thứ hai, không sửa dòng xếp đã có.
func XepMonMoiTrongGiaoDich(ctx context.Context, tx pgx.Tx, mon, dm int64) error {
	r := newRepository(tx)
	if e := r.khoaMon(ctx, mon); e != nil {
		return e
	}
	if e := r.khoa(ctx, dm); e != nil {
		return e
	}
	return r.xep(ctx, mon, dm)
}
