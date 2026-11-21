-- name: GoDong :exec
UPDATE customer_favourite_line SET removed_at = now()
WHERE customer_account_id = $1 AND removed_at IS NULL
  AND id = $2;
