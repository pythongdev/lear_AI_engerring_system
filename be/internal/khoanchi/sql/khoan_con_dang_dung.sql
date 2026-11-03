-- name: KhoanConDangDung :one
SELECT EXISTS (SELECT 1 FROM expense WHERE expense_item_id = $1 AND deleted_at IS NULL);
