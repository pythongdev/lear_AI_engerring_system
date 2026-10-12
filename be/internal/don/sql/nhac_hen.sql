-- Giữ độ lệch múi giờ của phiên PostgreSQL như hợp đồng §6.
-- name: NhacHen :many
SELECT id, to_jsonb(customer_needed_at)::jsonb AS needed_at, status FROM sales_order
 WHERE channel_code = 'phone_preorder' AND status IN ('confirmed', 'in_progress')
 ORDER BY customer_needed_at, id;
