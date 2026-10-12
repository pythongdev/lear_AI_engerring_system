-- name: ChuyenViec :exec
UPDATE station_job SET status = $2 WHERE id = $1;
