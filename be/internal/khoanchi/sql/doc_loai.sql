-- name: DocLoai :many
SELECT c.id, c.name, c.paid_from_till, c.tracks_supply,
  COALESCE((SELECT max(e.paid_date)::text FROM expense e WHERE e.expense_category_id = c.id AND e.deleted_at IS NULL), '')::text AS last_paid_date
FROM expense_category c WHERE c.deleted_at IS NULL ORDER BY c.name;
