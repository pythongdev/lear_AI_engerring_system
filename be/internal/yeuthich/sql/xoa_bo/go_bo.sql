-- name: GoBo :exec
UPDATE customer_favourite_set SET removed_at = now()
WHERE id = $1 AND customer_account_id = $2 AND removed_at IS NULL;
