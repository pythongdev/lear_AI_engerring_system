-- name: ThemDong :one
INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, is_takeaway, priced_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, COALESCE($8::timestamptz, now()))
RETURNING id;
