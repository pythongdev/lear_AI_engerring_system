-- name: CoVetChuyen :one
SELECT EXISTS (SELECT 1 FROM station_job_transfer t
 JOIN production_batch_item i ON i.id = t.production_batch_item_id
 WHERE t.id = $1 AND t.from_station_job_id = $2 AND i.station_job_id = t.to_station_job_id
 AND NOT i.batch_rolled_back);
