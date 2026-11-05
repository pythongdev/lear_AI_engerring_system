-- name: TongThang :one
SELECT coalesce(sum(coalesce(cost_microusd, reserved_microusd)), 0)::bigint
FROM model_call
WHERE date_trunc('month', created_at AT TIME ZONE 'Asia/Ho_Chi_Minh') = date_trunc('month', now() AT TIME ZONE 'Asia/Ho_Chi_Minh');
