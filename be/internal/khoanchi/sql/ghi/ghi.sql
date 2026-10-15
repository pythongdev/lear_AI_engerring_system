-- name: Ghi :one
INSERT INTO expense (expense_category_id, amount_vnd, paid_date)
VALUES ($1, $2, $3::text::date) RETURNING id;
