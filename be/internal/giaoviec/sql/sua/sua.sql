-- name: Sua :exec
UPDATE assigned_task SET content = $2, assignee_person_id = $3, due_at = coalesce($4::timestamptz, due_at) WHERE id = $1;
