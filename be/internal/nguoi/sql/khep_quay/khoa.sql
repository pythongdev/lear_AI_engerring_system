-- name: KhoaKhoang :one
SELECT id FROM counter_duty WHERE id=$1 AND person_id=$2 AND ended_at IS NULL FOR UPDATE;
