INSERT INTO bill (table_session_id, sales_order_id, due_vnd, cash_vnd, transfer_vnd,
 prepaid_cash_vnd, prepaid_transfer_vnd, debt_vnd, debtor_name, booked_at, sale_date, debt_note)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$10::timestamptz::date,$11) RETURNING id
