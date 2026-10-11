-- Cửa menu/doi_phu_thu (P3-06, lớp chu_quan); người và lý do đã khai trong giao dịch.
-- name: DoiPhuThu :one
UPDATE menu_option SET surcharge_vnd = $2 WHERE id = $1
RETURNING id, surcharge_vnd;
