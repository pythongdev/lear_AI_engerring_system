-- name: ThemKhoanCon :one
INSERT INTO expense_item (expense_category_id, name, tracks_supply, supply_item_id)
VALUES ($1, $2, $3, $4) RETURNING id, expense_category_id, name, supply_item_id;
