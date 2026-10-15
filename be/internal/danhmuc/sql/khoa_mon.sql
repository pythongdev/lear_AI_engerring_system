-- name: KhoaMon :one
SELECT id FROM menu_item WHERE id = $1 FOR NO KEY UPDATE;
