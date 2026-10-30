-- name: Ma :one
SELECT id,customer_account_id FROM customer_password_reset WHERE token_hash=$1 AND used_at IS NULL AND expires_at>now();
