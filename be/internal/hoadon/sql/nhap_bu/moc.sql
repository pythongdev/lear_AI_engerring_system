-- name: MocNhapBu :one
SELECT ($1::timestamptz::date = $2::date AND $1::timestamptz < $3::timestamptz)::boolean AS hop_le,
 to_jsonb($1::timestamptz)::jsonb AS booked_at;
