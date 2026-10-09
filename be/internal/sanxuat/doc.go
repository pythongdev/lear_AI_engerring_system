package sanxuat

import (
	"context"
	"encoding/json"
	"net/http"

	"banhcuon/be/internal/apierr"
)

// viecGom là định nghĩa DUY NHẤT của khoá gom (I-019 tầng 3): trạm + thành phần gốc đã chụp (null với
// nước chấm) + tập tuỳ chọn nhân đã chụp, sắp tăng, chỉ khi thành phần nhận nhân. Bảng nhu cầu, ứng viên
// chuyển và cửa đã ra bàn đều đọc khoá từ đây; câu dùng nó tự thêm WHERE.
const viecGom = `
 SELECT j.id, j.sales_order_id, o.dining_table_id, j.station_code, j.status,
        o.status AS order_status, s.status AS session_status,
        c.menu_component_id, coalesce(c.component_name, 'nước chấm') AS component_name,
        CASE WHEN c.takes_filling THEN ARRAY(
          SELECT DISTINCT x.menu_option_id FROM order_line_option x
          WHERE x.order_line_id = j.order_line_id ORDER BY x.menu_option_id
        ) ELSE ARRAY[]::bigint[] END AS filling_option_ids
 FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
 LEFT JOIN table_session s ON s.id = o.table_session_id
 LEFT JOIN order_line_component c ON c.id = j.order_line_component_id`

// Tổng và phần chia được đọc trong cùng câu SQL, nên không lệch khi quầy bấm giữa hai lần đọc.
const gom = `WITH viec AS MATERIALIZED (` + viecGom + `
 -- Chỉ phần còn sống, không quét cả lịch sử: nhu cầu và ứng viên chỉ lấy từ đây, nguồn là $2.
 WHERE o.status = 'in_progress' OR (s.status IS NOT NULL AND s.status <> 'closed') OR j.id = $2
), phan AS (
 SELECT station_code, menu_component_id, filling_option_ids,
        min(component_name) AS component_name, dining_table_id,
        CASE WHEN dining_table_id IS NULL THEN sales_order_id END AS sales_order_id,
        count(*) AS ordered, count(*) FILTER (WHERE status = 'pending') AS pending,
        count(*) FILTER (WHERE status = 'made') AS made,
        count(*) FILTER (WHERE status = 'served') AS served,
        count(*) FILTER (WHERE status <> 'served') AS missing
 FROM viec WHERE $2::bigint IS NULL AND order_status <> 'cancelled'
   AND (order_status = 'in_progress' OR session_status <> 'closed')
   AND ($1::text = '' OR station_code = $1)
 GROUP BY station_code, menu_component_id, filling_option_ids, dining_table_id,
          CASE WHEN dining_table_id IS NULL THEN sales_order_id END
), hang AS (
 SELECT station_code, menu_component_id, min(component_name) AS component_name,
        filling_option_ids, sum(ordered) AS ordered, sum(pending) AS pending,
        sum(made) AS made, sum(served) AS served, sum(missing) AS missing,
        jsonb_agg(jsonb_build_object('dining_table_id', dining_table_id,
          'sales_order_id', sales_order_id, 'ordered', ordered, 'pending', pending,
          'made', made, 'served', served, 'missing', missing)
          ORDER BY dining_table_id, sales_order_id) AS parts
 FROM phan GROUP BY station_code, menu_component_id, filling_option_ids
), nguon AS (
 SELECT v.*, v.order_status = 'cancelled' AND v.status = 'made'
   AND EXISTS (SELECT 1 FROM production_batch_item i WHERE i.live_station_job_id = v.id)
   AND NOT EXISTS (SELECT 1 FROM wrong_make_note n WHERE n.live_station_job_id = v.id) AS available
 FROM viec v WHERE v.id = $2
)
SELECT EXISTS (SELECT 1 FROM nguon), coalesce((SELECT available FROM nguon), false),
 CASE WHEN $2::bigint IS NULL THEN jsonb_build_object('rows', coalesce(
   (SELECT jsonb_agg(to_jsonb(h) ORDER BY station_code, menu_component_id, filling_option_ids)
    FROM hang h), '[]'::jsonb))
 ELSE jsonb_build_object('station_job_id', $2, 'candidates', coalesce((
   SELECT jsonb_agg(jsonb_build_object('station_job_id', d.id, 'sales_order_id', d.sales_order_id,
     'dining_table_id', d.dining_table_id) ORDER BY d.id)
   FROM viec d JOIN nguon n ON d.station_code = n.station_code
     AND d.menu_component_id IS NOT DISTINCT FROM n.menu_component_id
     AND d.filling_option_ids = n.filling_option_ids
   WHERE d.id <> n.id AND d.status = 'pending' AND d.order_status = 'in_progress'
 ), '[]'::jsonb)) END`

func (h handler) docGom(ctx context.Context, tram string, nguon *int64) (json.RawMessage, error) {
	var co, hop bool
	var out json.RawMessage
	if err := h.pool.QueryRow(ctx, gom, tram, nguon).Scan(&co, &hop, &out); err != nil {
		return nil, err
	}
	if nguon != nil {
		if !co {
			return nil, apierr.Error{Code: apierr.CodeStationJobNotFound}
		}
		if !hop {
			return nil, apierr.Error{Code: apierr.CodeTransferSourceNotAvailable}
		}
	}
	return out, nil
}

func (h handler) bang(w http.ResponseWriter, r *http.Request) {
	out, err := h.docGom(r.Context(), r.URL.Query().Get("station_code"), nil)
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, out)
}

func (h handler) ungVien(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "id")
	if !ok {
		return
	}
	out, err := h.docGom(r.Context(), "", &id)
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, out)
}
