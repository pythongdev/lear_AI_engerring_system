// Package hoadon đóng phiên và ghi hoá đơn trong cùng một giao dịch.
package hoadon

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/phien"
	"banhcuon/be/internal/vongdoi"
	_ "embed"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"net/http"
	"strings"
)

var Dong = authz.Door{Code: "hoadon/dong", Need: authz.NeedCounter}

//go:embed sql/dong/khoa_phien.sql
var khoaPhien string

//go:embed sql/dong/khoa_don.sql
var khoaDon string

func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	tienRoutes(mux, pool, auth)
	mux.HandleFunc("POST /table-sessions/{table_session_id}/closing", func(w http.ResponseWriter, r *http.Request) {
		id, ok := apierr.ReadID(w, r, "table_session_id")
		if !ok {
			return
		}
		var yc struct {
			DiscountVnd int64   `json:"discount_vnd"`
			CashVnd     *int64  `json:"cash_vnd"`
			TransferVnd *int64  `json:"transfer_vnd"`
			DebtVnd     *int64  `json:"debt_vnd"`
			DebtorName  *string `json:"debtor_name"`
		}
		if !apierr.ReadJSON(w, r, &yc) {
			return
		}
		for _, v := range []struct {
			name  string
			value *int64
		}{{"cash_vnd", yc.CashVnd}, {"transfer_vnd", yc.TransferVnd}, {"debt_vnd", yc.DebtVnd}} {
			if v.value == nil || *v.value < 0 {
				apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: v.name})
				return
			}
		}
		if yc.DiscountVnd < 0 {
			apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "discount_vnd"})
			return
		}
		if yc.DebtorName != nil && strings.TrimSpace(*yc.DebtorName) == "" {
			apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "debtor_name"})
			return
		}
		var person, bill, due int64
		if auth != nil {
			person, _ = auth.PersonID(r)
		}
		err := authz.Run(r.Context(), pool, person, Dong, func(tx pgx.Tx) error {
			if yc.DiscountVnd > 0 {
				return apierr.Error{Code: apierr.CodeOrderDiscountUndecided}
			}
			var status string
			if err := tx.QueryRow(r.Context(), khoaPhien, id).Scan(&status); err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return apierr.Error{Code: apierr.CodeTableSessionNotFound}
				}
				return err
			}
			moc, _, err := ngayban.ChoGhi(r.Context(), tx)
			if err != nil {
				return err
			}
			if err := vongdoi.KiemChuyenPhien(status, "closed"); err != nil {
				return err
			}
			rows, err := tx.Query(r.Context(), khoaDon, id)
			if err != nil {
				return err
			}
			states, err := pgx.CollectRows(rows, pgx.RowTo[string])
			if err != nil {
				return err
			}
			for _, s := range states {
				if s != "completed" && s != "cancelled" {
					return apierr.Error{Code: apierr.CodeTableSessionHasOpenOrders}
				}
			}
			due, err = phien.TongTien(r.Context(), tx, id)
			if err != nil {
				return err
			}
			bill, err = Ghi(r.Context(), tx, NoiDung{Phien: &id, Due: due, Cash: *yc.CashVnd, Transfer: *yc.TransferVnd, Debt: *yc.DebtVnd, Debtor: yc.DebtorName, Moc: moc})
			if err != nil {
				return err
			}
			return vongdoi.ChuyenPhien(r.Context(), tx, id, "closed")
		})
		if err != nil {
			apierr.WriteError(w, err)
			return
		}
		apierr.JSON(w, http.StatusCreated, map[string]any{"bill_id": bill, "table_session_id": id, "due_vnd": due})
	})
}
