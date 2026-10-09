INSERT INTO opening_float (sale_date) VALUES ($1::timestamptz::date) RETURNING id
