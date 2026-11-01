-- name: GoogleAccount :one
SELECT customer_account_id FROM customer_google_identity WHERE google_sub_code = $1;
