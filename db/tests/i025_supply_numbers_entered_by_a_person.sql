-- I-025 (tầng 1 · tầng 3) và YC-26 · YC-27 · YC-28: mỗi con số nguyên liệu do một NGƯỜI gõ vào,
-- mang ai nhập · ngày của con số · lúc gõ; thiếu một trong ba thì không tồn tại được; danh mục
-- thêm dần, đơn vị mua trống được; sửa một con số là một lần cập nhật có vết (I-018); không thao
-- tác bán hàng nào chạm tới sổ; lược đồ không cất ngưỡng, định lượng suất hay kết luận thiếu.
-- Chế độ NGHIÊM của vết từ bước 20 (T-138, ADR-092) áp cả ở đây: sửa không khai lý do bị từ chối.
-- Lát: 12-luoc-do-nguyen-lieu.md.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i025_supply_numbers_entered_by_a_person', true); END $$;
DO $$
DECLARE chu bigint; nv bigint; gao bigint; hanh bigint; e_mua bigint; e_dung bigint; e_le bigint;
        o1 bigint; n bigint; snap text; cols text; r record;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người làm') RETURNING id INTO nv;

  -- YC-26 — danh mục thêm dần; một thứ CHƯA có đơn vị mua vẫn tồn tại được (shop-facts §8.4: đơn
  -- vị chưa có lời thì trống, không tự gán).
  INSERT INTO supply_item (name, purchase_unit) VALUES ('test-gạo', 'kg') RETURNING id INTO gao;
  INSERT INTO supply_item (name) VALUES ('test-hành tây') RETURNING id INTO hanh;
  FOR r IN SELECT name, purchase_unit FROM supply_item WHERE id IN (gao, hanh) ORDER BY id LOOP
    RAISE NOTICE 'YC-26 danh mục — "%", đơn vị mua: %', r.name, COALESCE(r.purchase_unit, '(trống)');
  END LOOP;
  BEGIN
    INSERT INTO supply_item (name) VALUES ('   ');
    RAISE EXCEPTION 'YC-26: database KHÔNG từ chối một thứ không có tên';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-26 bị từ chối (tên chỉ có khoảng trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO supply_item (name, purchase_unit) VALUES ('test-quất', '  ');
    RAISE EXCEPTION 'YC-26: database KHÔNG từ chối đơn vị mua chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-26 bị từ chối (đơn vị mua chỉ có khoảng trắng — chưa có lời thì để TRỐNG): %', SQLERRM;
  END;

  -- Kịch bản dương của I-025: chủ quán nhập mua vào 10 và đã dùng 7 cho gạo, ngày 2026-09-21.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  VALUES (gao, '2026-09-21', 'purchased', 10) RETURNING id INTO e_mua;
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  VALUES (gao, '2026-09-21', 'used', 7) RETURNING id INTO e_dung;
  -- Người khác nhập con số khác: người nhập là của TỪNG con số, không của cả ngày. Số lẻ giữ
  -- nguyên như người gõ — máy không quy đổi đơn vị (I-026 điều kiện biên, câu B12).
  PERFORM set_config('shop.actor_person_id', nv::text, true);
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  VALUES (hanh, '2026-09-21', 'used', 2.5) RETURNING id INTO e_le;
  FOR r IN
    SELECT i.name, e.kind_code, e.entered_measure::text AS so, p.display_name, e.entry_date,
           e.created_at IS NOT NULL AS co_luc_go
    FROM supply_day_entry e JOIN supply_item i ON i.id = e.supply_item_id
    JOIN person p ON p.id = e.person_id ORDER BY e.id
  LOOP
    RAISE NOTICE 'YC-28 con số — % · % · %: % nhập, ngày của con số %, có lúc gõ: %',
      r.name, r.kind_code, r.so, r.display_name, r.entry_date, r.co_luc_go;
  END LOOP;
  IF (SELECT entered_measure::text FROM supply_day_entry WHERE id = e_le) <> '2.5'
     OR (SELECT person_id FROM supply_day_entry WHERE id = e_mua) <> chu
     OR (SELECT person_id FROM supply_day_entry WHERE id = e_le) <> nv
     OR EXISTS (SELECT 1 FROM supply_day_entry WHERE created_at IS NULL) THEN
    RAISE EXCEPTION 'I-025: con số không đọc lại được đúng như người gõ, kèm người nhập và lúc gõ';
  END IF;

  -- Tầng 1: thiếu người nhập · thiếu ngày · thiếu con số ⇒ không tồn tại được.
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    VALUES (hanh, '2026-09-21', 'purchased', 3);
    RAISE EXCEPTION 'I-025: database KHÔNG từ chối con số không có người nhập';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-025 bị từ chối (không có người nhập): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, kind_code, entered_measure)
    VALUES (hanh, 'purchased', 3);
    RAISE EXCEPTION 'I-025: database KHÔNG từ chối con số không có ngày';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-025 bị từ chối (không có ngày của con số): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code)
    VALUES (hanh, '2026-09-21', 'purchased');
    RAISE EXCEPTION 'I-025: database KHÔNG từ chối một dòng không có con số';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-025 bị từ chối (không có con số): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure, person_id)
    VALUES (hanh, '2026-09-21', 'purchased', 3, 999999999);
    RAISE EXCEPTION 'I-025: database KHÔNG từ chối người nhập không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-025 bị từ chối (người nhập không phải người của quán): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    VALUES (999999999, '2026-09-21', 'purchased', 3);
    RAISE EXCEPTION 'YC-27: database KHÔNG từ chối con số của một thứ không có trong danh mục';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-27 bị từ chối (thứ không có trong danh mục): %', SQLERRM;
  END;
  -- Hai loại con số, không loại thứ ba: không "còn lại cuối buổi" (B18), không chỉ số công tơ.
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    VALUES (hanh, '2026-09-21', 'remaining', 3);
    RAISE EXCEPTION 'YC-27: database KHÔNG từ chối một loại con số ngoài mua vào · đã dùng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-27 bị từ chối (loại con số thứ ba): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    VALUES (hanh, '2026-09-21', 'purchased', -1);
    RAISE EXCEPTION 'YC-27: database KHÔNG từ chối con số âm';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-27 bị từ chối (con số âm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    VALUES (hanh, '2026-09-21', 'purchased', 'NaN');
    RAISE EXCEPTION 'YC-27: database KHÔNG từ chối một con số không phải số';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-27 bị từ chối (NaN): %', SQLERRM;
  END;

  -- Kịch bản sửa: đã dùng 7 → 8, có khai lý do ⇒ đọc ra cả 7 lẫn 8, lý do và người sửa (I-018).
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  PERFORM set_config('shop.revision_reason', 'test-cân lại cuối buổi', true);
  UPDATE supply_day_entry SET entered_measure = 8 WHERE id = e_dung;
  SELECT v.before_image ->> 'entered_measure' AS truoc, v.after_image ->> 'entered_measure' AS sau,
         v.reason, p.display_name
  INTO r FROM record_revision v JOIN person p ON p.id = v.person_id
  WHERE v.target_table_code = 'supply_day_entry' AND v.target_row = e_dung;
  IF r.truoc IS DISTINCT FROM '7' OR r.sau IS DISTINCT FROM '8' THEN
    RAISE EXCEPTION 'I-025: sửa một con số có khai lý do mà không để lại bản trước 7 · bản sau 8';
  END IF;
  RAISE NOTICE 'I-025 sửa con số — trước %, sau %, lý do "%", % sửa', r.truoc, r.sau, r.reason, r.display_name;
  -- Chế độ nghiêm (T-138, ADR-092; F-046 đã gỡ): sửa KHÔNG khai lý do bị từ chối — không lần sửa nào
  -- của sổ đi qua mà mất vết.
  PERFORM set_config('shop.revision_reason', '', true);
  BEGIN
    UPDATE supply_day_entry SET entered_measure = 8.5 WHERE id = e_dung;
    RAISE EXCEPTION 'I-025: database KHÔNG từ chối lần sửa con số không khai lý do';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-025 chế độ nghiêm — sửa không khai lý do bị từ chối: %', SQLERRM;
  END;
  PERFORM set_config('shop.revision_reason', 'test-cân lại cuối buổi', true);

  -- Không xoá cứng (QD-50): vai ghi của hệ thống không xoá được con số hay một thứ trong danh mục.
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM supply_day_entry WHERE id = e_le;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một con số nguyên liệu';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 con số không xoá được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM supply_item WHERE id = hanh;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một thứ trong danh mục';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 danh mục không xoá được (shop_app): %', SQLERRM;
  END;

  -- Vế "máy không giữ thứ gì để tự tính" (tầng 3, kiểm bằng ĐỌC LƯỢC ĐỒ): danh sách cột của hai
  -- bảng là đúng danh sách dưới đây. Thêm một cột — một ngưỡng, một định lượng suất, một tổng cất
  -- sẵn, một kết luận thiếu — là đổi mệnh đề I-025 · I-026 trước, rồi mới đổi dòng này.
  SELECT string_agg(table_name::text, ',' ORDER BY table_name::text COLLATE "C") INTO cols
  FROM information_schema.tables WHERE table_schema = 'shop' AND table_name LIKE 'supply%';
  IF cols IS DISTINCT FROM 'supply_day_entry,supply_item' THEN
    RAISE EXCEPTION 'I-025: bảng của sổ nguyên liệu khác danh sách đã duyệt: %', cols;
  END IF;
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'supply_item';
  IF cols IS DISTINCT FROM 'created_at,id,name,purchase_unit' THEN
    RAISE EXCEPTION 'I-025: cột của supply_item khác danh sách đã duyệt: %', cols;
  END IF;
  RAISE NOTICE 'I-025 đọc lược đồ — supply_item: %', cols;
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'supply_day_entry';
  IF cols IS DISTINCT FROM 'created_at,entered_measure,entry_date,id,kind_code,person_id,supply_item_id' THEN
    RAISE EXCEPTION 'I-025: cột của supply_day_entry khác danh sách đã duyệt: %', cols;
  END IF;
  RAISE NOTICE 'I-025 đọc lược đồ — supply_day_entry: % — không ngưỡng, không định lượng suất, không tổng cất sẵn', cols;

  -- Vế "không thao tác bán hàng nào chạm" (tầng 3), phần đọc được trên lược đồ: không khoá ngoại
  -- nào nối sổ với đơn · phiên · mẻ · tiền; không hàm nào của schema nhắc tới sổ; hai bảng không
  -- mang trigger nào ngoài trigger vết.
  SELECT COUNT(*) INTO n FROM pg_constraint c
  JOIN pg_class a ON a.oid = c.conrelid JOIN pg_class b ON b.oid = c.confrelid
  JOIN pg_namespace ns ON ns.oid = c.connamespace
  WHERE ns.nspname = 'shop' AND c.contype = 'f'
    AND (   (b.relname LIKE 'supply%' AND a.relname NOT LIKE 'supply%')
         OR (a.relname LIKE 'supply%' AND b.relname NOT IN ('supply_item', 'person')));
  IF n <> 0 THEN RAISE EXCEPTION 'I-025: % khoá ngoại nối sổ nguyên liệu với bảng ngoài danh mục và người', n; END IF;
  SELECT COUNT(*) INTO n FROM pg_proc f JOIN pg_namespace ns ON ns.oid = f.pronamespace
  WHERE ns.nspname = 'shop' AND f.prosrc ILIKE '%supply\_%';
  IF n <> 0 THEN RAISE EXCEPTION 'I-025: % hàm của schema nhắc tới sổ nguyên liệu — một đường ghi thứ hai', n; END IF;
  SELECT COUNT(*) INTO n FROM pg_trigger g JOIN pg_class c ON c.oid = g.tgrelid
  JOIN pg_namespace ns ON ns.oid = c.relnamespace JOIN pg_proc f ON f.oid = g.tgfoid
  WHERE ns.nspname = 'shop' AND c.relname LIKE 'supply%' AND NOT g.tgisinternal
    AND f.proname <> 'record_revision_capture';
  IF n <> 0 THEN RAISE EXCEPTION 'I-025: % trigger ngoài trigger vết trên sổ nguyên liệu', n; END IF;
  RAISE NOTICE 'I-025 đọc lược đồ — 0 khoá ngoại sang đơn · phiên · mẻ · tiền, 0 hàm nhắc tới sổ, 0 trigger ngoài trigger vết';

  -- …và phần chạy thật, thu nhỏ: một đơn tới lấy được tạo, thu tiền, hoàn thành ⇒ sổ không đổi
  -- một con số nào. Buổi bán đủ năm kênh của mục Verification là việc của cổng P2A-08.
  SELECT md5(string_agg(to_jsonb(e)::text, '|' ORDER BY e.id)) INTO snap FROM supply_day_entry e;
  PERFORM set_config('shop.revision_reason', 'test-bán một đơn tới lấy', true);
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text)
  RETURNING id INTO o1;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd) VALUES (o1, 50000, 50000);
  UPDATE sales_order SET status = 'completed' WHERE id = o1;
  IF (SELECT md5(string_agg(to_jsonb(e)::text, '|' ORDER BY e.id)) FROM supply_day_entry e)
     IS DISTINCT FROM snap THEN
    RAISE EXCEPTION 'I-025: một thao tác bán hàng làm đổi sổ nguyên liệu';
  END IF;
  RAISE NOTICE 'I-025 sau một đơn tạo · thu tiền · hoàn thành — sổ nguyên liệu không đổi (% con số)',
    (SELECT COUNT(*) FROM supply_day_entry);
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
