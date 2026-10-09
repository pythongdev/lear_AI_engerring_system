INSERT INTO reconciled_day (sale_date) VALUES ($1::date) RETURNING id
