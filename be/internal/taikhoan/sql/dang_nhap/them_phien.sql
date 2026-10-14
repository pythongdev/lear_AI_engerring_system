-- name: MoPhien :exec
INSERT INTO login_session (account_id,token_hash,expires_at,counter_duty_id) VALUES ($1,$2,now()+interval '7 days',$3);
