-- name: DemThu :one
SELECT count(*) FROM password_reset WHERE account_id=$1 AND created_at>now()-interval '1 hour';
