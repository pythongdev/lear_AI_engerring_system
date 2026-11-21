-- Đường lùi của 20261120100000_khoa_sua_dong_don.up.sql (T-341 — I-034).
-- Không có khoá chặn "đường lùi từ chối": luật 2 của docs/product/2-db/07-thu-tu-migration.md
-- chỉ chặn khi đường lùi gỡ chỗ đang cất dữ liệu, mà bước này chỉ thu quyền UPDATE.
GRANT UPDATE ON order_line, order_line_option TO shop_app;
