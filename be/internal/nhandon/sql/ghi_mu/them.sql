-- name: GhiMu :one
INSERT INTO shop_blind_spell (started_at, declared_by_person_id)
SELECT least(now(), greatest($1::timestamptz,
 (SELECT max(ended_at) FROM shop_blind_spell))), nullif($2::bigint, 0)
WHERE NOT EXISTS (SELECT 1 FROM shop_blind_spell WHERE ended_at IS NULL)
RETURNING jsonb_build_object('id', id, 'started_at', started_at,
 'declared_by_person_id', declared_by_person_id, 'ended_at', ended_at,
 'ended_by_person_id', ended_by_person_id)::jsonb AS result;
