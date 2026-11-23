-- name: DocCon :one
SELECT id, expense_category_id, name, supply_item_id FROM expense_item WHERE id = $1;
