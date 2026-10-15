-- name: AnGhiNhan :exec
UPDATE training_record SET hidden_at = now(), hidden_by_person_id = actor_person_id() WHERE id = $1;
