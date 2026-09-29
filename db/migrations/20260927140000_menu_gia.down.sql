-- Đường lùi của 20260927140000_menu_gia.up.sql (P2-05 — menu · giá · ảnh chụp giá lúc đặt).
-- Thứ tự dựng và luật lùi: docs/product/2-db/07-thu-tu-migration.md · docs/decisions.md ADR-065.
--
-- KHOÁ CHẶN: đường lùi chỉ gỡ chỗ cất còn RỖNG. Một bảng sắp gỡ có dòng, hay một cột ghi sắp gỡ
-- có giá trị ⇒ từ chối, không gỡ gì (cả file là một giao dịch, QC-05). Lùi trên dữ liệu đã ghi
-- đi bằng một migration mới đi tới. Cột tự tính và ràng buộc không cất dữ liệu nên không cần chặn.
DO $$
DECLARE
  target text;
  n      bigint;
BEGIN
  FOREACH target IN ARRAY ARRAY[
    'order_line_option', 'order_line_component', 'option_group_prerequisite',
    'menu_item_option_group', 'menu_option', 'option_group', 'menu_item_component', 'menu_item',
    'menu_component', 'order_line.menu_item_id', 'order_line.item_name',
    'order_line.unit_price_vnd', 'order_line.priced_at', 'order_line.component_count'
  ] LOOP
    IF position('.' IN target) = 0 THEN
      EXECUTE format('SELECT count(*) FROM %I', target) INTO n;
    ELSE
      EXECUTE format('SELECT count(%I) FROM %I', split_part(target, '.', 2),
                     split_part(target, '.', 1)) INTO n;
    END IF;
    IF n > 0 THEN
      RAISE EXCEPTION 'đường lùi từ chối: % đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', target, n
        USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
    END IF;
  END LOOP;
END $$;

-- Khoá ngoại vòng từ dòng đơn sang ảnh chụp thành phần: gỡ trước.
ALTER TABLE order_line DROP CONSTRAINT order_line_last_component_fkey;

-- Hai bảng ảnh chụp trỏ vào cột mới của dòng đơn: gỡ trước cột.
DROP TABLE order_line_option, order_line_component;

-- Khoá ngoại sang món và ràng buộc chỉ đứng trên các cột này đi cùng cột; cột phải đi trước
-- bảng menu mà nó trỏ tới.
ALTER TABLE order_line
  DROP COLUMN line_total_vnd,
  DROP COLUMN menu_item_id,
  DROP COLUMN item_name,
  DROP COLUMN unit_price_vnd,
  DROP COLUMN priced_at,
  DROP COLUMN component_count;

DROP TABLE option_group_prerequisite, menu_item_option_group, menu_option, option_group,
  menu_item_component, menu_item, menu_component;
