-- name: Chot :execrows
UPDATE model_call SET settled_at = clock_timestamp(),
input_token_count = CASE WHEN $2::boolean THEN $3::integer ELSE NULL END,
output_token_count = CASE WHEN $2::boolean THEN $4::integer ELSE NULL END,
cost_microusd = $5::bigint WHERE id = $1;
