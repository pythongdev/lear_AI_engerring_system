-- name: GoDongBo :exec
UPDATE customer_favourite_line SET removed_at = now()
WHERE customer_account_id = $1 AND favourite_set_id = $2 AND removed_at IS NULL;
