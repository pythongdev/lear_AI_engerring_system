INSERT INTO prepayment (sales_order_id, cash_vnd, transfer_vnd, booked_at, sale_date)
VALUES ($1, $2, $3, $4, $4::timestamptz::date) RETURNING id
