-- name: DocSoNhapBu :one
SELECT id, entry_count FROM paper_ledger WHERE sale_date = $1::date;
