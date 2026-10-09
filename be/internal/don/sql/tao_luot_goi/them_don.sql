INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code, qr_code_id)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id
