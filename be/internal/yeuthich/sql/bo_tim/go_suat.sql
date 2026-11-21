-- name: GoSuat :exec
UPDATE customer_favourite_line SET removed_at = now()
WHERE customer_account_id = $1 AND parent_line_id = $2 AND removed_at IS NULL;
