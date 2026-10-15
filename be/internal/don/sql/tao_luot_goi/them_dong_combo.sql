-- Dòng combo (ADR-117 điểm 2): giá combo tại mốc, không món, không thành phần; suất con ghi ngay sau trong cùng giao dịch.
-- name: ThemDongCombo :one
INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd, is_takeaway, priced_at)
VALUES ($1, $2, $3, $4, $5, $6, COALESCE($7::timestamptz, now()))
RETURNING id;
