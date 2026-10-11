-- I-027 (tầng 1 · tầng 3) và YC-30: một ô "có đi làm" thuộc ĐÚNG MỘT người của quán và ĐÚNG MỘT
-- ngày, mang tên người đã tick và lúc tick; một người một ngày không có hai ô còn hiệu lực; ô tick
-- nhầm được HUỶ (lời chủ quán đóng U-070): ô ở lại, mang ai huỷ · lúc huỷ · ghi chú, không bị xoá
-- và không đổi được người hay ngày; lược đồ không cất giờ tới, ngưỡng đi muộn hay một khoản trừ. Vế "người tick là chủ quán" là tầng 3 — database KHÔNG xét, test nói
-- thẳng. Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-027.
-- Lát: 13-luoc-do-cham-cong.md. Thiết kế: docs/decisions.md ADR-072.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i027_attendance_one_box_per_worker_day', true); END $$;
DO $$
DECLARE chu bigint; a bigint; b bigint; o1 bigint; o2 bigint; n bigint; cols text; r record;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người tráng bánh') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-người gấp bánh') RETURNING id INTO b;

  -- Kịch bản dương: chủ quán tick cho hai người ngày 2026-09-21 và cho một trong hai người ngày
  -- 2026-09-22. Người tick lấy từ người thao tác của giao dịch, không ai gõ tay.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (a, '2026-09-21') RETURNING id INTO o1;
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (b, '2026-09-21');
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (a, '2026-09-22');
  FOR r IN
    SELECT w.display_name AS nguoi, d.work_date, t.display_name AS nguoi_tick,
           d.created_at IS NOT NULL AS co_luc_tick
    FROM attendance_day d JOIN person w ON w.id = d.worker_person_id
    JOIN person t ON t.id = d.person_id ORDER BY d.work_date, d.id
  LOOP
    RAISE NOTICE 'YC-30 ô có đi làm — %, ngày %: % tick, có lúc tick: %',
      r.nguoi, r.work_date, r.nguoi_tick, r.co_luc_tick;
  END LOOP;
  IF (SELECT COUNT(*) FROM attendance_day) <> 3
     OR EXISTS (SELECT 1 FROM attendance_day WHERE person_id <> chu OR created_at IS NULL)
     OR (SELECT COUNT(*) FROM attendance_day WHERE worker_person_id = a) <> 2
     OR EXISTS (SELECT 1 FROM attendance_day WHERE worker_person_id = b AND work_date = '2026-09-22') THEN
    RAISE EXCEPTION 'I-027: ba ô không đọc lại được đúng người · ngày · người tick';
  END IF;
  RAISE NOTICE 'I-027 đọc lại — test-người tráng bánh có đi làm % ngày, test-người gấp bánh % ngày',
    (SELECT COUNT(*) FROM attendance_day WHERE worker_person_id = a),
    (SELECT COUNT(*) FROM attendance_day WHERE worker_person_id = b);

  -- Ngày của ô và lúc tick là hai thứ đọc riêng: mệnh đề không buộc chúng trùng nhau, nên một ô
  -- cho ngày đã qua được nhận (lời chủ quán không nói cấm hay cho — lược đồ không chọn hộ).
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (b, '2026-09-01');
  RAISE NOTICE 'I-027 ngày của ô khác ngày tick — nhận: ô ngày 2026-09-01, có lúc tick riêng: %',
    (SELECT created_at IS NOT NULL FROM attendance_day WHERE worker_person_id = b AND work_date = '2026-09-01');

  -- Tầng 1: không người · người lạ · không ngày · không người tick · người tick lạ ⇒ từ chối.
  BEGIN
    INSERT INTO attendance_day (work_date) VALUES ('2026-09-23');
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối một ô không gắn người nào';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (ô không gắn người nào): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO attendance_day (worker_person_id, work_date) VALUES (999999999, '2026-09-23');
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối một ô của người không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (người không phải người của quán): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO attendance_day (worker_person_id) VALUES (a);
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối một ô không có ngày';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (ô không có ngày): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO attendance_day (worker_person_id, work_date) VALUES (a, '2026-09-23');
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối một ô không có người tick';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (ô không có người tick): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO attendance_day (worker_person_id, work_date, person_id) VALUES (a, '2026-09-23', 999999999);
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối người tick không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (người tick không phải người của quán): %', SQLERRM;
  END;

  -- Tầng 1: một người, một ngày, nhiều nhất một ô.
  BEGIN
    INSERT INTO attendance_day (worker_person_id, work_date) VALUES (a, '2026-09-21');
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối ô thứ hai cho cùng một người cùng một ngày';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (ô thứ hai cùng người, cùng ngày): %', SQLERRM;
  END;

  -- Tầng 3, nói thẳng: database KHÔNG xét người tick có phải chủ quán không — cửa ghi của pha sau
  -- xét, và tập đối chiếu "ô mà người tick không phải chủ quán" (P2A-07) bắt. Ô dưới đây được nhận.
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (a, '2026-09-23');
  RAISE NOTICE 'I-027 tầng 3 — ô do người KHÔNG phải chủ quán tick: database nhận (% ô như thế); cửa ghi và phép đối chiếu giữ vế này',
    (SELECT COUNT(*) FROM attendance_day d JOIN person t ON t.id = d.person_id WHERE NOT t.is_owner);
  PERFORM set_config('shop.actor_person_id', chu::text, true);

  -- Huỷ một ô tick nhầm (lời đóng U-070: nút huỷ, có phần ghi chú để sau kiểm lại). Vai ghi của hệ
  -- thống tick được và huỷ được; ô đã huỷ Ở LẠI và đọc ra ai huỷ · lúc huỷ · ghi chú.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO attendance_day (worker_person_id, work_date) VALUES (b, '2026-09-23') RETURNING id INTO o2;
    UPDATE attendance_day SET cancelled_at = now(), cancelled_by_person_id = chu,
                              cancel_note = 'test-tick nhầm người, hôm ấy nghỉ' WHERE id = o2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-027: vai shop_app KHÔNG tick hoặc KHÔNG huỷ được một ô: %', SQLERRM;
  END;
  SELECT w.display_name AS nguoi, d.work_date, c.display_name AS nguoi_huy, d.cancel_note,
         d.cancelled_at IS NOT NULL AS co_luc_huy
  INTO r FROM attendance_day d JOIN person w ON w.id = d.worker_person_id
  JOIN person c ON c.id = d.cancelled_by_person_id WHERE d.id = o2;
  IF r.nguoi_huy IS DISTINCT FROM 'test-chủ quán' OR NOT r.co_luc_huy
     OR r.cancel_note IS DISTINCT FROM 'test-tick nhầm người, hôm ấy nghỉ' THEN
    RAISE EXCEPTION 'I-027: ô đã huỷ không đọc lại được ai huỷ · lúc huỷ · ghi chú';
  END IF;
  RAISE NOTICE 'YC-30 ô đã huỷ — %, ngày %: % huỷ, có lúc huỷ: %, ghi chú "%"; ô vẫn còn để kiểm lại',
    r.nguoi, r.work_date, r.nguoi_huy, r.co_luc_huy, r.cancel_note;
  -- Ô đã huỷ không tính là có đi làm, và không chặn lần tick lại cho đúng người · ngày ấy.
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (b, '2026-09-23');
  RAISE NOTICE 'I-027 tick lại sau khi huỷ — nhận: test-người gấp bánh ngày 2026-09-23 có % ô còn hiệu lực, % ô đã huỷ',
    (SELECT COUNT(*) FROM attendance_day WHERE worker_person_id = b AND work_date = '2026-09-23' AND cancelled_at IS NULL),
    (SELECT COUNT(*) FROM attendance_day WHERE worker_person_id = b AND work_date = '2026-09-23' AND cancelled_at IS NOT NULL);
  BEGIN
    INSERT INTO attendance_day (worker_person_id, work_date) VALUES (b, '2026-09-23');
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối ô còn hiệu lực thứ hai sau lần tick lại';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (ô còn hiệu lực thứ hai, sau khi đã tick lại): %', SQLERRM;
  END;
  -- Một lần huỷ thiếu người huỷ · ghi chú trắng · ghi chú trên ô chưa huỷ · huỷ trước lúc tick ⇒ từ chối.
  BEGIN
    UPDATE attendance_day SET cancelled_at = now() WHERE id = o1;
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối một lần huỷ không có người huỷ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (huỷ mà không có người huỷ): %', SQLERRM;
  END;
  BEGIN
    UPDATE attendance_day SET cancelled_at = now(), cancelled_by_person_id = 999999999 WHERE id = o1;
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối người huỷ không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (người huỷ không phải người của quán): %', SQLERRM;
  END;
  BEGIN
    UPDATE attendance_day SET cancelled_at = now(), cancelled_by_person_id = chu, cancel_note = '   ' WHERE id = o1;
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối ghi chú huỷ chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (ghi chú huỷ chỉ có khoảng trắng): %', SQLERRM;
  END;
  BEGIN
    UPDATE attendance_day SET cancel_note = 'test-ghi chú không có lần huỷ' WHERE id = o1;
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối ghi chú huỷ trên một ô chưa huỷ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (ghi chú huỷ trên ô chưa huỷ): %', SQLERRM;
  END;
  BEGIN
    UPDATE attendance_day SET cancelled_at = created_at - interval '1 minute', cancelled_by_person_id = chu WHERE id = o1;
    RAISE EXCEPTION 'I-027: database KHÔNG từ chối một lần huỷ trước lúc tick';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-027 bị từ chối (huỷ trước lúc tick): %', SQLERRM;
  END;
  -- Nói thẳng hai chỗ database KHÔNG giữ: ghi chú để trống vẫn huỷ được (lời chủ quán không nói
  -- bắt buộc — U-071), và người huỷ không bị xét có phải chủ quán không (tầng 3, như người tick).
  UPDATE attendance_day SET cancelled_at = now(), cancelled_by_person_id = a
  WHERE worker_person_id = a AND work_date = '2026-09-23';
  RAISE NOTICE 'I-027 tầng 3 · U-071 — huỷ KHÔNG ghi chú, do người KHÔNG phải chủ quán: database nhận (% ô như thế)',
    (SELECT COUNT(*) FROM attendance_day d JOIN person c ON c.id = d.cancelled_by_person_id
     WHERE d.cancel_note IS NULL AND NOT c.is_owner);

  -- Vai ghi KHÔNG đổi được người hay ngày của một ô, KHÔNG xoá được ô (QD-50): huỷ là đường duy nhất.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE attendance_day SET work_date = '2026-09-24' WHERE id = o1;
    RAISE EXCEPTION 'I-027: vai shop_app đổi được ngày của một ô đã tick';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-027 ô đã tick không đổi được người hay ngày (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM attendance_day WHERE id = o2;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một ô chấm công';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 ô không xoá được, kể cả ô đã huỷ (shop_app): %', SQLERRM;
  END;

  -- Vế "không ô nào sinh khoản trừ" và "không giờ tới, không ngưỡng đi muộn" (tầng 3, kiểm bằng
  -- ĐỌC LƯỢC ĐỒ): lát có đúng một bảng, và danh sách cột của nó là đúng danh sách dưới đây. Thêm
  -- một cột — giờ tới, giờ về, buổi, đi muộn, một khoản trừ — là đổi mệnh đề I-027 trước, rồi mới
  -- đổi dòng này.
  SELECT string_agg(table_name::text, ',' ORDER BY table_name::text COLLATE "C") INTO cols
  FROM information_schema.tables WHERE table_schema = 'shop' AND table_name LIKE 'attendance%';
  IF cols IS DISTINCT FROM 'attendance_day' THEN
    RAISE EXCEPTION 'I-027: bảng của lát chấm công khác danh sách đã duyệt: %', cols;
  END IF;
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'attendance_day';
  IF cols IS DISTINCT FROM 'cancel_note,cancelled_at,cancelled_by_person_id,created_at,id,person_id,work_date,worker_person_id' THEN
    RAISE EXCEPTION 'I-027: cột của attendance_day khác danh sách đã duyệt: %', cols;
  END IF;
  RAISE NOTICE 'I-027 đọc lược đồ — attendance_day: % — không giờ tới, không buổi, không ngưỡng đi muộn, không khoản trừ', cols;

  -- Không đường nào đi từ một ô tới thứ khác: không khoá ngoại nào ngoài ba khoá trỏ về người,
  -- không bảng nào trỏ vào ô; không hàm nào của schema nhắc tới ô; không trigger nào ngoài trigger vết.
  SELECT COUNT(*) INTO n FROM pg_constraint c
  JOIN pg_class x ON x.oid = c.conrelid JOIN pg_class y ON y.oid = c.confrelid
  JOIN pg_namespace ns ON ns.oid = c.connamespace
  WHERE ns.nspname = 'shop' AND c.contype = 'f'
    AND (   (y.relname LIKE 'attendance%')
         OR (x.relname LIKE 'attendance%' AND y.relname <> 'person'));
  IF n <> 0 THEN RAISE EXCEPTION 'I-027: % khoá ngoại nối ô chấm công với bảng ngoài người', n; END IF;
  SELECT COUNT(*) INTO n FROM pg_proc f JOIN pg_namespace ns ON ns.oid = f.pronamespace
  WHERE ns.nspname = 'shop' AND f.prosrc ILIKE '%attendance%';
  IF n <> 0 THEN RAISE EXCEPTION 'I-027: % hàm của schema nhắc tới ô chấm công — một đường đi từ ô tới thứ khác', n; END IF;
  SELECT COUNT(*) INTO n FROM pg_trigger g JOIN pg_class c ON c.oid = g.tgrelid
  JOIN pg_namespace ns ON ns.oid = c.relnamespace JOIN pg_proc f ON f.oid = g.tgfoid
  WHERE ns.nspname = 'shop' AND c.relname LIKE 'attendance%' AND NOT g.tgisinternal
    AND f.proname <> 'record_revision_capture';
  IF n <> 0 THEN RAISE EXCEPTION 'I-027: % trigger ngoài trigger vết trên ô chấm công', n; END IF;
  RAISE NOTICE 'I-027 đọc lược đồ — 0 khoá ngoại ngoài ba khoá về người, 0 hàm nhắc tới ô, 0 trigger ngoài trigger vết ⇒ không đường nào tới một khoản trừ';
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
