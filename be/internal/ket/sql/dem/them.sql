INSERT INTO cash_count (sale_date) VALUES ($1::timestamptz::date) RETURNING id
