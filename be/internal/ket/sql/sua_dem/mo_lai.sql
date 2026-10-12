-- name: MoLaiNgay :exec
INSERT INTO reconciled_day_reopening (reconciled_day_id, sale_date, reason)
VALUES ($1, $2::text::date, $3);
