-- Đường lùi của 20261015120000_ban_combo.up.sql (T-193 — bán combo).
-- Thứ tự dựng và luật lùi: docs/product/2-db/07-thu-tu-migration.md · docs/decisions.md ADR-065.
--
-- KHOÁ CHẶN: đường lùi chỉ gỡ khi chỗ cất mới còn RỖNG — không mức nào, không dòng combo hay dòng con nào trên đơn.
-- Có dòng ⇒ từ chối, không gỡ gì (cả file là một giao dịch, QC-05). Lùi trên dữ liệu đã ghi bằng migration mới đi tới.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM menu_combo_item_option_surcharge;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: menu_combo_item_option_surcharge đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
  SELECT count(*) INTO n FROM order_line WHERE menu_combo_id IS NOT NULL OR parent_order_line_id IS NOT NULL;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: order_line đang giữ % dòng combo hay dòng suất con — gỡ cột là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER order_line_option_item_line_check ON order_line_option;
DROP FUNCTION order_line_option_item_line_guard();
DROP TRIGGER order_line_combo_has_child_check ON order_line;
DROP FUNCTION order_line_combo_has_child_guard();
ALTER TABLE order_line
  DROP CONSTRAINT order_line_combo_parent_fkey,
  DROP CONSTRAINT order_line_combo_parent_key,
  DROP CONSTRAINT order_line_combo_line_shape_check,
  DROP CONSTRAINT order_line_item_has_component_count_check,
  DROP CONSTRAINT order_line_item_xor_combo_check,
  DROP CONSTRAINT order_line_menu_combo_fkey,
  DROP COLUMN parent_is_combo_line,
  DROP COLUMN is_combo_line,
  DROP COLUMN parent_order_line_id,
  DROP COLUMN menu_combo_id,
  ALTER COLUMN component_count SET NOT NULL,
  ALTER COLUMN menu_item_id SET NOT NULL;

DROP TRIGGER menu_combo_item_option_surcharge_record_revision_trg ON menu_combo_item_option_surcharge;
DROP TRIGGER menu_combo_item_option_surcharge_option_of_item_check ON menu_combo_item_option_surcharge;
DROP FUNCTION menu_combo_item_option_surcharge_option_guard();
DROP TABLE menu_combo_item_option_surcharge;
