-- name: ChuyenDon :exec
UPDATE sales_order SET status = $2 WHERE id = $1;
