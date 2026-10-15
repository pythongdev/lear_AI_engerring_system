-- name: Khoa :one
SELECT hidden_at FROM menu_combo WHERE id = $1 FOR UPDATE;
