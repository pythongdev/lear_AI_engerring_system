-- Đơn của một phần (một bàn, hoặc một đơn không bàn) được khoá phiên trước đơn, như mọi cửa đụng việc.
-- name: KhoaPhienCuaDon :many
SELECT s.id FROM table_session s WHERE s.id IN (
 SELECT o.table_session_id FROM sales_order o WHERE o.id = ANY($1::bigint[])) ORDER BY s.id FOR UPDATE;
