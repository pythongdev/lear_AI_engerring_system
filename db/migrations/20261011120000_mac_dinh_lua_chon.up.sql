-- T-169 — mặc định của nhóm tuỳ chọn thành dữ liệu (shop-facts §4.6 luật 8, F-059, ADR-094).
-- Ý định: docs/product/2-db/03-luoc-do-menu-gia.md §1 · §5. Không một tên lựa chọn nào ở đây:
-- lựa chọn nào là mặc định do dữ liệu mồi đọc từ owner lúc chạy (db/seed/seed.pl).
-- Cờ chỉ để màn gọi món CHỌN SẴN; cửa tạo lượt gọi không đọc nó và không tự điền (I-010).
-- Thêm cột có giá trị mặc định không chạm dòng nào, nên trigger vết không chạy (ADR-092).
ALTER TABLE menu_option
  ADD COLUMN is_default boolean NOT NULL DEFAULT false;

-- Mỗi nhóm nhiều nhất một mặc định; nhóm không có mặc định là hợp lệ.
CREATE UNIQUE INDEX menu_option_one_default_per_group_key
  ON menu_option (option_group_id) WHERE is_default;
