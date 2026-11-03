-- name: DocLoai :many
SELECT id, name, paid_from_till FROM expense_category WHERE deleted_at IS NULL ORDER BY name;
