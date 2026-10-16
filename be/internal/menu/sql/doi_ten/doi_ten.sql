-- name: DoiTenMon :one
UPDATE menu_item SET name = $2 WHERE id = $1 RETURNING id, name;
