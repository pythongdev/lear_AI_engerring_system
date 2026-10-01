-- I-004 (tầng 1 · tầng 2 · tầng 3 · tầng 4): đơn chưa duyệt không sinh việc nào, và đơn đã có
-- việc không lùi về chưa duyệt; nổ đơn — bánh nhân theo suất, MỘT phần nước chấm mỗi đơn, canh
-- đúng số bát khách chọn — sống hoặc chết cùng lần chuyển sang Đang thực hiện; phần đã làm xong
-- của một đơn huỷ đổi chủ sang bàn khác trong một giao dịch, kèm vết. Lát: 05-luoc-do-san-xuat.md.
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

-- Việc trạm của một đơn, đếm theo (trạm, thành phần) — để so với ví dụ của shop-facts §5.3.
CREATE FUNCTION pg_temp.dem(p_don bigint) RETURNS text LANGUAGE sql AS $f$
  SELECT COALESCE(string_agg(x.tram || ' ' || x.tp || ' ×' || x.n, ' · ' ORDER BY x.tram DESC, x.tp), '0 việc')
  FROM (SELECT j.station_code AS tram, COALESCE(c.component_name, 'nước chấm') AS tp, COUNT(*) AS n
        FROM station_job j LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
        WHERE j.sales_order_id = p_don GROUP BY 1, 2) x
$f$;

-- Khoá gom của một đơn vị: trạm + thành phần gốc + tập MÃ tuỳ chọn nhân (khi thành phần nhận nhân).
CREATE FUNCTION pg_temp.khoa(p_viec bigint) RETURNS text LANGUAGE sql AS $f$
  SELECT j.station_code || '/' || COALESCE(c.menu_component_id::text, 'nước chấm') || '/' ||
         CASE WHEN c.takes_filling THEN
           (SELECT string_agg(x.menu_option_id::text, ',' ORDER BY x.menu_option_id)
            FROM order_line_option x WHERE x.order_line_id = j.order_line_id) ELSE '' END
  FROM station_job j LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
  WHERE j.id = p_viec
$f$;

-- Tập đối chiếu của hàng I-004 (03-bao-ve-invariant §2) mà lát này đọc ra được — P2-11 gom.
-- Đơn "đã nổ" = Đang thực hiện · Đang giao · Hoàn thành.
CREATE FUNCTION pg_temp.doi_chieu_i004() RETURNS TABLE (tap text, don bigint, chi_tiet text)
LANGUAGE sql AS $f$
  -- (1) việc trạm của một đơn đang Mới / Chờ xác nhận
  SELECT 'việc của đơn chưa duyệt', o.id, o.status
  FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
  WHERE o.status IN ('new', 'pending_confirmation')
  UNION ALL
  -- (2) đơn đã nổ mà một (thành phần, trạm nó chạm tới) có số đơn vị khác số suất × số thành phần —
  --     phủ cả việc CANH: bát canh là thành phần của dòng "canh", số bát = con số khách chọn
  SELECT 'thiếu hoặc thừa việc', g.don, g.tram || ' ' || g.tp || ': cần ' || g.can || ', có ' || COALESCE(v.co, 0)
  FROM (SELECT o.id AS don, s.station_code AS tram, c.id AS tp_id, c.component_name AS tp,
               l.quantity * c.quantity AS can
        FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
        JOIN order_line_component c ON c.order_line_id = l.id
        JOIN menu_component_station s ON s.menu_component_id = c.menu_component_id
        WHERE o.status IN ('in_progress', 'delivering', 'completed')) g
  LEFT JOIN (SELECT order_line_component_id AS tp_id, station_code AS tram, COUNT(*) AS co
             FROM station_job GROUP BY 1, 2) v USING (tp_id, tram)
  WHERE g.can <> COALESCE(v.co, 0)
  UNION ALL
  -- (3) đơn đã nổ mà số phần nước chấm khác MỘT
  SELECT 'nước chấm khác một', o.id, COUNT(j.id)::text
  FROM sales_order o
  LEFT JOIN station_job j ON j.sales_order_id = o.id AND j.order_line_component_id IS NULL
  WHERE o.status IN ('in_progress', 'delivering', 'completed')
  GROUP BY o.id HAVING COUNT(j.id) <> 1
  UNION ALL
  -- (4) đơn đã huỷ mà còn giữ thứ đã làm xong / đã ra bàn chưa chuyển sang bàn khác
  SELECT 'đã làm của đơn huỷ, chưa chuyển', o.id, j.station_code || ' ' || COALESCE(c.component_name, 'nước chấm')
  FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
  LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
  WHERE o.status = 'cancelled' AND j.status IN ('made', 'served')
  UNION ALL
  -- (5) lần chuyển mà bên nhận không cùng khoá gom với bên cho (quầy chọn nhầm — máy không ngăn)
  SELECT 'chuyển khác khoá gom', t.id, pg_temp.khoa(t.from_station_job_id) || ' → ' || pg_temp.khoa(t.to_station_job_id)
  FROM station_job_transfer t
  WHERE pg_temp.khoa(t.from_station_job_id) <> pg_temp.khoa(t.to_station_job_id)
$f$;

CREATE FUNCTION pg_temp.in_doi_chieu(p_nhan text) RETURNS integer LANGUAGE plpgsql AS $f$
DECLARE r record; n integer := 0;
BEGIN
  FOR r IN SELECT * FROM pg_temp.doi_chieu_i004() ORDER BY 1, 2 LOOP
    n := n + 1;
    RAISE NOTICE '% — tập "%": đơn/lần %, %', p_nhan, r.tap, r.don, r.chi_tiet;
  END LOOP;
  IF n = 0 THEN RAISE NOTICE '% — mọi tập đối chiếu I-004 rỗng', p_nhan; END IF;
  RETURN n;
END $f$;

DO $$
DECLARE o_qr bigint; o7 bigint; o8 bigint; o9 bigint; o_mang bigint; u bigint[]; f bigint;
        t bigint; t2 bigint; it bigint; b bigint; r record; n integer;
BEGIN
  -- Bảng trạm của thành phần: một thành phần xuống một trạm một lần.
  BEGIN
    INSERT INTO menu_component_station (menu_component_id, station_code)
    SELECT id, 'trang_banh' FROM menu_component WHERE name = 'test-bánh';
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối khai một thành phần xuống cùng trạm hai lần';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (bánh xuống trạm tráng hai lần — nổ đơn sẽ ra bánh ×2 mỗi cái): %', SQLERRM;
  END;

  -- ------------------------------------------ tầng 1 — đơn chưa duyệt không sinh việc nào
  -- Bàn 5 gửi qua QR: hai suất "đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân, kèm canh ×2.
  PERFORM pg_temp.don('test-b5');   -- mở phiên cho bàn 5
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code,
                           qr_code_id)
  SELECT 'qr_table', 'pending_confirmation', m.table_session_id, m.dining_table_id,
         gen_random_uuid()::text, qr_code_issue(m.dining_table_id)
  FROM table_session_member m JOIN dining_table d ON d.id = m.dining_table_id
  WHERE d.label = 'test-b5'
  RETURNING id INTO o_qr;
  PERFORM pg_temp.dong(o_qr, 'đầy đủ trứng tái', 2, ARRAY['Thịt + mộc nhĩ', 'Nhiều nhân']);
  PERFORM pg_temp.dong(o_qr, 'canh', 2, ARRAY[]::text[]);
  BEGIN
    INSERT INTO station_job (sales_order_id, station_code, position) VALUES (o_qr, 'canh', 1);
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối việc trạm của một đơn Chờ xác nhận';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (việc trạm cho đơn QR Chờ xác nhận): %', SQLERRM;
  END;
  UPDATE sales_order SET status = 'new' WHERE id = o_qr;
  BEGIN
    INSERT INTO station_job (sales_order_id, station_code, position) VALUES (o_qr, 'canh', 1);
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối việc trạm của một đơn Mới';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (việc trạm cho đơn Mới): %', SQLERRM;
  END;
  RAISE NOTICE 'I-004 đơn QR chưa duyệt — việc ở cả năm trạm: %', pg_temp.dem(o_qr);

  -- Quầy duyệt, rồi nổ đơn — hình của shop-facts §5.3: bánh ×6 chứ không ×2, giò không kèm nhân,
  -- MỘT phần nước chấm cho cả đơn, canh đúng 2 bát khách chọn.
  UPDATE sales_order SET status = 'confirmed' WHERE id = o_qr;
  PERFORM pg_temp.no_don(o_qr);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-004 duyệt rồi nổ — %', pg_temp.dem(o_qr);
  IF pg_temp.dem(o_qr) <> 'trang_banh test-bánh ×6 · trang_banh test-trứng tái ×2 · gap_banh test-bánh ×6 · '
                          'gap_banh test-giò ×2 · gap_banh test-trứng tái ×2 · canh nước chấm ×1 · canh test-bát canh ×2' THEN
    RAISE EXCEPTION 'I-004: đơn nổ sai so với ví dụ shop-facts §5.3';
  END IF;
  BEGIN
    UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o_qr;
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối lùi một đơn đã có việc về Chờ xác nhận';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (đơn đã có việc lùi về Chờ xác nhận): %', SQLERRM;
  END;

  -- Không chọn canh ⇒ không việc canh nào, nước chấm vẫn một. Đơn mang đi cũng một phần nước
  -- chấm (gói riêng) — và không có bàn, nên không vào bảng gom theo bàn (shop-facts §5.4 luật 2).
  o7 := pg_temp.don('test-b7');
  PERFORM pg_temp.dong(o7, 'đầy đủ trứng tái', 2, ARRAY['Thịt', 'Thường']);
  PERFORM pg_temp.no_don(o7);
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000000', now(), gen_random_uuid()::text)
  RETURNING id INTO o_mang;
  PERFORM pg_temp.dong(o_mang, 'đầy đủ trứng chín', 1, ARRAY['Thịt', 'Thường']);
  PERFORM pg_temp.no_don(o_mang);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-004 bàn 7 không chọn canh — %', pg_temp.dem(o7);
  RAISE NOTICE 'I-004 đơn mang đi — %', pg_temp.dem(o_mang);
  IF pg_temp.dem(o7) LIKE '%bát canh%' OR pg_temp.dem(o7) NOT LIKE '%canh nước chấm ×1%'
     OR pg_temp.dem(o_mang) NOT LIKE '%canh nước chấm ×1%' THEN
    RAISE EXCEPTION 'I-004: việc trạm canh sai (nước chấm một mỗi đơn, canh đúng số khách chọn)';
  END IF;

  -- -------------------------------- tầng 2 — nổ đơn cắt giữa chừng: không nửa nào sống sót
  o8 := pg_temp.don('test-b8');
  PERFORM pg_temp.dong(o8, 'đầy đủ trứng tái', 1, ARRAY['Thịt', 'Thường']);
  BEGIN
    PERFORM pg_temp.no_don(o8);
    RAISE EXCEPTION USING ERRCODE = 'P0003', MESSAGE = 'mất điện giữa lần nổ đơn';
  EXCEPTION WHEN SQLSTATE 'P0003' THEN NULL;
  END;
  RAISE NOTICE 'I-004 nổ đơn bàn 8 bị cắt giữa chừng — đơn ở "%", việc trạm: %',
    (SELECT status FROM sales_order WHERE id = o8), pg_temp.dem(o8);
  IF (SELECT status FROM sales_order WHERE id = o8) <> 'confirmed' OR pg_temp.dem(o8) <> '0 việc' THEN
    RAISE EXCEPTION 'I-004: một nửa của lần nổ đơn sống sót';
  END IF;

  IF pg_temp.in_doi_chieu('I-004 sau khi nổ') <> 0 THEN
    RAISE EXCEPTION 'I-004: tập đối chiếu không rỗng sau các lần nổ đúng';
  END IF;
  -- Biết kêu: một đường thứ hai đưa đơn bàn 8 sang Đang thực hiện mà không nổ — lược đồ KHÔNG chặn
  -- (vế đủ việc là tầng 2, cửa nổ đơn của pha 3 giữ); câu đối chiếu bắt.
  BEGIN
    UPDATE sales_order SET status = 'in_progress' WHERE id = o8;
    n := pg_temp.in_doi_chieu('I-004 biết kêu (đơn bàn 8 Đang thực hiện, không nổ)');
    IF n = 0 THEN RAISE EXCEPTION 'I-004: câu đối chiếu KHÔNG bắt được đơn Đang thực hiện thiếu việc'; END IF;
    RAISE EXCEPTION USING ERRCODE = 'P0003', MESSAGE = 'hoàn tác';
  EXCEPTION WHEN SQLSTATE 'P0003' THEN NULL;
  END;

  -- --------------------- đơn huỷ SAU KHI đã làm xong (tầng 4 chọn bàn · tầng 2 chuyển · vết)
  -- Bàn 9 gọi đúng thứ bàn 5 đã gọi, một suất. Một mẻ làm xong hai trứng tái của bàn 5, rồi
  -- đơn bàn 5 bị huỷ. Quầy chọn bàn 9 nhận MỘT quả (bàn 9 chỉ chờ một).
  o9 := pg_temp.don('test-b9');
  PERFORM pg_temp.dong(o9, 'đầy đủ trứng tái', 1, ARRAY['Thịt + mộc nhĩ', 'Nhiều nhân']);
  PERFORM pg_temp.no_don(o9);
  u := pg_temp.viec('test-b5', 'trang_banh', 'test-trứng tái', 'pending', 2);
  b := pg_temp.bam_me(u);
  UPDATE sales_order SET status = 'cancelled' WHERE id = o_qr;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  PERFORM pg_temp.in_doi_chieu('I-004 vừa huỷ đơn bàn 5');
  -- Tầng 3 (vế "rút nhu cầu, việc chưa xong"): bảng nhu cầu không còn thấy đơn đã huỷ — phép
  -- đọc lọc theo trạng thái đơn. Các đơn vị "chưa làm" ấy VẪN ở đó (không xoá — QD-50).
  RAISE NOTICE 'I-004 sau khi huỷ — "còn phải làm" của bàn 5 trên bảng: %; đơn vị "chưa làm" của đơn đã huỷ còn trong lược đồ: % (work/findings.md F-044)',
    (SELECT COUNT(*) FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
     JOIN dining_table d ON d.id = o.dining_table_id
     WHERE d.label = 'test-b5' AND j.status = 'pending' AND o.status <> 'cancelled'),
    (SELECT COUNT(*) FROM station_job WHERE sales_order_id = o_qr AND status = 'pending');

  f := u[1];
  t := (pg_temp.viec('test-b9', 'trang_banh', 'test-trứng tái', 'pending', 1))[1];
  SELECT id INTO it FROM production_batch_item WHERE live_station_job_id = f;
  BEGIN   -- đổi chủ mà không ghi lần chuyển
    UPDATE production_batch_item SET station_job_id = t WHERE id = it;
    UPDATE station_job SET status = 'pending' WHERE id = f;
    UPDATE station_job SET status = 'made' WHERE id = t;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối đổi chủ phần đã làm mà không có vết';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (đổi chủ phần đã làm, không có lần chuyển): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN   -- ghi lần chuyển, bàn 9 nhận, nhưng bàn 5 vẫn giữ quả trứng
    INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
    VALUES (it, f, t);
    UPDATE production_batch_item SET station_job_id = t WHERE id = it;
    UPDATE station_job SET status = 'made' WHERE id = t;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối một quả trứng tính cho cả bàn cũ lẫn bàn nhận';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (chuyển mà bàn cũ vẫn giữ phần ấy): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN   -- ghi lần chuyển, bàn 5 nhả, nhưng nhu cầu bàn 9 không giảm
    INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
    VALUES (it, f, t);
    UPDATE production_batch_item SET station_job_id = t WHERE id = it;
    UPDATE station_job SET status = 'pending' WHERE id = f;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối chuyển mà bàn nhận không giảm nhu cầu';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (chuyển mà nhu cầu bàn nhận không giảm): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;

  BEGIN
    INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
    VALUES (it, f, f);
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối lần chuyển mà chủ cũ là chủ mới';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (lần chuyển không đổi chủ): %', SQLERRM;
  END;

  BEGIN   -- lần chuyển không có người chọn bàn nhận (P2-08 — I-004 tầng 4: máy giữ vết có tên)
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
    VALUES (it, f, t);
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối lần chuyển không có người chọn bàn nhận';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (lần chuyển không ai chọn bàn nhận): %', SQLERRM;
  END;

  -- Chuyển đúng: bốn lệnh, một giao dịch.
  INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
  VALUES (it, f, t);
  UPDATE production_batch_item SET station_job_id = t WHERE id = it;
  UPDATE station_job SET status = 'pending' WHERE id = f;
  UPDATE station_job SET status = 'made' WHERE id = t;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  SELECT tr.id, tr.transferred_at, fd.label AS ban_cu, td.label AS ban_nhan, i.production_batch_id,
         (SELECT display_name FROM person WHERE id = tr.person_id) AS nguoi_chon
  INTO r
  FROM station_job_transfer tr
  JOIN production_batch_item i ON i.id = tr.production_batch_item_id
  JOIN station_job fj ON fj.id = tr.from_station_job_id JOIN sales_order fo ON fo.id = fj.sales_order_id
  JOIN dining_table fd ON fd.id = fo.dining_table_id
  JOIN station_job tj ON tj.id = tr.to_station_job_id JOIN sales_order tor ON tor.id = tj.sales_order_id
  JOIN dining_table td ON td.id = tor.dining_table_id
  WHERE tr.production_batch_item_id = it;
  RAISE NOTICE 'I-004 vết lần chuyển — lần %, lúc %: trứng tái của mẻ % từ % sang %, % chọn bàn nhận',
    r.id, r.transferred_at, r.production_batch_id, r.ban_cu, r.ban_nhan, r.nguoi_chon;
  RAISE NOTICE 'I-004 bàn 9 (gọi 1) trứng tái ở trạm tráng sau khi nhận: còn phải làm %, đã làm xong còn ở bếp %',
    COALESCE(array_length(pg_temp.viec('test-b9', 'trang_banh', 'test-trứng tái', 'pending', 9), 1), 0),
    COALESCE(array_length(pg_temp.viec('test-b9', 'trang_banh', 'test-trứng tái', 'made', 9), 1), 0);
  -- Mẻ đã bấm là một lúc đã qua: nó không "làm thêm" cho quả trứng bàn 5 vừa nhả.
  BEGIN
    INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
    VALUES (b, f, f);
    RAISE EXCEPTION 'I-004: database KHÔNG từ chối một mẻ làm cho cùng một đơn vị hai lần';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-004 bị từ chối (mẻ đã bấm làm thêm cho đơn vị nó từng làm): %', SQLERRM;
  END;
  -- Quả trứng thứ hai của bàn 5 không bàn nào chờ đúng nó, chưa ghi chú bánh làm sai. Tập (4) còn nó.
  n := pg_temp.in_doi_chieu('I-004 sau lần chuyển');
  IF n <> 1 OR NOT EXISTS (SELECT 1 FROM pg_temp.doi_chieu_i004() WHERE tap = 'đã làm của đơn huỷ, chưa chuyển') THEN
    RAISE EXCEPTION 'I-004: sau lần chuyển, tập (4) phải còn đúng quả trứng chưa chuyển, chưa ghi chú bánh làm sai';
  END IF;

  -- Vết không sửa được: mẻ làm cho ai lúc bấm là cột vai shop_app không có quyền sửa.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE production_batch_item SET made_for_station_job_id = t WHERE id = it;
    RAISE EXCEPTION 'I-004: vai shop_app sửa được "mẻ làm cho ai"';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-004 vết lần bấm không sửa được (shop_app): %', SQLERRM;
  END;

  -- Biết kêu, tập (5): quầy chọn nhầm — chuyển quả trứng thứ hai sang bàn 7, bàn chờ trứng tái
  -- nhân THỊT, THƯỜNG. Lược đồ nhận (tầng 4: máy không ngăn); câu đối chiếu bắt.
  BEGIN
    f := u[2];
    t2 := (pg_temp.viec('test-b7', 'trang_banh', 'test-trứng tái', 'pending', 1))[1];
    SELECT id INTO it FROM production_batch_item WHERE live_station_job_id = f;
    INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
    VALUES (it, f, t2);
    UPDATE production_batch_item SET station_job_id = t2 WHERE id = it;
    UPDATE station_job SET status = 'pending' WHERE id = f;
    UPDATE station_job SET status = 'made' WHERE id = t2;
    SET CONSTRAINTS ALL IMMEDIATE;
    n := pg_temp.in_doi_chieu('I-004 biết kêu (chuyển sang bàn chờ khác nhân)');
    IF NOT EXISTS (SELECT 1 FROM pg_temp.doi_chieu_i004() WHERE tap = 'chuyển khác khoá gom') THEN
      RAISE EXCEPTION 'I-004: câu đối chiếu KHÔNG bắt được lần chuyển sang bàn chờ khác nhân';
    END IF;
    RAISE EXCEPTION USING ERRCODE = 'P0003', MESSAGE = 'hoàn tác';
  EXCEPTION WHEN SQLSTATE 'P0003' THEN NULL;
  END;
  SET CONSTRAINTS ALL DEFERRED;
END $$;
