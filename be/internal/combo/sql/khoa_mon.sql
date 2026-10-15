-- name: KhoaMon :one
SELECT discontinued_at FROM menu_item WHERE id = $1 FOR NO KEY UPDATE;
