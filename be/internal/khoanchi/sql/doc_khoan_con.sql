-- name: DocKhoanCon :many
SELECT i.id, i.expense_category_id, i.name, i.supply_item_id,
  COALESCE((SELECT max(e.paid_date)::text FROM expense e WHERE e.expense_item_id = i.id AND e.deleted_at IS NULL), '')::text AS last_paid_date
FROM expense_item i WHERE i.deleted_at IS NULL ORDER BY i.name, i.id;
