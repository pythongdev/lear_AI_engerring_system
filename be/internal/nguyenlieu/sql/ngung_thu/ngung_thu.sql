-- name: NgungThu :exec
UPDATE supply_item SET deleted_at = now(), deleted_by_person_id = actor_person_id() WHERE id = $1 AND deleted_at IS NULL;
