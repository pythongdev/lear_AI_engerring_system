-- I-030 (tầng 1 · tầng 3) và YC-35: mỗi việc giao đọc ra được NỘI DUNG · NGƯỜI NHẬN · AI TẠO · LÚC TẠO;
-- mỗi lần đánh dấu xong hay bỏ đánh dấu là một SỰ KIỆN mang người bấm và lúc bấm, không sửa được;
-- "đã xong" đọc ra từ sự kiện mới nhất, việc không cất cờ nào; sửa việc là cập nhật có vết (I-018);
-- "xoá" là ẨN, có người ẩn và lúc ẩn, việc đã ẩn còn đọc lại được. Vế "người làm là chủ quán hoặc
-- POS" là tầng 3 — database KHÔNG xét, test nói thẳng (docs/decisions.md ADR-105 điểm 1).
-- Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-030.
-- Lát: 16-luoc-do-giao-viec.md. Viết trước khi có lược đồ (P2A-11, Claude Code): đỏ cho tới khi lát dựng.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i030_assigned_task_names_assignee_and_marks', true); END $$;
DO $$
DECLARE chu bigint; pos bigint; a bigint; b bigint; v1 bigint; v2 bigint; m1 bigint; r record; snap text; snap2 text;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO pos;
  INSERT INTO person (display_name) VALUES ('test-người tráng bánh') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-người gấp bánh') RETURNING id INTO b;

  -- Chụp số dòng mọi bảng khác: giao việc và đánh dấu không được làm đổi bảng nào của bán hàng hay tiền.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('assigned_task', 'assigned_task_mark', 'record_revision', 'person');

  -- Kịch bản dương: chủ quán giao một việc cho một người; POS đánh dấu xong. Người tạo và người bấm
  -- lấy từ người thao tác của giao dịch, không ai gõ tay. Chạy bằng vai ghi của hệ thống.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', chu::text, true);
    INSERT INTO assigned_task (content, assignee_person_id)
    VALUES ('test-rửa nồi hấp trước 15 giờ', a) RETURNING id INTO v1;
    PERFORM set_config('shop.actor_person_id', pos::text, true);
    INSERT INTO assigned_task_mark (assigned_task_id, mark_code) VALUES (v1, 'done') RETURNING id INTO m1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-030: vai shop_app KHÔNG giao được một việc hoặc KHÔNG đánh dấu được: %', SQLERRM;
  END;
  SELECT t.content, n.display_name AS nguoi_nhan, c.display_name AS nguoi_tao, t.created_at IS NOT NULL AS co_luc_tao,
         k.display_name AS nguoi_bam, m.mark_code, m.created_at IS NOT NULL AS co_luc_bam
  INTO r FROM assigned_task t JOIN person n ON n.id = t.assignee_person_id JOIN person c ON c.id = t.person_id
  JOIN assigned_task_mark m ON m.assigned_task_id = t.id JOIN person k ON k.id = m.person_id WHERE t.id = v1;
  IF r.content IS DISTINCT FROM 'test-rửa nồi hấp trước 15 giờ' OR r.nguoi_nhan IS DISTINCT FROM 'test-người tráng bánh'
     OR r.nguoi_tao IS DISTINCT FROM 'test-chủ quán' OR NOT r.co_luc_tao
     OR r.nguoi_bam IS DISTINCT FROM 'test-người đứng quầy' OR r.mark_code IS DISTINCT FROM 'done' OR NOT r.co_luc_bam THEN
    RAISE EXCEPTION 'I-030: việc giao không đọc lại được đủ nội dung · người nhận · ai tạo · lúc tạo · ai đánh dấu · lúc nào';
  END IF;
  RAISE NOTICE 'YC-35 việc giao — "%" cho %, % tạo (có lúc tạo: %); đánh dấu % bởi % (có lúc: %)',
    r.content, r.nguoi_nhan, r.nguoi_tao, r.co_luc_tao, r.mark_code, r.nguoi_bam, r.co_luc_bam;

  -- Tầng 1: nội dung rỗng · trắng · không người nhận · người nhận lạ · không người tạo · người tạo lạ ⇒ từ chối.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO assigned_task (assignee_person_id) VALUES (a);
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối một việc không có nội dung';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (việc không có nội dung): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO assigned_task (content, assignee_person_id) VALUES ('   ', a);
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối một việc chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (nội dung chỉ có khoảng trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO assigned_task (content) VALUES ('test-việc không ai nhận');
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối một việc không có người nhận';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (việc không có người nhận): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO assigned_task (content, assignee_person_id) VALUES ('test-việc cho người lạ', 999999999);
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối người nhận không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (người nhận không phải người của quán): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO assigned_task (content, assignee_person_id) VALUES ('test-việc không ai tạo', a);
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối một việc không có người tạo';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (việc không có người tạo): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO assigned_task (content, assignee_person_id, person_id) VALUES ('test-người tạo lạ', a, 999999999);
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối người tạo không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (người tạo không phải người của quán): %', SQLERRM;
  END;

  -- Tầng 1: sự kiện đánh dấu không người bấm · người bấm lạ · việc không có thật · mã lạ ⇒ từ chối.
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO assigned_task_mark (assigned_task_id, mark_code) VALUES (v1, 'undone');
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối một lần đánh dấu không có người bấm';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (đánh dấu không có người bấm): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', pos::text, true);
  BEGIN
    INSERT INTO assigned_task_mark (assigned_task_id, mark_code, person_id) VALUES (v1, 'undone', 999999999);
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối người bấm không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (người bấm không phải người của quán): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO assigned_task_mark (assigned_task_id, mark_code) VALUES (999999999, 'done');
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối đánh dấu một việc không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (đánh dấu việc không có thật): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO assigned_task_mark (assigned_task_id, mark_code) VALUES (v1, 'half');
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối một mã đánh dấu ngoài xong · bỏ đánh dấu';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (mã đánh dấu lạ): %', SQLERRM;
  END;

  -- Kịch bản gỡ: đánh dấu xong rồi bỏ đánh dấu ⇒ việc đọc ra "chưa xong" từ sự kiện mới nhất, cả hai
  -- sự kiện còn. Sự kiện không sửa và không xoá được bằng vai ghi.
  INSERT INTO assigned_task_mark (assigned_task_id, mark_code) VALUES (v1, 'undone');
  SELECT m.mark_code INTO r FROM assigned_task_mark m WHERE m.assigned_task_id = v1 ORDER BY m.created_at DESC, m.id DESC LIMIT 1;
  IF r.mark_code IS DISTINCT FROM 'undone' OR (SELECT COUNT(*) FROM assigned_task_mark WHERE assigned_task_id = v1) <> 2 THEN
    RAISE EXCEPTION 'I-030: bỏ đánh dấu không để lại hai sự kiện, hoặc sự kiện mới nhất không phải bỏ đánh dấu';
  END IF;
  RAISE NOTICE 'I-030 gỡ đánh dấu — sự kiện mới nhất: %, số sự kiện còn: %',
    r.mark_code, (SELECT COUNT(*) FROM assigned_task_mark WHERE assigned_task_id = v1);
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE assigned_task_mark SET mark_code = 'done' WHERE id = m1;
    RESET ROLE;
    RAISE EXCEPTION 'I-030: vai shop_app SỬA ĐƯỢC một sự kiện đánh dấu — cờ bị đè';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-030 bị từ chối (sửa một sự kiện đánh dấu): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM assigned_task_mark WHERE id = m1;
    RESET ROLE;
    RAISE EXCEPTION 'I-030: vai shop_app XOÁ ĐƯỢC một sự kiện đánh dấu';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-030 bị từ chối (xoá một sự kiện đánh dấu): %', SQLERRM;
  END;

  -- "Đã xong" không cất ở đâu: bảng việc không có cột trạng thái hay cờ xong (đọc lược đồ).
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'assigned_task'
             AND (column_name = 'status' OR column_name LIKE '%done%' OR column_name LIKE '%complete%' OR column_name LIKE '%mark%')) THEN
    RAISE EXCEPTION 'I-030: việc giao cất một cờ hay trạng thái xong — "đã xong" phải đọc ra từ sự kiện';
  END IF;
  RAISE NOTICE 'I-030 không cờ xong — cột của việc giao: %',
    (SELECT string_agg(column_name::text, ', ' ORDER BY ordinal_position) FROM information_schema.columns
     WHERE table_schema = 'shop' AND table_name = 'assigned_task');

  -- Kịch bản sửa: đổi nội dung và người nhận, có khai lý do ⇒ vết đọc ra bản trước, bản sau, lý do, người sửa.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'test-ghi nhầm người nhận', true);
    UPDATE assigned_task SET assignee_person_id = b WHERE id = v1;
    PERFORM set_config('shop.revision_reason', 'test-thêm giờ cho rõ', true);
    UPDATE assigned_task SET content = 'test-rửa nồi hấp trước 14 giờ' WHERE id = v1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-030: vai shop_app KHÔNG sửa được nội dung hoặc người nhận của một việc: %', SQLERRM;
  END;
  IF (SELECT COUNT(*) FROM record_revision WHERE target_table_code = 'assigned_task' AND target_row = v1
        AND person_id = chu AND reason IN ('test-ghi nhầm người nhận', 'test-thêm giờ cho rõ')) <> 2
     OR NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'assigned_task' AND target_row = v1
        AND before_image ->> 'content' = 'test-rửa nồi hấp trước 15 giờ'
        AND after_image ->> 'content' = 'test-rửa nồi hấp trước 14 giờ') THEN
    RAISE EXCEPTION 'I-030: sửa việc không để lại đủ bản trước · bản sau · lý do · người sửa';
  END IF;
  RAISE NOTICE 'I-030 sửa việc — % lần sửa có vết, người sửa test-chủ quán',
    (SELECT COUNT(*) FROM record_revision WHERE target_table_code = 'assigned_task' AND target_row = v1);
  PERFORM set_config('shop.revision_reason', 'test-i030_assigned_task_names_assignee_and_marks', true);
  -- Người tạo và lúc tạo không đổi được bằng vai ghi.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE assigned_task SET person_id = pos WHERE id = v1;
    RESET ROLE;
    RAISE EXCEPTION 'I-030: vai shop_app ĐỔI ĐƯỢC người tạo của một việc';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-030 bị từ chối (đổi người tạo): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE assigned_task SET created_at = now() - interval '1 day' WHERE id = v1;
    RESET ROLE;
    RAISE EXCEPTION 'I-030: vai shop_app ĐỔI ĐƯỢC lúc tạo của một việc';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-030 bị từ chối (đổi lúc tạo): %', SQLERRM;
  END;

  -- Kịch bản ẩn: "xoá" là ẩn — việc vẫn đọc lại được kèm ai ẩn, lúc ẩn; xoá cứng bị từ chối.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE assigned_task SET hidden_at = now(), hidden_by_person_id = chu WHERE id = v1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-030: vai shop_app KHÔNG ẩn được một việc: %', SQLERRM;
  END;
  SELECT t.content, h.display_name AS nguoi_an, t.hidden_at IS NOT NULL AS co_luc_an,
         (SELECT COUNT(*) FROM assigned_task_mark m WHERE m.assigned_task_id = t.id) AS so_su_kien
  INTO r FROM assigned_task t JOIN person h ON h.id = t.hidden_by_person_id WHERE t.id = v1;
  IF r.nguoi_an IS DISTINCT FROM 'test-chủ quán' OR NOT r.co_luc_an OR r.so_su_kien <> 2 THEN
    RAISE EXCEPTION 'I-030: việc đã ẩn không đọc lại được nội dung · ai ẩn · lúc ẩn · các lần đánh dấu';
  END IF;
  RAISE NOTICE 'YC-35 việc đã ẩn — "%": % ẩn, có lúc ẩn: %, vẫn còn % sự kiện đánh dấu', r.content, r.nguoi_an, r.co_luc_an, r.so_su_kien;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM assigned_task WHERE id = v1;
    RESET ROLE;
    RAISE EXCEPTION 'I-030: vai shop_app XOÁ CỨNG được một việc';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-030 bị từ chối (xoá cứng một việc): %', SQLERRM;
  END;
  INSERT INTO assigned_task (content, assignee_person_id) VALUES ('test-lau bàn', b) RETURNING id INTO v2;
  BEGIN
    UPDATE assigned_task SET hidden_at = now() WHERE id = v2;
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối một lần ẩn không có người ẩn';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (ẩn mà không có người ẩn): %', SQLERRM;
  END;
  BEGIN
    UPDATE assigned_task SET hidden_at = now(), hidden_by_person_id = 999999999 WHERE id = v2;
    RAISE EXCEPTION 'I-030: database KHÔNG từ chối người ẩn không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-030 bị từ chối (người ẩn không phải người của quán): %', SQLERRM;
  END;

  -- Tầng 3, nói thẳng: database KHÔNG xét người tạo hay người bấm có phải chủ quán hoặc POS không —
  -- cửa ghi của backend xét (ADR-105 điểm 1), tập đối chiếu của I-030 bắt. Hai dòng dưới được nhận.
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO assigned_task (content, assignee_person_id) VALUES ('test-việc do người làm tự giao', b);
  INSERT INTO assigned_task_mark (assigned_task_id, mark_code) VALUES (v2, 'done');
  RAISE NOTICE 'I-030 tầng 3 — việc và sự kiện do người KHÔNG phải chủ quán, không đứng quầy: database nhận; cửa ghi và phép đối chiếu giữ vế này';

  -- Không bảng nào ngoài lát này đổi số dòng.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('assigned_task', 'assigned_task_mark', 'record_revision', 'person');
  IF snap IS DISTINCT FROM snap2 THEN
    RAISE EXCEPTION 'I-030: giao việc hay đánh dấu làm đổi số dòng của một bảng khác';
  END IF;
  RAISE NOTICE 'I-030 không chạm bảng khác — số dòng mọi bảng ngoài lát giữ nguyên';
END $$;
