-- name: DaMu :one
SELECT EXISTS (SELECT 1 FROM shop_blind_spell WHERE ended_at IS NULL)::boolean;
