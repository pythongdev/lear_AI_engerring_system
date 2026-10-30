-- name: Don :many
SELECT id,submission_code,created_at FROM sales_order WHERE customer_account_id=$1 AND ($2::bigint=0 OR id<$2) ORDER BY id DESC LIMIT $3::int;
