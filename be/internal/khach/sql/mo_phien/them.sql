-- name: MoPhien :exec
INSERT INTO customer_session(customer_account_id,token_hash,expires_at) VALUES ($1,$2,now()+interval '7 days');
