-- Bảng nhu cầu ($2 = 0: không nguồn — mã việc là identity từ 1, handler từ chối mã ≤ 0) hoặc ứng viên
-- chuyển của nguồn $2; $1 lọc trạm, rỗng là mọi trạm. Tổng và phần chia đọc trong cùng câu,
-- nên không lệch khi quầy bấm giữa hai lần đọc.
-- name: Gom :one
WITH viec AS MATERIALIZED (
 -- khoá gom: đầu
 -- Định nghĩa DUY NHẤT của khoá gom (I-019 tầng 3, ADR-090 điểm 8): trạm + thành phần gốc đã chụp (null
 -- với nước chấm) + tập tuỳ chọn nhân đã chụp, sắp tăng, chỉ khi thành phần nhận nhân. Đoạn này nằm ở
 -- gom.sql và chon_da_lam.sql, giống từng byte; TestI019_KhoaGomMotDinhNghia đỏ khi hai bản lệch.
 SELECT j.id, j.sales_order_id, o.dining_table_id, j.station_code, j.status,
        o.status AS order_status, s.status AS session_status,
        c.menu_component_id, coalesce(c.component_name, 'nước chấm') AS component_name,
        CASE WHEN c.takes_filling THEN ARRAY(
          SELECT DISTINCT x.menu_option_id FROM order_line_option x
          WHERE x.order_line_id = j.order_line_id ORDER BY x.menu_option_id
        ) ELSE ARRAY[]::bigint[] END AS filling_option_ids
 FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
 LEFT JOIN table_session s ON s.id = o.table_session_id
 LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
 -- khoá gom: cuối
 -- Chỉ phần còn sống, không quét cả lịch sử: nhu cầu và ứng viên chỉ lấy từ đây, nguồn là $2.
 WHERE o.status = 'in_progress' OR (s.status IS NOT NULL AND s.status <> 'closed') OR j.id = $2::bigint
), phan AS (
 SELECT station_code, menu_component_id, filling_option_ids,
        min(component_name) AS component_name, dining_table_id,
        CASE WHEN dining_table_id IS NULL THEN sales_order_id END AS sales_order_id,
        count(*) AS ordered, count(*) FILTER (WHERE status = 'pending') AS pending,
        count(*) FILTER (WHERE status = 'made') AS made,
        count(*) FILTER (WHERE status = 'served') AS served,
        count(*) FILTER (WHERE status <> 'served') AS missing
 FROM viec WHERE $2::bigint = 0 AND order_status <> 'cancelled'
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
 SELECT v.id, v.sales_order_id, v.dining_table_id, v.station_code, v.status, v.order_status, v.session_status,
   v.menu_component_id, v.component_name, v.filling_option_ids, v.order_status = 'cancelled' AND v.status = 'made'
   AND EXISTS (SELECT 1 FROM production_batch_item i WHERE i.live_station_job_id = v.id)
   AND NOT EXISTS (SELECT 1 FROM wrong_make_note n WHERE n.live_station_job_id = v.id) AS available
 FROM viec v WHERE v.id = $2
)
SELECT EXISTS (SELECT 1 FROM nguon)::boolean AS co_nguon,
 coalesce((SELECT available FROM nguon), false)::boolean AS nguon_hop,
 (CASE WHEN $2::bigint = 0 THEN jsonb_build_object('read_at', now(), 'poll_interval_seconds', $3::integer, 'rows', coalesce(
   (SELECT jsonb_agg(to_jsonb(h) ORDER BY station_code, menu_component_id, filling_option_ids)
    FROM hang h), '[]'::jsonb))
 ELSE jsonb_build_object('station_job_id', $2::bigint, 'candidates', coalesce((
   SELECT jsonb_agg(jsonb_build_object('station_job_id', d.id, 'sales_order_id', d.sales_order_id,
     'dining_table_id', d.dining_table_id) ORDER BY d.id)
   FROM viec d JOIN nguon n ON d.station_code = n.station_code
     AND d.menu_component_id IS NOT DISTINCT FROM n.menu_component_id
     AND d.filling_option_ids = n.filling_option_ids
   WHERE d.id <> n.id AND d.status = 'pending' AND d.order_status = 'in_progress'
 ), '[]'::jsonb)) END)::jsonb AS ket_qua;
