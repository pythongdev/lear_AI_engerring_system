-- name: KhoaKhoanCon :one
SELECT expense_category_id, supply_item_id, (deleted_at IS NOT NULL)::boolean AS stopped FROM expense_item WHERE id = $1 FOR UPDATE;
