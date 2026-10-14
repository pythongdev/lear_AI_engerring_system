-- name: DocPhien :one
SELECT s.id, s.account_id, s.token_hash, s.created_at, s.expires_at, s.ended_at, s.end_reason, s.counter_duty_id FROM login_session s JOIN account a ON a.id=s.account_id WHERE s.token_hash=$1 AND s.ended_at IS NULL AND s.expires_at>now() AND a.status='hoat_dong';
