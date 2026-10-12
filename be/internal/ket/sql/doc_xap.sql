-- name: DocXapDem :many
SELECT id, denomination_vnd, amount_vnd FROM cash_count_line WHERE cash_count_id = $1 ORDER BY id;
