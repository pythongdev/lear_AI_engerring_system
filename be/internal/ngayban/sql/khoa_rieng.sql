-- name: KhoaRieng :exec
SELECT pg_advisory_xact_lock(309, $1::text::date - DATE '2000-01-01');
