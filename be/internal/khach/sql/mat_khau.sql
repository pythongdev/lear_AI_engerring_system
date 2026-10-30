-- name: MatKhau :one
SELECT password_hash FROM customer_password WHERE customer_account_id=$1 ORDER BY created_at DESC,id DESC LIMIT 1;
