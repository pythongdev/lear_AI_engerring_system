-- name: ThemDongMangDi :one
INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, priced_at)
VALUES ($1, $2, $3, $4, $5, $6, COALESCE($7::timestamptz, now()))
RETURNING id;
