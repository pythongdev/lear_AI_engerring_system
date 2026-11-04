-- name: Dau :one
SELECT id FROM station_message WHERE submission_code = $1;
