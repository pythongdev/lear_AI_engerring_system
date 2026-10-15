// Package nguyenlieu giữ sổ con số do chủ quán nhập (P3A-02, I-025 · I-026).
package nguyenlieu

import (
	"context"
	"errors"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ThemThu = authz.Door{Code: "nguyenlieu/them_thu", Need: authz.NeedOwner}
var DatDonVi = authz.Door{Code: "nguyenlieu/dat_don_vi", Need: authz.NeedOwner}
var GhiSo = authz.Door{Code: "nguyenlieu/ghi_so", Need: authz.NeedOwner}
var SuaSo = authz.Door{Code: "nguyenlieu/sua_so", Need: authz.NeedOwner}

type Thu struct {
	ID             int64   `json:"supply_item_id"`
	Name           string  `json:"name"`
	PurchaseUnit   *string `json:"purchase_unit"`
	PurchasedTotal string  `json:"purchased_total"`
	UsedTotal      string  `json:"used_total"`
	Balance        string  `json:"balance"`
}
type ConSo struct {
	ID         int64     `json:"supply_day_entry_id"`
	ItemID     int64     `json:"supply_item_id"`
	EntryDate  string    `json:"entry_date"`
	Kind       string    `json:"kind"`
	Measure    string    `json:"measure"`
	PersonID   int64     `json:"person_id"`
	PersonName string    `json:"person_name"`
	CreatedAt  time.Time `json:"created_at"`
}
type ChiTiet struct {
	Thu
	Entries []ConSo `json:"entries"`
}
type YeuCau struct {
	ItemID    int64  `json:"supply_item_id"`
	EntryDate string `json:"entry_date"`
	Kind      string `json:"kind"`
	Measure   string `json:"measure"`
	Reason    string `json:"reason"`
}
type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func (s *Service) Them(ctx context.Context, nguoi int64, ten, donVi string) (out Thu, err error) {
	err = authz.Run(ctx, s.pool, nguoi, ThemThu, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		id, e := repo.them(ctx, ten, donVi)
		if e != nil {
			return e
		}
		out, e = repo.docThu(ctx, id)
		return e
	})
	return
}
func (s *Service) Dat(ctx context.Context, nguoi, id int64, donVi string) (out Thu, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DatDonVi, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		daCo, e := repo.khoaThu(ctx, id)
		if errors.Is(e, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodeSupplyItemNotFound}
		}
		if e != nil {
			return e
		}
		if daCo {
			return apierr.Error{Code: apierr.CodeSupplyItemUnitAlreadySet}
		}
		if e = vongdoi.CoVet(ctx, tx, "nguyenlieu/dat_don_vi: đặt đơn vị lần đầu", func() error { return repo.dat(ctx, id, donVi) }); e != nil {
			return e
		}
		out, e = repo.docThu(ctx, id)
		return e
	})
	return
}
func (s *Service) Ghi(ctx context.Context, nguoi int64, p YeuCau) (out ConSo, err error) {
	err = authz.Run(ctx, s.pool, nguoi, GhiSo, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		moc, e := ngayban.DongHo(ctx, tx)
		if e != nil {
			return e
		}
		future, e := repo.ngayTuongLai(ctx, p.EntryDate, moc)
		if e != nil {
			return e
		}
		if future {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "entry_date"}
		}
		// Khoá ngoại ánh xạ sang supply_item_not_found trong cùng giao dịch ghi.
		id, e := repo.ghi(ctx, p)
		if e != nil {
			return e
		}
		out, e = repo.docConSo(ctx, id)
		return e
	})
	return
}
func (s *Service) Sua(ctx context.Context, nguoi, id int64, p YeuCau) (out ConSo, err error) {
	err = authz.Run(ctx, s.pool, nguoi, SuaSo, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		e := repo.khoaSo(ctx, id)
		if errors.Is(e, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodeSupplyDayEntryNotFound}
		}
		if e != nil {
			return e
		}
		if e = vongdoi.CoVet(ctx, tx, p.Reason, func() error { return repo.sua(ctx, id, p.Measure) }); e != nil {
			return e
		}
		out, e = repo.docConSo(ctx, id)
		return e
	})
	return
}
func (s *Service) Doc(ctx context.Context, nguoi int64) (out []Thu, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).doc(ctx, 0)
		return e
	})
	return
}
func (s *Service) DocChiTiet(ctx context.Context, nguoi, id int64) (out ChiTiet, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		var e error
		out.Thu, e = repo.docThu(ctx, id)
		if e != nil {
			return e
		}
		out.Entries, e = repo.docSo(ctx, id, 0)
		return e
	})
	return
}
