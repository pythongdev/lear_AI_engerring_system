-- name: KhoaDonDangLam :many
SELECT o.id FROM sales_order o WHERE o.id = ANY($1::bigint[]) AND o.status = 'in_progress'
 ORDER BY o.id FOR UPDATE;
