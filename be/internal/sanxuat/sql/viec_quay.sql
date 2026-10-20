-- Việc và mẻ của quầy đọc từ cùng một ảnh dữ liệu (T-217, phiếu Claude).
-- name: ViecQuay :one
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
 WHERE o.status = 'in_progress' OR (s.status IS NOT NULL AND s.status <> 'closed')
   OR (o.status = 'cancelled' AND j.status = 'made'
     AND EXISTS (SELECT 1 FROM production_batch_item i WHERE i.live_station_job_id = j.id)
     AND NOT EXISTS (SELECT 1 FROM wrong_make_note n WHERE n.live_station_job_id = j.id))
), jobs AS (
 SELECT v.id AS station_job_id, v.sales_order_id, v.dining_table_id, v.station_code,
   v.menu_component_id, v.component_name, v.filling_option_ids, v.status, v.order_status,
   (SELECT i.production_batch_id FROM production_batch_item i WHERE i.live_station_job_id = v.id) AS production_batch_id,
   (SELECT n.id FROM wrong_make_note n WHERE n.live_station_job_id = v.id) AS wrong_make_note_id,
   v.order_status = 'cancelled' AND v.status = 'made'
   AND EXISTS (SELECT 1 FROM production_batch_item i WHERE i.live_station_job_id = v.id)
   AND NOT EXISTS (SELECT 1 FROM wrong_make_note n WHERE n.live_station_job_id = v.id) AS transferable
 FROM viec v
), batches AS (
 SELECT b.id AS production_batch_id, b.made_at,
   ARRAY(SELECT i.station_job_id FROM production_batch_item i
     WHERE i.production_batch_id = b.id ORDER BY i.station_job_id) AS station_job_ids,
   EXISTS (SELECT 1 FROM production_batch_item i JOIN station_job j ON j.id = i.station_job_id
     WHERE i.production_batch_id = b.id AND j.status = 'served') AS has_served_units
 FROM production_batch b
 WHERE NOT b.is_rolled_back AND EXISTS (
   SELECT 1 FROM production_batch_item i JOIN viec v ON v.id = i.station_job_id
   WHERE i.production_batch_id = b.id)
)
SELECT jsonb_build_object('read_at', now(), 'poll_interval_seconds', $1::integer,
 'jobs', coalesce((SELECT jsonb_agg(to_jsonb(j) ORDER BY station_job_id) FROM jobs j), '[]'::jsonb),
 'batches', coalesce((SELECT jsonb_agg(to_jsonb(b) ORDER BY production_batch_id) FROM batches b), '[]'::jsonb)
)::jsonb AS ket_qua;
