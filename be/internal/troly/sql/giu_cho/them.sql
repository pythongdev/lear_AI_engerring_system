-- name: GiuCho :one
INSERT INTO model_call (provider_code, model_code, reserved_microusd)
VALUES ($1, $2, $3) RETURNING id;
