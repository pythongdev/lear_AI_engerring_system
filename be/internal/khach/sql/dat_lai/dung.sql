-- name: DungMa :exec
UPDATE customer_password_reset SET used_at=now() WHERE id=$1;
