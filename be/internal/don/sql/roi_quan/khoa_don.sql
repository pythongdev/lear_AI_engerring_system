SELECT status, handover_code FROM sales_order WHERE id = $1 FOR UPDATE
