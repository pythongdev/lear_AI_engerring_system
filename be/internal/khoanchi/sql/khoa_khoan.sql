-- name: KhoaKhoan :one
SELECT e.paid_date::text AS paid_date, c.paid_from_till
FROM expense e JOIN expense_category c ON c.id = e.expense_category_id
WHERE e.id = $1 FOR UPDATE OF e;
