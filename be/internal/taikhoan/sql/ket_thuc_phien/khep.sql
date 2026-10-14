-- name: KetThucPhien :exec
UPDATE login_session SET ended_at=now(), end_reason=$3 WHERE account_id=$1 AND ended_at IS NULL AND ($2::bigint=0 OR id=$2);
