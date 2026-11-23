-- name: Sua :exec
UPDATE expense SET expense_category_id = $2, amount_vnd = $3, paid_date = $4::text::date, expense_item_id = $5, received_date = NULLIF($6::text, '')::date WHERE id = $1;
