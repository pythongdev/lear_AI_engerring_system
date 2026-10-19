// Package menu giữ bốn cửa sửa menu của chủ quán (P3-06, I-011 · I-012 · I-018).
// Giá suất không có cửa sửa: nó là kết quả của gia.Tinh.
package menu

import (
	"context"
	"errors"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/danhmuc"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var DoiGiaThanhPhan = authz.Door{Code: "menu/doi_gia_thanh_phan", Need: authz.NeedOwner}
var DoiPhuThu = authz.Door{Code: "menu/doi_phu_thu", Need: authz.NeedOwner}
var SuaThanhPhan = authz.Door{Code: "menu/sua_thanh_phan", Need: authz.NeedOwner}
var NgungBan = authz.Door{Code: "menu/ngung_ban", Need: authz.NeedOwner}

// Service chạy mỗi cửa trong giao dịch của authz.Run: quyền, khoá dòng, lý do và câu ghi cùng một
// giao dịch (ADR-085). Hình yêu cầu đã được handler kiểm trước khi tới đây.
type Service struct {
	pool *pgxpool.Pool
}

func NewService(pool *pgxpool.Pool) *Service {
	return &Service{pool: pool}
}

type GiaThanhPhan struct {
	MenuComponentID int64
	BasePriceVnd    int64
}

type PhuThu struct {
	MenuOptionID int64
	SurchargeVnd int64
}

type ThanhPhanSuat struct {
	MenuItemID      int64
	MenuComponentID int64
	Quantity        int32
}

type MonNgungBan struct {
	MenuItemID     int64
	DiscontinuedAt string
}

func (s *Service) DoiGiaThanhPhan(ctx context.Context, nguoi, id, gia int64, lyDo string) (GiaThanhPhan, error) {
	var out GiaThanhPhan
	err := authz.Run(ctx, s.pool, nguoi, DoiGiaThanhPhan, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		if err := khongThay(repo.khoaThanhPhan(ctx, id), apierr.CodeMenuComponentNotFound); err != nil {
			return err
		}
		if err := repo.khaiLyDo(ctx, strings.TrimSpace(lyDo)); err != nil {
			return err
		}
		row, err := repo.doiGia(ctx, id, gia)
		out = GiaThanhPhan{MenuComponentID: row.ID, BasePriceVnd: row.BasePriceVnd}
		return err
	})
	return out, err
}

func (s *Service) DoiPhuThu(ctx context.Context, nguoi, id, phuThu int64, lyDo string) (PhuThu, error) {
	var out PhuThu
	err := authz.Run(ctx, s.pool, nguoi, DoiPhuThu, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		if err := khongThay(repo.khoaLuaChon(ctx, id), apierr.CodeMenuOptionNotFound); err != nil {
			return err
		}
		if err := repo.khaiLyDo(ctx, strings.TrimSpace(lyDo)); err != nil {
			return err
		}
		row, err := repo.doiPhuThu(ctx, id, phuThu)
		out = PhuThu{MenuOptionID: row.ID, SurchargeVnd: row.SurchargeVnd}
		return err
	})
	return out, err
}

func (s *Service) SuaThanhPhan(ctx context.Context, nguoi, monID, tpID int64, soLuong int32, lyDo string) (ThanhPhanSuat, error) {
	var out ThanhPhanSuat
	err := authz.Run(ctx, s.pool, nguoi, SuaThanhPhan, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		if err := khongThay(repo.timMon(ctx, monID), apierr.CodeMenuItemNotFound); err != nil {
			return err
		}
		if err := khongThay(repo.timThanhPhan(ctx, tpID), apierr.CodeMenuComponentNotFound); err != nil {
			return err
		}
		if err := khongThay(repo.khoaMonThanhPhan(ctx, monID, tpID), apierr.CodeMenuItemComponentNotFound); err != nil {
			return err
		}
		if err := repo.khaiLyDo(ctx, strings.TrimSpace(lyDo)); err != nil {
			return err
		}
		row, err := repo.suaSoLuong(ctx, monID, tpID, soLuong)
		out = ThanhPhanSuat{MenuItemID: row.MenuItemID, MenuComponentID: row.MenuComponentID, Quantity: row.Quantity}
		return err
	})
	return out, err
}

func (s *Service) NgungBan(ctx context.Context, nguoi, id int64, lyDo string) (MonNgungBan, error) {
	var out MonNgungBan
	err := authz.Run(ctx, s.pool, nguoi, NgungBan, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		daNgung, err := repo.khoaMonNgungBan(ctx, id)
		if err := khongThay(err, apierr.CodeMenuItemNotFound); err != nil {
			return err
		}
		// Đã có mốc thì không ghi đè, kể cả lần thứ hai bắt đầu trước lần thứ nhất hoàn tất.
		if daNgung {
			return apierr.Error{Code: apierr.CodeMenuItemDiscontinued}
		}
		if err := repo.khaiLyDo(ctx, strings.TrimSpace(lyDo)); err != nil {
			return err
		}
		row, err := repo.ngungBan(ctx, id)
		out = MonNgungBan{MenuItemID: row.ID, DiscontinuedAt: row.DiscontinuedAt}
		return err
	})
	return out, err
}

// khongThay đổi "không có dòng" thành mã lỗi của hợp đồng; lỗi khác giữ nguyên.
func khongThay(err error, code apierr.Code) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.Error{Code: code}
	}
	return err
}

var ThemMon = authz.Door{Code: "menu/them_mon", Need: authz.NeedOwner}
var DoiTenMon = authz.Door{Code: "menu/doi_ten", Need: authz.NeedOwner}

type Mon struct {
	MenuItemID int64  `json:"menu_item_id"`
	Name       string `json:"name"`
}
type ThanhPhanMoi struct {
	Name         string `json:"name"`
	BasePriceVnd *int64 `json:"base_price_vnd"`
	Quantity     int32  `json:"quantity"`
	TakesFilling *bool  `json:"takes_filling"`
}

func (s *Service) ThemMon(ctx context.Context, nguoi int64, ten string, dm int64, cac []ThanhPhanMoi) (out Mon, err error) {
	// Giữ nguyên tử cả với bên gọi nội bộ, không thể tạo món rỗng.
	if len(cac) == 0 {
		return out, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "components"}
	}
	err = authz.Run(ctx, s.pool, nguoi, ThemMon, func(tx pgx.Tx) error {
		r := newRepository(tx)
		var e error
		out, e = r.themMon(ctx, ten)
		if e != nil {
			return e
		}
		if e = danhmuc.XepMonMoiTrongGiaoDich(ctx, tx, out.MenuItemID, dm); e != nil {
			return e
		}
		for _, tp := range cac {
			if tp.BasePriceVnd == nil || tp.TakesFilling == nil {
				return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "components"}
			}
			if e = r.themThanhPhan(ctx, out.MenuItemID, tp); e != nil {
				return e
			}
		}
		return nil
	})
	return
}
func (s *Service) DoiTenMon(ctx context.Context, nguoi, id int64, ten, lyDo string) (out Mon, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DoiTenMon, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if _, e := r.khoaMonNgungBan(ctx, id); e != nil {
			return khongThay(e, apierr.CodeMenuItemNotFound)
		}
		if e := r.khaiLyDo(ctx, strings.TrimSpace(lyDo)); e != nil {
			return e
		}
		var e error
		out, e = r.doiTenMon(ctx, id, ten)
		return e
	})
	return
}

// --- T-210: topping (master_plan/shop-facts.md §8.9 *QUẢN LÝ TOPPING*) ------------------------

var ThemLuaChon = authz.Door{Code: "menu/them_lua_chon", Need: authz.NeedOwner}

// AnLuaChon là cửa của cả ẩn lẫn bật lại: hai đường gọi, một ô ghi (Gate 1f).
var AnLuaChon = authz.Door{Code: "menu/an_lua_chon", Need: authz.NeedOwner}

type LuaChonMoi struct {
	MenuOptionID  int64  `json:"menu_option_id"`
	OptionGroupID int64  `json:"option_group_id"`
	Name          string `json:"name"`
	SurchargeVnd  int64  `json:"surcharge_vnd"`
}

func (s *Service) DocNhom(ctx context.Context, nguoi int64) (out []NhomLuaChon, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).docNhom(ctx)
		return e
	})
	return
}

// ThemLuaChon thêm một lựa chọn không mặc định vào nhóm có sẵn; moNhom là các nhóm chủ quán tích cho lựa chọn mở
// (luật 3 §4.6). Nhóm mở phải là nhóm khác và có thật — sai thì invalid_request trên enables_option_group_ids.
func (s *Service) ThemLuaChon(ctx context.Context, nguoi, nhom int64, ten string, phuThu int64, moNhom []int64) (out LuaChonMoi, err error) {
	err = authz.Run(ctx, s.pool, nguoi, ThemLuaChon, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if e := khongThay(r.khoaNhom(ctx, nhom), apierr.CodeOptionGroupNotFound); e != nil {
			return e
		}
		da := map[int64]bool{}
		for _, g := range moNhom {
			if g == nhom || da[g] {
				return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "enables_option_group_ids"}
			}
			da[g] = true
			if e := r.khoaNhom(ctx, g); e != nil {
				if errors.Is(e, pgx.ErrNoRows) {
					return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "enables_option_group_ids"}
				}
				return e
			}
		}
		row, e := r.themLuaChon(ctx, nhom, ten, phuThu)
		if e != nil {
			return e
		}
		for _, g := range moNhom {
			if e := r.themDieuKien(ctx, g, row.ID); e != nil {
				return e
			}
		}
		out = LuaChonMoi{MenuOptionID: row.ID, OptionGroupID: row.OptionGroupID, Name: row.Name, SurchargeVnd: row.SurchargeVnd}
		return nil
	})
	return
}

// AnLuaChon · BoAnLuaChon: lý do bắt buộc, đi qua vết (I-018). Lựa chọn mặc định của nhóm không ẩn được (§8.9, cách đọc).
func (s *Service) AnLuaChon(ctx context.Context, nguoi, id int64, lyDo string) (out PhuThu, err error) {
	return s.doiAn(ctx, nguoi, id, lyDo, true)
}

func (s *Service) BoAnLuaChon(ctx context.Context, nguoi, id int64, lyDo string) (out PhuThu, err error) {
	return s.doiAn(ctx, nguoi, id, lyDo, false)
}

func (s *Service) doiAn(ctx context.Context, nguoi, id int64, lyDo string, an bool) (out PhuThu, err error) {
	err = authz.Run(ctx, s.pool, nguoi, AnLuaChon, func(tx pgx.Tx) error {
		r := newRepository(tx)
		row, e := r.khoaLuaChonAn(ctx, id)
		if e := khongThay(e, apierr.CodeMenuOptionNotFound); e != nil {
			return e
		}
		switch {
		case an && row.DaAn:
			return apierr.Error{Code: apierr.CodeMenuOptionHidden}
		case an && row.IsDefault:
			return apierr.Error{Code: apierr.CodeMenuOptionIsDefault}
		case !an && !row.DaAn:
			return apierr.Error{Code: apierr.CodeMenuOptionNotHidden}
		}
		if e := r.khaiLyDo(ctx, strings.TrimSpace(lyDo)); e != nil {
			return e
		}
		out = PhuThu{MenuOptionID: id}
		return r.datAnLuaChon(ctx, id, an)
	})
	return
}
