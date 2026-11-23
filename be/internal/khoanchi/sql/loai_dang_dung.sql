-- name: LoaiDangDung :one
SELECT (EXISTS (SELECT 1 FROM expense e WHERE e.expense_category_id = $1 AND e.deleted_at IS NULL)
    OR EXISTS (SELECT 1 FROM expense_item i WHERE i.expense_category_id = $1 AND i.supply_item_id IS NOT NULL AND i.deleted_at IS NULL))::boolean;
