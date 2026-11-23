-- name: TimKhoanCon :one
SELECT supply_item_id FROM expense_item WHERE id = $1 AND expense_category_id = $2 AND deleted_at IS NULL FOR SHARE;
