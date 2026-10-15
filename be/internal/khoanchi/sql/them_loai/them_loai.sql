-- name: ThemLoai :one
INSERT INTO expense_category (name, paid_from_till) VALUES ($1, $2)
RETURNING id, name, paid_from_till;
