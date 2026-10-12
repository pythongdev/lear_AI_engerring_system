// Package ket khai tiền đầu két, đếm và chủ quán ký ngày kèm giải thích khi lệch (ADR-089).
package ket

import (
	"context"
	"errors"
	"fmt"
	"math"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/platform/postgres"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var KhaiDauKet = authz.Door{Code: "ket/khai_dau_ket", Need: authz.NeedCounterOrOwner}
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

type SoKet struct {
	SaleDate string `json:"sale_date"`
	Counted  int64  `json:"counted_vnd"`
	Opening  int64  `json:"opening_float_vnd"`
	Expected int64  `json:"expected_vnd"`
	Gap      int64  `json:"gap_vnd"`
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
	s.Gap = s.Counted - s.Opening - s.Expected
	return s, err
}

func (s *Service) DocSo(ctx context.Context, ngay string) (SoKet, error) {
	var so SoKet
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		so, err = docSo(ctx, tx, ngay)
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
		co, err := ngayban.DaKy(ctx, tx, ngay)
		if err != nil {
			return err
		}
		if co {
			return apierr.Error{Code: apierr.CodeSaleDayAlreadyReconciled}
		}
		repo := newRepository(tx)
		if co, err = repo.conSoGiay(ctx, ngay); err != nil {
			return err
		}
		if co {
			return apierr.Error{Code: apierr.CodePaperEntriesPending}
		}
		gap = so.Gap
		if gap != 0 && explanation == nil {
			return apierr.Error{Code: apierr.CodeGapExplanationRequired}
		}
		id, err = repo.themKyNgay(ctx, ngay, gap, explanation)
		return err
	})
	return id, gap, err
}
