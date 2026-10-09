// Package ket khai tiền đầu két, đếm và ký ngày ở ngưỡng lệch 0đ (ADR-089).
package ket

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/db"
	"banhcuon/be/internal/ngayban"
	_ "embed"
	"errors"
	"fmt"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"math"
	"net/http"
	"time"
)

var KhaiDauKet = authz.Door{Code: "ket/khai_dau_ket", Need: authz.NeedCounterOrOwner}
var Dem = authz.Door{Code: "ket/dem", Need: authz.NeedCounterOrOwner}
var DoiSoatXong = authz.Door{Code: "ket/doi_soat_xong", Need: authz.NeedCounterOrOwner}

//go:embed sql/khai_dau_ket/them.sql
var dauThem string

//go:embed sql/khai_dau_ket/dong.sql
var dauDong string

//go:embed sql/dem/them.sql
var demThem string

//go:embed sql/dem/dong.sql
var demDong string

//go:embed sql/doi_soat_xong/them.sql
var kyThem string

//go:embed sql/doi_soat_xong/giay.sql
var giaySQL string

//go:embed sql/ket_ngay.sql
var ketSQL string

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

type handler struct {
	pool *pgxpool.Pool
	auth authz.Authenticator
}

func (h handler) person(r *http.Request) int64 {
	if h.auth == nil {
		return 0
	}
	id, _ := h.auth.PersonID(r)
	return id
}
func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	h := handler{pool, auth}
	mux.HandleFunc("POST /opening-floats", h.khai)
	mux.HandleFunc("POST /cash-counts", h.dem)
	mux.HandleFunc("POST /sale-days/{sale_date}/reconciliation", h.ky)
	mux.HandleFunc("GET /sale-days/{sale_date}/cash-reconciliation", h.doc)
}
func (h handler) khai(w http.ResponseWriter, r *http.Request) {
	h.ghiSo(w, r, KhaiDauKet, dauThem, dauDong, "opening_float_id")
}
func (h handler) dem(w http.ResponseWriter, r *http.Request) {
	h.ghiSo(w, r, Dem, demThem, demDong, "cash_count_id")
}
func (h handler) ghiSo(w http.ResponseWriter, r *http.Request, cua authz.Door, them, dong, key string) {
	var p YeuCau
	if !apierr.ReadJSON(w, r, &p) {
		return
	}
	total, err := p.Kiem()
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	var id int64
	var ngay string
	err = authz.Run(r.Context(), h.pool, h.person(r), cua, func(tx pgx.Tx) error {
		moc, d, err := ngayban.ChoGhi(r.Context(), tx)
		if err != nil {
			return err
		}
		ngay = d
		if err := tx.QueryRow(r.Context(), them, moc).Scan(&id); err != nil {
			return err
		}
		for _, l := range p.Lines {
			if _, err := tx.Exec(r.Context(), dong, id, *l.Denomination, *l.Amount); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 201, map[string]any{key: id, "sale_date": ngay, "total_vnd": total})
}
func docNgay(w http.ResponseWriter, r *http.Request) (string, bool) {
	s := r.PathValue("sale_date")
	d, err := time.Parse("2006-01-02", s)
	if err != nil || d.Year() < 1 || d.Format("2006-01-02") != s {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sale_date"})
		return "", false
	}
	return s, true
}

type SoKet struct {
	SaleDate string `json:"sale_date"`
	Counted  int64  `json:"counted_vnd"`
	Opening  int64  `json:"opening_float_vnd"`
	Expected int64  `json:"expected_vnd"`
	Gap      int64  `json:"gap_vnd"`
}

func docSo(r *http.Request, tx pgx.Tx, ngay string) (SoKet, bool, error) {
	var s SoKet
	var date time.Time
	var cho bool
	err := tx.QueryRow(r.Context(), ketSQL, ngay).Scan(&date, &s.Counted, &s.Opening, &s.Expected, &cho)
	if errors.Is(err, pgx.ErrNoRows) {
		err = apierr.Error{Code: apierr.CodeCashDayIncomplete}
	}
	s.SaleDate = ngay
	s.Gap = s.Counted - s.Opening - s.Expected
	return s, cho, err
}
func (h handler) doc(w http.ResponseWriter, r *http.Request) {
	ngay, ok := docNgay(w, r)
	if !ok {
		return
	}
	var s SoKet
	err := db.InTx(r.Context(), h.pool, func(tx pgx.Tx) error { var err error; s, _, err = docSo(r, tx, ngay); return err })
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 200, s)
}
func (h handler) ky(w http.ResponseWriter, r *http.Request) {
	ngay, ok := docNgay(w, r)
	if !ok {
		return
	}
	var id int64
	err := authz.Run(r.Context(), h.pool, h.person(r), DoiSoatXong, func(tx pgx.Tx) error {
		if err := ngayban.Khoa(r.Context(), tx, ngay, true); err != nil {
			return err
		}
		so, cho, err := docSo(r, tx, ngay)
		if err != nil {
			return err
		}
		co, err := ngayban.DaKy(r.Context(), tx, ngay)
		if err != nil {
			return err
		}
		if co {
			return apierr.Error{Code: apierr.CodeSaleDayAlreadyReconciled}
		}
		if err := tx.QueryRow(r.Context(), giaySQL, ngay).Scan(&co); err != nil {
			return err
		}
		if co {
			return apierr.Error{Code: apierr.CodePaperEntriesPending}
		}
		if cho {
			return apierr.Error{Code: apierr.CodeCashDayExpenseDateUndecided}
		}
		if so.Gap != 0 {
			return apierr.Error{Code: apierr.CodeCashDayNotBalanced}
		}
		return tx.QueryRow(r.Context(), kyThem, ngay).Scan(&id)
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, 201, map[string]any{"reconciled_day_id": id, "sale_date": ngay})
}
