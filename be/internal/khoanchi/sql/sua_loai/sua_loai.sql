-- name: SuaLoai :one
UPDATE expense_category SET name = $2 WHERE id = $1 AND deleted_at IS NULL RETURNING id, name, paid_from_till;
