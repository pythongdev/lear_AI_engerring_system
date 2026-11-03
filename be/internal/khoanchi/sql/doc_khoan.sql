-- name: DocKhoan :one
SELECT e.id, e.expense_category_id, c.name AS category_name, c.paid_from_till, e.amount_vnd, e.paid_date::text AS paid_date, e.person_id, p.display_name AS person_name, e.created_at, e.expense_item_id, i.name AS item_name
FROM expense e JOIN expense_category c ON c.id = e.expense_category_id JOIN person p ON p.id = e.person_id LEFT JOIN expense_item i ON i.id = e.expense_item_id
WHERE e.deleted_at IS NULL AND e.id = $1;
