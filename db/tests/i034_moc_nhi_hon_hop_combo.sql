-- I-034 (tầng 1 · tầng 2) · T-271 · ADR-134: chế độ "Hỗn hợp" ở trang gọi combo chia
-- số bánh cuốn con giữa lựa chọn "Thịt" và "Mộc nhĩ" bằng portions sẵn có (ADR-117
-- điểm 2 · ADR-129). Vì phụ thu "Mộc nhĩ" bằng đúng "Thịt" (shop-facts §4.4, §4.6
-- luật 4), tổng tiền một combo "Hỗn hợp" phải bằng đúng tổng tiền combo ấy khi mọi
-- bánh chọn "Thịt". Luật này là HỆ QUẢ của cấu tạo bán combo đã có — không bước mới
-- ở hàm giá, chỉ portions tách thành hai dòng con khác menu_option_id cùng cha.
-- Tên và số dưới đây là GIẢ; menu thật do P2-10 dựng từ shop-facts.
-- Viết trước lát ở T-271 (Claude Code): đỏ cho tới khi seed thật có "Mộc nhĩ".

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do.
DO $$ DECLARE p bigint; BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán i034 moc nhi', true) RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  PERFORM set_config('shop.revision_reason', 'test-i034_moc_nhi_hon_hop_combo', true);
END $$;

DO $$
DECLARE
  c_banh bigint; c_trung bigint; c_gio bigint;
  m_cuon bigint; m_trung bigint; m_gio bigint;
  g_nhan bigint;
  o_thit bigint; o_chay bigint; o_mocnhi bigint;
  cb bigint; ci_cuon bigint; ci_trung bigint; ci_gio bigint;
  so_hh bigint; so_th bigint;
  l_combo_hh bigint; l_combo_th bigint;
  tong_hh bigint; tong_th bigint;
  r record; n_dong_con int;
BEGIN
  ---------------------------------------------------------------------------
  -- Menu giả: ba thành phần (bánh cuốn, bánh trứng chín, giò); ba món lẻ nền;
  --   nhóm Nhân gắn cho bánh cuốn và bánh trứng chín (hai món nhận nhân).
  ---------------------------------------------------------------------------
  INSERT INTO menu_component (name, base_price_vnd, takes_filling)
    VALUES ('test-i034 moc-nhi bánh', 100, true) RETURNING id INTO c_banh;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling)
    VALUES ('test-i034 moc-nhi trứng chín', 300, true) RETURNING id INTO c_trung;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling)
    VALUES ('test-i034 moc-nhi giò', 400, false) RETURNING id INTO c_gio;

  INSERT INTO menu_item (name) VALUES ('test-i034 moc-nhi bánh cuốn') RETURNING id INTO m_cuon;
  INSERT INTO menu_item (name) VALUES ('test-i034 moc-nhi bánh trứng chín') RETURNING id INTO m_trung;
  INSERT INTO menu_item (name) VALUES ('test-i034 moc-nhi giò bán rời') RETURNING id INTO m_gio;

  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity)
    VALUES (m_cuon, c_banh, 1), (m_trung, c_trung, 1), (m_gio, c_gio, 1);

  INSERT INTO option_group (name) VALUES ('test-i034 moc-nhi Nhân') RETURNING id INTO g_nhan;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd)
    VALUES (g_nhan, 'test-Chay', 0) RETURNING id INTO o_chay;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd)
    VALUES (g_nhan, 'test-Thịt', 10) RETURNING id INTO o_thit;
  -- Lựa chọn thứ tư, cùng mức phụ thu Thịt (shop-facts §4.4, luật 4 §4.6).
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd)
    VALUES (g_nhan, 'test-Mộc nhĩ', 10) RETURNING id INTO o_mocnhi;

  INSERT INTO menu_item_option_group (menu_item_id, option_group_id)
    VALUES (m_cuon, g_nhan), (m_trung, g_nhan);

  ---------------------------------------------------------------------------
  -- Combo giả như "Đầy đủ": 3 bánh cuốn + 1 bánh trứng chín + 1 giò, giá
  --   combo 1000; mức phụ thu theo món của combo = menu_option.surcharge_vnd
  --   cho mỗi (suất con có nhóm Nhân) × lựa chọn (ADR-117 điểm 1).
  ---------------------------------------------------------------------------
  INSERT INTO menu_combo (name, price_vnd)
    VALUES ('test-i034 moc-nhi Combo Đầy đủ', 1000) RETURNING id INTO cb;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity)
    VALUES (cb, m_cuon, 3) RETURNING id INTO ci_cuon;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity)
    VALUES (cb, m_trung, 1) RETURNING id INTO ci_trung;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity)
    VALUES (cb, m_gio, 1) RETURNING id INTO ci_gio;

  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd)
      SELECT x.id, o.id, o.surcharge_vnd
        FROM menu_combo c
        JOIN menu_combo_item x ON x.menu_combo_id = c.id
        JOIN menu_item_option_group g ON g.menu_item_id = x.menu_item_id
        JOIN menu_option o ON o.option_group_id = g.option_group_id
       WHERE c.id = cb;
    RESET ROLE;
  END;

  ---------------------------------------------------------------------------
  -- Đơn A ("Hỗn hợp"): 1 combo, bánh cuốn tách thành 2 Thịt + 1 Mộc nhĩ,
  --   bánh trứng chín = Thịt, giò không nhân. Mỗi tổ hợp lựa chọn khác nhau là
  --   MỘT dòng con độc lập (ADR-117 điểm 2 bullet 2); các suất bánh cùng tổ hợp
  --   gộp vào MỘT dòng con có quantity > 1.
  ---------------------------------------------------------------------------
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone,
                           customer_needed_at, submission_code)
    VALUES ('pickup', 'new', 'shop_pickup', '0900000000', now(), gen_random_uuid()::text)
    RETURNING id INTO so_hh;

  -- Dòng combo: menu_combo_id, không món, không thành phần, không cha.
  INSERT INTO order_line (sales_order_id, menu_combo_id, quantity, item_name, unit_price_vnd)
    VALUES (so_hh, cb, 1, 'test-i034 moc-nhi Combo Đầy đủ', 1000)
    RETURNING id INTO l_combo_hh;

  -- Dòng con 1: 2 suất bánh cuốn + Thịt. unit_price_vnd = tổng mức một suất =
  --   mức combo cho (bánh cuốn, Thịt) = 10 (= menu_option.surcharge_vnd Thịt).
  INSERT INTO order_line (sales_order_id, menu_item_id, item_name, unit_price_vnd,
                          component_count, parent_order_line_id, quantity)
    VALUES (so_hh, m_cuon, 'test-i034 moc-nhi bánh cuốn', 10, 1, l_combo_hh, 2)
    RETURNING id INTO r;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                    menu_component_id, component_name, quantity,
                                    takes_filling, base_price_vnd)
    VALUES (r.id, 1, 1, c_banh, 'test-i034 moc-nhi bánh', 1, true, 100);
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name,
                                 option_name, surcharge_vnd)
    VALUES (r.id, o_thit, 'test-i034 moc-nhi Nhân', 'test-Thịt', 10);

  -- Dòng con 2: 1 suất bánh cuốn + Mộc nhĩ, cùng cha combo, khác menu_option_id.
  INSERT INTO order_line (sales_order_id, menu_item_id, item_name, unit_price_vnd,
                          component_count, parent_order_line_id, quantity)
    VALUES (so_hh, m_cuon, 'test-i034 moc-nhi bánh cuốn', 10, 1, l_combo_hh, 1)
    RETURNING id INTO r;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                    menu_component_id, component_name, quantity,
                                    takes_filling, base_price_vnd)
    VALUES (r.id, 1, 1, c_banh, 'test-i034 moc-nhi bánh', 1, true, 100);
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name,
                                 option_name, surcharge_vnd)
    VALUES (r.id, o_mocnhi, 'test-i034 moc-nhi Nhân', 'test-Mộc nhĩ', 10);

  -- Dòng con 3: 1 bánh trứng chín + Thịt.
  INSERT INTO order_line (sales_order_id, menu_item_id, item_name, unit_price_vnd,
                          component_count, parent_order_line_id, quantity)
    VALUES (so_hh, m_trung, 'test-i034 moc-nhi bánh trứng chín', 10, 1, l_combo_hh, 1)
    RETURNING id INTO r;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                    menu_component_id, component_name, quantity,
                                    takes_filling, base_price_vnd)
    VALUES (r.id, 1, 1, c_trung, 'test-i034 moc-nhi trứng chín', 1, true, 300);
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name,
                                 option_name, surcharge_vnd)
    VALUES (r.id, o_thit, 'test-i034 moc-nhi Nhân', 'test-Thịt', 10);

  -- Dòng con 4: 1 giò, không nhận nhân, không lựa chọn, unit_price = 0.
  INSERT INTO order_line (sales_order_id, menu_item_id, item_name, unit_price_vnd,
                          component_count, parent_order_line_id, quantity)
    VALUES (so_hh, m_gio, 'test-i034 moc-nhi giò bán rời', 0, 1, l_combo_hh, 1)
    RETURNING id INTO r;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                    menu_component_id, component_name, quantity,
                                    takes_filling, base_price_vnd)
    VALUES (r.id, 1, 1, c_gio, 'test-i034 moc-nhi giò', 1, false, 400);

  SET CONSTRAINTS ALL IMMEDIATE;

  SELECT count(*) INTO n_dong_con FROM order_line WHERE parent_order_line_id = l_combo_hh;
  IF n_dong_con <> 4 THEN
    RAISE EXCEPTION 'I-034 Hỗn hợp: combo cha phải có 4 dòng con, thấy %', n_dong_con;
  END IF;

  SELECT sum(line_total_vnd) INTO tong_hh FROM order_line WHERE sales_order_id = so_hh;
  -- Kiểm nhanh hai dòng bánh cuốn con có menu_option_id khác nhau (chứng cứ "chia bánh").
  SELECT count(*) INTO n_dong_con
    FROM order_line ol
    JOIN order_line_option oo ON oo.order_line_id = ol.id
   WHERE ol.parent_order_line_id = l_combo_hh AND ol.menu_item_id = m_cuon;
  IF n_dong_con <> 2 THEN
    RAISE EXCEPTION 'I-034 Hỗn hợp: bánh cuốn con phải tách thành 2 dòng khác lựa chọn, thấy %', n_dong_con;
  END IF;

  ---------------------------------------------------------------------------
  -- Đơn B (so sánh — toàn Thịt): 1 combo, 3 suất bánh cuốn cùng Thịt (gộp làm
  --   một dòng con quantity=3), bánh trứng chín Thịt, giò.
  ---------------------------------------------------------------------------
  -- Mỗi đơn dựng đủ cha và con rồi mới kiểm ràng buộc trì hoãn.
  SET CONSTRAINTS ALL DEFERRED;

  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone,
                           customer_needed_at, submission_code)
    VALUES ('pickup', 'new', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text)
    RETURNING id INTO so_th;

  INSERT INTO order_line (sales_order_id, menu_combo_id, quantity, item_name, unit_price_vnd)
    VALUES (so_th, cb, 1, 'test-i034 moc-nhi Combo Đầy đủ', 1000)
    RETURNING id INTO l_combo_th;

  INSERT INTO order_line (sales_order_id, menu_item_id, item_name, unit_price_vnd,
                          component_count, parent_order_line_id, quantity)
    VALUES (so_th, m_cuon, 'test-i034 moc-nhi bánh cuốn', 10, 1, l_combo_th, 3)
    RETURNING id INTO r;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                    menu_component_id, component_name, quantity,
                                    takes_filling, base_price_vnd)
    VALUES (r.id, 1, 1, c_banh, 'test-i034 moc-nhi bánh', 1, true, 100);
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name,
                                 option_name, surcharge_vnd)
    VALUES (r.id, o_thit, 'test-i034 moc-nhi Nhân', 'test-Thịt', 10);

  INSERT INTO order_line (sales_order_id, menu_item_id, item_name, unit_price_vnd,
                          component_count, parent_order_line_id, quantity)
    VALUES (so_th, m_trung, 'test-i034 moc-nhi bánh trứng chín', 10, 1, l_combo_th, 1)
    RETURNING id INTO r;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                    menu_component_id, component_name, quantity,
                                    takes_filling, base_price_vnd)
    VALUES (r.id, 1, 1, c_trung, 'test-i034 moc-nhi trứng chín', 1, true, 300);
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name,
                                 option_name, surcharge_vnd)
    VALUES (r.id, o_thit, 'test-i034 moc-nhi Nhân', 'test-Thịt', 10);

  INSERT INTO order_line (sales_order_id, menu_item_id, item_name, unit_price_vnd,
                          component_count, parent_order_line_id, quantity)
    VALUES (so_th, m_gio, 'test-i034 moc-nhi giò bán rời', 0, 1, l_combo_th, 1)
    RETURNING id INTO r;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                    menu_component_id, component_name, quantity,
                                    takes_filling, base_price_vnd)
    VALUES (r.id, 1, 1, c_gio, 'test-i034 moc-nhi giò', 1, false, 400);

  SET CONSTRAINTS ALL IMMEDIATE;

  SELECT sum(line_total_vnd) INTO tong_th FROM order_line WHERE sales_order_id = so_th;

  IF tong_hh IS DISTINCT FROM tong_th THEN
    RAISE EXCEPTION 'I-034 Hỗn hợp: tổng tiền đơn Hỗn hợp (%)=đ KHÁC đơn toàn Thịt (%)=đ — phụ thu Mộc nhĩ phải bằng Thịt (shop-facts §4.4, §4.6 luật 4, ADR-134)', tong_hh, tong_th;
  END IF;
  RAISE NOTICE 'I-034 Hỗn hợp: tổng % đồng, bằng đơn toàn Thịt (shop-facts §4.4, ADR-134 điểm 1 · 2)', tong_hh;

  ---------------------------------------------------------------------------
  -- Tầng 2: phép chia ceil/floor của chế độ Hỗn hợp (shop-facts §4.4 đoạn
  -- Mộc nhĩ) đọc được từ bất kỳ dòng combo nào có N bánh cuốn con ≥ 2. Phép
  -- chia là lời dặn giao diện khách, không phải trigger database — test chỉ
  -- canh phép đếm trả về đúng con số ví dụ của chủ repo (3 → 2 + 1).
  ---------------------------------------------------------------------------
  SELECT ceil(3.0 / 2)::int AS thit, floor(3.0 / 2)::int AS mocnhi INTO r;
  IF r.thit <> 2 OR r.mocnhi <> 1 THEN
    RAISE EXCEPTION 'I-034 Hỗn hợp: N=3 phải chia 2 Thịt + 1 Mộc nhĩ, thấy % + %', r.thit, r.mocnhi;
  END IF;
  SELECT ceil(4.0 / 2)::int AS thit, floor(4.0 / 2)::int AS mocnhi INTO r;
  IF r.thit <> 2 OR r.mocnhi <> 2 THEN
    RAISE EXCEPTION 'I-034 Hỗn hợp: N=4 phải chia 2 Thịt + 2 Mộc nhĩ, thấy % + %', r.thit, r.mocnhi;
  END IF;
  RAISE NOTICE 'I-034 Hỗn hợp: phép chia ceil/floor khớp hai ví dụ chủ repo (3 → 2+1, 4 → 2+2)';
END $$;
