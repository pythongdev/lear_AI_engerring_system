-- I-013 (tầng 3) · shop-facts §4.6 luật 1 · 5: giá một suất CỘNG LẠI từ bảng thành
-- phần; phụ thu cất MỘT lần cho mỗi lựa chọn, hệ số (số phần nhận nhân) đọc ra từ
-- thành phần của suất — không cất ở đâu. Đổi phụ thu một lần, ở một dòng ⇒ mọi suất
-- đổi đúng Δ × số phần nhận nhân. Và: dòng đơn không có cột "giá khách gửi" nào.
-- Số và tên dưới đây là GIẢ; menu thật do P2-10 dựng. Lát: 03-luoc-do-menu-gia.md.
DO $$
DECLARE
  c_banh bigint; c_trung bigint; c_gio bigint; g_nhan bigint; o_thit bigint;
  n_sua int; r record; sai int := 0;
BEGIN
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES
    ('test-bánh', 100, true) RETURNING id INTO c_banh;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES
    ('test-trứng', 700, true) RETURNING id INTO c_trung;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES
    ('test-giò', 900, false) RETURNING id INTO c_gio;
  -- Năm hình suất: 1 · 4 · 4 · 5 · 0 phần nhận nhân (hình của shop-facts §4.4 bảng thứ hai).
  INSERT INTO menu_item (name) VALUES ('test-1 bánh'), ('test-giò + 4 bánh'),
    ('test-3 bánh + trứng + giò'), ('test-trứng + 4 bánh'), ('test-giò rời');
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity)
  SELECT m.id, x.c, x.q
  FROM menu_item m JOIN (VALUES
    ('test-1 bánh', c_banh, 1),
    ('test-giò + 4 bánh', c_gio, 1), ('test-giò + 4 bánh', c_banh, 4),
    ('test-3 bánh + trứng + giò', c_banh, 3), ('test-3 bánh + trứng + giò', c_trung, 1),
    ('test-3 bánh + trứng + giò', c_gio, 1),
    ('test-trứng + 4 bánh', c_trung, 1), ('test-trứng + 4 bánh', c_banh, 4),
    ('test-giò rời', c_gio, 1)) AS x(ten, c, q) ON x.ten = m.name;
  INSERT INTO option_group (name) VALUES ('test-Nhân') RETURNING id INTO g_nhan;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd)
  VALUES (g_nhan, 'test-Thịt', 10) RETURNING id INTO o_thit;

  -- Giá "nhân Thịt" của mọi suất, tính lại từ dữ liệu, trước lần đổi.
  CREATE TEMP TABLE truoc ON COMMIT DROP AS
  SELECT m.name,
         SUM(ic.quantity) FILTER (WHERE mc.takes_filling) AS phan,
         SUM(ic.quantity * mc.base_price_vnd)
           + (SELECT surcharge_vnd FROM menu_option WHERE id = o_thit)
             * COALESCE(SUM(ic.quantity) FILTER (WHERE mc.takes_filling), 0) AS gia
  FROM menu_item m
  JOIN menu_item_component ic ON ic.menu_item_id = m.id
  JOIN menu_component mc ON mc.id = ic.menu_component_id
  WHERE m.name LIKE 'test-%' GROUP BY m.name;

  -- Đổi phụ thu: MỘT lệnh, MỘT dòng.
  UPDATE menu_option SET surcharge_vnd = 15 WHERE id = o_thit;
  GET DIAGNOSTICS n_sua = ROW_COUNT;
  RAISE NOTICE 'Luật 5 — đổi phụ thu nhân 10 → 15: % dòng bị sửa', n_sua;

  FOR r IN
    SELECT t.name, COALESCE(t.phan, 0) AS phan, t.gia AS truoc,
           SUM(ic.quantity * mc.base_price_vnd)
             + 15 * COALESCE(SUM(ic.quantity) FILTER (WHERE mc.takes_filling), 0) AS sau
    FROM truoc t
    JOIN menu_item m ON m.name = t.name
    JOIN menu_item_component ic ON ic.menu_item_id = m.id
    JOIN menu_component mc ON mc.id = ic.menu_component_id
    GROUP BY t.name, t.phan, t.gia ORDER BY COALESCE(t.phan, 0), t.name
  LOOP
    RAISE NOTICE 'Luật 5 — % : % phần nhận nhân · % → % (Δ = %)',
      r.name, r.phan, r.truoc, r.sau, r.sau - r.truoc;
    IF r.sau - r.truoc <> 5 * r.phan THEN sai := sai + 1; END IF;
  END LOOP;
  IF n_sua <> 1 OR sai > 0 THEN
    RAISE EXCEPTION 'Luật 5: % suất đổi sai Δ × số phần, hoặc phải sửa % dòng', sai, n_sua;
  END IF;

  -- I-013: mọi cột tiền của dòng đơn và ảnh chụp của nó; chỉ unit_price_vnd là giá
  -- của dòng, thành tiền tự tính, không cột nào mang giá khách gửi. Tập cột phải
  -- đúng bốn cột dưới đây: một cột tiền mới trên họ order_line ⇒ test đỏ, và người
  -- thêm nó phải nói nó KHÔNG phải giá khách gửi rồi mới sửa danh sách này.
  IF (SELECT string_agg(table_name || '.' || column_name
                        || CASE WHEN is_generated = 'ALWAYS' THEN '(t)' ELSE '' END,
                        ' ' ORDER BY table_name, column_name)
      FROM information_schema.columns
      WHERE table_schema = 'shop' AND table_name LIKE 'order!_line%' ESCAPE '!'
        AND column_name LIKE '%!_vnd' ESCAPE '!')
     IS DISTINCT FROM 'order_line.line_total_vnd(t) order_line.unit_price_vnd '
                      'order_line_component.base_price_vnd order_line_option.surcharge_vnd' THEN
    RAISE EXCEPTION 'I-013: họ order_line có cột tiền ngoài bốn cột đã khai — có thể là giá khách gửi';
  END IF;
  FOR r IN
    SELECT table_name, column_name, is_generated
    FROM information_schema.columns
    WHERE table_schema = 'shop' AND table_name LIKE 'order!_line%' ESCAPE '!'
      AND column_name LIKE '%!_vnd' ESCAPE '!'
    ORDER BY table_name, column_name
  LOOP
    RAISE NOTICE 'I-013 cột tiền: %.% (tự tính: %)', r.table_name, r.column_name,
      r.is_generated = 'ALWAYS';
  END LOOP;
END $$;
