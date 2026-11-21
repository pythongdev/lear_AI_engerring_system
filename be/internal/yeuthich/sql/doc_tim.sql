-- name: DocTim :one
SELECT id FROM customer_favourite_line
WHERE id = $1 AND customer_account_id = $2 AND favourite_set_id IS NULL
  AND parent_line_id IS NULL AND removed_at IS NULL;
