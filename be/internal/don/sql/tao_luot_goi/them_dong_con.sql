-- Dòng suất con của một combo: món và ảnh chụp như dòng thường, giá là tổng mức combo của lựa chọn (ADR-117 điểm 2).
-- name: ThemDongCon :one
INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count,
 parent_order_line_id, is_takeaway, priced_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, COALESCE($9::timestamptz, now()))
RETURNING id;
