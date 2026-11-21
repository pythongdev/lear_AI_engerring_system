-- YT-03 (tầng 1): món yêu thích và bộ món của khách lưu theo tài khoản khách, KHÔNG mang giá, tên hay ảnh; một dòng có
-- đúng hình một dòng giỏ (món + lựa chọn, hoặc combo + các suất con); không xoá cứng — bỏ tim, xoá bộ là đặt mốc gỡ một
-- lần; dữ liệu khách này không trỏ được vào bộ hay dòng của khách khác; ghi yêu thích không đổi bảng nào khác.
-- Thiết kế: docs/decisions.md ADR-145. Viết trước lược đồ (YT-03, Claude Code, 2026-11-19): đỏ cho tới khi migration dựng.
-- Chống trùng dòng tim (cộng số lượng) và kiểm lựa chọn thuộc món là việc của cửa ghi backend (ADR-145 điểm 4 · 7), không ở đây.
--
-- Tên Claude chốt (ràng buộc / trigger phát lời từ chối với CONSTRAINT = tên dưới, ERRCODE như ghi):
--   customer_favourite_set: customer_favourite_set_account_fkey · customer_favourite_set_owner_key (unique: id, customer_account_id)
--     customer_favourite_set_kind_check (kind IN ('rieng','da_luu')) · customer_favourite_set_name_check (btrim <> '' và ≤ 60 ký tự)
--     customer_favourite_set_limit_check (trigger, check_violation: tối đa 20 bộ chưa gỡ mỗi khách)
--     customer_favourite_set_removed_once_check (trigger, check_violation: removed_at ghi một lần, không bỏ)
--   customer_favourite_line: customer_favourite_line_account_fkey · customer_favourite_line_owner_key (unique: id, customer_account_id)
--     customer_favourite_line_set_fkey ((favourite_set_id, customer_account_id) → set owner_key)
--     customer_favourite_line_parent_fkey ((parent_line_id, customer_account_id) → line owner_key)
--     customer_favourite_line_menu_item_fkey · customer_favourite_line_menu_combo_fkey
--     customer_favourite_line_item_xor_combo_check · customer_favourite_line_quantity_check (1…99)
--     customer_favourite_line_shape_check (trigger, check_violation: dòng con phải là dòng món, cha phải là dòng combo chưa gỡ
--       cùng bộ; dòng combo không có cha)
--     customer_favourite_line_limit_check (trigger, check_violation: tối đa 50 dòng tim gốc chưa gỡ mỗi khách — favourite_set_id
--       NULL, không cha —, tối đa 20 dòng gốc chưa gỡ mỗi bộ)
--     customer_favourite_line_removed_once_check (trigger, check_violation)
--   customer_favourite_line_option: customer_favourite_line_option_line_fkey · customer_favourite_line_option_option_fkey
--     customer_favourite_line_option_key (unique: favourite_line_id, menu_option_id)
--     customer_favourite_line_option_item_line_check (trigger, check_violation: chỉ dòng món mang lựa chọn)
-- Quyền vai shop_app: SELECT, INSERT cả ba bảng; UPDATE chỉ (name, removed_at) của bộ, (quantity, removed_at) của dòng;
-- không UPDATE lựa chọn; không DELETE/TRUNCATE. Mỗi bảng có trigger vết <bảng>_record_revision_trg (QD-52).

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-yt03_customer_favourite', true); END $$;
DO $$
DECLARE p bigint; k1 bigint; k2 bigint; mon bigint; mon2 bigint; cb bigint; g bigint; o1 bigint; o2 bigint;
        s1 bigint; s2 bigint; l1 bigint; l2 bigint; lc bigint; lp bigint; x bigint; n int; i int;
        ten text; cols text; snap text; snap2 text;
BEGIN
  -- Dữ liệu menu của riêng test, ghi bằng người của quán; rồi bỏ người thao tác vì khách tự ghi yêu thích.
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán yt03', true) RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  INSERT INTO menu_item (name) VALUES ('test-yt03 món một') RETURNING id INTO mon;
  INSERT INTO menu_item (name) VALUES ('test-yt03 món hai') RETURNING id INTO mon2;
  INSERT INTO menu_combo (name, price_vnd) VALUES ('test-yt03 combo', 20000) RETURNING id INTO cb;
  INSERT INTO option_group (name) VALUES ('test-yt03 Nhân') RETURNING id INTO g;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g, 'test-yt03 Chay', 0) RETURNING id INTO o1;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g, 'test-yt03 Thịt', 1000) RETURNING id INTO o2;
  PERFORM set_config('shop.actor_person_id', '', true);

  -- Chụp mọi bảng ngoài ba bảng yêu thích và vết: ghi yêu thích không được đổi đơn, tiền, menu hay tài khoản.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('customer_favourite_set', 'customer_favourite_line', 'customer_favourite_line_option',
                             'record_revision', 'customer_account');

  -- Kịch bản dương bằng vai ghi.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO customer_account (phone, display_name) VALUES ('0987000301', 'test-khách yt03 một') RETURNING id INTO k1;
    INSERT INTO customer_account (phone, display_name) VALUES ('0987000302', 'test-khách yt03 hai') RETURNING id INTO k2;
    -- Dòng tim món + lựa chọn.
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, quantity) VALUES (k1, mon, 2) RETURNING id INTO l1;
    INSERT INTO customer_favourite_line_option (favourite_line_id, menu_option_id) VALUES (l1, o2);
    -- Hai dòng cùng món khác lựa chọn là hai dòng.
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, quantity) VALUES (k1, mon, 1) RETURNING id INTO l2;
    INSERT INTO customer_favourite_line_option (favourite_line_id, menu_option_id) VALUES (l2, o1);
    -- Dòng tim combo + một suất con.
    INSERT INTO customer_favourite_line (customer_account_id, menu_combo_id, quantity) VALUES (k1, cb, 1) RETURNING id INTO lc;
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, parent_line_id, quantity)
    VALUES (k1, mon, lc, 3) RETURNING id INTO lp;
    INSERT INTO customer_favourite_line_option (favourite_line_id, menu_option_id) VALUES (lp, o2);
    -- Hai loại bộ; dòng của bộ dùng chung bảng dòng.
    INSERT INTO customer_favourite_set (customer_account_id, kind, name) VALUES (k1, 'rieng', 'Bữa sáng của mình') RETURNING id INTO s1;
    INSERT INTO customer_favourite_set (customer_account_id, kind, name) VALUES (k1, 'da_luu', 'Cuối tuần') RETURNING id INTO s2;
    INSERT INTO customer_favourite_line (customer_account_id, favourite_set_id, menu_item_id, quantity) VALUES (k1, s1, mon2, 1);
    -- Đổi số lượng, đổi tên bộ, bỏ tim, xoá bộ bằng vai ghi.
    UPDATE customer_favourite_line SET quantity = 4 WHERE id = l1;
    UPDATE customer_favourite_set SET name = 'Bữa sáng nhanh' WHERE id = s1;
    UPDATE customer_favourite_line SET removed_at = now() WHERE id = l2;
    UPDATE customer_favourite_set SET removed_at = now() WHERE id = s2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'YT-03: vai shop_app KHÔNG ghi được dữ liệu yêu thích: %', SQLERRM;
  END;
  SELECT count(*) INTO n FROM customer_favourite_line WHERE customer_account_id = k1;
  IF n <> 5 THEN RAISE EXCEPTION 'YT-03: đọc lại % dòng thay vì 5 (bỏ tim không được xoá dòng)', n; END IF;
  RAISE NOTICE 'YT-03 dương: tim món + lựa chọn, cùng món khác lựa chọn, combo + suất, hai loại bộ, đổi số lượng, gỡ';

  -- Lược đồ không cất giá, tên món hay ảnh.
  SELECT string_agg(table_name || '.' || column_name, ',' ORDER BY table_name::text COLLATE "C", column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns
  WHERE table_schema = 'shop' AND table_name IN ('customer_favourite_set', 'customer_favourite_line', 'customer_favourite_line_option');
  IF cols IS DISTINCT FROM
     'customer_favourite_line.created_at,customer_favourite_line.customer_account_id,customer_favourite_line.favourite_set_id,'
     'customer_favourite_line.id,customer_favourite_line.menu_combo_id,customer_favourite_line.menu_item_id,'
     'customer_favourite_line.parent_line_id,customer_favourite_line.quantity,customer_favourite_line.removed_at,'
     'customer_favourite_line_option.created_at,customer_favourite_line_option.favourite_line_id,customer_favourite_line_option.id,'
     'customer_favourite_line_option.menu_option_id,'
     'customer_favourite_set.created_at,customer_favourite_set.customer_account_id,customer_favourite_set.id,'
     'customer_favourite_set.kind,customer_favourite_set.name,customer_favourite_set.removed_at' THEN
    RAISE EXCEPTION 'YT-03: cột của ba bảng yêu thích lệch ADR-145 (không giá, không tên món, không ảnh): %', cols;
  END IF;
  RAISE NOTICE 'YT-03 đọc lược đồ: %', cols;

  -- Ca âm, mỗi ca kiểm lớp lỗi và tên ràng buộc. Chạy bằng vai ghi.
  SET LOCAL ROLE shop_app;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, menu_combo_id, quantity) VALUES (k1, mon, cb, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng vừa món vừa combo';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_item_xor_combo_check' THEN RAISE EXCEPTION 'YT-03: vừa món vừa combo bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, quantity) VALUES (k1, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng không món không combo';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_item_xor_combo_check' THEN RAISE EXCEPTION 'YT-03: dòng rỗng bị từ chối bằng %', ten; END IF;
  END;
  FOREACH i IN ARRAY ARRAY[0, 100] LOOP
    BEGIN
      INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, quantity) VALUES (k1, mon, i);
      RAISE EXCEPTION 'YT-03: database KHÔNG từ chối số lượng %', i;
    EXCEPTION WHEN check_violation THEN
      GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
      IF ten IS DISTINCT FROM 'customer_favourite_line_quantity_check' THEN RAISE EXCEPTION 'YT-03: số lượng % bị từ chối bằng %', i, ten; END IF;
    END;
  END LOOP;
  BEGIN
    INSERT INTO customer_favourite_line_option (favourite_line_id, menu_option_id) VALUES (lc, o1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối lựa chọn gắn thẳng vào dòng combo';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_option_item_line_check' THEN RAISE EXCEPTION 'YT-03: lựa chọn trên dòng combo bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO customer_favourite_line_option (favourite_line_id, menu_option_id) VALUES (l1, o2);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối cùng lựa chọn hai lần trên một dòng';
  EXCEPTION WHEN unique_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_option_key' THEN RAISE EXCEPTION 'YT-03: lựa chọn trùng bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, menu_combo_id, parent_line_id, quantity) VALUES (k1, cb, lc, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng con là combo';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_shape_check' THEN RAISE EXCEPTION 'YT-03: dòng con combo bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, parent_line_id, quantity) VALUES (k1, mon, l1, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng con có cha là dòng món';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_shape_check' THEN RAISE EXCEPTION 'YT-03: cha là dòng món bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, favourite_set_id, menu_item_id, parent_line_id, quantity)
    VALUES (k1, s1, mon, lc, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng con khác bộ với cha';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_shape_check' THEN RAISE EXCEPTION 'YT-03: dòng con khác bộ bị từ chối bằng %', ten; END IF;
  END;
  -- Khách hai không trỏ được vào bộ hay dòng cha của khách một.
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, favourite_set_id, menu_item_id, quantity) VALUES (k2, s1, mon, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng của khách hai trong bộ của khách một';
  EXCEPTION WHEN foreign_key_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_set_fkey' THEN RAISE EXCEPTION 'YT-03: bộ của khách khác bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, parent_line_id, quantity) VALUES (k2, mon, lc, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng con của khách hai dưới combo của khách một';
  EXCEPTION WHEN foreign_key_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_parent_fkey' THEN RAISE EXCEPTION 'YT-03: cha của khách khác bị từ chối bằng %', ten; END IF;
  END;
  -- Bộ: loại và tên.
  BEGIN
    INSERT INTO customer_favourite_set (customer_account_id, kind, name) VALUES (k1, 'combo', 'x');
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối loại bộ lạ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_set_kind_check' THEN RAISE EXCEPTION 'YT-03: loại bộ lạ bị từ chối bằng %', ten; END IF;
  END;
  FOREACH ten IN ARRAY ARRAY['   ', repeat('a', 61)] LOOP
    BEGIN
      INSERT INTO customer_favourite_set (customer_account_id, kind, name) VALUES (k1, 'rieng', ten);
      RAISE EXCEPTION 'YT-03: database KHÔNG từ chối tên bộ dài % ký tự', char_length(ten);
    EXCEPTION WHEN check_violation THEN
      GET STACKED DIAGNOSTICS cols = CONSTRAINT_NAME;
      IF cols IS DISTINCT FROM 'customer_favourite_set_name_check' THEN RAISE EXCEPTION 'YT-03: tên bộ sai bị từ chối bằng %', cols; END IF;
    END;
  END LOOP;
  -- Gỡ một lần: không bỏ gỡ, không đổi mốc gỡ.
  BEGIN
    UPDATE customer_favourite_line SET removed_at = NULL WHERE id = l2;
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối bỏ mốc gỡ của dòng';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_removed_once_check' THEN RAISE EXCEPTION 'YT-03: bỏ gỡ dòng bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    UPDATE customer_favourite_set SET removed_at = now() + interval '1 hour' WHERE id = s2;
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối đổi mốc gỡ của bộ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_set_removed_once_check' THEN RAISE EXCEPTION 'YT-03: đổi gỡ bộ bị từ chối bằng %', ten; END IF;
  END;
  -- Quyền: không xoá, không đổi món của dòng, không sửa lựa chọn.
  BEGIN
    DELETE FROM customer_favourite_line WHERE id = l2;
    RAISE EXCEPTION 'YT-03: vai shop_app xoá cứng được dòng yêu thích';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    DELETE FROM customer_favourite_set WHERE id = s2;
    RAISE EXCEPTION 'YT-03: vai shop_app xoá cứng được bộ';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    UPDATE customer_favourite_line SET menu_item_id = mon2 WHERE id = l1;
    RAISE EXCEPTION 'YT-03: vai shop_app đổi được món của dòng yêu thích';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    UPDATE customer_favourite_line_option SET menu_option_id = o1 WHERE favourite_line_id = l1;
    RAISE EXCEPTION 'YT-03: vai shop_app sửa được lựa chọn của dòng';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  RAISE NOTICE 'YT-03 âm: hình dòng, số lượng, lựa chọn, dòng con, khách khác, loại và tên bộ, gỡ một lần, quyền';

  -- Giới hạn: 50 dòng tim gốc chưa gỡ (k1 đang có l1 và lc), 20 dòng gốc mỗi bộ, 20 bộ chưa gỡ.
  FOR i IN 1..48 LOOP
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, quantity) VALUES (k1, mon2, 1);
  END LOOP;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, quantity) VALUES (k1, mon2, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng tim thứ 51';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_limit_check' THEN RAISE EXCEPTION 'YT-03: dòng tim thứ 51 bị từ chối bằng %', ten; END IF;
  END;
  -- Dòng con không tính vào giới hạn; dòng đã gỡ không tính.
  INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, parent_line_id, quantity) VALUES (k1, mon2, lc, 1);
  UPDATE customer_favourite_line SET removed_at = now() WHERE id = l1;
  INSERT INTO customer_favourite_line (customer_account_id, menu_item_id, quantity) VALUES (k1, mon2, 1);
  FOR i IN 1..19 LOOP
    INSERT INTO customer_favourite_line (customer_account_id, favourite_set_id, menu_item_id, quantity) VALUES (k1, s1, mon2, 1);
  END LOOP;
  BEGIN
    INSERT INTO customer_favourite_line (customer_account_id, favourite_set_id, menu_item_id, quantity) VALUES (k1, s1, mon2, 1);
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối dòng thứ 21 của một bộ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_line_limit_check' THEN RAISE EXCEPTION 'YT-03: dòng thứ 21 của bộ bị từ chối bằng %', ten; END IF;
  END;
  FOR i IN 1..19 LOOP
    INSERT INTO customer_favourite_set (customer_account_id, kind, name) VALUES (k1, 'da_luu', 'bộ ' || i);
  END LOOP;
  BEGIN
    INSERT INTO customer_favourite_set (customer_account_id, kind, name) VALUES (k1, 'rieng', 'bộ thừa');
    RAISE EXCEPTION 'YT-03: database KHÔNG từ chối bộ thứ 21';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'customer_favourite_set_limit_check' THEN RAISE EXCEPTION 'YT-03: bộ thứ 21 bị từ chối bằng %', ten; END IF;
  END;
  -- Khách hai có giới hạn riêng.
  INSERT INTO customer_favourite_set (customer_account_id, kind, name) VALUES (k2, 'rieng', 'bộ của khách hai');
  RESET ROLE;
  RAISE NOTICE 'YT-03 giới hạn: 50 dòng tim, 20 dòng mỗi bộ, 20 bộ; dòng con và dòng đã gỡ không tính; mỗi khách riêng';

  -- Vết và không đổi bảng khác.
  -- Khách tự sửa: vết có người sửa rỗng như các bảng khách khác (ADR-131 sửa đổi 2026-10-28).
  SELECT count(*) INTO n FROM record_revision
  WHERE person_id IS NULL AND target_table_code IN ('customer_favourite_set', 'customer_favourite_line')
    AND target_row IN (l1, l2, s1, s2) AND reason = 'test-yt03_customer_favourite';
  IF n < 4 THEN RAISE EXCEPTION 'YT-03: sửa dòng / bộ không để lại vết (% dòng vết)', n; END IF;
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('customer_favourite_set', 'customer_favourite_line', 'customer_favourite_line_option',
                             'record_revision', 'customer_account');
  IF snap2 IS DISTINCT FROM snap THEN RAISE EXCEPTION 'YT-03: ghi yêu thích đã đổi bảng khác ngoài ba bảng của nó'; END IF;
  RAISE NOTICE 'YT-03: có vết; không bảng nào khác đổi';
END $$;
