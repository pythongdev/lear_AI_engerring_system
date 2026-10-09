package don

import (
	_ "embed"
	"errors"
	"net/http"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var Huy = authz.Door{Code: "don/huy", Need: authz.NeedCounter}

//go:embed sql/huy/doc_phien.sql
var huyDocPhien string

func (h handler) huy(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "sales_order_id")
	if !ok {
		return
	}
	err := authz.Run(r.Context(), h.pool, h.person(r), Huy, func(tx pgx.Tx) error {
		var phien *int64
		if err := tx.QueryRow(r.Context(), huyDocPhien, id).Scan(&phien); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		if phien != nil {
			var st string
			if err := tx.QueryRow(r.Context(), duyetKhoaPhien, *phien).Scan(&st); err != nil {
				return err
			}
		}
		var st string
		if err := tx.QueryRow(r.Context(), duyetKhoaDon, id).Scan(&st); err != nil {
			return err
		}
		if st == "completed" {
			return apierr.Error{Code: apierr.CodeCompletedOrderCancelNotReady}
		}
		if st != "confirmed" && st != "in_progress" {
			return apierr.Error{Code: apierr.CodeOrderTransitionNotAllowed}
		}
		return vongdoi.ChuyenDon(r.Context(), tx, id, "cancelled")
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"sales_order_id": id, "status": "cancelled"})
}
