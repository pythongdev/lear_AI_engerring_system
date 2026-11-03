-- name: KhoaLoai :one
SELECT id FROM expense_category WHERE id = $1 AND deleted_at IS NULL FOR UPDATE;
