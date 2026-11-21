-- name: TimBo :one
SELECT id, kind, name FROM customer_favourite_set
WHERE id = $1 AND customer_account_id = $2 AND removed_at IS NULL;
