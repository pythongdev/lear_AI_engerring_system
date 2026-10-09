INSERT INTO wrong_make_note (station_job_id, sales_order_id, note) VALUES ($1, $2, $3) RETURNING id;
