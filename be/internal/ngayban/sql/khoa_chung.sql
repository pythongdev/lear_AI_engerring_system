-- name: KhoaChung :exec
SELECT pg_advisory_xact_lock_shared(309, $1::text::date - DATE '2000-01-01');
