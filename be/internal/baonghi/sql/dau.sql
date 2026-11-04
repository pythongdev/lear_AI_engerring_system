-- name: Dau :one
SELECT id FROM leave_notice WHERE person_id = actor_person_id() AND submission_code = $1;
