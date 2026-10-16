-- Ngày bán theo timezone kết nối của quán, mốc từ ngayban.DongHo.
-- name: Ngay :one
SELECT ($1::timestamptz)::date::text AS sale_date;
