-- name: DatToiThieu :one
INSERT INTO daily_minimum (sale_date, minimum_banh, minimum_workers)
VALUES ($1::text::date, $2, $3)
ON CONFLICT (sale_date) DO UPDATE
SET minimum_banh = EXCLUDED.minimum_banh, minimum_workers = EXCLUDED.minimum_workers
RETURNING sale_date::text, minimum_banh, minimum_workers, person_id, created_at;
