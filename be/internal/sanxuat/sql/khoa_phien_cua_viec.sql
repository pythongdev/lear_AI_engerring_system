-- Mọi cửa khoá phiên trước đơn, rồi các đơn vị theo id.
-- name: KhoaPhienCuaViec :many
SELECT s.id FROM table_session s WHERE s.id IN (
 SELECT o.table_session_id FROM sales_order o JOIN station_job j ON j.sales_order_id = o.id
 WHERE j.id = ANY($1::bigint[])) ORDER BY s.id FOR UPDATE;
