-- name: Bao :one
INSERT INTO leave_notice (leave_date, submission_code) VALUES ($1, $2) RETURNING id;
