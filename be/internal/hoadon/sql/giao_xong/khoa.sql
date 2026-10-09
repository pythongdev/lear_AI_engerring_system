SELECT table_session_id, status, channel_code, handover_code FROM sales_order WHERE id = $1 FOR UPDATE
