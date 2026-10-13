-- name: TrungViTriGiay :one
SELECT EXISTS (SELECT 1 FROM bill WHERE paper_ledger_id = $1 AND paper_position = $2)::boolean;
