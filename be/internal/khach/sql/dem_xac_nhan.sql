-- name: DemXacNhan :one
SELECT count(*) FROM customer_email_verification WHERE customer_account_id=$1 AND created_at>now()-interval '1 hour';
