-- name: ThemThanhPhan :one
INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ($1, $2, $3) RETURNING id;
