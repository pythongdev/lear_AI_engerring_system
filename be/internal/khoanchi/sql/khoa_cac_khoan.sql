-- name: KhoaCacKhoan :many
SELECT id, amount_vnd, paid_date::text AS paid_date, COALESCE(received_date::text, '')::text AS received_date
FROM expense WHERE expense_item_id = $1 ORDER BY id FOR UPDATE;
