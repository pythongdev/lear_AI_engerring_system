-- name: TimThu :one
SELECT s.name, (s.deleted_at IS NOT NULL)::boolean AS stopped,
  EXISTS (SELECT 1 FROM expense_item i WHERE i.supply_item_id = s.id)::boolean AS linked
FROM supply_item s WHERE s.id = $1 FOR UPDATE OF s;
