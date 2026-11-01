-- name: LinkGoogle :exec
INSERT INTO customer_google_identity (customer_account_id, google_sub_code) VALUES ($1, $2);
