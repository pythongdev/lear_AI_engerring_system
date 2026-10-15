-- kêu: I-034/2 I-034/4 I-034/7
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/2', true);
END $$;
-- Một dòng combo 0đ ghi đúng luật kèm một suất con, rồi vượt quyền xoá suất con: dòng combo đứng không dòng con nào,
-- combo ấy thiếu suất, và giá 0đ khác giá combo tại mốc.
DO $$
DECLARE lc bigint; l bigint; g order_line;
BEGIN
  SELECT * INTO g FROM order_line WHERE id = (SELECT id FROM bc WHERE ten = 'dong_combo');
  INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd, priced_at, created_at)
  VALUES (g.sales_order_id, 1, g.menu_combo_id, g.item_name, 0, g.priced_at, g.priced_at) RETURNING id INTO lc;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count,
                          parent_order_line_id, priced_at, created_at)
  SELECT g.sales_order_id, 1, c.menu_item_id, c.item_name, 0, 1, lc, g.priced_at, g.priced_at
  FROM order_line c WHERE c.parent_order_line_id = g.id ORDER BY c.id LIMIT 1 RETURNING id INTO l;
  INSERT INTO order_line_component (order_line_id, position, line_component_count, menu_component_id,
                                    component_name, quantity, takes_filling, base_price_vnd)
  SELECT l, 1, 1, menu_component_id, component_name, quantity, takes_filling, base_price_vnd
  FROM order_line_component WHERE order_line_id = (SELECT min(id) FROM order_line WHERE parent_order_line_id = g.id)
  ORDER BY position LIMIT 1;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  DELETE FROM order_line_component WHERE order_line_id = l;
  DELETE FROM order_line WHERE id = l;
END $$;
