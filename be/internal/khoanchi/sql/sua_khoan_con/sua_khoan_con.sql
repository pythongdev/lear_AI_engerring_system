-- name: SuaKhoanCon :one
UPDATE expense_item SET name = $2 WHERE id = $1 AND deleted_at IS NULL RETURNING id, expense_category_id, name;
