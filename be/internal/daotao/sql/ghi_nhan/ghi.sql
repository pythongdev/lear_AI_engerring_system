-- name: GhiNhan :one
INSERT INTO training_record (trainee_person_id, remark, rating_code) VALUES ($1,$2,$3) RETURNING id;
