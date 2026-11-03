-- name: Xoa :exec
UPDATE expense SET deleted_at = now(), deleted_by_person_id = actor_person_id() WHERE id = $1;
