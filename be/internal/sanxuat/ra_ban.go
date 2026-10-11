package sanxuat

import (
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"net/http"
	"slices"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var RaBan = authz.Door{Code: "sanxuat/ra_ban", Need: authz.NeedCounter}

//go:embed sql/ra_ban/doc.sql
var daRaHet string

// Đơn của một phần (một bàn, hoặc một đơn không bàn) được khoá phiên trước đơn, như mọi cửa đụng việc.
const khoaPhienCuaPhan = `SELECT s.id FROM table_session s WHERE s.id IN (
 SELECT o.table_session_id FROM sales_order o WHERE o.id = ANY($1::bigint[])) ORDER BY s.id FOR UPDATE`

const khoaDonCuaPhan = `SELECT o.id FROM sales_order o WHERE o.id = ANY($1::bigint[]) AND o.status = 'in_progress'
 ORDER BY o.id FOR UPDATE`

// Cái đã làm của một hàng ở các đơn đã khoá, lượt gọi sớm hơn trước (ADR-090 điểm 4 Sửa đổi).
const chonDaLam = `WITH viec AS (` + viecGom + `
 WHERE j.status = 'made' AND o.id = ANY($1::bigint[]))
SELECT id FROM viec WHERE station_code = $2 AND menu_component_id IS NOT DISTINCT FROM $3
 AND filling_option_ids = $4::bigint[] ORDER BY sales_order_id, id LIMIT $5`

type mucRa struct {
	StationCode      string  `json:"station_code"`
	MenuComponentID  *int64  `json:"menu_component_id"`
	FillingOptionIDs []int64 `json:"filling_option_ids"`
	Quantity         int64   `json:"quantity"`
	// Hợp đồng đòi cả hai trường (menu_component_id được null — nước chấm; filling_option_ids không null).
	// Thiếu trường không được đọc thành nước chấm (T-144, duyệt độc lập phần S-5).
	coThanhPhan, coNhan bool
}

func (m *mucRa) UnmarshalJSON(b []byte) error {
	type tho mucRa
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(b, &raw); err != nil {
		return err
	}
	var x tho
	if err := json.Unmarshal(b, &x); err != nil {
		return err
	}
	*m = mucRa(x)
	_, m.coThanhPhan = raw["menu_component_id"]
	nhan, co := raw["filling_option_ids"]
	m.coNhan = co && string(nhan) != "null"
	return nil
}

type yeuCauRa struct {
	DiningTableID *int64  `json:"dining_table_id"`
	SalesOrderID  *int64  `json:"sales_order_id"`
	Items         []mucRa `json:"items"`
}

// docRa đọc lời S-5 (chủ quán 2026-10-09): số cái từng thứ cho MỘT bàn, hoặc một đơn không bàn.
func docRa(w http.ResponseWriter, r *http.Request) (yeuCauRa, bool) {
	var yc yeuCauRa
	if !apierr.ReadJSON(w, r, &yc) {
		return yc, false
	}
	if (yc.DiningTableID == nil) == (yc.SalesOrderID == nil) ||
		(yc.DiningTableID != nil && *yc.DiningTableID <= 0) || (yc.SalesOrderID != nil && *yc.SalesOrderID <= 0) {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
		return yc, false
	}
	hop := len(yc.Items) > 0
	daCo := make(map[string]bool)
	for i := range yc.Items {
		m := &yc.Items[i]
		if m.FillingOptionIDs == nil {
			m.FillingOptionIDs = []int64{}
		}
		slices.Sort(m.FillingOptionIDs)
		khoa, _ := json.Marshal([]any{m.StationCode, m.MenuComponentID, m.FillingOptionIDs})
		if m.StationCode == "" || m.Quantity <= 0 || daCo[string(khoa)] || !m.coThanhPhan || !m.coNhan ||
			len(slices.Compact(slices.Clone(m.FillingOptionIDs))) != len(m.FillingOptionIDs) {
			hop = false
		}
		daCo[string(khoa)] = true
	}
	if !hop {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "items"})
		return yc, false
	}
	return yc, true
}

// donCuaPhan: các đơn Đang thực hiện của phần quầy chọn, đã khoá. Không suy ra phần từ mẻ hay từ món.
func donCuaPhan(ctx context.Context, tx pgx.Tx, yc yeuCauRa) ([]int64, error) {
	var ids []int64
	if yc.DiningTableID != nil {
		var co bool
		if err := tx.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM dining_table WHERE id = $1)`, *yc.DiningTableID).Scan(&co); err != nil {
			return nil, err
		}
		if !co {
			return nil, apierr.Error{Code: apierr.CodeDiningTableNotFound}
		}
		rows, err := tx.Query(ctx, `SELECT id FROM sales_order WHERE dining_table_id = $1 AND status = 'in_progress' ORDER BY id`, *yc.DiningTableID)
		if err != nil {
			return nil, err
		}
		if ids, err = pgx.CollectRows(rows, pgx.RowTo[int64]); err != nil {
			return nil, err
		}
	} else {
		var ban *int64
		err := tx.QueryRow(ctx, `SELECT dining_table_id FROM sales_order WHERE id = $1`, *yc.SalesOrderID).Scan(&ban)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apierr.Error{Code: apierr.CodeSalesOrderNotFound}
		}
		if err != nil {
			return nil, err
		}
		if ban != nil {
			// Đơn có bàn thì phần của nó là bàn: bấm theo bàn, không theo đơn.
			return nil, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sales_order_id"}
		}
		ids = []int64{*yc.SalesOrderID}
	}
	for _, q := range []string{khoaPhienCuaPhan, khoaDonCuaPhan} {
		rows, err := tx.Query(ctx, q, ids)
		if err != nil {
			return nil, err
		}
		khoa, err := pgx.CollectRows(rows, pgx.RowTo[int64])
		if err != nil {
			return nil, err
		}
		if q == khoaDonCuaPhan {
			ids = khoa // đơn vừa rời Đang thực hiện trước lúc khoá thì không còn cái nào để bưng
		}
	}
	return ids, nil
}

func (h handler) raBan(w http.ResponseWriter, r *http.Request) {
	yc, ok := docRa(w, r)
	if !ok {
		return
	}
	daRa, xong := []int64{}, []int64{}
	err := authz.Run(r.Context(), h.pool, h.person(r), RaBan, func(tx pgx.Tx) error {
		dons, err := donCuaPhan(r.Context(), tx, yc)
		if err != nil {
			return err
		}
		for _, m := range yc.Items {
			rows, err := tx.Query(r.Context(), chonDaLam, dons, m.StationCode, m.MenuComponentID, m.FillingOptionIDs, m.Quantity)
			if err != nil {
				return err
			}
			ids, err := pgx.CollectRows(rows, pgx.RowTo[int64])
			if err != nil {
				return err
			}
			if int64(len(ids)) < m.Quantity {
				return apierr.Error{Code: apierr.CodeServedQuantityExceedsMade}
			}
			daRa = append(daRa, ids...)
		}
		ds, err := khoaTap(r.Context(), tx, daRa)
		if err != nil {
			return err
		}
		for _, v := range ds {
			// Đơn đã khoá trước khi chọn nên cái đã chọn còn ở made; kiểm lại sau khoá việc cho chắc.
			if v.TrangThai != "made" {
				return apierr.Error{Code: apierr.CodeServedQuantityExceedsMade}
			}
		}
		for _, v := range ds {
			if err := vongdoi.ChuyenViec(r.Context(), tx, v.ID, "served"); err != nil {
				return err
			}
		}
		daXet := make(map[int64]bool)
		for _, v := range ds {
			if v.PhienID == nil || daXet[v.DonID] {
				continue
			}
			daXet[v.DonID] = true
			var het bool
			if err := tx.QueryRow(r.Context(), daRaHet, v.DonID).Scan(&het); err != nil {
				return err
			}
			if het {
				if err := vongdoi.ChuyenDon(r.Context(), tx, v.DonID, "completed"); err != nil {
					return err
				}
				xong = append(xong, v.DonID)
			}
		}
		return nil
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"station_job_ids": daRa, "completed_order_ids": xong})
}
