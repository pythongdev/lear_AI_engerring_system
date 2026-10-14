-- I-032 (tầng 1 · tầng 2 · tầng 3) và YC-37: danh mục do chủ quán đặt tên, một tên một lần trong danh mục
-- còn dùng; mỗi món thuộc NHIỀU NHẤT MỘT danh mục có thật, món chưa xếp vẫn là món; mỗi combo gồm ÍT NHẤT
-- MỘT món có thật (tầng 2, kiểm lúc giao dịch kết thúc), mỗi món kèm số phần > 0, và mang ĐÚNG MỘT giá
-- nguyên đồng > 0 do chủ quán đặt — không cộng từ giá món, không đổi theo giá món; đổi giá có vết (I-018);
-- danh mục và combo bị ẨN chứ không xoá. Vế "người làm là chủ quán" và "không đổi giá giữa buổi" là
-- tầng 3 — database KHÔNG xét, test nói thẳng (docs/decisions.md ADR-105 điểm 1, ADR-108).
-- Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-032.
-- Lát: 18-luoc-do-danh-muc-combo.md. Viết trước khi có lược đồ (P2A-13, Claude Code): đỏ cho tới khi lát dựng.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i032_category_and_combo_own_price', true); END $$;
DO $$
DECLARE chu bigint; a bigint; c1 bigint; m1 bigint; m2 bigint; m3 bigint; m4 bigint;
        d1 bigint; d2 bigint; d3 bigint; x1 bigint; x2 bigint; cb1 bigint; cb2 bigint;
        r record; snap text; snap2 text; cn text;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO a;

  -- Món giả của lát menu P2-05 — không một con giá thật nào (03-luoc-do-menu-gia.md §0).
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-phần bánh', 10000, true) RETURNING id INTO c1;
  INSERT INTO menu_item (name) VALUES ('test-suất một') RETURNING id INTO m1;
  INSERT INTO menu_item (name) VALUES ('test-suất hai') RETURNING id INTO m2;
  INSERT INTO menu_item (name) VALUES ('test-suất ba') RETURNING id INTO m3;
  INSERT INTO menu_item (name) VALUES ('test-suất chưa xếp') RETURNING id INTO m4;
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity)
  SELECT m, c1, 1 FROM unnest(ARRAY[m1, m2, m3, m4]) AS m;

  -- Chụp số dòng mọi bảng ngoài lát và ngoài menu giả của test: lát không được đổi bảng bán hàng hay tiền.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('menu_category', 'menu_item_category', 'menu_combo', 'menu_combo_item',
                             'menu_component', 'record_revision', 'person');

  -- ===================== DANH MỤC =====================
  -- Kịch bản dương: chủ quán lập danh mục, xếp ba món vào ⇒ đọc lại được; món thứ tư chưa xếp vẫn là món.
  -- Người lập lấy từ người thao tác của giao dịch. Chạy bằng vai ghi của hệ thống.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO menu_category (name) VALUES ('test-Bánh cuốn') RETURNING id INTO d1;
    INSERT INTO menu_category (name) VALUES ('test-Đồ uống') RETURNING id INTO d2;
    INSERT INTO menu_item_category (menu_item_id, menu_category_id) SELECT m, d1 FROM unnest(ARRAY[m1, m2, m3]) AS m;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-032: vai shop_app KHÔNG lập được danh mục hay KHÔNG xếp được món: %', SQLERRM;
  END;
  SELECT string_agg(i.name, ', ' ORDER BY i.id) AS mon, bool_and(p.display_name = 'test-chủ quán') AS dung_nguoi,
         bool_and(d.created_at IS NOT NULL) AS co_luc
  INTO r FROM menu_item_category ic JOIN menu_item i ON i.id = ic.menu_item_id
  JOIN menu_category d ON d.id = ic.menu_category_id JOIN person p ON p.id = d.person_id WHERE d.id = d1;
  IF r.mon IS DISTINCT FROM 'test-suất một, test-suất hai, test-suất ba' OR NOT r.dung_nguoi OR NOT r.co_luc
     OR EXISTS (SELECT 1 FROM menu_item_category WHERE menu_item_id = m4) THEN
    RAISE EXCEPTION 'I-032: danh mục không đọc lại được đúng các món đã xếp, người lập và lúc lập';
  END IF;
  RAISE NOTICE 'YC-37 danh mục "test-Bánh cuốn" — %; người lập test-chủ quán; test-suất chưa xếp: không danh mục', r.mon;

  -- Món chưa xếp vẫn là món: lát không thêm cột nào vào bảng món, và không bảng nào ngoài lát trỏ tới danh mục.
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'menu_item'
             AND column_name NOT IN ('id', 'name', 'discontinued_at', 'created_at'))
     OR EXISTS (SELECT 1 FROM pg_constraint k WHERE k.contype = 'f'
                AND k.confrelid IN ('shop.menu_category'::regclass, 'shop.menu_combo'::regclass)
                AND k.conrelid NOT IN ('shop.menu_item_category'::regclass, 'shop.menu_combo_item'::regclass)) THEN
    RAISE EXCEPTION 'I-032: bảng món bị thêm cột, hoặc một bảng ngoài lát trỏ tới danh mục hay combo — món chưa xếp có thể bị chặn bán';
  END IF;
  RAISE NOTICE 'I-032 món chưa xếp vẫn bán được — bảng món giữ nguyên cột, chỉ bảng của lát trỏ tới danh mục và combo';

  -- Tầng 1: tên rỗng · trắng · trùng tên còn dùng ⇒ từ chối; ẩn danh mục cũ thì lập lại được tên ấy.
  BEGIN
    INSERT INTO menu_category (name) VALUES (NULL);
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối một danh mục không có tên';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (danh mục không có tên): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO menu_category (name) VALUES ('   ');
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối một tên danh mục chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (tên danh mục chỉ có khoảng trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO menu_category (name) VALUES ('test-Bánh cuốn');
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối một tên đứng hai lần trong danh mục còn dùng';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (tên danh mục trùng): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO menu_category (name) VALUES ('test-không ai lập');
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối một danh mục không có người lập';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (danh mục không có người lập): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);

  -- Tầng 1: xếp món vào danh mục không có thật · món không có thật · xếp một món vào danh mục thứ hai ⇒ từ chối.
  BEGIN
    INSERT INTO menu_item_category (menu_item_id, menu_category_id) VALUES (m4, 999999999);
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối xếp món vào một danh mục không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (danh mục không có thật): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO menu_item_category (menu_item_id, menu_category_id) VALUES (999999999, d1);
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối xếp một món không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (món không có thật): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO menu_item_category (menu_item_id, menu_category_id) VALUES (m1, d2);
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối một món thuộc hai danh mục';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (món thuộc hai danh mục): %', SQLERRM;
  END;

  -- Kịch bản chuyển: chuyển một món sang danh mục khác là sửa có vết; món vẫn đúng một danh mục.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'test-xếp nhầm', true);
    UPDATE menu_item_category SET menu_category_id = d2 WHERE menu_item_id = m3 RETURNING id INTO x1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-032: vai shop_app KHÔNG chuyển được món sang danh mục khác: %', SQLERRM;
  END;
  IF (SELECT count(*) FROM menu_item_category WHERE menu_item_id = m3) <> 1
     OR NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'menu_item_category' AND target_row = x1
                    AND person_id = chu AND reason = 'test-xếp nhầm'
                    AND (before_image ->> 'menu_category_id')::bigint = d1 AND (after_image ->> 'menu_category_id')::bigint = d2) THEN
    RAISE EXCEPTION 'I-032: chuyển món sang danh mục khác không giữ đúng một danh mục, hay không có vết';
  END IF;
  RAISE NOTICE 'I-032 chuyển danh mục — test-suất ba sang test-Đồ uống, có vết, vẫn một danh mục';
  PERFORM set_config('shop.revision_reason', 'test-i032_category_and_combo_own_price', true);

  -- ===================== COMBO =====================
  -- Kịch bản dương: chủ quán lập một combo hai món với giá riêng; combo và món của nó ghi cùng một giao dịch.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO menu_combo (name, price_vnd) VALUES ('test-Combo đôi', 25000) RETURNING id INTO cb1;
    INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (cb1, m1, 1), (cb1, m2, 2);
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-032: vai shop_app KHÔNG lập được combo: %', SQLERRM;
  END;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  SELECT c.name, c.price_vnd, p.display_name AS nguoi_lap, c.created_at IS NOT NULL AS co_luc,
         (SELECT string_agg(i.name || ' ×' || ci.quantity, ', ' ORDER BY i.id)
          FROM menu_combo_item ci JOIN menu_item i ON i.id = ci.menu_item_id WHERE ci.menu_combo_id = c.id) AS mon
  INTO r FROM menu_combo c JOIN person p ON p.id = c.person_id WHERE c.id = cb1;
  IF r.price_vnd IS DISTINCT FROM 25000::bigint OR r.mon IS DISTINCT FROM 'test-suất một ×1, test-suất hai ×2'
     OR r.nguoi_lap IS DISTINCT FROM 'test-chủ quán' OR NOT r.co_luc THEN
    RAISE EXCEPTION 'I-032: combo không đọc lại được tên · món và số phần · giá riêng · người lập · lúc lập';
  END IF;
  RAISE NOTICE 'YC-37 combo "%" — %; giá riêng %đ (tổng giá món theo thành phần sẽ là %đ); người lập %',
    r.name, r.mon, r.price_vnd, 3 * 10000, r.nguoi_lap;

  -- Tầng 2: combo không có món nào ⇒ từ chối lúc giao dịch kết thúc (ở đây: lúc ép kiểm ngay).
  BEGIN
    INSERT INTO menu_combo (name, price_vnd) VALUES ('test-Combo rỗng', 20000);
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối một combo không có món nào';
  EXCEPTION WHEN integrity_constraint_violation THEN
    GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME;
    IF cn IS DISTINCT FROM 'menu_combo_has_item_check' THEN RAISE; END IF;
    RAISE NOTICE 'I-032 bị từ chối (combo không có món, kiểm lúc kết thúc giao dịch — %): %', cn, SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;

  -- Tầng 1: giá không có · 0đ · âm ⇒ từ chối; giá là số nguyên đồng (đọc lược đồ: lẻ đồng không cất được).
  FOR r IN SELECT * FROM (VALUES (NULL::bigint, 'combo không có giá', 'nn'), (0::bigint, 'giá combo 0đ', 'ck'),
                                 (-5000::bigint, 'giá combo âm', 'ck')) AS x(gia, ca, loai) LOOP
    BEGIN
      INSERT INTO menu_combo (name, price_vnd) VALUES ('test-Combo giá sai', r.gia);
      RAISE EXCEPTION 'I-032: database KHÔNG từ chối %', r.ca;
    EXCEPTION
      WHEN not_null_violation THEN
        IF r.loai <> 'nn' THEN RAISE; END IF;
        RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
      WHEN check_violation THEN
        IF r.loai <> 'ck' THEN RAISE; END IF;
        RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;
  IF (SELECT data_type FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'menu_combo'
      AND column_name = 'price_vnd') IS DISTINCT FROM 'bigint'
     OR (SELECT count(*) FROM information_schema.columns WHERE table_schema = 'shop'
         AND table_name IN ('menu_combo', 'menu_combo_item') AND column_name LIKE '%\_vnd') <> 1 THEN
    RAISE EXCEPTION 'I-032: combo không mang đúng MỘT cột giá nguyên đồng';
  END IF;
  RAISE NOTICE 'I-032 giá nguyên đồng — combo có đúng một cột tiền, kiểu bigint; thành phần combo không cất giá';
  BEGIN
    INSERT INTO menu_combo (name, price_vnd) VALUES ('   ', 20000);
    RAISE EXCEPTION 'I-032: database KHÔNG từ chối một tên combo chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-032 bị từ chối (tên combo chỉ có khoảng trắng): %', SQLERRM;
  END;

  -- Tầng 1: món trong combo không có thật · combo không có thật · số phần thiếu · 0 · âm · một món hai dòng ⇒ từ chối.
  FOR r IN SELECT * FROM (VALUES
      (format('INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (%s, 999999999, 1)', cb1), 'món trong combo không có thật', 'fk'),
      (format('INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (999999999, %s, 1)', m3), 'combo không có thật', 'fk'),
      (format('INSERT INTO menu_combo_item (menu_combo_id, menu_item_id) VALUES (%s, %s)', cb1, m3), 'món trong combo thiếu số phần', 'nn'),
      (format('INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (%s, %s, 0)', cb1, m3), 'số phần 0', 'ck'),
      (format('INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (%s, %s, -1)', cb1, m3), 'số phần âm', 'ck'),
      (format('INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (%s, %s, 1)', cb1, m1), 'một món đứng hai dòng trong combo', 'uq')
    ) AS x(sql, ca, loai) LOOP
    BEGIN
      EXECUTE r.sql;
      RAISE EXCEPTION 'I-032: database KHÔNG từ chối %', r.ca;
    EXCEPTION
      WHEN foreign_key_violation THEN IF r.loai <> 'fk' THEN RAISE; END IF; RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
      WHEN not_null_violation THEN IF r.loai <> 'nn' THEN RAISE; END IF; RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
      WHEN check_violation THEN IF r.loai <> 'ck' THEN RAISE; END IF; RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
      WHEN unique_violation THEN IF r.loai <> 'uq' THEN RAISE; END IF; RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- Giá riêng, không đổi theo giá món: đổi giá thành phần của món trong combo ⇒ giá combo giữ nguyên.
  UPDATE menu_component SET base_price_vnd = 12000 WHERE id = c1;
  IF (SELECT price_vnd FROM menu_combo WHERE id = cb1) <> 25000 THEN
    RAISE EXCEPTION 'I-032: giá combo đổi theo giá món';
  END IF;
  RAISE NOTICE 'I-032 giá riêng — giá thành phần 10000đ → 12000đ, giá combo vẫn %đ', (SELECT price_vnd FROM menu_combo WHERE id = cb1);

  -- Kịch bản sửa: đổi giá combo, có khai lý do ⇒ vết đọc ra giá cũ, giá mới, người sửa.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'test-đổi giá đầu năm', true);
    UPDATE menu_combo SET price_vnd = 27000 WHERE id = cb1;
    PERFORM set_config('shop.revision_reason', 'test-thêm một suất hai', true);
    UPDATE menu_combo_item SET quantity = 3 WHERE menu_combo_id = cb1 AND menu_item_id = m2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-032: vai shop_app KHÔNG đổi được giá combo hay số phần: %', SQLERRM;
  END;
  IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'menu_combo' AND target_row = cb1
                   AND person_id = chu AND reason = 'test-đổi giá đầu năm'
                   AND (before_image ->> 'price_vnd')::bigint = 25000 AND (after_image ->> 'price_vnd')::bigint = 27000)
     OR NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'menu_combo_item'
                   AND reason = 'test-thêm một suất hai'
                   AND (before_image ->> 'quantity')::int = 2 AND (after_image ->> 'quantity')::int = 3) THEN
    RAISE EXCEPTION 'I-032: đổi giá combo hay số phần không để lại bản trước · bản sau · lý do · người sửa';
  END IF;
  RAISE NOTICE 'YC-37 đổi giá combo — 25000đ → 27000đ, lý do "test-đổi giá đầu năm", người sửa test-chủ quán; có vết đổi số phần';
  PERFORM set_config('shop.revision_reason', 'test-i032_category_and_combo_own_price', true);

  -- Người lập, lúc lập của danh mục và combo; combo và món của một dòng thành phần: vai ghi không đổi được.
  SELECT id INTO x2 FROM menu_combo_item WHERE menu_combo_id = cb1 AND menu_item_id = m1;
  FOR r IN SELECT * FROM (VALUES
      (format('UPDATE menu_category SET person_id = %s WHERE id = %s', a, d1), 'đổi người lập danh mục'),
      (format('UPDATE menu_category SET created_at = now() - interval ''1 day'' WHERE id = %s', d1), 'đổi lúc lập danh mục'),
      (format('UPDATE menu_combo SET person_id = %s WHERE id = %s', a, cb1), 'đổi người lập combo'),
      (format('UPDATE menu_combo SET created_at = now() - interval ''1 day'' WHERE id = %s', cb1), 'đổi lúc lập combo'),
      (format('UPDATE menu_combo_item SET menu_combo_id = %s WHERE id = %s', cb1, x2), 'chuyển thành phần sang combo khác'),
      (format('UPDATE menu_combo_item SET menu_item_id = %s WHERE id = %s', m3, x2), 'đổi món của một thành phần combo'),
      (format('UPDATE menu_item_category SET menu_item_id = %s WHERE id = %s', m4, x1), 'đổi món của một lần xếp')
    ) AS x(sql, ca) LOOP
    BEGIN
      SET LOCAL ROLE shop_app;
      EXECUTE r.sql;
      RESET ROLE;
      RAISE EXCEPTION 'I-032: vai shop_app %', upper(r.ca);
    EXCEPTION WHEN insufficient_privilege THEN
      RESET ROLE;
      RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- ===================== ẨN, KHÔNG XOÁ =====================
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE menu_combo SET hidden_at = now(), hidden_by_person_id = chu WHERE id = cb1;
    UPDATE menu_category SET hidden_at = now(), hidden_by_person_id = chu WHERE id = d1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-032: vai shop_app KHÔNG ẩn được combo hay danh mục: %', SQLERRM;
  END;
  SELECT (SELECT h.display_name FROM menu_combo c JOIN person h ON h.id = c.hidden_by_person_id WHERE c.id = cb1) AS an_cb,
         (SELECT h.display_name FROM menu_category d JOIN person h ON h.id = d.hidden_by_person_id WHERE d.id = d1) AS an_dm,
         (SELECT count(*) FROM menu_combo_item WHERE menu_combo_id = cb1) AS so_mon,
         (SELECT count(*) FROM menu_item_category WHERE menu_category_id = d1) AS so_xep
  INTO r;
  IF r.an_cb IS DISTINCT FROM 'test-chủ quán' OR r.an_dm IS DISTINCT FROM 'test-chủ quán' OR r.so_mon <> 2 OR r.so_xep <> 2 THEN
    RAISE EXCEPTION 'I-032: combo hay danh mục đã ẩn không đọc lại được kèm ai ẩn và các món của nó';
  END IF;
  RAISE NOTICE 'YC-37 đã ẩn — combo ẩn bởi % (còn % món), danh mục ẩn bởi % (còn % món xếp)', r.an_cb, r.so_mon, r.an_dm, r.so_xep;
  -- Danh mục đã ẩn nhường tên: lập lại "test-Bánh cuốn" được.
  INSERT INTO menu_category (name) VALUES ('test-Bánh cuốn') RETURNING id INTO d3;
  RAISE NOTICE 'I-032 tên danh mục — danh mục cũ đã ẩn, lập lại cùng tên được (danh mục mới %)', d3;
  FOR r IN SELECT * FROM (VALUES
      (format('DELETE FROM menu_combo WHERE id = %s', cb1), 'xoá cứng một combo'),
      (format('DELETE FROM menu_combo_item WHERE id = %s', x2), 'xoá cứng một món của combo'),
      (format('DELETE FROM menu_category WHERE id = %s', d2), 'xoá cứng một danh mục'),
      (format('DELETE FROM menu_item_category WHERE id = %s', x1), 'xoá cứng một lần xếp món')
    ) AS x(sql, ca) LOOP
    BEGIN
      SET LOCAL ROLE shop_app;
      EXECUTE r.sql;
      RESET ROLE;
      RAISE EXCEPTION 'I-032: vai shop_app %', upper(r.ca);
    EXCEPTION WHEN insufficient_privilege THEN
      RESET ROLE;
      RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;
  FOR r IN SELECT * FROM (VALUES
      (format('UPDATE menu_category SET hidden_at = now() WHERE id = %s', d2), 'ẩn danh mục không có người ẩn', 'ck'),
      (format('UPDATE menu_combo SET hidden_at = now(), hidden_by_person_id = NULL WHERE id = %s', cb1), 'combo đã ẩn mất người ẩn', 'ck'),
      (format('UPDATE menu_category SET hidden_at = now(), hidden_by_person_id = 999999999 WHERE id = %s', d2), 'người ẩn danh mục là người lạ', 'fk')
    ) AS x(sql, ca, loai) LOOP
    BEGIN
      EXECUTE r.sql;
      RAISE EXCEPTION 'I-032: database KHÔNG từ chối %', r.ca;
    EXCEPTION
      WHEN check_violation THEN IF r.loai <> 'ck' THEN RAISE; END IF; RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
      WHEN foreign_key_violation THEN IF r.loai <> 'fk' THEN RAISE; END IF; RAISE NOTICE 'I-032 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- Tầng 3, nói thẳng: database KHÔNG xét người lập, sửa, ẩn có phải chủ quán không, cũng không xét giờ bán
  -- khi đổi giá combo — cửa ghi của backend xét (ADR-105 điểm 1, ADR-108), tập đối chiếu của I-032 bắt.
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO menu_category (name) VALUES ('test-danh mục do người làm lập');
  INSERT INTO menu_combo (name, price_vnd) VALUES ('test-Combo do người làm lập', 30000) RETURNING id INTO cb2;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (cb2, m4, 1);
  PERFORM set_config('shop.revision_reason', 'test-đổi giá bởi người không phải chủ quán', true);
  UPDATE menu_combo SET price_vnd = 31000 WHERE id = cb2;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-032 tầng 3 — danh mục, combo và lần đổi giá do người KHÔNG phải chủ quán: database nhận; cửa ghi và phép đối chiếu giữ vế này';

  -- Không bảng nào ngoài lát (và ngoài menu giả của test) đổi số dòng.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('menu_category', 'menu_item_category', 'menu_combo', 'menu_combo_item',
                             'menu_component', 'record_revision', 'person');
  IF snap IS DISTINCT FROM snap2 THEN
    RAISE EXCEPTION 'I-032: danh mục hay combo làm đổi số dòng của một bảng khác';
  END IF;
  RAISE NOTICE 'I-032 không chạm bảng khác — số dòng mọi bảng ngoài lát giữ nguyên';
END $$;
