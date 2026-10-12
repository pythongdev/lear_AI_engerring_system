-- Chủ của station_job không đổi; lần chuyển chỉ đổi chủ của production_batch_item.
-- name: KhoaViec :many
SELECT j.id, j.sales_order_id, o.table_session_id, j.status, o.status AS order_status,
 EXISTS (SELECT 1 FROM wrong_make_note n WHERE n.live_station_job_id = j.id)::boolean AS lam_sai
 FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
 WHERE j.id = ANY($1::bigint[]) ORDER BY j.id FOR UPDATE OF j;
