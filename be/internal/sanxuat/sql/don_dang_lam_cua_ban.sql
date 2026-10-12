-- name: DonDangLamCuaBan :many
SELECT id FROM sales_order WHERE dining_table_id = $1 AND status = 'in_progress' ORDER BY id;
