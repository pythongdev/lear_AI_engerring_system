-- I-019 (tầng 1 · tầng 3) và YC-06: tổng nhu cầu một thành phần luôn bằng tổng phần chia về từng
-- bàn, cả hai chiều — vì lát không có ô tổng nào để lệch; khoá gom là thành phần + loại nhân +
-- lượng nhân. Kịch bản của 03-lat-cat.md §3.4.3 · §3.4.4 · §3.4.5 · §3.4.6.
-- Lát: 05-luoc-do-san-xuat.md.
-- Dựng chung của file (pg_temp — mất cùng ROLLBACK). Menu, tên và số đều GIẢ (test-…); menu thật
-- là của P2-10, tra shop-facts §4.5 · §5.3. Hàm don · dong đứng THAY cửa tạo lượt gọi, no_don
-- thay cửa nổ đơn, bam_me thay nút "đã làm xong" — đều của pha 3; chúng không phải các cửa ấy.
CREATE TEMP TABLE tm (name text PRIMARY KEY, id bigint NOT NULL);

DO $$
DECLARE banh bigint; tai bigint; chin bigint; gio bigint; bat bigint;
        m_tai bigint; m_chin bigint; m_canh bigint; g_nhan bigint; g_luong bigint;
BEGIN
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-bánh', 0, true) RETURNING id INTO banh;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-trứng tái', 0, true) RETURNING id INTO tai;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-trứng chín', 0, true) RETURNING id INTO chin;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-giò', 0, false) RETURNING id INTO gio;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-bát canh', 0, false) RETURNING id INTO bat;
  -- Trạm của từng thành phần, hình của shop-facts §5.3: bánh và trứng qua tráng rồi gấp.
  INSERT INTO menu_component_station (menu_component_id, station_code) VALUES
    (banh, 'trang_banh'), (banh, 'gap_banh'), (tai, 'trang_banh'), (tai, 'gap_banh'),
    (chin, 'trang_banh'), (chin, 'gap_banh'), (gio, 'gap_banh'), (bat, 'canh');
  INSERT INTO menu_item (name) VALUES ('test-đầy đủ trứng tái') RETURNING id INTO m_tai;
  INSERT INTO menu_item (name) VALUES ('test-đầy đủ trứng chín') RETURNING id INTO m_chin;
  INSERT INTO menu_item (name) VALUES ('test-canh') RETURNING id INTO m_canh;
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity) VALUES
    (m_tai, banh, 3), (m_tai, tai, 1), (m_tai, gio, 1),
    (m_chin, banh, 3), (m_chin, chin, 1), (m_chin, gio, 1), (m_canh, bat, 1);
  INSERT INTO option_group (name) VALUES ('test-Nhân') RETURNING id INTO g_nhan;
  INSERT INTO option_group (name) VALUES ('test-Lượng nhân') RETURNING id INTO g_luong;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES
    (g_nhan, 'test-Thịt', 0), (g_nhan, 'test-Thịt + mộc nhĩ', 0),
    (g_luong, 'test-Thường', 0), (g_luong, 'test-Nhiều nhân', 0);
  INSERT INTO tm (name, id) VALUES
    ('đầy đủ trứng tái', m_tai), ('đầy đủ trứng chín', m_chin), ('canh', m_canh);
  INSERT INTO tm (name, id) SELECT substr(name, 6), id FROM menu_option WHERE name LIKE 'test-%';
END $$;

-- Một lượt gọi staff_pos của bàn p_ban (mở phiên nếu bàn chưa có), đơn ở Đã xác nhận.
CREATE FUNCTION pg_temp.don(p_ban text) RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE t bigint; s bigint; o bigint;
BEGIN
  SELECT id INTO t FROM dining_table WHERE label = p_ban;
  IF t IS NULL THEN
    INSERT INTO dining_table (label) VALUES (p_ban) RETURNING id INTO t;
    INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s;
    INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, t);
  ELSE
    SELECT table_session_id INTO s FROM table_session_member WHERE dining_table_id = t;
  END IF;
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
  VALUES ('staff_pos', 'confirmed', s, t, gen_random_uuid()::text) RETURNING id INTO o;
  RETURN o;
END $f$;

-- Một dòng đơn kèm ảnh chụp thành phần và tuỳ chọn, chép từ menu lúc đặt (I-009).
CREATE FUNCTION pg_temp.dong(p_don bigint, p_mon text, p_so_suat integer, p_tuy_chon text[])
RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE l bigint; m bigint; n integer;
BEGIN
  SELECT id INTO m FROM tm WHERE name = p_mon;
  SELECT COUNT(*) INTO n FROM menu_item_component WHERE menu_item_id = m;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                          component_count)
  VALUES (p_don, p_so_suat, m, 'test-' || p_mon, 0, n) RETURNING id INTO l;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  SELECT l, row_number() OVER (ORDER BY ic.id), n, ic.menu_component_id, mc.name, ic.quantity,
         mc.takes_filling, 0
  FROM menu_item_component ic JOIN menu_component mc ON mc.id = ic.menu_component_id
  WHERE ic.menu_item_id = m;
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name,
                                 surcharge_vnd)
  SELECT l, o.id, g.name, o.name, 0
  FROM menu_option o JOIN option_group g ON g.id = o.option_group_id
  WHERE o.id IN (SELECT id FROM tm WHERE name = ANY (p_tuy_chon));
  RETURN l;
END $f$;

-- Nổ đơn: Đã xác nhận → Đang thực hiện và mọi việc trạm của đơn trong CÙNG giao dịch (I-004
-- tầng 2). Mỗi đơn vị một dòng; mỗi đơn đúng một phần nước chấm ở trạm canh (shop-facts §5.3).
CREATE FUNCTION pg_temp.no_don(p_don bigint) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  UPDATE sales_order SET status = 'in_progress' WHERE id = p_don;
  INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                           line_quantity, component_quantity, position)
  SELECT p_don, l.id, c.id, s.station_code, l.quantity, c.quantity, g.p
  FROM order_line l
  JOIN order_line_component c ON c.order_line_id = l.id
  JOIN menu_component_station s ON s.menu_component_id = c.menu_component_id
  CROSS JOIN LATERAL generate_series(1, l.quantity * c.quantity) AS g(p)
  WHERE l.sales_order_id = p_don;
  INSERT INTO station_job (sales_order_id, station_code, position) VALUES (p_don, 'canh', 1);
END $f$;

-- Một lần bấm "đã làm xong": một mẻ làm ra đúng các đơn vị trong p_viec (I-020 tầng 2).
CREATE FUNCTION pg_temp.bam_me(p_viec bigint[]) RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE b bigint;
BEGIN
  INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b;
  INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
  SELECT b, v, v FROM unnest(p_viec) AS v;
  UPDATE station_job SET status = 'made' WHERE id = ANY (p_viec);
  RETURN b;
END $f$;

-- Đơn vị của bàn p_ban ở trạm p_tram, thành phần có tên p_tp, đang ở p_status — p_n cái đầu.
CREATE FUNCTION pg_temp.viec(p_ban text, p_tram text, p_tp text, p_status text, p_n integer)
RETURNS bigint[] LANGUAGE sql AS $f$
  SELECT array_agg(id ORDER BY id) FROM (
    SELECT j.id FROM station_job j
    JOIN sales_order o ON o.id = j.sales_order_id
    JOIN dining_table t ON t.id = o.dining_table_id
    LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
    WHERE t.label = p_ban AND j.station_code = p_tram AND j.status = p_status
      AND COALESCE(c.component_name, 'nước chấm') = p_tp AND o.status <> 'cancelled'
    ORDER BY j.id LIMIT p_n) x
$f$;

-- Bảng nhu cầu — "còn phải làm" của bếp (03-lat-cat §3.4.1 · §3.4.2) — cộng lại từ việc trạm,
-- tách theo bàn. Khoá gom = trạm + thành phần + tập tuỳ chọn nhân của dòng (MÃ gốc, không tên),
-- chỉ khi thành phần nhận nhân (§3.4.6); nước chấm là việc cấp đơn. Đơn đã huỷ và ba kênh không
-- gắn bàn không vào bảng này (§3.4.5). Đây là phép đọc để chứng minh dữ liệu ĐỦ — câu của pha 3
-- và của P2-11 viết lại nó, lát này không cất nó.
CREATE FUNCTION pg_temp.nhu_cau() RETURNS TABLE (tram text, khoa text, ban text, so bigint)
LANGUAGE sql AS $f$
  SELECT j.station_code,
         CASE WHEN j.order_line_component_id IS NULL THEN 'nước chấm'
              WHEN NOT c.takes_filling THEN c.component_name
              ELSE c.component_name || ' — ' ||
                   (SELECT string_agg(x.option_name, ', ' ORDER BY x.menu_option_id)
                    FROM order_line_option x WHERE x.order_line_id = j.order_line_id) END,
         t.label, COUNT(*)
  FROM station_job j
  JOIN sales_order o ON o.id = j.sales_order_id
  JOIN dining_table t ON t.id = o.dining_table_id
  LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
  WHERE j.status = 'pending' AND o.status <> 'cancelled'
  GROUP BY 1, 2, 3
$f$;

-- Cùng khoá ấy, đọc từ DÒNG ĐƠN (số suất × số thành phần, mỗi trạm thành phần chạm tới) — phía
-- "khách đã gọi" để so với phía việc trạm. Nước chấm: một cho mỗi đơn đã nổ.
CREATE FUNCTION pg_temp.da_goi() RETURNS TABLE (tram text, khoa text, ban text, so bigint)
LANGUAGE sql AS $f$
  SELECT s.station_code,
         CASE WHEN NOT c.takes_filling THEN c.component_name
              ELSE c.component_name || ' — ' ||
                   (SELECT string_agg(x.option_name, ', ' ORDER BY x.menu_option_id)
                    FROM order_line_option x WHERE x.order_line_id = l.id) END,
         t.label, SUM(l.quantity * c.quantity)
  FROM sales_order o JOIN dining_table t ON t.id = o.dining_table_id
  JOIN order_line l ON l.sales_order_id = o.id
  JOIN order_line_component c ON c.order_line_id = l.id
  JOIN menu_component_station s ON s.menu_component_id = c.menu_component_id
  WHERE o.status = 'in_progress'
  GROUP BY 1, 2, 3
  UNION ALL
  SELECT 'canh', 'nước chấm', t.label, COUNT(*)
  FROM sales_order o JOIN dining_table t ON t.id = o.dining_table_id
  WHERE o.status = 'in_progress'
  GROUP BY 3
$f$;

-- In bảng theo hình của 03-lat-cat §3.4.4 và kiểm HAI CHIỀU: tổng của dòng (một phép cộng thẳng
-- trên việc trạm, không qua bàn) = tổng các phần chia; phần chia của từng bàn = đúng phần bàn ấy
-- đã gọi. Trả về số dòng nhu cầu.
CREATE FUNCTION pg_temp.in_bang(p_nhan text) RETURNS integer LANGUAGE plpgsql AS $f$
DECLARE r record; n integer := 0;
BEGIN
  FOR r IN
    SELECT b.tram, b.khoa, SUM(b.so) AS tong_phan,
           string_agg(b.ban || ': ' || b.so, ' · ' ORDER BY b.ban) AS phan
    FROM pg_temp.nhu_cau() b GROUP BY b.tram, b.khoa ORDER BY b.tram DESC, b.khoa
  LOOP
    n := n + 1;
    RAISE NOTICE '% │ % │ % │ % │ %', p_nhan, r.tram, r.khoa, r.tong_phan, r.phan;
  END LOOP;
  -- Chiều xuôi: tổng mỗi dòng, cộng thẳng trên việc trạm, không nhóm theo bàn.
  IF EXISTS (
    SELECT 1 FROM (SELECT tram, khoa, SUM(so) AS tong FROM pg_temp.nhu_cau() GROUP BY 1, 2) a
    FULL JOIN (
      SELECT j.station_code AS tram,
             CASE WHEN j.order_line_component_id IS NULL THEN 'nước chấm'
                  WHEN NOT c.takes_filling THEN c.component_name
                  ELSE c.component_name || ' — ' ||
                       (SELECT string_agg(x.option_name, ', ' ORDER BY x.menu_option_id)
                        FROM order_line_option x WHERE x.order_line_id = j.order_line_id) END AS khoa,
             COUNT(*) AS tong
      FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
      LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
      WHERE j.status = 'pending' AND o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
      GROUP BY 1, 2) d USING (tram, khoa)
    WHERE a.tong IS DISTINCT FROM d.tong) THEN
    RAISE EXCEPTION 'I-019 (%): tổng một dòng khác tổng các phần chia', p_nhan;
  END IF;
  -- Chiều ngược: phần chia về từng bàn = đúng phần bàn ấy đã gọi, cả hai phía EXCEPT rỗng.
  IF EXISTS ((SELECT * FROM pg_temp.nhu_cau() EXCEPT SELECT * FROM pg_temp.da_goi())
             UNION ALL
             (SELECT * FROM pg_temp.da_goi() EXCEPT SELECT * FROM pg_temp.nhu_cau())) THEN
    RAISE EXCEPTION 'I-019 (%): phần chia về từng bàn khác phần bàn ấy đã gọi', p_nhan;
  END IF;
  RAISE NOTICE '% — hai chiều khớp: tổng mỗi dòng = tổng phần chia, phần mỗi bàn = phần bàn ấy đã gọi', p_nhan;
  RETURN n;
END $f$;

DO $$
DECLARE b text; o bigint; o9 bigint; n integer;
BEGIN
  -- 03-lat-cat §3.4.3: sáu bàn, mỗi bàn một combo "đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân.
  FOREACH b IN ARRAY ARRAY['test-b1', 'test-b4', 'test-b5', 'test-b7', 'test-b8', 'test-b9'] LOOP
    o := pg_temp.don(b);
    PERFORM pg_temp.dong(o, 'đầy đủ trứng tái', 1, ARRAY['Thịt + mộc nhĩ', 'Nhiều nhân']);
    PERFORM pg_temp.no_don(o);
    IF b = 'test-b9' THEN o9 := o; END IF;
  END LOOP;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  n := pg_temp.in_bang('I-019 sáu bàn');
  IF n <> 6 THEN RAISE EXCEPTION 'I-019: sáu bàn giống nhau phải là SÁU dòng nhu cầu, được %', n; END IF;

  -- §3.4.6: thêm bàn 10 gọi combo "đầy đủ trứng chín", thịt, thường. Hai dòng bánh KHÔNG gộp
  -- (khác nhân), trứng chín là dòng riêng (khác loại), giò và nước chấm GỘP.
  o := pg_temp.don('test-b10');
  PERFORM pg_temp.dong(o, 'đầy đủ trứng chín', 1, ARRAY['Thịt', 'Thường']);
  PERFORM pg_temp.no_don(o);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  n := pg_temp.in_bang('I-019 thêm bàn 10');
  IF n <> 10
     OR (SELECT COUNT(DISTINCT khoa) FROM pg_temp.nhu_cau()
         WHERE tram = 'trang_banh' AND khoa LIKE 'test-bánh%') <> 2
     OR (SELECT SUM(so) FROM pg_temp.nhu_cau() WHERE tram = 'gap_banh' AND khoa = 'test-giò') <> 7
     OR (SELECT COUNT(DISTINCT khoa) FROM pg_temp.nhu_cau() WHERE khoa = 'test-giò') <> 1
     OR (SELECT SUM(so) FROM pg_temp.nhu_cau() WHERE khoa = 'nước chấm') <> 7 THEN
    RAISE EXCEPTION 'I-019: khoá gom gộp nhầm hoặc tách nhầm (cần 10 dòng; 2 dòng bánh ở trạm tráng; giò 7; nước chấm 7)';
  END IF;

  -- Vế tầng 1: không có ô tổng nào để sửa tay cho lệch — mẻ và việc trạm không mang con số tổng.
  BEGIN
    EXECUTE 'UPDATE production_batch SET quantity = 18';
    RAISE EXCEPTION 'I-019: có một ô tổng ghi được độc lập với phần chia';
  EXCEPTION WHEN undefined_column THEN
    RAISE NOTICE 'I-019 không có ô tổng để sửa tay cho lệch: %', SQLERRM;
  END;

  -- Kịch bản huỷ (§3.4.5): huỷ đơn bàn 9 ⇒ dòng tổng và phần chia của bàn 9 giảm cùng một lượt.
  UPDATE sales_order SET status = 'cancelled' WHERE id = o9;
  n := pg_temp.in_bang('I-019 sau khi huỷ đơn bàn 9');
  IF EXISTS (SELECT 1 FROM pg_temp.nhu_cau() WHERE ban = 'test-b9')
     OR (SELECT SUM(so) FROM pg_temp.nhu_cau()
         WHERE tram = 'trang_banh' AND khoa = 'test-bánh — test-Thịt + mộc nhĩ, test-Nhiều nhân') <> 15 THEN
    RAISE EXCEPTION 'I-019: huỷ đơn bàn 9 không rút đúng ba cái bánh khỏi dòng tổng và khỏi phần chia';
  END IF;
END $$;
