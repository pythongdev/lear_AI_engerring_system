// Package phien giữ cửa tính tiền và phép cộng duy nhất của một phiên.
package phien

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"context"
	_ "embed"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"net/http"
)

var TinhTien = authz.Door{Code: "phien/tinh_tien", Need: authz.NeedCounter}

//go:embed sql/tinh_tien/khoa.sql
var khoa string

// TongTien là một chỗ cộng line_total_vnd cho cả tính tiền và đóng phiên.
func TongTien(ctx context.Context, tx pgx.Tx, id int64) (int64, error) {
	var due int64
	err := tx.QueryRow(ctx, `SELECT coalesce(sum(l.line_total_vnd),0)::bigint
 FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
 WHERE o.table_session_id = $1 AND o.status <> 'cancelled'`, id).Scan(&due)
	return due, err
}
func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	mux.HandleFunc("POST /table-sessions/{table_session_id}/bill-request", func(w http.ResponseWriter, r *http.Request) {
		id, ok := apierr.ReadID(w, r, "table_session_id")
		if !ok {
			return
		}
		var person, due int64
		if auth != nil {
			person, _ = auth.PersonID(r)
		}
		err := authz.Run(r.Context(), pool, person, TinhTien, func(tx pgx.Tx) error {
			var status string
			if err := tx.QueryRow(r.Context(), khoa, id).Scan(&status); err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return apierr.Error{Code: apierr.CodeTableSessionNotFound}
				}
				return err
			}
			if err := vongdoi.ChuyenPhien(r.Context(), tx, id, "awaiting_payment"); err != nil {
				return err
			}
			var err error
			due, err = TongTien(r.Context(), tx, id)
			return err
		})
		if err != nil {
			apierr.WriteError(w, err)
			return
		}
		apierr.JSON(w, http.StatusOK, map[string]any{"table_session_id": id, "status": "awaiting_payment", "due_vnd": due})
	})
}
