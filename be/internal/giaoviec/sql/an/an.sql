-- name: An :exec
UPDATE assigned_task SET hidden_at = now(), hidden_by_person_id = actor_person_id() WHERE id = $1;
