-- name: DemThu :one
SELECT count(*) FROM customer_password_reset WHERE customer_account_id=$1 AND created_at>now()-interval '1 hour';
