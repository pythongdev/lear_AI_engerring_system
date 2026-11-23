-- name: ThemLoai :one
INSERT INTO expense_category (name, paid_from_till, tracks_supply) VALUES ($1, $2, $3)
RETURNING id, name, paid_from_till, tracks_supply;
