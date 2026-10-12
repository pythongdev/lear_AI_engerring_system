-- name: BanCuaDon :one
SELECT dining_table_id FROM sales_order WHERE id = $1;
