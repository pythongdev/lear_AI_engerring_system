-- Cửa menu/doi_gia_thanh_phan (P3-06, lớp chu_quan); người và lý do đã khai trong giao dịch.
-- name: DoiGia :one
UPDATE menu_component SET base_price_vnd = $2 WHERE id = $1
RETURNING id, base_price_vnd;
