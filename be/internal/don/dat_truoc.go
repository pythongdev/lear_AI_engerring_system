package don

import (
	_ "embed"
	"encoding/json"
	"io"
	"net/http"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/sanxuat"
	"github.com/jackc/pgx/v5"
)

var NhaHen = authz.Door{Code: "don/nha_hen", Need: authz.NeedCounter}

//go:embed sql/nha_hen/khoa_don.sql
var nhaHenKhoaDon string

func (h handler) nhaHen(w http.ResponseWriter, r *http.Request) {
	// Không có trường đầu vào; thân rỗng hoặc object theo hợp đồng.
	dec := json.NewDecoder(r.Body)
	var body map[string]json.RawMessage
	err := dec.Decode(&body)
	if err != io.EOF && (err != nil || body == nil || dec.Decode(new(any)) != io.EOF) {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest})
		return
	}
	ids := make([]int64, 0)
	err = authz.Run(r.Context(), h.pool, h.person(r), NhaHen, func(tx pgx.Tx) error {
		moc, err := DongHo(r.Context(), tx)
		if err != nil {
			return err
		}
		rows, err := tx.Query(r.Context(), nhaHenKhoaDon, moc)
		if err != nil {
			return err
		}
		// Đọc hết và đóng rows trước khi dùng lại kết nối để nổ đơn.
		defer rows.Close()
		for rows.Next() {
			var id int64
			var status string
			if err := rows.Scan(&id, &status); err != nil {
				return err
			}
			if status == "confirmed" {
				ids = append(ids, id)
			}
		}
		if err := rows.Err(); err != nil {
			return err
		}
		for _, id := range ids {
			if err := sanxuat.NoDon(r.Context(), tx, id); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"released_order_ids": ids})
}

const docNhacHen = `SELECT id, to_jsonb(customer_needed_at), status FROM sales_order
 WHERE channel_code = 'phone_preorder' AND status IN ('confirmed', 'in_progress')
 ORDER BY customer_needed_at, id`

type NhacHen struct {
	SalesOrderID     int64       `json:"sales_order_id"`
	CustomerNeededAt time.Time   `json:"customer_needed_at"`
	Status           string      `json:"status"`
	RemindAt         []time.Time `json:"remind_at"`
	DueReminders     []int       `json:"due_reminders"`
}

func (h handler) nhacHen(w http.ResponseWriter, r *http.Request) {
	preorders := make([]NhacHen, 0)
	// Đường đọc không kiểm quyền hay khai người; giao dịch chỉ để dùng cùng DongHo.
	err := postgres.InTx(r.Context(), h.pool, func(tx pgx.Tx) error {
		moc, err := DongHo(r.Context(), tx)
		if err != nil {
			return err
		}
		rows, err := tx.Query(r.Context(), docNhacHen)
		if err != nil {
			return err
		}
		defer rows.Close()
		for rows.Next() {
			var n NhacHen
			var neededAt []byte
			if err := rows.Scan(&n.SalesOrderID, &neededAt, &n.Status); err != nil {
				return err
			}
			// Giữ độ lệch múi giờ của phiên PostgreSQL như hợp đồng §6.
			if err := json.Unmarshal(neededAt, &n.CustomerNeededAt); err != nil {
				return err
			}
			n.RemindAt = make([]time.Time, 0, 2)
			n.DueReminders = make([]int, 0, 2)
			for _, phut := range []int{20, 10} {
				nhac := n.CustomerNeededAt.Add(-time.Duration(phut) * time.Minute)
				n.RemindAt = append(n.RemindAt, nhac)
				if !nhac.After(moc) {
					n.DueReminders = append(n.DueReminders, phut)
				}
			}
			preorders = append(preorders, n)
		}
		return rows.Err()
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"preorders": preorders})
}
