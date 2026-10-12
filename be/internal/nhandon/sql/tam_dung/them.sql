-- name: TamDung :one
INSERT INTO order_intake_pause (started_at) VALUES (now())
RETURNING jsonb_build_object('id', id, 'started_at', started_at,
 'started_by_person_id', started_by_person_id, 'ended_at', ended_at,
 'ended_by_person_id', ended_by_person_id)::jsonb AS result;
