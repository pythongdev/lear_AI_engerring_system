-- name: LoaiDangDung :one
SELECT EXISTS (SELECT 1 FROM expense e WHERE e.expense_category_id = $1 AND e.deleted_at IS NULL);
