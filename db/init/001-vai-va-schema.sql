-- Chạy MỘT lần, lúc container database khởi tạo thư mục dữ liệu, dưới vai
-- shop_owner. Quy ước: docs/product/2-db/10-quy-uoc-code.md QC-03.
--
-- shop_owner  chủ của schema `shop`, chạy migration.
-- shop_app    vai hệ thống dùng để ghi: đọc · thêm · sửa, KHÔNG xoá (QD-50).
-- Mật khẩu dưới đây là mật khẩu máy phát triển.

CREATE ROLE shop_app LOGIN PASSWORD 'shop_app_dev';

REVOKE ALL ON DATABASE banhcuon FROM PUBLIC;
GRANT CONNECT ON DATABASE banhcuon TO shop_app;

CREATE SCHEMA shop AUTHORIZATION shop_owner;
REVOKE ALL ON SCHEMA shop FROM PUBLIC;
GRANT USAGE ON SCHEMA shop TO shop_app;

-- Mọi bảng shop_owner tạo về sau trong `shop` tự mang đúng ba quyền này.
-- Bảng kỹ thuật cần xoá (:bang_ky_thuat) thì migration của nó cấp thêm, kèm lý do.
ALTER DEFAULT PRIVILEGES FOR ROLE shop_owner IN SCHEMA shop
  GRANT SELECT, INSERT, UPDATE ON TABLES TO shop_app;
ALTER DEFAULT PRIVILEGES FOR ROLE shop_owner IN SCHEMA shop
  GRANT USAGE, SELECT ON SEQUENCES TO shop_app;

ALTER ROLE shop_owner SET search_path = shop, public;
ALTER ROLE shop_app   SET search_path = shop;
