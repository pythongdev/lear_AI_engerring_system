// Package ket khai tiền đầu két, đếm và chủ quán ký ngày kèm giải thích khi lệch (ADR-089).
package ket

import (
	"context"
	"errors"
	"fmt"
	"math"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var KhaiDauKet = authz.Door{Code: "ket/khai_dau_ket", Need: authz.NeedCounterOrOwner}
var KhaiSoGiay = authz.Door{Code: "ket/khai_so_giay", Need: authz.NeedCounterOrOwner}
var SuaDem = authz.Door{Code: "ket/sua_dem", Need: authz.NeedOwner}
var GhiDongDem = authz.Door{Code: "ket/ghi_dong_dem", Need: authz.NeedCallingDoor}
var Dem = authz.Door{Code: "ket/dem", Need: authz.NeedCounterOrOwner}
var DoiSoatXong = authz.Door{Code: "ket/doi_soat_xong", Need: authz.NeedOwner}

type Dong struct {
	Denomination *int64 `json:"denomination_vnd"`
	Amount       *int64 `json:"amount_vnd"`
}
type YeuCau struct {
	Lines []Dong `json:"lines"`
}

func (p YeuCau) Kiem() (int64, error) {
	bad := func(f string) (int64, error) { return 0, apierr.Error{Code: apierr.CodeInvalidRequest, Field: f} }
	if len(p.Lines) == 0 {
		return bad("lines")
	}
	seen := map[int64]bool{}
	var total int64
	for i, l := range p.Lines {
		f := fmt.Sprintf("lines[%d].", i)
		if l.Denomination == nil || *l.Denomination <= 0 {
			return bad(f + "denomination_vnd")
		}
		if seen[*l.Denomination] {
			return bad(f + "denomination_vnd")
		}
		seen[*l.Denomination] = true
		if l.Amount == nil || *l.Amount < 0 || *l.Amount%*l.Denomination != 0 || *l.Amount > math.MaxInt64-total {
			return bad(f + "amount_vnd")
		}
		total += *l.Amount
	}
	return total, nil
}

type MoLai struct {
	Reason    string    `json:"reason"`
	PersonID  int64     `json:"person_id"`
	CreatedAt time.Time `json:"created_at"`
}
type Dau struct {
	ID          int64     `json:"reconciled_day_id"`
	PreviousID  *int64    `json:"previous_reconciled_day_id"`
	PersonID    int64     `json:"person_id"`
	CreatedAt   time.Time `json:"created_at"`
	Gap         int64     `json:"gap_vnd"`
	Explanation *string   `json:"gap_explanation"`
	Reopening   *MoLai    `json:"reopening"`
}
type SoKet struct {
	Status               *string `json:"status"`
	Reconciliations      []Dau   `json:"reconciliations"`
	PaperEntriesDeclared *int32  `json:"paper_entries_declared"`
	PaperEntriesPending  int64   `json:"paper_entries_pending"`
	SaleDate             string  `json:"sale_date"`
	Counted              int64   `json:"counted_vnd"`
	Opening              int64   `json:"opening_float_vnd"`
	Expected             int64   `json:"expected_vnd"`
	Gap                  int64   `json:"gap_vnd"`
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

// GhiSo chạy cửa khai_dau_ket (dem = false) hoặc dem (dem = true); p đã qua Kiem ở handler.
func (s *Service) GhiSo(ctx context.Context, nguoi int64, dem bool, p YeuCau) (id int64, ngay string, err error) {
	cua := KhaiDauKet
	if dem {
		cua = Dem
	}
	err = authz.Run(ctx, s.pool, nguoi, cua, func(tx pgx.Tx) error {
		moc, d, err := ngayban.ChoGhi(ctx, tx)
		if err != nil {
			return err
		}
		ngay = d
		id, err = newRepository(tx).ghiSo(ctx, dem, moc, p.Lines)
		if err == nil && dem {
			err = ghiDongDem(ctx, tx, id, p.Lines)
		}
		return err
	})
	return id, ngay, err
}

func docSo(ctx context.Context, tx pgx.Tx, ngay string) (SoKet, error) {
	s := SoKet{SaleDate: ngay}
	var err error
	s.Counted, s.Opening, s.Expected, err = newRepository(tx).ketNgay(ctx, ngay)
	if errors.Is(err, pgx.ErrNoRows) {
		err = apierr.Error{Code: apierr.CodeCashDayIncomplete}
	}
	if err == nil {
		s.PaperEntriesDeclared, s.PaperEntriesPending, err = newRepository(tx).soGiay(ctx, ngay)
	}
	s.Gap = s.Counted - s.Opening - s.Expected
	return s, err
}

func (s *Service) DocSo(ctx context.Context, ngay string) (SoKet, error) {
	var so SoKet
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		// Cùng khoá ngày với cửa sửa/ký để các lần đọc không trộn hai đời dấu.
		if err = ngayban.Khoa(ctx, tx, ngay, false); err != nil {
			return err
		}
		so, err = docSo(ctx, tx, ngay)
		if err != nil {
			return err
		}
		so.Reconciliations, err = newRepository(tx).docDau(ctx, ngay)
		if err == nil && len(so.Reconciliations) > 0 {
			status := "reconciled"
			if so.Reconciliations[len(so.Reconciliations)-1].Reopening != nil {
				status = "reopened"
			}
			so.Status = &status
		}
		return err
	})
	return so, err
}

// KyNgay chạy cửa doi_soat_xong: khoá riêng ngày trước khi đọc số, để không lần ghi tiền nào lọt vào giữa.
func (s *Service) KyNgay(ctx context.Context, nguoi int64, ngay string, explanation *string) (id, gap int64, err error) {
	err = authz.Run(ctx, s.pool, nguoi, DoiSoatXong, func(tx pgx.Tx) error {
		if err := ngayban.Khoa(ctx, tx, ngay, true); err != nil {
			return err
		}
		so, err := docSo(ctx, tx, ngay)
		if err != nil {
			return err
		}
		dau, err := newRepository(tx).docDau(ctx, ngay)
		if err != nil {
			return err
		}
		var previous *int64
		if len(dau) > 0 {
			cuoi := dau[len(dau)-1]
			if cuoi.Reopening == nil {
				return apierr.Error{Code: apierr.CodeSaleDayAlreadyReconciled}
			}
			previous = &cuoi.ID
		}
		repo := newRepository(tx)
		if so.PaperEntriesPending > 0 {
			return apierr.Error{Code: apierr.CodePaperEntriesPending}
		}
		gap = so.Gap
		if gap != 0 && explanation == nil {
			return apierr.Error{Code: apierr.CodeGapExplanationRequired}
		}
		id, err = repo.themKyNgay(ctx, ngay, gap, explanation, previous)
		return err
	})
	return id, gap, err
}

// KhaiGiay giữ khoá chung của NGÀY KHAI, kể cả khi nhập sổ của ngày trước.
func (s *Service) KhaiGiay(ctx context.Context, nguoi int64, ngay string, so int32) (id int64, err error) {
	err = authz.Run(ctx, s.pool, nguoi, KhaiSoGiay, func(tx pgx.Tx) error {
		moc, err := ngayban.DongHo(ctx, tx)
		if err != nil {
			return err
		}
		repo := newRepository(tx)
		tuongLai, err := repo.ngayTuongLai(ctx, ngay, moc)
		if err != nil {
			return err
		}
		if tuongLai {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sale_date"}
		}
		if err := ngayban.Khoa(ctx, tx, ngay, false); err != nil {
			return err
		}
		daKy, err := ngayban.DaKy(ctx, tx, ngay)
		if err != nil {
			return err
		}
		if daKy {
			return apierr.Error{Code: apierr.CodeSaleDayReconciled}
		}
		id, err = repo.themSoGiay(ctx, ngay, so)
		return err
	})
	return id, err
}

// ghiDongDem là cửa không lối vào: dùng giao dịch đã kiểm quyền của dem hoặc sua_dem.
func ghiDongDem(ctx context.Context, tx pgx.Tx, id int64, lines []Dong) error {
	r := newRepository(tx)
	for _, l := range lines {
		if err := r.themDongDem(ctx, id, l); err != nil {
			return err
		}
	}
	return nil
}

// SuaSoDem giữ cùng khoá riêng với ký ngày; mở lại và thay số cùng sống hoặc cùng lùi.
func (s *Service) SuaSoDem(ctx context.Context, nguoi int64, ngay string, p YeuCau, reason string) (id int64, err error) {
	err = authz.Run(ctx, s.pool, nguoi, SuaDem, func(tx pgx.Tx) error {
		if err := ngayban.Khoa(ctx, tx, ngay, true); err != nil {
			return err
		}
		repo := newRepository(tx)
		dau, err := repo.docDau(ctx, ngay)
		if err != nil {
			return err
		}
		if len(dau) == 0 {
			return apierr.Error{Code: apierr.CodeSaleDayNotReconciled}
		}
		cuoi := dau[len(dau)-1]
		if cuoi.Reopening == nil {
			if err := repo.moLai(ctx, cuoi.ID, ngay, reason); err != nil {
				return err
			}
		}
		id, err = repo.docDem(ctx, ngay)
		if err != nil {
			return err
		}
		old, err := repo.docXap(ctx, id)
		if err != nil {
			return err
		}
		wanted := make(map[int64]int64, len(p.Lines))
		for _, l := range p.Lines {
			wanted[*l.Denomination] = *l.Amount
		}
		return vongdoi.CoVet(ctx, tx, reason, func() error {
			for _, l := range old {
				amount := wanted[l.menhGia] // xấp bị bỏ về 0, không xoá dòng
				if amount != l.soTien {
					if err := repo.datSo(ctx, l.id, amount); err != nil {
						return err
					}
				}
				delete(wanted, l.menhGia)
			}
			for _, l := range p.Lines {
				if _, ok := wanted[*l.Denomination]; ok {
					if err := ghiDongDem(ctx, tx, id, []Dong{l}); err != nil {
						return err
					}
				}
			}
			return nil
		})
	})
	return id, err
}
