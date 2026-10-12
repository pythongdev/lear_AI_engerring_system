-- name: KhoaPhanSong :one
SELECT id FROM production_batch_item WHERE live_station_job_id = $1 FOR UPDATE;
