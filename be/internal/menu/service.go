// Package menu giữ bốn cửa sửa menu của chủ quán (P3-06, I-011 · I-012 · I-018).
// Giá suất không có cửa sửa: nó là kết quả của gia.Tinh.
package menu

import (
	"context"
	"errors"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
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
