-- name: DungMa :exec
UPDATE password_reset SET used_at=now() WHERE id=$1;
