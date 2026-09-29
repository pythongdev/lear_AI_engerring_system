-- I-020 (tầng 1 · tầng 2) và YC-06 · YC-07: số đã phục vụ của một bàn không vượt số bàn ấy đã
-- gọi — kể cả con số giữa "đã làm xong, còn ở bếp"; một lần bấm mẻ phủ nhiều bàn, và một lần
-- lùi mẻ, là MỘT giao dịch cho mọi bàn; "còn thiếu" và "còn phải làm" là hai con số.
-- Lát: 05-luoc-do-san-xuat.md.
-- Dựng chung của file (pg_temp — mất cùng ROLLBACK). Menu, tên và số đều GIẢ (test-…); menu thật
-- là của P2-10, tra shop-facts §4.5 · §5.3. Hàm don · dong đứng THAY cửa tạo lượt gọi, no_don
-- thay cửa nổ đơn, bam_me thay nút "đã làm xong" — đều của pha 3; chúng không phải các cửa ấy.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
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

-- Bốn con số của bàn p_ban ở trạm p_tram cho thành phần p_tp — đọc từ chi tiết, đơn đã huỷ không
-- tính (03-lat-cat §3.4.2 · §3.4.5). "Đã gọi" đọc từ DÒNG ĐƠN, không từ việc trạm.
CREATE FUNCTION pg_temp.so(p_ban text, p_tram text, p_tp text) RETURNS text LANGUAGE sql AS $f$
  SELECT format('đã gọi %s · còn phải làm %s · đã làm xong còn ở bếp %s · đã bưng ra bàn %s · còn thiếu %s',
                g.n, v.chua, v.xong, v.ra, g.n - v.ra)
  FROM (SELECT COALESCE(SUM(l.quantity * c.quantity), 0) AS n
        FROM sales_order o JOIN dining_table t ON t.id = o.dining_table_id
        JOIN order_line l ON l.sales_order_id = o.id
        JOIN order_line_component c ON c.order_line_id = l.id
        WHERE t.label = p_ban AND c.component_name = p_tp AND o.status <> 'cancelled') g,
       (SELECT COUNT(*) FILTER (WHERE j.status = 'pending') AS chua,
               COUNT(*) FILTER (WHERE j.status = 'made') AS xong,
               COUNT(*) FILTER (WHERE j.status = 'served') AS ra
        FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
        JOIN dining_table t ON t.id = o.dining_table_id
        JOIN order_line_component c ON c.id = j.order_line_component_id
        WHERE t.label = p_ban AND j.station_code = p_tram AND c.component_name = p_tp
          AND o.status <> 'cancelled') v
$f$;

-- Hai tập đối chiếu của hàng I-020 (03-bao-ve-invariant §4) — P2-11 gom. Mỗi (bàn, thành phần,
-- trạm): đã bưng ra bàn > đã gọi · đã làm xong còn ở bếp + đã bưng ra bàn > đã gọi.
CREATE FUNCTION pg_temp.doi_chieu_i020() RETURNS TABLE (ban text, tp text, tram text, goi bigint,
  da_ra bigint, da_lam bigint) LANGUAGE sql AS $f$
  WITH goi AS (
    SELECT o.dining_table_id AS ban, c.menu_component_id AS tp, SUM(l.quantity * c.quantity) AS n
    FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
    JOIN order_line_component c ON c.order_line_id = l.id
    WHERE o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
    GROUP BY 1, 2),
  lam AS (
    SELECT o.dining_table_id AS ban, c.menu_component_id AS tp, j.station_code AS tram,
           COUNT(*) FILTER (WHERE j.status = 'served') AS da_ra,
           COUNT(*) FILTER (WHERE j.status IN ('made', 'served')) AS da_lam
    FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
    JOIN order_line_component c ON c.id = j.order_line_component_id
    WHERE o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
    GROUP BY 1, 2, 3)
  SELECT t.label, mc.name, lam.tram, COALESCE(goi.n, 0), lam.da_ra, lam.da_lam
  FROM lam LEFT JOIN goi USING (ban, tp)
  JOIN dining_table t ON t.id = lam.ban JOIN menu_component mc ON mc.id = lam.tp
  WHERE lam.da_ra > COALESCE(goi.n, 0) OR lam.da_lam > COALESCE(goi.n, 0)
$f$;

-- Ảnh các con số của hai bàn ở trạm tráng — để so trước lúc bấm với sau lúc lùi.
CREATE FUNCTION pg_temp.anh(p_tp text) RETURNS text LANGUAGE sql AS $f$
  SELECT 'bàn 5: ' || pg_temp.so('test-b5', 'trang_banh', p_tp)
      || ' | bàn 7: ' || pg_temp.so('test-b7', 'trang_banh', p_tp)
$f$;

DO $$
DECLARE o5 bigint; o7 bigint; l5 bigint; l7 bigint; c_banh5 bigint; u bigint[]; x bigint;
        b_a bigint; b_b bigint; truoc text; sau text; r record;
BEGIN
  -- Bàn 5 gọi 1 suất, bàn 7 gọi 2 suất — cùng "đầy đủ trứng tái, thịt, thường" (3 bánh + 1 trứng
  -- + 1 giò mỗi suất). Duyệt rồi nổ, như cửa của pha 3 sẽ làm.
  o5 := pg_temp.don('test-b5');
  l5 := pg_temp.dong(o5, 'đầy đủ trứng tái', 1, ARRAY['Thịt', 'Thường']);
  o7 := pg_temp.don('test-b7');
  l7 := pg_temp.dong(o7, 'đầy đủ trứng tái', 2, ARRAY['Thịt', 'Thường']);
  PERFORM pg_temp.no_don(o5);
  PERFORM pg_temp.no_don(o7);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  SELECT id INTO c_banh5 FROM order_line_component
   WHERE order_line_id = l5 AND component_name = 'test-bánh';

  -- ---------------------------------------------------------------- tầng 1 — trần trên
  BEGIN
    INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                             line_quantity, component_quantity, position)
    VALUES (o5, l5, c_banh5, 'trang_banh', 1, 3, 4);
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối cái bánh thứ tư của bàn chỉ gọi ba';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (bánh thứ 4 của bàn 5, bàn gọi 3): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                             line_quantity, component_quantity, position)
    VALUES (o5, l5, c_banh5, 'trang_banh', 1, 3, 3);
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối đơn vị thứ ba ghi lần hai';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (cùng một đơn vị ghi hai lần): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_job (sales_order_id, station_code, position) VALUES (o5, 'canh', 1);
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối phần nước chấm thứ hai của một đơn';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (nước chấm thứ hai của một đơn): %', SQLERRM;
  END;
  BEGIN
    -- Khai dòng có 2 suất để có chỗ cho bánh thứ tư: bản soi lệch dòng đơn thật (1 suất).
    INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                             line_quantity, component_quantity, position)
    VALUES (o5, l5, c_banh5, 'trang_banh', 2, 3, 4);
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối bản soi số suất khai sai';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (bản soi số suất khác dòng đơn): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    -- Khai suất có 4 bánh để có chỗ cho bánh thứ tư: bản soi lệch ảnh chụp thành phần (3).
    INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                             line_quantity, component_quantity, position)
    VALUES (o5, l5, c_banh5, 'trang_banh', 1, 4, 4);
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối bản soi số thành phần khai sai';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (bản soi số thành phần khác ảnh chụp): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    -- Bỏ trống bản soi: trần không tính được, khoá ngoại nhiều cột bỏ qua dòng có ô trống.
    INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                             position)
    VALUES (o5, l5, c_banh5, 'trang_banh', 99);
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối đơn vị thành phần không có bản soi số';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (đơn vị thành phần bỏ trống bản soi số): %', SQLERRM;
  END;
  -- Chỗ trống có tên (file lát §5): giảm số suất của một dòng đã nổ. Đơn vị không xoá được
  -- (QD-50), nên bánh thứ 4…6 của bàn 7 vượt số mới và lần giảm bị từ chối.
  BEGIN
    UPDATE order_line SET quantity = 1 WHERE id = l7;
    UPDATE station_job SET line_quantity = 1 WHERE order_line_id = l7;
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối giảm số suất khi đơn vị cũ vượt số mới';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-020 giảm số suất sau khi nổ — bị từ chối (chỗ trống có tên, file lát §5): %', SQLERRM;
  END;

  -- ------------------------------------------- tầng 2 — một lần bấm mẻ phủ hai bàn
  -- Mẻ A: ba quả trứng tái ở trạm tráng — một của bàn 5, hai của bàn 7.
  u := pg_temp.viec('test-b5', 'trang_banh', 'test-trứng tái', 'pending', 1)
    || pg_temp.viec('test-b7', 'trang_banh', 'test-trứng tái', 'pending', 2);
  BEGIN
    INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b_a;
    INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
    SELECT b_a, v, v FROM unnest(u) AS v;
    UPDATE station_job SET status = 'made' WHERE id = u[1];   -- bàn 5 được cộng, bàn 7 thì chưa
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối mẻ cộng cho bàn 5 mà sót bàn 7';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (một lần bấm cộng cho bàn này, sót bàn kia): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    UPDATE station_job SET status = 'made' WHERE id = u[2];   -- "đã làm xong" không mẻ nào làm ra
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối đơn vị đã làm xong mà không thuộc mẻ nào';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (đã làm xong mà không mẻ nào làm ra): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;

  b_a := pg_temp.bam_me(u);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b_b;
    INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
    VALUES (b_b, u[1], u[1]);
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối một quả trứng được hai mẻ làm ra';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (một đơn vị, hai mẻ còn hiệu lực): %', SQLERRM;
  END;

  -- YC-07: phần của từng bàn trong mẻ A — đọc từ thứ mẻ đã làm, mẻ không mang con số nào.
  FOR r IN
    SELECT t.label, COUNT(*) AS n
    FROM production_batch_item i JOIN station_job j ON j.id = i.station_job_id
    JOIN sales_order o ON o.id = j.sales_order_id JOIN dining_table t ON t.id = o.dining_table_id
    WHERE i.production_batch_id = b_a GROUP BY t.label ORDER BY t.label
  LOOP
    RAISE NOTICE 'YC-07 mẻ A (một lần bấm) — phần của %: % quả trứng tái', r.label, r.n;
  END LOOP;
  IF (SELECT COUNT(*) FROM production_batch_item WHERE production_batch_id = b_a) <> 3
     OR pg_temp.so('test-b5', 'trang_banh', 'test-trứng tái') NOT LIKE '%đã làm xong còn ở bếp 1 %'
     OR pg_temp.so('test-b7', 'trang_banh', 'test-trứng tái') NOT LIKE '%đã làm xong còn ở bếp 2 %' THEN
    RAISE EXCEPTION 'I-020: phần chia của mẻ A không khớp phần mỗi bàn đã gọi';
  END IF;

  -- Quầy bưng quả trứng của bàn 5. Hai chữ "còn" (03-lat-cat §3.4.2): "còn thiếu" của người
  -- bưng và "còn phải làm" của bếp lệch nhau đúng bằng "đã làm xong, còn ở bếp".
  UPDATE station_job SET status = 'served' WHERE id = u[1];
  RAISE NOTICE 'YC-07 bàn 5 trứng tái: %', pg_temp.so('test-b5', 'trang_banh', 'test-trứng tái');
  RAISE NOTICE 'YC-07 bàn 7 trứng tái: %', pg_temp.so('test-b7', 'trang_banh', 'test-trứng tái');
  IF pg_temp.so('test-b7', 'trang_banh', 'test-trứng tái')
     <> 'đã gọi 2 · còn phải làm 0 · đã làm xong còn ở bếp 2 · đã bưng ra bàn 0 · còn thiếu 2' THEN
    RAISE EXCEPTION 'YC-07: "còn thiếu" và "còn phải làm" của bàn 7 bị gộp hoặc đếm sai';
  END IF;

  -- -------------------------------------------------- tầng 2 — đường lùi của một mẻ
  -- Mẻ B: bốn cái bánh ở trạm tráng — ba của bàn 5, một của bàn 7. Quầy bấm nhầm rồi lùi.
  truoc := pg_temp.anh('test-bánh');
  u := pg_temp.viec('test-b5', 'trang_banh', 'test-bánh', 'pending', 3)
    || pg_temp.viec('test-b7', 'trang_banh', 'test-bánh', 'pending', 1);
  b_b := pg_temp.bam_me(u);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-020 mẻ B vừa bấm — %', pg_temp.anh('test-bánh');
  BEGIN
    UPDATE production_batch SET rolled_back_at = clock_timestamp(), rolled_back_by_person_id = actor_person_id() WHERE id = b_b;
    UPDATE production_batch_item SET batch_rolled_back = true
     WHERE production_batch_id = b_b AND station_job_id <> u[4];
    UPDATE station_job SET status = 'pending' WHERE id = ANY (u[1:3]);
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối lùi phần bàn 5 mà để phần bàn 7 đứng nguyên';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (lùi một phần của mẻ): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    UPDATE production_batch SET rolled_back_at = clock_timestamp(), rolled_back_by_person_id = actor_person_id() WHERE id = b_b;
    UPDATE production_batch_item SET batch_rolled_back = true WHERE production_batch_id = b_b;
    SET CONSTRAINTS ALL IMMEDIATE;   -- mẻ đã lùi, bốn cái bánh vẫn "đã làm xong"
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối lùi mẻ mà không trả đơn vị về chưa làm';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (lùi mẻ, con số của các bàn không lùi theo): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;

  UPDATE production_batch SET rolled_back_at = clock_timestamp(), rolled_back_by_person_id = actor_person_id() WHERE id = b_b;
  UPDATE production_batch_item SET batch_rolled_back = true WHERE production_batch_id = b_b;
  UPDATE station_job SET status = 'pending' WHERE id = ANY (u);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN
    UPDATE production_batch SET rolled_back_at = made_at - interval '1 minute', rolled_back_by_person_id = actor_person_id() WHERE id = b_b;
    RAISE EXCEPTION 'I-020: database KHÔNG từ chối mốc lùi đứng trước mốc bấm';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-020 bị từ chối (vết lần lùi có mốc lùi trước mốc bấm): %', SQLERRM;
  END;
  sau := pg_temp.anh('test-bánh');
  RAISE NOTICE 'I-020 đường lùi — trước lúc bấm: %', truoc;
  RAISE NOTICE 'I-020 đường lùi — sau lúc lùi:  %', sau;
  IF sau IS DISTINCT FROM truoc THEN
    RAISE EXCEPTION 'I-020: lùi mẻ B không trả mọi bàn về đúng số trước lúc bấm';
  END IF;
  SELECT b.id, b.made_at, b.rolled_back_at,
         (SELECT display_name FROM person WHERE id = b.made_by_person_id) AS nguoi_bam,
         (SELECT display_name FROM person WHERE id = b.rolled_back_by_person_id) AS nguoi_lui,
         string_agg(t.label || ' ×' || x.n, ', ' ORDER BY t.label) AS phan
  INTO r
  FROM production_batch b
  JOIN LATERAL (SELECT o.dining_table_id, COUNT(*) AS n
                FROM production_batch_item i JOIN station_job j ON j.id = i.station_job_id
                JOIN sales_order o ON o.id = j.sales_order_id
                WHERE i.production_batch_id = b.id GROUP BY 1) x ON true
  JOIN dining_table t ON t.id = x.dining_table_id
  WHERE b.id = b_b GROUP BY b.id, b.made_at, b.rolled_back_at, b.made_by_person_id,
                              b.rolled_back_by_person_id;
  RAISE NOTICE 'YC-07 vết lần lùi — mẻ %, % bấm lúc %, % lùi lúc %, đã phủ [%]',
    r.id, r.nguoi_bam, r.made_at, r.nguoi_lui, r.rolled_back_at, r.phan;
  IF r.nguoi_lui IS NULL THEN RAISE EXCEPTION 'YC-07: lần lùi không đọc ra ai lùi'; END IF;
  -- Bấm lại sau khi lùi: mẻ cũ không còn giữ đơn vị nào, nên một mẻ mới nhận được chúng.
  PERFORM pg_temp.bam_me(u[1:2]);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-020 bấm lại sau lùi — %', pg_temp.anh('test-bánh');

  -- ---------------------------------------- huỷ một đơn đã phục vụ một phần (kịch bản huỷ)
  UPDATE station_job SET status = 'served' WHERE id = u[1];           -- một bánh của bàn 5 ra bàn
  SELECT j.id INTO x FROM station_job j
   JOIN production_batch_item i ON i.live_station_job_id = j.id
   JOIN sales_order o ON o.id = j.sales_order_id
   WHERE o.id = o7 AND j.status = 'made' ORDER BY j.id LIMIT 1;
  UPDATE station_job SET status = 'served' WHERE id = x;              -- một trứng của bàn 7 ra bàn
  UPDATE sales_order SET status = 'cancelled' WHERE id = o7;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-020 sau khi huỷ đơn bàn 7 (đã bưng một trứng) — bàn 7 trứng tái: %',
    pg_temp.so('test-b7', 'trang_banh', 'test-trứng tái');

  -- Hai tập đối chiếu của I-020 — rỗng.
  IF EXISTS (SELECT 1 FROM pg_temp.doi_chieu_i020()) THEN
    RAISE EXCEPTION 'I-020: tập đối chiếu không rỗng';
  END IF;
  RAISE NOTICE 'I-020 đối chiếu: tập "đã bưng ra bàn > đã gọi" và "đã làm xong + đã bưng > đã gọi" rỗng';

  -- Câu đối chiếu biết kêu: gỡ trần trên (chỉ trong khối này), bưng cái bánh thứ tư cho bàn 5.
  BEGIN
    ALTER TABLE station_job DROP CONSTRAINT station_job_position_in_range_check;
    INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                             line_quantity, component_quantity, position)
    VALUES (o5, l5, c_banh5, 'trang_banh', 1, 3, 4) RETURNING id INTO x;
    -- Bàn 5 đã có hai bánh làm xong; mẻ này làm nốt cái thứ ba và cái thứ tư lậu.
    PERFORM pg_temp.bam_me(pg_temp.viec('test-b5', 'trang_banh', 'test-bánh', 'pending', 1) || x);
    UPDATE station_job SET status = 'served' WHERE id = x;
    FOR r IN SELECT * FROM pg_temp.doi_chieu_i020() LOOP
      RAISE NOTICE 'I-020 đối chiếu biết kêu (trần đã gỡ): % · % · % — gọi %, đã bưng %, đã làm %',
        r.ban, r.tp, r.tram, r.goi, r.da_ra, r.da_lam;
    END LOOP;
    IF NOT EXISTS (SELECT 1 FROM pg_temp.doi_chieu_i020()) THEN
      RAISE EXCEPTION 'I-020: câu đối chiếu KHÔNG bắt được bàn 5 được bưng 4 bánh khi gọi 3';
    END IF;
    RAISE EXCEPTION USING ERRCODE = 'P0003', MESSAGE = 'hoàn tác khối gỡ trần';
  EXCEPTION WHEN SQLSTATE 'P0003' THEN NULL;
  END;
END $$;
