-- name: Ghi :one
INSERT INTO station_message (recipient_person_id, work_code, body, dining_table_id, reply_to_message_id, submission_code)
VALUES ($1, $2, $3, $4, $5, $6) RETURNING id;
