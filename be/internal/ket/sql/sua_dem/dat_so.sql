-- name: DatSoDem :exec
UPDATE cash_count_line SET amount_vnd = $2 WHERE id = $1;
