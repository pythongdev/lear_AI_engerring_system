INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, transfer_vnd,
 remaining_before_vnd, remaining_vnd, booked_at, sale_date)
VALUES ($1,$2,$3,$4,$5,$6,$7,$7::timestamptz::date) RETURNING id
