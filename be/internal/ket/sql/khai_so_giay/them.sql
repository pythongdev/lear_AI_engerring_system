-- name: ThemSoGiay :one
INSERT INTO paper_ledger (sale_date, entry_count)
VALUES ($1::text::date, $2) RETURNING id;
