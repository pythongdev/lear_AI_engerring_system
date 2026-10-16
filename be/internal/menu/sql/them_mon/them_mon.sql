-- name: ThemMon :one
INSERT INTO menu_item (name) VALUES ($1) RETURNING id, name;
