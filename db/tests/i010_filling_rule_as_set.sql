-- I-010 (tầng 3 — cửa tạo lượt gọi ở pha 3 từ chối; database KHÔNG từ chối tổ hợp).
-- Phần lược đồ nợ: luật "Lượng nhân chỉ có khi nhân ≠ Chay" (shop-facts §4.6 luật 3)
-- nằm TRỌN trong dữ liệu, theo TẬP — không nửa nào phải sống ở code — và ảnh chụp
-- tuỳ chọn giữ MÃ GỐC để phép đếm không gãy khi đổi tên hiển thị.
-- Tên dưới đây là tên giả; menu thật do P2-10 dựng. Lát: 03-luoc-do-menu-gia.md.
DO $$
DECLARE
  g_nhan bigint; g_luong bigint; o_chay bigint; o_thit bigint; o_moc bigint; o_nam bigint;
  o_thuong bigint; o_nhieu bigint; c1 bigint; m1 bigint; so bigint; l1 bigint; l2 bigint;
  r record; sai int := 0;
BEGIN
  INSERT INTO option_group (name) VALUES ('test-Nhân') RETURNING id INTO g_nhan;
  INSERT INTO option_group (name) VALUES ('test-Lượng nhân') RETURNING id INTO g_luong;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES
    (g_nhan, 'test-Chay', 0) RETURNING id INTO o_chay;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES
    (g_nhan, 'test-Thịt', 10) RETURNING id INTO o_thit;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES
    (g_nhan, 'test-Thịt + mộc nhĩ', 10) RETURNING id INTO o_moc;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES
    (g_luong, 'test-Thường', 0) RETURNING id INTO o_thuong;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES
    (g_luong, 'test-Nhiều nhân', 10) RETURNING id INTO o_nhieu;
  -- Luật, cất theo tập: nhóm Lượng nhân tồn tại khi nhân ∈ {Thịt, Thịt + mộc nhĩ}.
  INSERT INTO option_group_prerequisite (option_group_id, menu_option_id)
  VALUES (g_luong, o_thit), (g_luong, o_moc);

  -- Phép đọc luật, CHỈ trên dữ liệu: một nhóm có mặt khi nó không có điều kiện nào,
  -- hoặc ít nhất một lựa chọn trong tập điều kiện của nó được chọn.
  CREATE TEMP TABLE chon (ca text, menu_option_id bigint) ON COMMIT DROP;
  INSERT INTO chon VALUES
    ('Chay + Nhiều nhân', o_chay), ('Chay + Nhiều nhân', o_nhieu),
    ('Thịt + Nhiều nhân', o_thit), ('Thịt + Nhiều nhân', o_nhieu),
    ('Thịt + mộc nhĩ + Nhiều nhân', o_moc), ('Thịt + mộc nhĩ + Nhiều nhân', o_nhieu),
    ('Chay, không chọn lượng', o_chay);
  FOR r IN
    SELECT ch.ca,
           bool_and(NOT EXISTS (SELECT 1 FROM option_group_prerequisite p
                                 WHERE p.option_group_id = mo.option_group_id)
                    OR EXISTS (SELECT 1 FROM option_group_prerequisite p
                                 JOIN chon k ON k.menu_option_id = p.menu_option_id AND k.ca = ch.ca
                                WHERE p.option_group_id = mo.option_group_id)) AS hop_le
    FROM chon ch JOIN menu_option mo ON mo.id = ch.menu_option_id
    GROUP BY ch.ca ORDER BY ch.ca
  LOOP
    RAISE NOTICE 'I-010 luật đọc từ dữ liệu: % ⇒ %', r.ca,
      CASE WHEN r.hop_le THEN 'hợp lệ' ELSE 'KHÔNG hợp lệ' END;
    IF r.hop_le <> (r.ca <> 'Chay + Nhiều nhân') THEN sai := sai + 1; END IF;
  END LOOP;
  IF sai > 0 THEN RAISE EXCEPTION 'I-010: luật trong dữ liệu đọc ra sai % ca', sai; END IF;

  -- Thêm một loại nhân thứ tư: một dòng lựa chọn + một dòng điều kiện, không sửa code.
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES
    (g_nhan, 'test-Nấm', 10) RETURNING id INTO o_nam;
  INSERT INTO option_group_prerequisite (option_group_id, menu_option_id) VALUES (g_luong, o_nam);
  RAISE NOTICE 'I-010 nhân thứ tư: tập điều kiện của Lượng nhân nay có % lựa chọn',
    (SELECT COUNT(*) FROM option_group_prerequisite WHERE option_group_id = g_luong);

  -- Mã gốc: hai đơn chọn cùng một lựa chọn, tên hiển thị đổi ở giữa.
  INSERT INTO menu_component (name, base_price_vnd, takes_filling)
  VALUES ('test-bánh', 100, true) RETURNING id INTO c1;
  INSERT INTO menu_item (name) VALUES ('test-suất') RETURNING id INTO m1;
  -- Đơn pickup mang đủ liên hệ tối thiểu của I-022 (T-111), để chỉ ràng buộc của test này nói.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000000', now(), gen_random_uuid()::text) RETURNING id INTO so;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                          component_count)
  VALUES (so, 1, m1, 'test-suất', 110, 1) RETURNING id INTO l1;
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name,
                                 surcharge_vnd)
  VALUES (l1, o_moc, 'test-Nhân', 'test-Thịt + mộc nhĩ', 10);
  UPDATE menu_option SET name = 'test-Thịt + mộc nhĩ (đặc biệt)' WHERE id = o_moc;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                          component_count)
  VALUES (so, 1, m1, 'test-suất', 110, 1) RETURNING id INTO l2;
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name,
                                 surcharge_vnd)
  VALUES (l2, o_moc, 'test-Nhân', 'test-Thịt + mộc nhĩ (đặc biệt)', 10);
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l1, 1, 1, c1, 'test-bánh', 1, true, 100), (l2, 1, 1, c1, 'test-bánh', 1, true, 100);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-010 đếm theo mã gốc: % suất · đếm theo tên hiển thị: %',
    (SELECT COUNT(*) FROM order_line_option WHERE menu_option_id = o_moc),
    (SELECT string_agg(option_name || ' = ' || n, ' · ' ORDER BY option_name)
     FROM (SELECT option_name, COUNT(*) AS n FROM order_line_option
           WHERE menu_option_id = o_moc GROUP BY option_name) t);

  -- Cái database CÓ từ chối: ảnh chụp tuỳ chọn trỏ tới một lựa chọn không tồn tại.
  BEGIN
    INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name,
                                   surcharge_vnd)
    VALUES (l1, -1, 'test-Nhân', 'test-bịa', 0);
    RAISE EXCEPTION 'I-010: database KHÔNG từ chối tuỳ chọn không có gốc';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-010 bị từ chối (ảnh chụp tuỳ chọn không có gốc): %', SQLERRM;
  END;
END $$;
