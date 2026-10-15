-- name: Khoa :one
SELECT hidden_at FROM menu_category WHERE id = $1 FOR UPDATE;
