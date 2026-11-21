-- name: DocBo :many
SELECT id, kind, name FROM customer_favourite_set
WHERE customer_account_id = $1 AND removed_at IS NULL ORDER BY id;
