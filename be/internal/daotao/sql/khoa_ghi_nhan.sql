-- name: KhoaGhiNhan :one
SELECT hidden_at FROM training_record WHERE id = $1 FOR UPDATE;
