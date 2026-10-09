INSERT INTO refund (bill_id, prepayment_id, amount_vnd, method_code, source_method_code,
 reason, booked_at, sale_date) VALUES ($1,$2,$3,$4,$5,$6,$7,$7::timestamptz::date) RETURNING id
