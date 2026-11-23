-- name: Ghi :one
INSERT INTO expense (expense_category_id, amount_vnd, paid_date, expense_item_id, received_date)
VALUES ($1, $2, $3::text::date, $4, NULLIF($5::text, '')::date) RETURNING id;
