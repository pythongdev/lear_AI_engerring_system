-- name: Huy :exec
UPDATE leave_notice SET cancelled_at = now(), cancelled_by_person_id = actor_person_id() WHERE id = $1;
