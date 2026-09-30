-- kêu: I-018/3 I-009/3
-- Chủ quán tăng giá giò lúc 10:02; lúc 10:30 quầy sửa dòng "Suất giò" của đơn tới lấy sang giá
-- mới mà không khai lý do — không vết nào mang giá trước và sau của dòng ấy.
DO $$ DECLARE mc bigint := (SELECT id FROM menu_component WHERE name = 'Giò'); l bigint; BEGIN
  UPDATE menu_component SET base_price_vnd = base_price_vnd + 1000 WHERE id = mc;
  UPDATE record_revision SET revised_at = pg_temp.bc_luc('10:02')
   WHERE target_table_code = 'menu_component' AND target_row = mc;
  SELECT id INTO l FROM order_line WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
  PERFORM set_config('shop.revision_reason', '', true);
  UPDATE order_line SET priced_at = pg_temp.bc_luc('10:30') WHERE id = l;
  UPDATE order_line SET unit_price_vnd = pg_temp.gia_dong_tai(l) WHERE id = l;
END $$;
