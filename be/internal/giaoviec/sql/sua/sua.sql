-- name: Sua :exec
UPDATE assigned_task SET content = $2, assignee_person_id = $3 WHERE id = $1;
