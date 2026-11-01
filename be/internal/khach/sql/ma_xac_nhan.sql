-- name: MaXacNhan :one
SELECT id, customer_account_id, email FROM customer_email_verification WHERE token_hash=$1 AND used_at IS NULL AND expires_at>clock_timestamp();
