-- name: AnHuongDan :exec
UPDATE assigned_task_guide SET hidden_at = now(), hidden_by_person_id = actor_person_id() WHERE id = $1;
