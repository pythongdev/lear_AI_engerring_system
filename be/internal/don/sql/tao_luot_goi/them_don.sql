INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code, qr_code_id,
 handover_code, customer_phone, delivery_address, customer_needed_at, customer_name, contact_note)
VALUES ($1, $2, nullif($3::bigint, 0), nullif($4::bigint, 0), $5, $6, nullif($7, ''), nullif($8, ''), $9, $10, $11, $12)
RETURNING id
