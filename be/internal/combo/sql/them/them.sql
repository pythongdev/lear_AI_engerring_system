-- name: Them :one
INSERT INTO menu_combo (name, price_vnd) VALUES ($1, $2) RETURNING id;
