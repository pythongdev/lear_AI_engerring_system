-- name: ThemKhoanCon :one
INSERT INTO expense_item (expense_category_id, name) VALUES ($1, $2) RETURNING id, expense_category_id, name;
