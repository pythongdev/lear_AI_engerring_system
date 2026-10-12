-- name: QuanMu :one
SELECT EXISTS (SELECT 1 FROM shop_blind_spell
 WHERE tstzrange(started_at, ended_at, '[)') @> $1::timestamptz)::boolean;
