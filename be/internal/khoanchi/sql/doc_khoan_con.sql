-- name: DocKhoanCon :many
SELECT id, expense_category_id, name FROM expense_item WHERE deleted_at IS NULL ORDER BY name, id;
