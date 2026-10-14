-- Đường lùi của 20261014160000_danh_muc_combo.up.sql (P2A-13 — danh mục và combo).
-- Thứ tự dựng và luật lùi: docs/product/2-db/07-thu-tu-migration.md · docs/decisions.md ADR-065.
--
-- KHOÁ CHẶN: đường lùi chỉ gỡ chỗ cất còn RỖNG. Bảng sắp gỡ có dòng ⇒ từ chối,
-- không gỡ gì (cả file là một giao dịch, QC-05). Lùi trên dữ liệu đã ghi bằng migration mới đi tới.
DO $$
DECLARE
  target text;
  n      bigint;
BEGIN
  FOREACH target IN ARRAY ARRAY['menu_combo_item', 'menu_combo', 'menu_item_category', 'menu_category'] LOOP
    EXECUTE format('SELECT count(*) FROM %I', target) INTO n;
    IF n > 0 THEN
      RAISE EXCEPTION 'đường lùi từ chối: % đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', target, n
        USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
    END IF;
  END LOOP;
END $$;

DROP TRIGGER menu_combo_has_item_check ON menu_combo;
DROP FUNCTION menu_combo_has_item_guard();
DROP TRIGGER menu_combo_item_record_revision_trg ON menu_combo_item;
DROP TABLE menu_combo_item;
DROP TRIGGER menu_combo_record_revision_trg ON menu_combo;
DROP TABLE menu_combo;
DROP TRIGGER menu_item_category_record_revision_trg ON menu_item_category;
DROP TABLE menu_item_category;
DROP TRIGGER menu_category_record_revision_trg ON menu_category;
DROP TABLE menu_category;
