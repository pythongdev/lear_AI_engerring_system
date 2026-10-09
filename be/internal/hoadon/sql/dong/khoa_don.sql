SELECT status FROM sales_order WHERE table_session_id = $1 ORDER BY id FOR UPDATE
