-- name: Ghi :one
INSERT INTO expense (expense_category_id, amount_vnd, paid_date, expense_item_id)
VALUES ($1, $2, $3::text::date, $4) RETURNING id;
