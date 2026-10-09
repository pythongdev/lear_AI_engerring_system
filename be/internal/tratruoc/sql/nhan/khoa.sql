SELECT table_session_id, status FROM sales_order WHERE id = $1 FOR UPDATE
