SELECT j.status, o.status FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id WHERE j.id = $1 FOR UPDATE OF j;
