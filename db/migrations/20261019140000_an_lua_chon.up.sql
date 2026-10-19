-- T-210 — lựa chọn phụ thu (topping) ẩn được: chủ quán thêm lựa chọn vào nhóm có sẵn và ẩn · bật lại
-- (chủ repo 2026-10-19, master_plan/shop-facts.md §8.9 *QUẢN LÝ TOPPING*).
-- Ý định: docs/product/2-db/03-luoc-do-menu-gia.md §1 (đoạn bước 34). File này thắng về tên · kiểu · ràng buộc (ADR-053 luật 2).
-- Thêm lựa chọn là một dòng menu_option mới (cùng các dòng option_group_prerequisite chủ quán tích) — không bảng mới.
-- Ẩn là hai cột cùng khuôn ẩn của danh mục và combo (bước 26); bỏ ẩn là đặt hai cột về NULL, đi qua vết (bước 20).
-- Thêm cột không giá trị mặc định không chạm dòng nào, nên trigger vết không chạy.

ALTER TABLE menu_option
  ADD COLUMN hidden_at timestamptz,
  ADD COLUMN hidden_by_person_id bigint,
  ADD CONSTRAINT menu_option_hidden_by_person_fkey FOREIGN KEY (hidden_by_person_id) REFERENCES person (id),
  ADD CONSTRAINT menu_option_hidden_by_iff_hidden_check CHECK ((hidden_at IS NULL) = (hidden_by_person_id IS NULL)),
  ADD CONSTRAINT menu_option_hidden_after_created_check CHECK (hidden_at IS NULL OR hidden_at >= created_at);
