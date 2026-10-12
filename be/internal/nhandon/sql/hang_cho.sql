-- name: HangCho :one
SELECT jsonb_build_object('read_at', now(), 'poll_interval_seconds', $1::integer,
 'paused_since', (SELECT started_at FROM order_intake_pause WHERE ended_at IS NULL),
 'blind_since', (SELECT started_at FROM shop_blind_spell WHERE ended_at IS NULL),
 'orders', coalesce((SELECT jsonb_agg(jsonb_build_object(
   'sales_order_id', id, 'channel_code', channel_code, 'dining_table_id', dining_table_id,
   'created_at', created_at, 'customer_phone', customer_phone, 'customer_needed_at', customer_needed_at)
   ORDER BY created_at, id) FROM sales_order WHERE status = 'pending_confirmation'), '[]'::jsonb))::jsonb AS result;
