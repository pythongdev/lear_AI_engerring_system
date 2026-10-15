-- name: DanhDau :exec
INSERT INTO assigned_task_mark (assigned_task_id, mark_code) VALUES ($1, $2);
