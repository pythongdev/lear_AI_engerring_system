-- I-009 (tầng 1, vế lưu bản sao): đơn đã tạo giữ giá, tên món, thành phần và tuỳ
-- chọn như lúc đặt, dù chủ quán đổi giá thành phần, đổi phụ thu, đổi thành phần
-- suất, đổi tên hay ngừng bán. Đơn cũ đọc lại CHỈ từ ảnh chụp, không chạm menu.
-- Một dòng đơn thiếu giá · thiếu tên · thiếu ảnh chụp thành phần thì không ghi được.
-- Số dưới đây là số GIẢ, không phải giá quán (giá thật: shop-facts.md §4.2 · §4.4).
-- Lát: 03-luoc-do-menu-gia.md.
DO $$
DECLARE
  c_banh bigint; c_gio bigint; m_gio bigint; g_nhan bigint; g_luong bigint;
  o_thit bigint; o_thuong bigint; so bigint; l_cu bigint; l_moi bigint; l_x bigint;
  gia_moi bigint; r record;
BEGIN
  -- Menu lúc đặt: suất = 1 giò (không nhận nhân) + 4 bánh (nhận nhân).
  INSERT INTO menu_component (name, base_price_vnd, takes_filling)
  VALUES ('test-bánh', 100, true) RETURNING id INTO c_banh;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling)
  VALUES ('test-giò', 900, false) RETURNING id INTO c_gio;
  INSERT INTO menu_item (name) VALUES ('test-suất giò') RETURNING id INTO m_gio;
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity)
  VALUES (m_gio, c_gio, 1), (m_gio, c_banh, 4);
  INSERT INTO option_group (name) VALUES ('test-Nhân') RETURNING id INTO g_nhan;
  INSERT INTO option_group (name) VALUES ('test-Lượng nhân') RETURNING id INTO g_luong;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd)
  VALUES (g_nhan, 'test-Thịt', 10) RETURNING id INTO o_thit;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd)
  VALUES (g_luong, 'test-Thường', 0) RETURNING id INTO o_thuong;

  -- Đặt: phần việc của cửa tạo lượt gọi (pha 3) — ở đây test tự chép từ menu.
  -- Giá = 900 + 4 × 100 + (10 + 0) × 4 phần nhận nhân = 1340.
  -- Đơn pickup mang đủ liên hệ tối thiểu của I-022 (T-111), để chỉ ràng buộc của test này nói.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000000', now(), gen_random_uuid()::text) RETURNING id INTO so;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                          component_count)
  VALUES (so, 1, m_gio, 'test-suất giò', 1340, 2) RETURNING id INTO l_cu;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l_cu, 1, 2, c_gio, 'test-giò', 1, false, 900),
         (l_cu, 2, 2, c_banh, 'test-bánh', 4, true, 100);
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name,
                                 surcharge_vnd)
  VALUES (l_cu, o_thit, 'test-Nhân', 'test-Thịt', 10),
         (l_cu, o_thuong, 'test-Lượng nhân', 'test-Thường', 0);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Chủ quán sửa menu, đủ các chiều của 03-lat-cat.md §3.3.2 · §3.3.4.
  UPDATE menu_component SET base_price_vnd = 150 WHERE id = c_banh;         -- giá thành phần
  UPDATE menu_option SET surcharge_vnd = 20 WHERE id = o_thit;              -- phụ thu nhân
  UPDATE menu_item_component SET quantity = 3
    WHERE menu_item_id = m_gio AND menu_component_id = c_banh;             -- thành phần suất
  UPDATE menu_item SET name = 'test-suất giò (mới)' WHERE id = m_gio;       -- tên món
  UPDATE menu_option SET name = 'test-Thịt heo' WHERE id = o_thit;          -- tên tuỳ chọn

  -- Cùng suất ấy tính theo menu HIỆN HÀNH (việc của hàm giá pha 3; ở đây chỉ để đối chứng).
  SELECT SUM(ic.quantity * mc.base_price_vnd)
         + 20 * SUM(ic.quantity) FILTER (WHERE mc.takes_filling)
  INTO gia_moi
  FROM menu_item_component ic JOIN menu_component mc ON mc.id = ic.menu_component_id
  WHERE ic.menu_item_id = m_gio;

  -- Đối chứng dương: suất đặt MỚI sau lần sửa ghi giá mới, trên CÙNG đơn.
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                          component_count)
  VALUES (so, 1, m_gio, 'test-suất giò (mới)', gia_moi, 2) RETURNING id INTO l_moi;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l_moi, 1, 2, c_gio, 'test-giò', 1, false, 900),
         (l_moi, 2, 2, c_banh, 'test-bánh', 3, true, 150);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-009 suất đặt mới sau lần sửa: % — một đơn, hai mức giá cho cùng món: %',
    gia_moi, (SELECT string_agg(unit_price_vnd::text, ' · ' ORDER BY id)
              FROM order_line WHERE sales_order_id = so);

  UPDATE menu_item SET discontinued_at = now() WHERE id = m_gio;            -- ngừng bán

  -- Đọc lại đơn cũ CHỈ từ ảnh chụp.
  SELECT l.item_name, l.unit_price_vnd, l.line_total_vnd,
         (SELECT string_agg(c.component_name || ' ×' || c.quantity || ' @' || c.base_price_vnd,
                            ', ' ORDER BY c.position)
          FROM order_line_component c WHERE c.order_line_id = l.id) AS thanh_phan,
         (SELECT string_agg(o.option_group_name || ': ' || o.option_name || ' +' || o.surcharge_vnd,
                            ', ' ORDER BY o.option_group_name)
          FROM order_line_option o WHERE o.order_line_id = l.id) AS tuy_chon
  INTO r FROM order_line l WHERE l.id = l_cu;
  RAISE NOTICE 'I-009 đơn cũ đọc lại sau năm lần sửa menu: "%" · giá % · thành tiền % · [%] · [%]',
    r.item_name, r.unit_price_vnd, r.line_total_vnd, r.thanh_phan, r.tuy_chon;
  IF r.item_name <> 'test-suất giò' OR r.unit_price_vnd <> 1340
     OR r.thanh_phan <> 'test-giò ×1 @900, test-bánh ×4 @100'
     OR r.tuy_chon <> 'test-Lượng nhân: test-Thường +0, test-Nhân: test-Thịt +10' THEN
    RAISE EXCEPTION 'I-009: đơn cũ ĐỔI theo menu';
  END IF;

  -- Vế ngừng bán của I-009: món đã ngừng bán, database VẪN ghi được một dòng mới.
  -- Vế "không kênh nào đặt mới được" là TẦNG 3 (ADR-056, đóng F-036): cửa tạo lượt
  -- gọi ở pha 3 từ chối; lược đồ chỉ cất mốc ngừng bán, cố ý không ràng buộc.
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                          component_count)
  VALUES (so, 1, m_gio, 'test-suất giò (mới)', gia_moi, 1) RETURNING id INTO l_x;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l_x, 1, 1, c_gio, 'test-giò', 1, false, 900);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-009 vế ngừng bán: dòng mới cho món đã ngừng bán vẫn ghi được ở database (tầng 3 — cửa pha 3 từ chối, ADR-056)';

  -- Tầng 1: dòng đơn thiếu giá · thiếu tên món · thiếu ảnh chụp thành phần.
  BEGIN
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, component_count)
    VALUES (so, 1, m_gio, 'test-suất giò', 2);
    RAISE EXCEPTION 'I-009: database KHÔNG từ chối dòng đơn thiếu giá';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-009 bị từ chối (dòng đơn thiếu giá): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, unit_price_vnd, component_count)
    VALUES (so, 1, m_gio, 1340, 2);
    RAISE EXCEPTION 'I-009: database KHÔNG từ chối dòng đơn thiếu tên món';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-009 bị từ chối (dòng đơn thiếu tên món): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                            component_count)
    VALUES (so, 1, m_gio, 'test-suất giò', 1340, 2) RETURNING id INTO l_x;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-009: database KHÔNG từ chối dòng đơn không có ảnh chụp thành phần nào';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-009 bị từ chối (không có ảnh chụp thành phần nào): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                            component_count)
    VALUES (so, 1, m_gio, 'test-suất giò', 1340, 2) RETURNING id INTO l_x;
    INSERT INTO order_line_component (order_line_id, position, line_component_count,
      menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
    VALUES (l_x, 2, 2, c_banh, 'test-bánh', 4, true, 100);
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-009: database KHÔNG từ chối dòng đơn thiếu một trong hai thành phần';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-009 bị từ chối (thiếu một thành phần của suất): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                            component_count)
    VALUES (so, 1, m_gio, 'test-suất giò', 1340, 1) RETURNING id INTO l_x;
    INSERT INTO order_line_component (order_line_id, position, line_component_count,
      menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
    VALUES (l_x, 1, 1, c_gio, 'test-giò', 1, false, 900),
           (l_x, 2, 1, c_banh, 'test-bánh', 4, true, 100);
    RAISE EXCEPTION 'I-009: database KHÔNG từ chối ảnh chụp thừa so với số đã khai';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-009 bị từ chối (ảnh chụp thừa so với số đã khai): %', SQLERRM;
  END;

END $$;
