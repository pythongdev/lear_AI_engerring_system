-- name: ThemKyNgay :one
INSERT INTO reconciled_day (sale_date, gap_vnd, gap_explanation, previous_reconciled_day_id)
VALUES ($1::date, $2, $3, $4) RETURNING id;
