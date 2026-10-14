-- I-031 (tầng 1 · tầng 3) và YC-36: mỗi HƯỚNG DẪN gắn đúng một việc giao, là chữ, ảnh hoặc video — ảnh và
-- video là CHỖ TRỎ tới tệp (khoá tệp), không phải tệp; mỗi GHI NHẬN ĐÀO TẠO về đúng một người của quán,
-- mang người ghi và lúc ghi, có nhận xét, đánh giá đạt · chưa, hoặc cả hai, không rỗng cả hai; mọi ghi
-- nhận ở lại theo lúc ghi; sửa có vết (I-018); "xoá" là ẨN có người và lúc. Vế "người ghi là chủ quán
-- hoặc POS" là tầng 3 — database KHÔNG xét, test nói thẳng (docs/decisions.md ADR-105 điểm 1).
-- Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-031. Chỗ giữ tệp: ADR-107.
-- Lát: 17-luoc-do-dao-tao.md. Viết trước khi có lược đồ (P2A-12, Claude Code): đỏ cho tới khi lát dựng.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i031_task_guide_and_training_record', true); END $$;
DO $$
DECLARE chu bigint; pos bigint; a bigint; b bigint; v1 bigint; v2 bigint; g1 bigint; g2 bigint; t1 bigint; t2 bigint;
        r record; snap text; snap2 text; k text;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO pos;
  INSERT INTO person (display_name) VALUES ('test-người gấp bánh') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-người tráng bánh') RETURNING id INTO b;

  -- Chụp số dòng mọi bảng khác: hướng dẫn và đào tạo không được làm đổi bảng nào của bán hàng hay tiền.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('assigned_task', 'assigned_task_guide', 'training_record', 'record_revision', 'person');

  PERFORM set_config('shop.actor_person_id', chu::text, true);
  INSERT INTO assigned_task (content, assignee_person_id) VALUES ('test-gấp bánh cuốn', a) RETURNING id INTO v1;
  INSERT INTO assigned_task (content, assignee_person_id) VALUES ('test-rửa nồi hấp', b) RETURNING id INTO v2;

  -- ===================== HƯỚNG DẪN =====================
  -- Kịch bản dương: chủ quán gắn một hướng dẫn chữ và một ảnh vào việc v1 ⇒ đọc lại được từ v1, không từ v2.
  -- Người gắn lấy từ người thao tác của giao dịch, không ai gõ tay. Chạy bằng vai ghi của hệ thống.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body)
    VALUES (v1, 'text', 'test-gấp ba nếp, mép dưới') RETURNING id INTO g1;
    INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, file_code)
    VALUES (v1, 'image', 'huong-dan/2026/10/7f3c9a.jpg') RETURNING id INTO g2;
    INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, file_code)
    VALUES (v1, 'video', 'huong-dan/2026/10/b81e04.mp4');
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-031: vai shop_app KHÔNG gắn được một hướng dẫn: %', SQLERRM;
  END;
  SELECT string_agg(g.guide_kind_code || ':' || coalesce(g.body, g.file_code), ' | ' ORDER BY g.id) AS ds,
         bool_and(p.display_name = 'test-chủ quán') AS dung_nguoi, bool_and(g.created_at IS NOT NULL) AS co_luc
  INTO r FROM assigned_task_guide g JOIN person p ON p.id = g.person_id WHERE g.assigned_task_id = v1;
  IF r.ds IS DISTINCT FROM 'text:test-gấp ba nếp, mép dưới | image:huong-dan/2026/10/7f3c9a.jpg | video:huong-dan/2026/10/b81e04.mp4'
     OR NOT r.dung_nguoi OR NOT r.co_luc
     OR EXISTS (SELECT 1 FROM assigned_task_guide WHERE assigned_task_id = v2) THEN
    RAISE EXCEPTION 'I-031: hướng dẫn không đọc lại được đúng từ việc của nó, với người gắn và lúc gắn';
  END IF;
  RAISE NOTICE 'YC-36 hướng dẫn của việc "test-gấp bánh cuốn" — %; người gắn test-chủ quán; việc khác: 0 hướng dẫn', r.ds;

  -- Tầng 1: hướng dẫn không gắn việc · gắn việc không có thật · loại lạ · không người gắn · người lạ ⇒ từ chối.
  BEGIN
    INSERT INTO assigned_task_guide (guide_kind_code, body) VALUES ('text', 'test-không gắn việc nào');
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối một hướng dẫn không gắn việc giao nào';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (hướng dẫn không gắn việc): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body) VALUES (999999999, 'text', 'test-việc lạ');
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối hướng dẫn gắn một việc không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (gắn việc không có thật): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, file_code) VALUES (v1, 'audio', 'huong-dan/a.m4a');
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối một loại hướng dẫn ngoài chữ · ảnh · video';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (loại hướng dẫn lạ): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body) VALUES (v1, 'text', 'test-không ai gắn');
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối một hướng dẫn không có người gắn';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (hướng dẫn không có người gắn): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body, person_id) VALUES (v1, 'text', 'test-người lạ', 999999999);
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối người gắn không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (người gắn không phải người của quán): %', SQLERRM;
  END;

  -- Tầng 1: chữ phải có chữ và không có khoá tệp; ảnh, video phải có khoá tệp và không có chữ.
  FOR r IN SELECT * FROM (VALUES
      ('text',  NULL::text,         NULL::text,                    'hướng dẫn chữ không có chữ'),
      ('text',  '   ',              NULL,                          'hướng dẫn chữ chỉ có khoảng trắng'),
      ('text',  'test-chữ',         'huong-dan/x.jpg',             'hướng dẫn chữ mang thêm khoá tệp'),
      ('image', NULL,               NULL,                          'ảnh không có khoá tệp'),
      ('video', NULL,               NULL,                          'video không có khoá tệp'),
      ('image', 'test-chú thích',   'huong-dan/x.jpg',             'ảnh mang thêm chữ')
    ) AS x(kind, body, file_code, ca) LOOP
    BEGIN
      INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body, file_code) VALUES (v1, r.kind, r.body, r.file_code);
      RAISE EXCEPTION 'I-031: database KHÔNG từ chối %', r.ca;
    EXCEPTION WHEN check_violation THEN
      RAISE NOTICE 'I-031 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- Tầng 1: tệp không được cất trong dữ liệu thay chỗ trỏ (YC-36). Khoá tệp là một tên tương đối ngắn
  -- trong kho tệp (ADR-107): không phải dữ liệu nhúng, không phải đường tuyệt đối, không leo ra ngoài kho.
  FOREACH k IN ARRAY ARRAY[
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk',
      '/etc/passwd',
      'huong-dan/../../bi-mat.jpg',
      'https://example.com/anh.jpg',
      'huong-dan/' || repeat('a', 300) || '.jpg'] LOOP
    BEGIN
      INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, file_code) VALUES (v1, 'image', k);
      RAISE EXCEPTION 'I-031: database KHÔNG từ chối khoá tệp "%"', left(k, 40);
    EXCEPTION WHEN check_violation THEN
      RAISE NOTICE 'I-031 bị từ chối (khoá tệp "%…"): %', left(k, 30), SQLERRM;
    END;
  END LOOP;
  -- Đọc lược đồ: không cột nào của lát cất được tệp (bytea hay large object).
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
             AND table_name IN ('assigned_task_guide', 'training_record') AND data_type IN ('bytea', 'oid')) THEN
    RAISE EXCEPTION 'I-031: lát có cột cất được tệp — ảnh, video phải là chỗ trỏ';
  END IF;
  RAISE NOTICE 'I-031 không cất tệp — cột của hướng dẫn: %',
    (SELECT string_agg(column_name || ' ' || data_type, ', ' ORDER BY ordinal_position) FROM information_schema.columns
     WHERE table_schema = 'shop' AND table_name = 'assigned_task_guide');

  -- ===================== GHI NHẬN ĐÀO TẠO =====================
  -- Kịch bản dương: POS ghi "chưa" kèm nhận xét cho người a; sau đó chủ quán ghi "đạt" ⇒ đọc lại được cả hai,
  -- đúng thứ tự, mỗi cái có người ghi và lúc ghi; ghi nhận mới không làm mất ghi nhận cũ.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', pos::text, true);
    INSERT INTO training_record (trainee_person_id, remark, rating_code)
    VALUES (a, 'test-gấp còn lỏng tay', 'not_yet') RETURNING id INTO t1;
    PERFORM set_config('shop.actor_person_id', chu::text, true);
    INSERT INTO training_record (trainee_person_id, rating_code) VALUES (a, 'pass') RETURNING id INTO t2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-031: vai shop_app KHÔNG ghi được một ghi nhận đào tạo: %', SQLERRM;
  END;
  SELECT string_agg(k2.display_name || ':' || coalesce(t.rating_code, '-') || ':' || coalesce(t.remark, '-'), ' → '
                    ORDER BY t.created_at, t.id) AS ds,
         bool_and(t.created_at IS NOT NULL) AS co_luc, count(*) AS so
  INTO r FROM training_record t JOIN person k2 ON k2.id = t.person_id WHERE t.trainee_person_id = a;
  IF r.ds IS DISTINCT FROM 'test-người đứng quầy:not_yet:test-gấp còn lỏng tay → test-chủ quán:pass:-'
     OR NOT r.co_luc OR r.so <> 2 THEN
    RAISE EXCEPTION 'I-031: ghi nhận đào tạo không đọc lại được đủ, đúng thứ tự, với người ghi và lúc ghi (đọc ra: %)', r.ds;
  END IF;
  RAISE NOTICE 'YC-36 ghi nhận về test-người gấp bánh — % (% ghi nhận, mọi cái có lúc ghi: %)', r.ds, r.so, r.co_luc;

  -- Tầng 1: không về ai · về người lạ · không người ghi · người ghi lạ ⇒ từ chối.
  BEGIN
    INSERT INTO training_record (rating_code) VALUES ('pass');
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối một ghi nhận không về ai';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (ghi nhận không về ai): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO training_record (trainee_person_id, rating_code) VALUES (999999999, 'pass');
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối ghi nhận về một người ngoài tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (ghi nhận về người lạ): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO training_record (trainee_person_id, rating_code) VALUES (a, 'pass');
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối một ghi nhận không có người ghi';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (ghi nhận không có người ghi): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO training_record (trainee_person_id, rating_code, person_id) VALUES (a, 'pass', 999999999);
    RAISE EXCEPTION 'I-031: database KHÔNG từ chối người ghi không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-031 bị từ chối (người ghi không phải người của quán): %', SQLERRM;
  END;

  -- Tầng 1: rỗng cả nhận xét lẫn đánh giá · nhận xét chỉ khoảng trắng · đánh giá ngoài đạt · chưa ⇒ từ chối.
  FOR r IN SELECT * FROM (VALUES
      (NULL::text, NULL::text, 'ghi nhận rỗng cả nhận xét lẫn đánh giá'),
      ('   ',      NULL,       'nhận xét chỉ có khoảng trắng'),
      ('   ',      'pass',     'nhận xét chỉ có khoảng trắng dù có đánh giá'),
      (NULL,       'good',     'đánh giá thứ ba'),
      ('test-ok',  '8',        'đánh giá bằng điểm số')
    ) AS x(remark, rating, ca) LOOP
    BEGIN
      INSERT INTO training_record (trainee_person_id, remark, rating_code) VALUES (a, r.remark, r.rating);
      RAISE EXCEPTION 'I-031: database KHÔNG từ chối %', r.ca;
    EXCEPTION WHEN check_violation THEN
      RAISE NOTICE 'I-031 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- ===================== SỬA CÓ VẾT =====================
  -- Sửa nhận xét, đánh giá và chữ của hướng dẫn, có khai lý do ⇒ vết đọc ra bản trước, bản sau, lý do, người sửa.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'test-ghi rõ chỗ lỏng', true);
    UPDATE training_record SET remark = 'test-gấp còn lỏng tay ở mép' WHERE id = t1;
    PERFORM set_config('shop.revision_reason', 'test-thêm bước', true);
    UPDATE assigned_task_guide SET body = 'test-gấp ba nếp, mép dưới, ép nhẹ' WHERE id = g1;
    PERFORM set_config('shop.revision_reason', 'test-thay ảnh rõ hơn', true);
    UPDATE assigned_task_guide SET file_code = 'huong-dan/2026/10/7f3c9b.jpg' WHERE id = g2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-031: vai shop_app KHÔNG sửa được nhận xét hay hướng dẫn: %', SQLERRM;
  END;
  IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'training_record' AND target_row = t1
                   AND person_id = chu AND reason = 'test-ghi rõ chỗ lỏng'
                   AND before_image ->> 'remark' = 'test-gấp còn lỏng tay'
                   AND after_image ->> 'remark' = 'test-gấp còn lỏng tay ở mép')
     OR NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'assigned_task_guide' AND target_row = g1
                   AND person_id = chu AND reason = 'test-thêm bước'
                   AND before_image ->> 'body' = 'test-gấp ba nếp, mép dưới')
     OR NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'assigned_task_guide' AND target_row = g2
                   AND before_image ->> 'file_code' = 'huong-dan/2026/10/7f3c9a.jpg'
                   AND after_image ->> 'file_code' = 'huong-dan/2026/10/7f3c9b.jpg') THEN
    RAISE EXCEPTION 'I-031: sửa ghi nhận hay hướng dẫn không để lại đủ bản trước · bản sau · lý do · người sửa';
  END IF;
  RAISE NOTICE 'I-031 sửa có vết — % lần sửa ghi nhận, % lần sửa hướng dẫn, người sửa test-chủ quán',
    (SELECT COUNT(*) FROM record_revision WHERE target_table_code = 'training_record' AND target_row = t1),
    (SELECT COUNT(*) FROM record_revision WHERE target_table_code = 'assigned_task_guide' AND target_row IN (g1, g2));
  PERFORM set_config('shop.revision_reason', 'test-i031_task_guide_and_training_record', true);

  -- Về ai, ai ghi, lúc ghi của ghi nhận; việc, loại, ai gắn, lúc gắn của hướng dẫn: vai ghi không đổi được.
  FOR r IN SELECT * FROM (VALUES
      (format('UPDATE training_record SET trainee_person_id = %s WHERE id = %s', b, t1), 'đổi người được ghi nhận'),
      (format('UPDATE training_record SET person_id = %s WHERE id = %s', pos, t2), 'đổi người ghi'),
      (format('UPDATE training_record SET created_at = now() - interval ''1 day'' WHERE id = %s', t1), 'đổi lúc ghi'),
      (format('UPDATE assigned_task_guide SET assigned_task_id = %s WHERE id = %s', v2, g1), 'chuyển hướng dẫn sang việc khác'),
      (format('UPDATE assigned_task_guide SET guide_kind_code = ''video'' WHERE id = %s', g2), 'đổi loại hướng dẫn'),
      (format('UPDATE assigned_task_guide SET person_id = %s WHERE id = %s', pos, g1), 'đổi người gắn'),
      (format('UPDATE assigned_task_guide SET created_at = now() - interval ''1 day'' WHERE id = %s', g1), 'đổi lúc gắn')
    ) AS x(sql, ca) LOOP
    BEGIN
      SET LOCAL ROLE shop_app;
      EXECUTE r.sql;
      RESET ROLE;
      RAISE EXCEPTION 'I-031: vai shop_app %', upper(r.ca);
    EXCEPTION WHEN insufficient_privilege THEN
      RESET ROLE;
      RAISE NOTICE 'I-031 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- ===================== ẨN, KHÔNG XOÁ =====================
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE training_record SET hidden_at = now(), hidden_by_person_id = chu WHERE id = t1;
    UPDATE assigned_task_guide SET hidden_at = now(), hidden_by_person_id = chu WHERE id = g2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-031: vai shop_app KHÔNG ẩn được ghi nhận hay hướng dẫn: %', SQLERRM;
  END;
  SELECT (SELECT h.display_name FROM training_record t JOIN person h ON h.id = t.hidden_by_person_id WHERE t.id = t1) AS an_gn,
         (SELECT h.display_name FROM assigned_task_guide g JOIN person h ON h.id = g.hidden_by_person_id WHERE g.id = g2) AS an_hd,
         (SELECT COUNT(*) FROM training_record WHERE trainee_person_id = a) AS so_gn
  INTO r;
  IF r.an_gn IS DISTINCT FROM 'test-chủ quán' OR r.an_hd IS DISTINCT FROM 'test-chủ quán' OR r.so_gn <> 2 THEN
    RAISE EXCEPTION 'I-031: ghi nhận hay hướng dẫn đã ẩn không đọc lại được kèm ai ẩn';
  END IF;
  RAISE NOTICE 'YC-36 đã ẩn — ghi nhận ẩn bởi %, ảnh hướng dẫn ẩn bởi %; người a vẫn còn % ghi nhận', r.an_gn, r.an_hd, r.so_gn;
  FOR r IN SELECT * FROM (VALUES
      (format('DELETE FROM training_record WHERE id = %s', t1), 'xoá cứng một ghi nhận'),
      (format('DELETE FROM assigned_task_guide WHERE id = %s', g1), 'xoá cứng một hướng dẫn')
    ) AS x(sql, ca) LOOP
    BEGIN
      SET LOCAL ROLE shop_app;
      EXECUTE r.sql;
      RESET ROLE;
      RAISE EXCEPTION 'I-031: vai shop_app %', upper(r.ca);
    EXCEPTION WHEN insufficient_privilege THEN
      RESET ROLE;
      RAISE NOTICE 'I-031 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;
  FOR r IN SELECT * FROM (VALUES
      (format('UPDATE training_record SET hidden_at = now() WHERE id = %s', t2), 'ẩn ghi nhận không có người ẩn', 'check'),
      (format('UPDATE assigned_task_guide SET hidden_at = now() WHERE id = %s', g1), 'ẩn hướng dẫn không có người ẩn', 'check'),
      (format('UPDATE training_record SET hidden_at = now(), hidden_by_person_id = 999999999 WHERE id = %s', t2), 'người ẩn ghi nhận là người lạ', 'fk'),
      (format('UPDATE assigned_task_guide SET hidden_at = now(), hidden_by_person_id = 999999999 WHERE id = %s', g1), 'người ẩn hướng dẫn là người lạ', 'fk')
    ) AS x(sql, ca, loai) LOOP
    BEGIN
      EXECUTE r.sql;
      RAISE EXCEPTION 'I-031: database KHÔNG từ chối %', r.ca;
    EXCEPTION
      WHEN check_violation THEN
        IF r.loai <> 'check' THEN RAISE; END IF;
        RAISE NOTICE 'I-031 bị từ chối (%): %', r.ca, SQLERRM;
      WHEN foreign_key_violation THEN
        IF r.loai <> 'fk' THEN RAISE; END IF;
        RAISE NOTICE 'I-031 bị từ chối (%): %', r.ca, SQLERRM;
    END;
  END LOOP;

  -- Tầng 3, nói thẳng: database KHÔNG xét người ghi hay người gắn có phải chủ quán hoặc POS không —
  -- cửa ghi của backend xét (ADR-105 điểm 1), tập đối chiếu của I-031 bắt. Hai dòng dưới được nhận.
  PERFORM set_config('shop.actor_person_id', b::text, true);
  INSERT INTO training_record (trainee_person_id, rating_code) VALUES (a, 'pass');
  INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body) VALUES (v2, 'text', 'test-người làm tự gắn');
  RAISE NOTICE 'I-031 tầng 3 — ghi nhận và hướng dẫn do người KHÔNG phải chủ quán, không đứng quầy: database nhận; cửa ghi và phép đối chiếu giữ vế này';

  -- Không bảng nào ngoài lát này đổi số dòng.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('assigned_task', 'assigned_task_guide', 'training_record', 'record_revision', 'person');
  IF snap IS DISTINCT FROM snap2 THEN
    RAISE EXCEPTION 'I-031: hướng dẫn hay đào tạo làm đổi số dòng của một bảng khác';
  END IF;
  RAISE NOTICE 'I-031 không chạm bảng khác — số dòng mọi bảng ngoài lát giữ nguyên';
END $$;
