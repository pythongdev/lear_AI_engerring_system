-- name: ChuyenMuc :exec
UPDATE expense_item SET expense_category_id = $2 WHERE id = $1 AND deleted_at IS NULL;
