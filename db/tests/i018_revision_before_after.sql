-- I-018 (tầng 1 · tầng 2) và YC-12 · YC-13 · YC-14: một lần sửa có khai lý do để lại bản TRƯỚC,
-- bản SAU, LÝ DO, NGƯỜI SỬA — chụp trong cùng câu lệnh với lần sửa; hai người ghi đè thì bản của
-- người trước dựng lại được; vết thiếu một trong bốn thứ không tồn tại được; vết sống khi bản ghi
-- gốc bị xoá và vai ghi của hệ thống không sửa được nó. Chế độ NGHIÊM từ bước 20 (T-138, ADR-092; F-046
-- đã gỡ): sửa không khai lý do bị từ chối — db/tests/i018_strict_revision.sql. Lát: 06-luoc-do-nguoi-va-vet.md.

-- Vế "mốc tính tiền không dời" của QD-33 (01-quy-uoc-du-lieu.md), đọc từ vết — P2-11 gom.
CREATE FUNCTION pg_temp.moc_bi_doi() RETURNS TABLE (bang text, dong bigint, truoc text, sau text)
LANGUAGE sql AS $f$
  SELECT target_table_code, target_row, before_image ->> 'booked_at', after_image ->> 'booked_at'
  FROM record_revision
  WHERE (before_image ->> 'booked_at') IS DISTINCT FROM (after_image ->> 'booked_at')
$f$;

DO $$
DECLARE b bigint; c bigint; chu bigint; o1 bigint; bl bigint; t9 bigint; mc bigint; n integer;
        r record;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-B đứng quầy') RETURNING id INTO b;
  INSERT INTO person (display_name) VALUES ('test-C đứng quầy') RETURNING id INTO c;
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  PERFORM set_config('shop.actor_person_id', b::text, true);
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text)
  RETURNING id INTO o1;

  -- Chế độ nghiêm: sửa KHÔNG khai lý do ⇒ từ chối, số điện thoại không đổi, không vết nào.
  BEGIN
    UPDATE sales_order SET customer_phone = '0900000009' WHERE id = o1;
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối lần sửa không khai lý do';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-018 chế độ nghiêm — sửa không khai lý do bị từ chối: %', SQLERRM;
  END;
  -- Số điện thoại ban đầu, có lý do: bản trước của lần sửa sau là số này.
  PERFORM set_config('shop.revision_reason', 'test-ghi số khách đọc lần đầu', true);
  UPDATE sales_order SET customer_phone = '0900000009' WHERE id = o1;

  -- B sửa số điện thoại, có lý do; rồi C sửa đè lên — người bấm sau thắng (shop-facts §6.22).
  PERFORM set_config('shop.revision_reason', 'test-khách đọc lại số', true);
  UPDATE sales_order SET customer_phone = '0911111111' WHERE id = o1;
  PERFORM set_config('shop.actor_person_id', c::text, true);
  PERFORM set_config('shop.revision_reason', 'test-ghi đè: khách gọi lại lần hai', true);
  UPDATE sales_order SET customer_phone = '0922222222' WHERE id = o1;
  FOR r IN
    SELECT v.id, v.before_image ->> 'customer_phone' AS truoc, v.after_image ->> 'customer_phone' AS sau,
           v.reason, p.display_name, v.revised_at
    FROM record_revision v JOIN person p ON p.id = v.person_id
    WHERE v.target_table_code = 'sales_order' AND v.target_row = o1 ORDER BY v.id
  LOOP
    RAISE NOTICE 'YC-13 đơn % — trước %, sau %, lý do "%", % sửa lúc %', o1, r.truoc, r.sau, r.reason,
      r.display_name, to_char(r.revised_at, 'HH24:MI:SS.US');
  END LOOP;
  -- Dựng lại bản của người bấm trước (B) từ vết, sau khi C đã đè.
  IF (SELECT before_image ->> 'customer_phone' FROM record_revision
      WHERE target_row = o1 AND person_id = c) IS DISTINCT FROM '0911111111'
     OR (SELECT customer_phone FROM sales_order WHERE id = o1) <> '0922222222' THEN
    RAISE EXCEPTION 'I-018: bản của người bấm trước không dựng lại được sau lần ghi đè';
  END IF;
  RAISE NOTICE 'I-018 ghi đè — bản của B dựng lại từ vết của C: %',
    (SELECT before_image ->> 'customer_phone' FROM record_revision WHERE target_row = o1 AND person_id = c);

  -- Tầng 2: lần sửa và vết của nó là MỘT câu lệnh — cắt giữa chừng không nửa nào sống sót.
  n := (SELECT COUNT(*) FROM record_revision);
  BEGIN
    UPDATE sales_order SET customer_phone = '0933333333' WHERE id = o1;
    RAISE EXCEPTION USING ERRCODE = 'P0003', MESSAGE = 'mất điện ngay sau lần sửa';
  EXCEPTION WHEN SQLSTATE 'P0003' THEN NULL;
  END;
  RAISE NOTICE 'I-018 cắt giữa chừng — số điện thoại %, số vết % (trước khi cắt %)',
    (SELECT customer_phone FROM sales_order WHERE id = o1), (SELECT COUNT(*) FROM record_revision), n;
  IF (SELECT customer_phone FROM sales_order WHERE id = o1) <> '0922222222'
     OR (SELECT COUNT(*) FROM record_revision) <> n THEN
    RAISE EXCEPTION 'I-018: một nửa của lần sửa sống sót';
  END IF;
  -- Khai lý do mà không khai người sửa: lần sửa bị từ chối CÙNG vết của nó.
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    UPDATE sales_order SET customer_phone = '0944444444' WHERE id = o1;
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối lần sửa có lý do mà không có người sửa';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-018 bị từ chối (sửa có lý do, không người sửa): %', SQLERRM;
  END;

  -- Tầng 1 hình dạng vết: thiếu một trong bốn thứ, hay vết không phải của dòng nó nói về.
  BEGIN
    INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, person_id)
    VALUES ('sales_order', o1, jsonb_build_object('id', o1), jsonb_build_object('id', o1, 'x', 2), c);
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối vết không lý do';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-018 bị từ chối (vết không lý do): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason, person_id)
    VALUES ('sales_order', o1, jsonb_build_object('id', o1), jsonb_build_object('id', o1, 'x', 2), '   ', c);
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối lý do trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-018 bị từ chối (lý do chỉ có khoảng trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO record_revision (target_table_code, target_row, after_image, reason, person_id)
    VALUES ('sales_order', o1, jsonb_build_object('id', o1), 'test-x', c);
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối vết thiếu bản trước';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-018 bị từ chối (vết thiếu bản trước): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason, person_id)
    VALUES ('sales_order', o1, '{"id": 999999}', jsonb_build_object('id', o1, 'x', 2), 'test-x', c);
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối bản trước của một dòng khác';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-018 bị từ chối (bản trước không phải của dòng ấy): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason, person_id)
    VALUES ('sales_order', o1, jsonb_build_object('id', o1), jsonb_build_object('id', o1), 'test-x', c);
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối vết không đổi gì';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-018 bị từ chối (bản trước bằng bản sau): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason, person_id)
    VALUES ('Sales Order', o1, jsonb_build_object('id', o1), jsonb_build_object('id', o1, 'x', 2), 'test-x', c);
    RAISE EXCEPTION 'I-018: database KHÔNG từ chối tên bảng không phải mã';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-018 bị từ chối (tên bảng không phải mã): %', SQLERRM;
  END;

  -- Chủ quán đổi giá giữa buổi (§6.17, I-011): vết giữ giá cũ và giá mới — giá tại một mốc đã qua
  -- đọc lại được (03-luoc-do-menu-gia.md §5).
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  PERFORM set_config('shop.revision_reason', 'test-đổi giá giữa buổi', true);
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-giò', 900, false)
  RETURNING id INTO mc;
  UPDATE menu_component SET base_price_vnd = 1000 WHERE id = mc;
  SELECT before_image ->> 'base_price_vnd' AS truoc, after_image ->> 'base_price_vnd' AS sau,
         p.display_name, p.is_owner
  INTO r FROM record_revision v JOIN person p ON p.id = v.person_id
  WHERE v.target_table_code = 'menu_component' AND v.target_row = mc;
  RAISE NOTICE 'I-018 đổi giá — trước %, sau %, % (chủ quán: %)', r.truoc, r.sau, r.display_name, r.is_owner;

  -- Vết sống khi bản ghi gốc mất (YC-12): đổi tên một bàn, rồi xoá bàn ấy bằng vai chủ lược đồ.
  INSERT INTO dining_table (label) VALUES ('test-9') RETURNING id INTO t9;
  UPDATE dining_table SET label = 'test-9b' WHERE id = t9;
  DELETE FROM dining_table WHERE id = t9;
  SELECT before_image ->> 'label' AS truoc, after_image ->> 'label' AS sau INTO r
  FROM record_revision WHERE target_table_code = 'dining_table' AND target_row = t9;
  RAISE NOTICE 'YC-12 bàn % đã xoá — vết vẫn đọc: "%" → "%"', t9, r.truoc, r.sau;
  IF r.truoc IS DISTINCT FROM 'test-9' THEN RAISE EXCEPTION 'YC-12: vết chết theo bản ghi gốc'; END IF;
  -- Vai ghi của hệ thống không sửa, không xoá được vết.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE record_revision SET reason = 'test-sửa vết' WHERE target_row = t9;
    RAISE EXCEPTION 'I-018: vai shop_app sửa được vết';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-018 vết không sửa được (shop_app): %', SQLERRM;
  END;
  -- …và không chèn thẳng được: một vết không đi kèm lần sửa nào là lịch sử bịa (review 2026-09-29).
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason,
                                 person_id)
    VALUES ('bill', 1, '{"id":1,"due_vnd":0}', '{"id":1,"due_vnd":999}', 'test-vết bịa', b);
    RAISE EXCEPTION 'I-018: vai shop_app chèn thẳng được một vết bịa';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-018 vết không chèn thẳng được (shop_app): %', SQLERRM;
  END;
  -- Vết vẫn sinh khi chính vai ghi của hệ thống sửa: trigger ghi bằng quyền chủ lược đồ.
  INSERT INTO dining_table (label) VALUES ('test-10') RETURNING id INTO t9;
  SET LOCAL ROLE shop_app;
  PERFORM set_config('shop.revision_reason', 'test-shop_app đổi tên bàn', true);
  UPDATE dining_table SET label = 'test-10b' WHERE id = t9;
  RESET ROLE;
  SELECT before_image ->> 'label' AS truoc, after_image ->> 'label' AS sau, reason INTO r
  FROM record_revision WHERE target_table_code = 'dining_table' AND target_row = t9;
  IF r.truoc IS DISTINCT FROM 'test-10' THEN
    RAISE EXCEPTION 'I-018: shop_app sửa có khai lý do mà không sinh vết';
  END IF;
  RAISE NOTICE 'I-018 shop_app sửa ⇒ vết qua trigger: "%" → "%", lý do "%"', r.truoc, r.sau, r.reason;

  -- QD-33 vế "mốc tính tiền không dời": rỗng; rồi một lần dời mốc có khai lý do — câu bắt được.
  IF EXISTS (SELECT 1 FROM pg_temp.moc_bi_doi()) THEN
    RAISE EXCEPTION 'QD-33: tập "mốc tính tiền bị dời" không rỗng trước khi cài lỗi';
  END IF;
  PERFORM set_config('shop.actor_person_id', b::text, true);
  PERFORM set_config('shop.revision_reason', 'test-thu tiền và hoàn thành đơn', true);
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd) VALUES (o1, 50000, 50000) RETURNING id INTO bl;
  UPDATE sales_order SET status = 'completed' WHERE id = o1;
  PERFORM set_config('shop.revision_reason', 'test-dời mốc sang hôm qua', true);
  UPDATE bill SET booked_at = booked_at - interval '1 day', sale_date = sale_date - 1 WHERE id = bl;
  FOR r IN SELECT * FROM pg_temp.moc_bi_doi() LOOP
    RAISE NOTICE 'QD-33 đối chiếu biết kêu — % %: mốc % → %', r.bang, r.dong, r.truoc, r.sau;
  END LOOP;
  IF NOT EXISTS (SELECT 1 FROM pg_temp.moc_bi_doi()) THEN
    RAISE EXCEPTION 'QD-33: câu đối chiếu KHÔNG bắt được lần dời mốc tính tiền';
  END IF;
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
