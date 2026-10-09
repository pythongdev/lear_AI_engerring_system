INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id) SELECT $1, v, v FROM unnest($2::bigint[]) AS v;
