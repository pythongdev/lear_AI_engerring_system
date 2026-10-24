-- name: Tao :one
INSERT INTO assigned_task (content, assignee_person_id, due_at) VALUES ($1, $2, $3) RETURNING id;
