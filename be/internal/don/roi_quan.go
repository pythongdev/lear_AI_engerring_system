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

var RoiQuan = authz.Door{Code: "don/roi_quan", Need: authz.NeedCounter}

//go:embed sql/roi_quan/khoa_don.sql
var roiQuanKhoaDon string

//go:embed sql/roi_quan/doc_viec.sql
var roiQuanDocViec string

func (h handler) roiQuan(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "sales_order_id")
	if !ok {
		return
	}
	err := authz.Run(r.Context(), h.pool, h.person(r), RoiQuan, func(tx pgx.Tx) error {
		var status string
		var handover *string
		if err := tx.QueryRow(r.Context(), roiQuanKhoaDon, id).Scan(&status, &handover); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		// Kiểm cặp trước S-6; chỉ ChuyenDon sở hữu lần ghi trạng thái.
		if err := vongdoi.KiemChuyenDon(status, "delivering", "", handover); err != nil {
			return err
		}
		var chuaRaBan bool
		if err := tx.QueryRow(r.Context(), roiQuanDocViec, id).Scan(&chuaRaBan); err != nil {
			return err
		}
		if chuaRaBan {
			return apierr.Error{Code: apierr.CodeDeliveryServedMarkUndecided}
		}
		return vongdoi.ChuyenDon(r.Context(), tx, id, "delivering")
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"sales_order_id": id, "status": "delivering", "table_session_id": nil, "table_session_status": nil})
}
