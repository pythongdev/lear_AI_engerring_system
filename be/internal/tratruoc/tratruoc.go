// Package tratruoc nhận trả trước và nối chuỗi số dư trong giao dịch của cửa gọi.
package tratruoc

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"context"
	_ "embed"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"math"
	"net/http"
)

var Nhan = authz.Door{Code: "tratruoc/nhan", Need: authz.NeedCounter}
var CuaDung = authz.Door{Code: "tratruoc/dung", Need: authz.NeedCallingDoor}

//go:embed sql/nhan/khoa.sql
var khoaDon string

//go:embed sql/nhan/them.sql
var them string

//go:embed sql/dung/khoa.sql
var khoaKhoan string

//go:embed sql/dung/du.sql
var docDu string

//go:embed sql/dung/them.sql
var themMat string

// PhanTien là hai phần bắt buộc của một lần nhận tiền.
type PhanTien struct {
	Cash     *int64 `json:"cash_vnd"`
	Transfer *int64 `json:"transfer_vnd"`
}

func (p PhanTien) Kiem() error {
	for _, f := range []struct {
		name string
		v    *int64
	}{{"cash_vnd", p.Cash}, {"transfer_vnd", p.Transfer}} {
		if f.v == nil || *f.v < 0 {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: f.name}
		}
	}
	if *p.Cash > math.MaxInt64-*p.Transfer || *p.Cash+*p.Transfer == 0 {
		return apierr.Error{Code: apierr.CodeInvalidRequest}
	}
	return nil
}

func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	mux.HandleFunc("POST /orders/{sales_order_id}/prepayment", func(w http.ResponseWriter, r *http.Request) {
		id, ok := apierr.ReadID(w, r, "sales_order_id")
		if !ok {
			return
		}
		var p PhanTien
		if !apierr.ReadJSON(w, r, &p) {
			return
		}
		if err := p.Kiem(); err != nil {
			apierr.WriteError(w, err)
			return
		}
		var person, out int64
		if auth != nil {
			person, _ = auth.PersonID(r)
		}
		err := authz.Run(r.Context(), pool, person, Nhan, func(tx pgx.Tx) error {
			var phien *int64
			var status string
			if err := tx.QueryRow(r.Context(), khoaDon, id).Scan(&phien, &status); err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
				}
				return err
			}
			moc, _, err := ngayban.ChoGhi(r.Context(), tx)
			if err != nil {
				return err
			}
			if phien != nil || (status != "pending_confirmation" && status != "confirmed" && status != "in_progress") {
				return apierr.Error{Code: apierr.CodeOrderNotPrepayable}
			}
			return tx.QueryRow(r.Context(), them, id, *p.Cash, *p.Transfer, moc).Scan(&out)
		})
		if err != nil {
			apierr.WriteError(w, err)
			return
		}
		apierr.JSON(w, http.StatusCreated, map[string]any{"prepayment_id": out, "sales_order_id": id})
	})
}

// SoDu là mắt cuối đã khoá của một khoản; mắt đầu dùng số đã nhận.
type SoDu struct {
	Don, Cash, Transfer int64
	UseNo               int
}

func KiemSoDu(ctx context.Context, tx pgx.Tx, id, cash, transfer int64) (SoDu, error) {
	var s SoDu
	if err := tx.QueryRow(ctx, khoaKhoan, id).Scan(&s.Don, &s.Cash, &s.Transfer); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return s, apierr.Error{Code: apierr.CodePrepaymentNotFound}
		}
		return s, err
	}
	err := tx.QueryRow(ctx, docDu, id).Scan(&s.UseNo, &s.Cash, &s.Transfer)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return s, err
	}
	if cash > s.Cash || transfer > s.Transfer {
		return s, apierr.Error{Code: apierr.CodePrepaymentBalanceExceeded}
	}
	return s, nil
}

// Dung chỉ nhận giao dịch đã kiểm quyền. Khoá khoản trước khi đọc mắt cuối; không tự chia tiền.
func Dung(ctx context.Context, tx pgx.Tx, id, cash, transfer int64, bill, refund *int64) error {
	s, err := KiemSoDu(ctx, tx, id, cash, transfer)
	if err != nil {
		return err
	}
	_, err = tx.Exec(ctx, themMat, id, s.Don, s.UseNo+1, s.Cash, s.Transfer, cash, transfer, bill, refund)
	return err
}
