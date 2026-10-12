-- name: DaKy :one
SELECT EXISTS (SELECT 1 FROM reconciled_day WHERE sale_date = $1::text::date);
