-- name: DocKhoan :one
SELECT e.id, e.expense_category_id, c.name AS category_name, c.paid_from_till, e.amount_vnd, e.paid_date::text AS paid_date, e.person_id, p.display_name AS person_name, e.created_at
FROM expense e JOIN expense_category c ON c.id = e.expense_category_id JOIN person p ON p.id = e.person_id
WHERE e.id = $1;
