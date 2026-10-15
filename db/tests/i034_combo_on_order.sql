-- I-034 (tầng 1 · tầng 2) — bán combo, phần database (ADR-117 điểm 1 · 2 · 3; T-193):
--   * mức phụ thu theo món của combo là bảng riêng menu_combo_item_option_surcharge: mỗi cặp món của combo ·
--     lựa chọn một dòng, mức nguyên đồng ≥ 0, lựa chọn thuộc một nhóm mà món ấy mang, sửa có vết, không xoá;
--   * combo trên đơn là hai tầng trong chính order_line: DÒNG COMBO (menu_combo_id, không món, không thành phần,
--     không lựa chọn, không cha) và DÒNG SUẤT CON (món như dòng thường, parent_order_line_id trỏ về một dòng
--     combo CÙNG đơn, cùng dấu đem về); mỗi dòng combo có ít nhất một dòng con (kiểm lúc giao dịch kết thúc);
--   * tổng đơn vẫn là Σ line_total_vnd = giá combo + các mức đã chụp — không cộng giá món.
-- Vế "đủ suất" (số suất mỗi món = số phần × số combo), "chưa đặt mức thì 0đ", "khoá trong giờ bán" là tầng 3 —
-- cửa ghi và hàm giá xét (T-194 · T-195 · T-196); database KHÔNG xét, test nói thẳng ở cuối.
-- Số dưới đây là số GIẢ, không phải giá quán. Viết trước khi có lát (T-193, Claude Code): đỏ cho tới khi lát dựng.

DO $$ DECLARE p bigint; BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán i034', true) RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  PERFORM set_config('shop.revision_reason', 'test-i034_combo_on_order', true);
END $$;
DO $$
DECLARE
  c_banh bigint; c_trung bigint; m_cuon bigint; m_trung bigint; m_le bigint;
  g_nhan bigint; g_luong bigint; g_khac bigint; o_thit bigint; o_chay bigint; o_thuong bigint; o_nhieu bigint; o_khac bigint;
  cb bigint; ci_cuon bigint; ci_trung bigint; s_nhieu bigint;
  so bigint; so2 bigint; l_combo bigint; l_cuon bigint; l_trung1 bigint; l_trung2 bigint; l_le bigint; l_x bigint;
  r record; cn text; tong bigint;
BEGIN
  -- Menu giả: bánh cuốn (bánh nhận nhân), trứng (trứng nhận nhân); nhóm Nhân · Lượng nhân; một nhóm lạ món không mang.
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-i034 bánh', 100, true) RETURNING id INTO c_banh;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-i034 trứng', 300, true) RETURNING id INTO c_trung;
  INSERT INTO menu_item (name) VALUES ('test-i034 suất cuốn') RETURNING id INTO m_cuon;
  INSERT INTO menu_item (name) VALUES ('test-i034 suất trứng') RETURNING id INTO m_trung;
  INSERT INTO menu_item (name) VALUES ('test-i034 suất lẻ') RETURNING id INTO m_le;
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity)
  VALUES (m_cuon, c_banh, 4), (m_trung, c_trung, 1), (m_le, c_banh, 1);
  INSERT INTO option_group (name) VALUES ('test-i034 Nhân') RETURNING id INTO g_nhan;
  INSERT INTO option_group (name) VALUES ('test-i034 Lượng nhân') RETURNING id INTO g_luong;
  INSERT INTO option_group (name) VALUES ('test-i034 Nhóm lạ') RETURNING id INTO g_khac;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g_nhan, 'test-Thịt', 10) RETURNING id INTO o_thit;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g_nhan, 'test-Chay', 0) RETURNING id INTO o_chay;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g_luong, 'test-Thường', 0) RETURNING id INTO o_thuong;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g_luong, 'test-Nhiều', 5) RETURNING id INTO o_nhieu;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g_khac, 'test-Lạ', 0) RETURNING id INTO o_khac;
  INSERT INTO menu_item_option_group (menu_item_id, option_group_id)
  VALUES (m_cuon, g_nhan), (m_cuon, g_luong), (m_trung, g_nhan), (m_trung, g_luong);

  -- Combo: 1 suất cuốn + 2 suất trứng, giá riêng 5000.
  INSERT INTO menu_combo (name, price_vnd) VALUES ('test-i034 Combo', 5000) RETURNING id INTO cb;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (cb, m_cuon, 1) RETURNING id INTO ci_cuon;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (cb, m_trung, 2) RETURNING id INTO ci_trung;

  -- ===================== MỨC PHỤ THU THEO MÓN CỦA COMBO =====================
  -- Dương: chủ quán (vai ghi của hệ thống) đặt mức cho "Nhiều" của món trứng trong combo này; người và lúc tự điền.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd)
    VALUES (ci_trung, o_nhieu, 700) RETURNING id INTO s_nhieu;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-034: vai shop_app KHÔNG đặt được mức phụ thu trong combo: %', SQLERRM;
  END;
  SELECT s.surcharge_vnd, p.display_name AS nguoi, s.created_at IS NOT NULL AS co_luc INTO r
  FROM menu_combo_item_option_surcharge s JOIN person p ON p.id = s.person_id WHERE s.id = s_nhieu;
  IF r.surcharge_vnd IS DISTINCT FROM 700::bigint OR r.nguoi IS DISTINCT FROM 'test-chủ quán i034' OR NOT r.co_luc THEN
    RAISE EXCEPTION 'I-034: mức phụ thu trong combo không đọc lại được mức · người đặt · lúc đặt';
  END IF;
  RAISE NOTICE 'I-034 mức theo món của combo — trứng · Nhiều = %đ, người đặt %', r.surcharge_vnd, r.nguoi;

  -- Tầng 1: mức thiếu · âm · cặp trùng · món của combo hay lựa chọn không có thật · lựa chọn món không mang ⇒ từ chối.
  FOR r IN SELECT * FROM (VALUES
      (format('INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id) VALUES (%s, %s)', ci_cuon, o_nhieu), 'mức thiếu'),
      (format('INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES (%s, %s, -1)', ci_cuon, o_nhieu), 'mức âm'),
      (format('INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES (%s, %s, 900)', ci_trung, o_nhieu), 'một cặp món · lựa chọn đứng hai dòng'),
      (format('INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES (999999999, %s, 1)', o_nhieu), 'món của combo không có thật'),
      (format('INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES (%s, 999999999, 1)', ci_cuon), 'lựa chọn không có thật'),
      (format('INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES (%s, %s, 1)', ci_cuon, o_khac), 'lựa chọn thuộc nhóm món không mang')
    ) AS x(sql, ca) LOOP
    BEGIN
      EXECUTE r.sql;
      SET CONSTRAINTS ALL IMMEDIATE;
      RAISE EXCEPTION 'I-034: database KHÔNG từ chối %', r.ca;
    EXCEPTION WHEN integrity_constraint_violation THEN
      GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME;
      IF coalesce(cn, '') <> '' AND cn NOT LIKE 'menu_combo_item_option_surcharge%' AND cn NOT LIKE '%\_not\_null' THEN RAISE; END IF;
      RAISE NOTICE 'I-034 bị từ chối (% — %): %', r.ca, coalesce(cn, '—'), SQLERRM;
    END;
    SET CONSTRAINTS ALL DEFERRED;
  END LOOP;
  IF (SELECT data_type FROM information_schema.columns WHERE table_schema = 'shop'
      AND table_name = 'menu_combo_item_option_surcharge' AND column_name = 'surcharge_vnd') IS DISTINCT FROM 'bigint' THEN
    RAISE EXCEPTION 'I-034: mức phụ thu trong combo không phải số nguyên đồng';
  END IF;

  -- Sửa có vết; vai ghi chỉ sửa được mức, không xoá, không đổi cặp hay người.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'test-i034 đổi mức', true);
    UPDATE menu_combo_item_option_surcharge SET surcharge_vnd = 800 WHERE id = s_nhieu;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-034: vai shop_app KHÔNG đổi được mức phụ thu trong combo: %', SQLERRM;
  END;
  IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'menu_combo_item_option_surcharge'
                 AND target_row = s_nhieu AND reason = 'test-i034 đổi mức'
                 AND (before_image ->> 'surcharge_vnd')::bigint = 700 AND (after_image ->> 'surcharge_vnd')::bigint = 800) THEN
    RAISE EXCEPTION 'I-034: đổi mức phụ thu trong combo không để lại bản trước · bản sau · lý do';
  END IF;
  RAISE NOTICE 'I-034 đổi mức — 700đ → 800đ, có vết kèm lý do';
  PERFORM set_config('shop.revision_reason', 'test-i034_combo_on_order', true);
  FOR r IN SELECT * FROM (VALUES
      (format('DELETE FROM menu_combo_item_option_surcharge WHERE id = %s', s_nhieu), 'xoá cứng một mức'),
      (format('UPDATE menu_combo_item_option_surcharge SET menu_option_id = %s WHERE id = %s', o_thuong, s_nhieu), 'đổi lựa chọn của một mức'),
      (format('UPDATE menu_combo_item_option_surcharge SET menu_combo_item_id = %s WHERE id = %s', ci_cuon, s_nhieu), 'đổi món của một mức'),
      (format('UPDATE menu_combo_item_option_surcharge SET person_id = person_id WHERE id = %s', s_nhieu), 'đổi người đặt mức')
    ) AS x(sql, ca) LOOP
    BEGIN
      SET LOCAL ROLE shop_app;
      EXECUTE r.sql;
      RESET ROLE;
      RAISE EXCEPTION 'I-034: vai shop_app %', upper(r.ca);
    EXCEPTION WHEN insufficient_privilege THEN
      RESET ROLE;
      RAISE NOTICE 'I-034 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- ===================== COMBO TRÊN ĐƠN =====================
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000000', now(), gen_random_uuid()::text) RETURNING id INTO so;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text) RETURNING id INTO so2;

  -- Dương: một combo = dòng combo (giá combo) + suất cuốn Thịt·Thường (0đ) + suất trứng Thịt·Nhiều (800đ)
  -- + suất trứng Chay (0đ — lựa chọn chưa đặt mức). Bằng vai ghi của hệ thống.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd)
    VALUES (so, 1, cb, 'test-i034 Combo', 5000) RETURNING id INTO l_combo;
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, parent_order_line_id)
    VALUES (so, 1, m_cuon, 'test-i034 suất cuốn', 0, 1, l_combo) RETURNING id INTO l_cuon;
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, parent_order_line_id)
    VALUES (so, 1, m_trung, 'test-i034 suất trứng', 800, 1, l_combo) RETURNING id INTO l_trung1;
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, parent_order_line_id)
    VALUES (so, 1, m_trung, 'test-i034 suất trứng', 0, 1, l_combo) RETURNING id INTO l_trung2;
    INSERT INTO order_line_component (order_line_id, position, line_component_count,
      menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
    VALUES (l_cuon, 1, 1, c_banh, 'test-i034 bánh', 4, true, 100),
           (l_trung1, 1, 1, c_trung, 'test-i034 trứng', 1, true, 300),
           (l_trung2, 1, 1, c_trung, 'test-i034 trứng', 1, true, 300);
    INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name, surcharge_vnd)
    VALUES (l_cuon, o_thit, 'test-i034 Nhân', 'test-Thịt', 0), (l_cuon, o_thuong, 'test-i034 Lượng nhân', 'test-Thường', 0),
           (l_trung1, o_thit, 'test-i034 Nhân', 'test-Thịt', 0), (l_trung1, o_nhieu, 'test-i034 Lượng nhân', 'test-Nhiều', 800),
           (l_trung2, o_chay, 'test-i034 Nhân', 'test-Chay', 0);
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-034: vai shop_app KHÔNG ghi được combo lên đơn: %', SQLERRM;
  END;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  SELECT coalesce(sum(line_total_vnd), 0)::bigint INTO tong FROM order_line WHERE sales_order_id = so;
  IF tong IS DISTINCT FROM 5800::bigint THEN
    RAISE EXCEPTION 'I-034: tổng đơn có một combo là %đ, không phải giá combo 5000đ + mức 800đ', tong;
  END IF;
  RAISE NOTICE 'I-034 combo trên đơn — dòng combo 5000đ + ba suất con (0đ, 800đ, 0đ) ⇒ Σ line_total_vnd = %đ, không cộng giá món', tong;

  -- Dòng thường (không combo) vẫn ghi như cũ trên cùng đơn.
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count)
  VALUES (so, 1, m_le, 'test-i034 suất lẻ', 100, 1) RETURNING id INTO l_le;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l_le, 1, 1, c_banh, 'test-i034 bánh', 1, true, 100);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Tầng 1 · tầng 2: những hình sai của combo trên đơn ⇒ từ chối (mỗi ca trong một khối riêng, ép kiểm ngay).
  FOR r IN SELECT * FROM (VALUES
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_item_id, menu_combo_id, item_name, unit_price_vnd, component_count)
                 VALUES (%s, 1, %s, %s, 'x', 0, 1)$q$, so, m_le, cb), 'dòng mang cả món lẫn combo'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, item_name, unit_price_vnd)
                 VALUES (%s, 1, 'x', 0)$q$, so), 'dòng không món không combo'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd)
                 VALUES (%s, 1, %s, 'x', 0)$q$, so, m_le), 'dòng món không có số thành phần'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd, component_count)
                 VALUES (%s, 1, %s, 'x', 0, 1)$q$, so, cb), 'dòng combo mang số thành phần'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd, parent_order_line_id)
                 VALUES (%s, 1, %s, 'x', 0, %s)$q$, so, cb, l_combo), 'dòng combo có cha'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd)
                 VALUES (%s, 1, 999999999, 'x', 0)$q$, so), 'dòng combo trỏ combo không có thật'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd)
                 VALUES (%s, 1, %s, 'x', 0)$q$, so, cb), 'dòng combo không có dòng con nào'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, parent_order_line_id)
                 VALUES (%s, 1, %s, 'x', 0, 1, %s)$q$, so, m_le, l_le), 'dòng con trỏ về một dòng món, không phải dòng combo'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, parent_order_line_id)
                 VALUES (%s, 1, %s, 'x', 0, 1, %s)$q$, so2, m_le, l_combo), 'dòng con trỏ về dòng combo của đơn khác'),
      (format($q$INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, parent_order_line_id, is_takeaway)
                 VALUES (%s, 1, %s, 'x', 0, 1, %s, true)$q$, so, m_le, l_combo), 'dòng con khác dấu đem về với dòng combo'),
      (format($q$INSERT INTO order_line_component (order_line_id, position, line_component_count, menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
                 VALUES (%s, 1, 1, %s, 'x', 1, true, 0)$q$, l_combo, c_banh), 'dòng combo có thành phần'),
      (format($q$INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name, surcharge_vnd)
                 VALUES (%s, %s, 'x', 'x', 0)$q$, l_combo, o_thit), 'dòng combo có lựa chọn')
    ) AS x(sql, ca) LOOP
    BEGIN
      EXECUTE r.sql;
      -- Dòng món thiếu thành phần cũng bị khoá ngoại hoãn bắt: ca nào cần thành phần để hợp lệ thì thêm ở đây.
      IF r.ca IN ('dòng con trỏ về một dòng món, không phải dòng combo', 'dòng con trỏ về dòng combo của đơn khác',
                  'dòng con khác dấu đem về với dòng combo') THEN
        SELECT max(id) INTO l_x FROM order_line;
        INSERT INTO order_line_component (order_line_id, position, line_component_count,
          menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
        VALUES (l_x, 1, 1, c_banh, 'test-i034 bánh', 1, true, 100);
      END IF;
      SET CONSTRAINTS ALL IMMEDIATE;
      RAISE EXCEPTION 'I-034: database KHÔNG từ chối %', r.ca;
    EXCEPTION WHEN integrity_constraint_violation THEN
      GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME;
      IF coalesce(cn, '') <> '' AND cn NOT LIKE 'order_line%' AND cn NOT LIKE '%\_not\_null' THEN RAISE; END IF;
      RAISE NOTICE 'I-034 bị từ chối (% — %): %', r.ca, coalesce(cn, '—'), SQLERRM;
    END;
    SET CONSTRAINTS ALL DEFERRED;
  END LOOP;

  -- Ảnh chụp không chạm menu: đổi giá combo và mức sau khi đặt ⇒ dòng đã ghi giữ nguyên (I-009).
  PERFORM set_config('shop.revision_reason', 'test-i034 đổi sau khi đặt', true);
  UPDATE menu_combo SET price_vnd = 9000 WHERE id = cb;
  UPDATE menu_combo_item_option_surcharge SET surcharge_vnd = 1500 WHERE id = s_nhieu;
  SELECT coalesce(sum(line_total_vnd), 0)::bigint INTO tong FROM order_line WHERE sales_order_id = so AND id <> l_le;
  IF tong IS DISTINCT FROM 5800::bigint THEN
    RAISE EXCEPTION 'I-034: đổi giá combo hay mức làm đổi tiền của combo đã đặt (%đ)', tong;
  END IF;
  RAISE NOTICE 'I-034 ảnh chụp — giá combo 5000đ → 9000đ, mức 800đ → 1500đ: combo đã đặt vẫn %đ', tong;

  -- Tầng 3, nói thẳng: database KHÔNG xét đủ suất (combo 1 cuốn + 2 trứng, ghi chỉ một suất con vẫn nhận),
  -- KHÔNG xét mức đã chụp có khớp bảng mức, KHÔNG xét giờ bán — cửa ghi và hàm giá xét (ADR-117 điểm 3 · 4 · 6).
  INSERT INTO order_line (sales_order_id, quantity, menu_combo_id, item_name, unit_price_vnd)
  VALUES (so2, 1, cb, 'test-i034 Combo', 9000) RETURNING id INTO l_x;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count, parent_order_line_id)
  VALUES (so2, 1, m_cuon, 'test-i034 suất cuốn', 0, 1, l_x) RETURNING id INTO l_x;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l_x, 1, 1, c_banh, 'test-i034 bánh', 4, true, 100);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-034 tầng 3 — combo thiếu suất: database nhận; cửa ghi (T-196) và hàm giá (T-195) giữ vế đủ suất';
END $$;
