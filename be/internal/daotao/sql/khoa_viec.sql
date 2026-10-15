-- name: KhoaViec :one
SELECT hidden_at FROM assigned_task WHERE id = $1 FOR UPDATE;
