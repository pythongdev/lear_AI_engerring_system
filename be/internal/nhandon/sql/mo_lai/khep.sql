-- name: MoLai :one
UPDATE shop_blind_spell SET ended_at = now(), ended_by_person_id = actor_person_id()
WHERE ended_at IS NULL
RETURNING jsonb_build_object('id', id, 'started_at', started_at,
 'declared_by_person_id', declared_by_person_id, 'ended_at', ended_at,
 'ended_by_person_id', ended_by_person_id)::jsonb AS result;
