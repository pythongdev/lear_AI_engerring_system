-- name: DaBiet :exec
UPDATE leave_notice SET acknowledged_at = now(), acknowledged_by_person_id = actor_person_id() WHERE id = $1;
