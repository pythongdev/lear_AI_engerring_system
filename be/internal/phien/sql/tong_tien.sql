-- name: TongTien :one
SELECT coalesce(sum(l.line_total_vnd),0)::bigint
 FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
 WHERE o.table_session_id = $1 AND o.status <> 'cancelled';
