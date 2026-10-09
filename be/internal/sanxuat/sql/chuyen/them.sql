INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id) VALUES ($1, $2, $3) RETURNING id;
