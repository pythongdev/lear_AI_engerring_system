-- name: RoiQuanKhoaViec :many
SELECT id, status FROM station_job WHERE sales_order_id = $1 ORDER BY id FOR UPDATE;
