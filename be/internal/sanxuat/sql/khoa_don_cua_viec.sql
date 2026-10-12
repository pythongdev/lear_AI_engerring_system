-- name: KhoaDonCuaViec :many
SELECT o.id FROM sales_order o WHERE o.id IN (
 SELECT j.sales_order_id FROM station_job j WHERE j.id = ANY($1::bigint[]))
 ORDER BY o.id FOR UPDATE;
