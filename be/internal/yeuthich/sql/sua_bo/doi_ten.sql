-- name: DoiTen :exec
UPDATE customer_favourite_set SET name = $3
WHERE id = $1 AND customer_account_id = $2 AND removed_at IS NULL;
