-- Đường lùi bước 17 (T-137; ADR-081). Bước này không dựng bảng: vết thêm dòng con nằm ở
-- record_revision (bước 8) và không bị gỡ. KHOÁ CHẶN: đã có vết thêm dòng con thì từ chối trước khi gỡ
-- gì — gỡ trigger lúc ấy là để lần thêm sau đi qua không vết trong khi lần thêm trước có vết, tức mở lại
-- chỗ hở F-047 trên dữ liệu đã ghi (luật 2 của 07-thu-tu-migration.md, cùng lối bước 16).
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM record_revision
  WHERE (target_table_code = 'sales_order'   AND after_image ? 'order_line')
     OR (target_table_code = 'menu_item'     AND after_image ? 'menu_item_component')
     OR (target_table_code = 'opening_float' AND after_image ? 'opening_float_line');
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: record_revision đang giữ % vết thêm dòng con đã ghi — gỡ trigger là để lần thêm sau mất vết', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER opening_float_line_added_line_trg ON opening_float_line;
DROP TRIGGER menu_item_component_added_line_trg ON menu_item_component;
DROP TRIGGER order_line_added_line_trg ON order_line;
DROP FUNCTION record_revision_capture_added_line();
