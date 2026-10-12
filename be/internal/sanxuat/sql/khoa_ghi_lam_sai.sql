-- name: KhoaGhiLamSai :one
SELECT (cancelled_at IS NOT NULL)::boolean AS da_huy FROM wrong_make_note WHERE id = $1 FOR UPDATE;
