-- name: Tao :one
INSERT INTO assigned_task (content, assignee_person_id) VALUES ($1, $2) RETURNING id;
