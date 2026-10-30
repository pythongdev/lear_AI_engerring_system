-- name: TaoMa :exec
INSERT INTO customer_password_reset(customer_account_id,token_hash,expires_at) VALUES ($1,$2,now()+interval '30 minutes');
