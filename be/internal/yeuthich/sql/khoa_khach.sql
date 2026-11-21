-- name: KhoaKhach :one
SELECT id FROM customer_account WHERE id = $1 FOR NO KEY UPDATE;
