-- name: DocMa :one
SELECT id, account_id, token_hash, created_at, expires_at, used_at FROM password_reset WHERE token_hash=$1 AND used_at IS NULL AND expires_at>now() FOR UPDATE;
