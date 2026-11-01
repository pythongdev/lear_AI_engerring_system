-- name: TaoXacNhan :exec
INSERT INTO customer_email_verification(customer_account_id,email,token_hash,expires_at) VALUES ($1,$2,$3,now()+interval '24 hours');
