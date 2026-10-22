-- Khoá sau phiên và mọi đơn; cửa gọi chỉ chuyển pending/made, kể cả đơn đã huỷ từ trước.
-- name: KhoaViecCuaPhien :many
SELECT j.id, j.sales_order_id, j.status FROM station_job j
JOIN sales_order o ON o.id = j.sales_order_id
WHERE o.table_session_id = $1 ORDER BY j.id FOR UPDATE OF j;
