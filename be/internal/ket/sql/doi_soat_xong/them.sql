INSERT INTO reconciled_day (sale_date, gap_vnd, gap_explanation) VALUES ($1::date, $2, $3) RETURNING id
