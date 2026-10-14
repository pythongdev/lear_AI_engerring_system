-- name: TaoMa :exec
INSERT INTO password_reset (account_id,token_hash,expires_at) VALUES ($1,$2,now()+interval '30 minutes');
