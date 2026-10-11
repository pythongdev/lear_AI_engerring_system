// Package ban đọc trạng thái bàn từ chi tiết và giữ cửa xác nhận đã dọn.
package ban

import (
	"context"
	_ "embed"
	"errors"
	"net/http"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var DaDon = authz.Door{Code: "ban/da_don", Need: authz.NeedPerson}

//go:embed sql/da_don/khoa.sql
var khoa string

//go:embed sql/da_don/don.sql
var don string

// Một phép đọc cho danh sách bàn và cửa tạo lượt gọi (I-003).
const doc = `SELECT t.id, t.label,
 CASE WHEN s.id IS NOT NULL THEN 'in_session'
 WHEN EXISTS (SELECT 1 FROM table_session_member m WHERE m.dining_table_id = t.id AND m.session_closed AND m.cleaned_at IS NULL)
 THEN 'needs_cleaning' ELSE 'empty' END,
 s.id, s.status
 FROM dining_table t
 LEFT JOIN table_session_member m ON m.dining_table_id = t.id AND NOT m.session_closed
 LEFT JOIN table_session s ON s.id = m.table_session_id`

type Ban struct {
	DiningTableID      int64   `json:"dining_table_id"`
	Label              string  `json:"label"`
	State              string  `json:"state"`
	TableSessionID     *int64  `json:"table_session_id,omitempty"`
	TableSessionStatus *string `json:"table_session_status,omitempty"`
}

func scan(row pgx.Row) (Ban, error) {
	var b Ban
	err := row.Scan(&b.DiningTableID, &b.Label, &b.State, &b.TableSessionID, &b.TableSessionStatus)
	return b, err
}
func Doc(ctx context.Context, tx pgx.Tx, id int64) (Ban, error) {
	b, err := scan(tx.QueryRow(ctx, doc+" WHERE t.id = $1", id))
	if errors.Is(err, pgx.ErrNoRows) {
		return Ban{}, apierr.Error{Code: apierr.CodeDiningTableNotFound}
	}
	return b, err
}
func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	mux.HandleFunc("GET /dining-tables", func(w http.ResponseWriter, r *http.Request) {
		out := struct {
			Tables []Ban `json:"tables"`
		}{Tables: []Ban{}}
		err := postgres.InTx(r.Context(), pool, func(tx pgx.Tx) error {
			rows, err := tx.Query(r.Context(), doc+" ORDER BY t.id")
			if err != nil {
				return err
			}
			defer rows.Close()
			for rows.Next() {
				b, err := scan(rows)
				if err != nil {
					return err
				}
				out.Tables = append(out.Tables, b)
			}
			return rows.Err()
		})
		if err != nil {
			apierr.WriteError(w, err)
			return
		}
		apierr.JSON(w, http.StatusOK, out)
	})
	mux.HandleFunc("POST /dining-tables/{dining_table_id}/cleaning", func(w http.ResponseWriter, r *http.Request) {
		id, ok := apierr.ReadID(w, r, "dining_table_id")
		if !ok {
			return
		}
		var person int64
		if auth != nil {
			person, _ = auth.PersonID(r)
		}
		var b Ban
		err := authz.Run(r.Context(), pool, person, DaDon, func(tx pgx.Tx) error {
			rows, err := tx.Query(r.Context(), khoa, id)
			if err != nil {
				return err
			}
			ids, err := pgx.CollectRows(rows, pgx.RowTo[int64])
			if err != nil {
				return err
			}
			if len(ids) == 0 {
				if _, err := Doc(r.Context(), tx, id); err != nil {
					return err
				}
				return apierr.Error{Code: apierr.CodeDiningTableNotNeedingCleaning}
			}
			if err := vongdoi.CoVet(r.Context(), tx, DaDon.Code+": needs_cleaning → empty", func() error {
				_, err := tx.Exec(r.Context(), don, ids)
				return err
			}); err != nil {
				return err
			}
			b, err = Doc(r.Context(), tx, id)
			return err
		})
		if err != nil {
			apierr.WriteError(w, err)
			return
		}
		apierr.JSON(w, http.StatusOK, map[string]any{"dining_table_id": id, "state": b.State})
	})
}
