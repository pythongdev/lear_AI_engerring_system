-- name: KetThucPhien :exec
UPDATE customer_session SET ended_at=now(),end_reason=$4 WHERE customer_account_id=$1 AND ended_at IS NULL AND ($2::bigint=0 OR id=$2) AND ($3::bigint=0 OR id<>$3);
