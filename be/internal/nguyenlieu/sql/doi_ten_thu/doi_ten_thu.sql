-- name: DoiTenThu :exec
UPDATE supply_item SET name = $2 WHERE id = $1 AND deleted_at IS NULL;
