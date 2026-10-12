-- name: DocDem :one
SELECT id FROM cash_count WHERE sale_date = $1::text::date;
