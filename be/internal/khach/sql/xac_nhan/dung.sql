-- name: DungXacNhan :exec
UPDATE customer_email_verification SET used_at=clock_timestamp() WHERE id=$1;
