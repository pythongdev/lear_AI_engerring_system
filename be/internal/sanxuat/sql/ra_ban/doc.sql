SELECT NOT EXISTS (SELECT 1 FROM station_job WHERE sales_order_id = $1 AND status <> 'served');
