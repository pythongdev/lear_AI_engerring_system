-- name: ViecCuaMe :many
SELECT station_job_id FROM production_batch_item WHERE production_batch_id = $1 ORDER BY station_job_id;
