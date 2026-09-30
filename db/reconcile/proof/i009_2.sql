-- kêu: I-009/2 I-013/1
-- Chủ quán tăng giá bánh cuốn lúc 10:02; bàn 10 gọi bánh cuốn lúc 10:00 và 10:05 — lượt sau vẫn
-- mang giá cũ. Lần đổi giá là một lần sửa thật; mốc của vết đặt vào 10:02 của ngày mẫu.
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); a bigint; b bigint;
              la bigint; lb bigint; mc bigint := (SELECT id FROM menu_component WHERE name = 'Bánh cuốn'); BEGIN
  a := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:00'));
  la := pg_temp.bc_mon(a, 'Bánh cuốn', 1, ARRAY['Chay']);
  b := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:05'));
  lb := pg_temp.bc_mon(b, 'Bánh cuốn', 1, ARRAY['Chay']);
  UPDATE menu_component SET base_price_vnd = base_price_vnd + 1000 WHERE id = mc;
  UPDATE record_revision SET revised_at = pg_temp.bc_luc('10:02')
   WHERE target_table_code = 'menu_component' AND target_row = mc;
END $$;
