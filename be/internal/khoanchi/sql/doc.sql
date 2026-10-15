-- name: Doc :many
SELECT e.id, e.expense_category_id, c.name AS category_name, c.paid_from_till, e.amount_vnd, e.paid_date::text AS paid_date, e.person_id, p.display_name AS person_name, e.created_at
FROM expense e JOIN expense_category c ON c.id = e.expense_category_id JOIN person p ON p.id = e.person_id
WHERE e.paid_date >= $1::text::date AND e.paid_date <= $2::text::date
  AND ($3::bigint = 0 OR e.expense_category_id = $3::bigint)
  AND (NOT $4::boolean OR c.paid_from_till = $5::boolean)
ORDER BY e.paid_date, e.id;
