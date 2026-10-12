-- name: DocSoGiay :one
SELECT p.entry_count, coalesce(p.entry_count - (SELECT count(*) FROM bill b WHERE b.paper_ledger_id = p.id), 0)::bigint AS pending
FROM (SELECT $1::text::date AS sale_date) d
LEFT JOIN paper_ledger p ON p.sale_date = d.sale_date;
