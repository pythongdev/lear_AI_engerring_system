-- name: MoThu :exec
UPDATE supply_item SET deleted_at = NULL, deleted_by_person_id = NULL WHERE id = $1 AND deleted_at IS NOT NULL;
