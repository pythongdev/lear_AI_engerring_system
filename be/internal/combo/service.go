// Package combo giữ combo có giá riêng của chủ quán (P3A-06, I-032) và mức phụ thu theo món của combo (T-194, I-034).
package combo

import (
	"context"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var Them = authz.Door{Code: "combo/them", Need: authz.NeedOwner}
var DoiGia = authz.Door{Code: "combo/doi_gia", Need: authz.NeedOwner}
var An = authz.Door{Code: "combo/an", Need: authz.NeedOwner}
var DatMuc = authz.Door{Code: "combo/dat_muc", Need: authz.NeedOwner}

type Mon struct {
	Quantity     int32  `json:"quantity"`
	ID           int64  `json:"menu_item_id"`
	Name         string `json:"item_name"`
	Discontinued bool   `json:"discontinued"`
	Surcharges   []Muc  `json:"surcharges"`
}

// Muc là mức chủ quán đặt cho một lựa chọn của một món trong combo; cặp chưa đặt không có mặt (0đ, U-096).
type Muc struct {
	SurchargeVND    int64  `json:"surcharge_vnd"`
	MenuOptionID    int64  `json:"menu_option_id"`
	OptionGroupName string `json:"option_group_name"`
	OptionName      string `json:"option_name"`
}
type MenuCombo struct {
	PriceVND     int64      `json:"price_vnd"`
	ID           int64      `json:"menu_combo_id"`
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
	Combos []MenuCombo `json:"combos"`
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
func (s *Service) Them(ctx context.Context, nguoi int64, ten string, gia int64, items []ThanhPhan) (out MenuCombo, err error) {
	err = authz.Run(ctx, s.pool, nguoi, Them, func(tx pgx.Tx) error {
		r := newRepository(tx)
		for i, item := range items {
			if e := r.kiemMon(ctx, item.MenuItemID, i); e != nil {
				return e
			}
		}
		id, e := r.them(ctx, ten, gia)
		if e != nil {
			return e
		}
		for _, item := range items {
			if e := r.themMon(ctx, id, item); e != nil {
				return e
			}
		}
		out, e = r.docMenuCombo(ctx, id)
		return e
	})
	return
}
func (s *Service) DoiGia(ctx context.Context, nguoi, id, gia int64, reason string) (out MenuCombo, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DoiGia, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		moc, e := ngayban.DongHo(ctx, tx)
		if e != nil {
			return e
		}
		ngoai, e := ngayban.NgoaiGio(ctx, tx, moc)
		if e != nil {
			return e
		}
		if !ngoai {
			return apierr.Error{Code: apierr.CodeMenuComboPriceInSalesHours}
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.doiGia(ctx, id, gia) }); e != nil {
			return e
		}
		out, e = r.docMenuCombo(ctx, id)
		return e
	})
	return
}
func (s *Service) An(ctx context.Context, nguoi, id int64, reason string) (out MenuCombo, err error) {
	err = authz.Run(ctx, s.pool, nguoi, An, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error { return r.an(ctx, id) }); e != nil {
			return e
		}
		var e error
		out, e = r.docMenuCombo(ctx, id)
		return e
	})
	return
}

// ThanhPhan giữ thứ tự món gửi khi lập combo.
type ThanhPhan struct {
	MenuItemID int64 `json:"menu_item_id"`
	Quantity   int32 `json:"quantity"`
}

// MucDat là một cặp món · lựa chọn và mức muốn đặt.
type MucDat struct {
	MenuItemID   int64
	MenuOptionID int64
	SurchargeVND int64
}

// DatMuc đặt mức phụ thu theo món của combo: khoá như giá combo — chỉ ngoài giờ bán, có lý do (lượt tám, ADR-117 điểm 6).
func (s *Service) DatMuc(ctx context.Context, nguoi, id int64, reason string, cac []MucDat) (out MenuCombo, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DatMuc, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := r.khoa(ctx, id); e != nil {
			return e
		}
		moc, e := ngayban.DongHo(ctx, tx)
		if e != nil {
			return e
		}
		ngoai, e := ngayban.NgoaiGio(ctx, tx, moc)
		if e != nil {
			return e
		}
		if !ngoai {
			return apierr.Error{Code: apierr.CodeMenuComboSurchargeInSalesHours}
		}
		if e := vongdoi.CoVet(ctx, tx, reason, func() error {
			for i, m := range cac {
				if e := r.datMuc(ctx, id, i, m); e != nil {
					return e
				}
			}
			return nil
		}); e != nil {
			return e
		}
		out, e = r.docMenuCombo(ctx, id)
		return e
	})
	return
}
