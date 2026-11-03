-- name: KhoaKhoanCon :one
SELECT expense_category_id FROM expense_item WHERE id = $1 AND deleted_at IS NULL FOR UPDATE;
