-- I-039 (tầng 1): một người một ngày KHÔNG vừa có ô "có đi làm" còn hiệu lực vừa có báo nghỉ còn hiệu lực; báo nghỉ
-- không đổi ô chấm công nào và không chạm tiền. Một dòng `leave_notice` là một người nghỉ một ngày; người báo LÀ người
-- nghỉ (mặc định người thao tác của giao dịch — không ghi hộ); không báo cho ngày lịch đã qua (giờ Việt Nam); một dòng còn
-- hiệu lực cho một người một ngày; chỉ chủ quán ghi "đã biết"; huỷ là chủ quán, hoặc chính người nghỉ khi hôm nay còn trước
-- ngày nghỉ; dấu "đã biết" và dấu huỷ ghi một lần. Loại báo trước / đột xuất KHÔNG cất (suy khi đọc ở backend).
-- Lời: master_plan/shop-facts.md §8.11 điểm 7. Thiết kế: docs/decisions.md ADR-138. Kịch bản: quality/invariants.md I-039.
-- Viết trước lược đồ (CHAT-30, Claude Code, 2026-11-04): đỏ cho tới khi migration báo nghỉ dựng.
--
-- Tên Claude chốt (ràng buộc / trigger phát lời từ chối với CONSTRAINT = tên dưới, ERRCODE như ghi):
--   leave_notice_person_fkey · leave_notice_acknowledged_by_person_fkey · leave_notice_cancelled_by_person_fkey
--   leave_notice_submission_code_check (check) · leave_notice_person_submission_code_key (unique: person_id, submission_code)
--   leave_notice_acknowledged_pair_check · leave_notice_cancelled_pair_check (check: cả hai hoặc không)
--   leave_notice_one_live_per_person_day_key (unique một phần: person_id, leave_date khi cancelled_at IS NULL)
--   leave_notice_not_past_check · leave_notice_acknowledged_by_owner_check · leave_notice_cancel_allowed_check ·
--   leave_notice_stamps_once_check · leave_notice_attendance_ticked_check (trigger, check_violation)
--   attendance_day_on_leave_check (trigger mới trên attendance_day, check_violation)

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i039_leave_notice', true); END $$;
DO $$
DECLARE chu bigint; a bigint; b bigint; hom_nay date; l1 bigint; l2 bigint; l3 bigint; o1 bigint; n int; r record;
        ten text; cols text; snap text; snap2 text;
BEGIN
  hom_nay := (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date;
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán i039', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người canh i039') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-người tráng i039') RETURNING id INTO b;

  -- Chụp nội dung mọi bảng ngoài báo nghỉ, chấm công và vết: báo nghỉ không được đổi tiền, đơn hay người.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('leave_notice', 'attendance_day', 'record_revision', 'person');

  -- Kịch bản dương bằng vai ghi. Người nghỉ lấy từ người thao tác của giao dịch.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', a::text, true);
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 5, 'test-i039-l1') RETURNING id INTO l1;
    -- Báo cho chính hôm nay (đột xuất) vẫn được nhận.
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay, 'test-i039-l2') RETURNING id INTO l2;
    -- Nghỉ nhiều ngày là nhiều dòng.
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 6, 'test-i039-l3') RETURNING id INTO l3;
    -- Người khác dùng cùng mã gửi được (mã duy nhất theo người).
    PERFORM set_config('shop.actor_person_id', b::text, true);
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 5, 'test-i039-l1');
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-039: vai shop_app KHÔNG báo nghỉ được: %', SQLERRM;
  END;
  SELECT l.person_id, l.leave_date, l.created_at IS NOT NULL AS co_luc, l.acknowledged_at, l.cancelled_at INTO r
  FROM leave_notice l WHERE l.id = l1;
  IF r.person_id IS DISTINCT FROM a OR r.leave_date IS DISTINCT FROM hom_nay + 5 OR NOT r.co_luc
     OR r.acknowledged_at IS NOT NULL OR r.cancelled_at IS NOT NULL THEN
    RAISE EXCEPTION 'I-039: báo nghỉ không đọc lại được người · ngày nghỉ · lúc báo, hay mang sẵn dấu đã biết / huỷ';
  END IF;
  RAISE NOTICE 'I-039 dương: báo trước, báo cho hôm nay, nghỉ hai ngày là hai dòng, người khác dùng cùng mã';

  -- Lược đồ không cất loại nghỉ, lý do, trạng thái hay tiền.
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'leave_notice';
  IF cols IS DISTINCT FROM 'acknowledged_at,acknowledged_by_person_id,cancelled_at,cancelled_by_person_id,created_at,id,leave_date,person_id,submission_code' THEN
    RAISE EXCEPTION 'I-039: cột của leave_notice lệch thiết kế ADR-138 điểm 1: %', cols;
  END IF;
  RAISE NOTICE 'I-039 đọc lược đồ — leave_notice: %', cols;

  -- Tầng 1, ca âm. Mỗi ca kiểm cả lớp lỗi lẫn tên ràng buộc.
  PERFORM set_config('shop.actor_person_id', a::text, true);
  BEGIN
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay - 1, 'test-i039-x1');
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối báo nghỉ cho ngày đã qua';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_not_past_check' THEN RAISE EXCEPTION 'I-039: ngày đã qua bị từ chối bằng % thay vì leave_notice_not_past_check', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (ngày đã qua): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 5, 'test-i039-x2');
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối hai báo nghỉ còn hiệu lực cùng người cùng ngày';
  EXCEPTION WHEN unique_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_one_live_per_person_day_key' THEN RAISE EXCEPTION 'I-039: trùng ngày bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (hai báo nghỉ cùng ngày): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 9, 'test-i039-l1');
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối cùng người dùng lại mã gửi';
  EXCEPTION WHEN unique_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_person_submission_code_key' THEN RAISE EXCEPTION 'I-039: mã gửi trùng bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (cùng người, cùng mã gửi): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 9, '  ');
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối mã gửi trắng';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_submission_code_check' THEN RAISE EXCEPTION 'I-039: mã gửi trắng bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (mã gửi trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO leave_notice (person_id, leave_date, submission_code) VALUES (999999999, hom_nay + 9, 'test-i039-x5');
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối người nghỉ không phải người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-039 bị từ chối (người lạ): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', '', true);
  BEGIN
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 9, 'test-i039-x6');
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối báo nghỉ không có người';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-039 bị từ chối (không có người): %', SQLERRM;
  END;

  -- Đã biết: chỉ chủ quán; cặp dấu đủ đôi; ghi một lần.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', a::text, true);
    UPDATE leave_notice SET acknowledged_at = now(), acknowledged_by_person_id = a WHERE id = l1;
    RESET ROLE;
    RAISE EXCEPTION 'I-039: người không phải chủ quán GHI ĐƯỢC dấu đã biết';
  EXCEPTION WHEN check_violation THEN
    RESET ROLE;
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_acknowledged_by_owner_check' THEN RAISE EXCEPTION 'I-039: đã biết của người thường bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (đã biết không phải chủ quán): %', SQLERRM;
  END;
  BEGIN
    UPDATE leave_notice SET acknowledged_at = now() WHERE id = l1;
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối dấu đã biết thiếu người';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_acknowledged_pair_check' THEN RAISE EXCEPTION 'I-039: dấu đã biết lẻ bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (dấu đã biết lẻ đôi): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', chu::text, true);
    UPDATE leave_notice SET acknowledged_at = now(), acknowledged_by_person_id = chu WHERE id = l1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-039: vai shop_app KHÔNG ghi được dấu đã biết của chủ quán: %', SQLERRM;
  END;
  BEGIN
    UPDATE leave_notice SET acknowledged_at = NULL, acknowledged_by_person_id = NULL WHERE id = l1;
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối xoá trắng dấu đã biết';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_stamps_once_check' THEN RAISE EXCEPTION 'I-039: xoá dấu đã biết bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (xoá trắng dấu đã biết): %', SQLERRM;
  END;
  RAISE NOTICE 'I-039 dương: chủ quán ghi đã biết một lần';

  -- Vai ghi không đổi người, ngày hay mã của một báo nghỉ, không xoá được.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE leave_notice SET leave_date = hom_nay + 7 WHERE id = l1;
    RESET ROLE;
    RAISE EXCEPTION 'I-039: vai shop_app ĐỔI ĐƯỢC ngày của một báo nghỉ';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-039 bị từ chối (đổi ngày nghỉ): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM leave_notice WHERE id = l1;
    RESET ROLE;
    RAISE EXCEPTION 'I-039: vai shop_app XOÁ ĐƯỢC một báo nghỉ';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-039 bị từ chối (xoá báo nghỉ): %', SQLERRM;
  END;
  BEGIN
    UPDATE leave_notice SET person_id = b WHERE id = l3;
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối đổi người của một báo nghỉ (sửa tay)';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_stamps_once_check' THEN RAISE EXCEPTION 'I-039: đổi người bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (đổi người, sửa tay): %', SQLERRM;
  END;

  -- Huỷ: người nghỉ chỉ huỷ được khi hôm nay còn trước ngày nghỉ; chủ quán lúc nào cũng được; ghi một lần.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', a::text, true);
    UPDATE leave_notice SET cancelled_at = now(), cancelled_by_person_id = a WHERE id = l2;
    RESET ROLE;
    RAISE EXCEPTION 'I-039: người nghỉ HUỶ ĐƯỢC báo nghỉ của chính hôm nay';
  EXCEPTION WHEN check_violation THEN
    RESET ROLE;
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_cancel_allowed_check' THEN RAISE EXCEPTION 'I-039: huỷ muộn bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (người nghỉ huỷ vào ngày nghỉ): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', b::text, true);
    UPDATE leave_notice SET cancelled_at = now(), cancelled_by_person_id = b WHERE id = l3;
    RESET ROLE;
    RAISE EXCEPTION 'I-039: người khác HUỶ ĐƯỢC báo nghỉ của một người';
  EXCEPTION WHEN check_violation THEN
    RESET ROLE;
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_cancel_allowed_check' THEN RAISE EXCEPTION 'I-039: người khác huỷ bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (người khác huỷ): %', SQLERRM;
  END;
  BEGIN
    UPDATE leave_notice SET cancelled_by_person_id = chu WHERE id = l3;
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối dấu huỷ thiếu lúc huỷ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_cancelled_pair_check' THEN RAISE EXCEPTION 'I-039: dấu huỷ lẻ bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (dấu huỷ lẻ đôi): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', a::text, true);
    UPDATE leave_notice SET cancelled_at = now(), cancelled_by_person_id = a WHERE id = l1;
    PERFORM set_config('shop.actor_person_id', chu::text, true);
    UPDATE leave_notice SET cancelled_at = now(), cancelled_by_person_id = chu WHERE id = l2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege OR check_violation THEN
    RAISE EXCEPTION 'I-039: người nghỉ huỷ trước ngày, hay chủ quán huỷ vào ngày nghỉ, bị từ chối: %', SQLERRM;
  END;
  BEGIN
    UPDATE leave_notice SET cancelled_at = NULL, cancelled_by_person_id = NULL WHERE id = l1;
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối bỏ huỷ một báo nghỉ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_stamps_once_check' THEN RAISE EXCEPTION 'I-039: bỏ huỷ bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (bỏ huỷ): %', SQLERRM;
  END;
  -- Huỷ xong thì báo lại cùng ngày là một dòng mới.
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay + 5, 'test-i039-l1b');
  RAISE NOTICE 'I-039 dương: người nghỉ huỷ trước ngày, chủ quán huỷ vào ngày nghỉ, báo lại là dòng mới';

  -- Chặn tick hai chiều.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO attendance_day (worker_person_id, work_date) VALUES (a, hom_nay + 6);
    RAISE EXCEPTION 'I-039: database KHÔNG chặn tick ô có đi làm của ngày đã báo nghỉ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'attendance_day_on_leave_check' THEN RAISE EXCEPTION 'I-039: tick ngày nghỉ bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (tick ngày đã báo nghỉ): %', SQLERRM;
  END;
  -- Báo nghỉ đã huỷ (l2, hôm nay) không chặn: tick hôm nay được.
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (a, hom_nay) RETURNING id INTO o1;
  PERFORM set_config('shop.actor_person_id', a::text, true);
  BEGIN
    INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay, 'test-i039-x7');
    RAISE EXCEPTION 'I-039: database KHÔNG từ chối báo nghỉ cho ngày đã có ô có đi làm';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'leave_notice_attendance_ticked_check' THEN RAISE EXCEPTION 'I-039: báo nghỉ ngày đã tick bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (báo nghỉ ngày đã tick): %', SQLERRM;
  END;
  -- Chủ quán huỷ ô (có ghi chú, U-071) thì người ấy báo nghỉ được; làm sống lại ô cũ thì bị chặn.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  UPDATE attendance_day SET cancelled_at = now(), cancelled_by_person_id = chu, cancel_note = 'test-tick nhầm' WHERE id = o1;
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO leave_notice (leave_date, submission_code) VALUES (hom_nay, 'test-i039-l4');
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    UPDATE attendance_day SET cancelled_at = NULL, cancelled_by_person_id = NULL, cancel_note = NULL WHERE id = o1;
    RAISE EXCEPTION 'I-039: database KHÔNG chặn làm sống lại ô có đi làm của ngày đã báo nghỉ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'attendance_day_on_leave_check' THEN RAISE EXCEPTION 'I-039: làm sống lại ô bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-039 bị từ chối (làm sống lại ô ngày đã báo nghỉ): %', SQLERRM;
  END;
  -- Người khác cùng ngày không bị chặn.
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (b, hom_nay + 6);
  RAISE NOTICE 'I-039 dương: báo nghỉ đã huỷ không chặn; người khác cùng ngày tick được';

  -- Kiểm ngược (1): không ngày nào của một người vừa có ô còn hiệu lực vừa có báo nghỉ còn hiệu lực.
  SELECT count(*) INTO n FROM attendance_day d JOIN leave_notice l
    ON l.person_id = d.worker_person_id AND l.leave_date = d.work_date
  WHERE d.cancelled_at IS NULL AND l.cancelled_at IS NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'I-039: % ngày vừa có ô có đi làm vừa có báo nghỉ còn hiệu lực', n; END IF;
  -- Kiểm ngược (2): khoá ngoại từ leave_notice chỉ trỏ tới người.
  SELECT count(*) INTO n
  FROM information_schema.referential_constraints rc
  JOIN information_schema.table_constraints src ON src.constraint_name = rc.constraint_name AND src.constraint_schema = rc.constraint_schema
  JOIN information_schema.table_constraints dst ON dst.constraint_name = rc.unique_constraint_name AND dst.constraint_schema = rc.unique_constraint_schema
  WHERE src.table_schema = 'shop' AND src.table_name = 'leave_notice' AND dst.table_name <> 'person';
  IF n <> 0 THEN RAISE EXCEPTION 'I-039: % khoá ngoại từ leave_notice trỏ ra ngoài người', n; END IF;
  -- Kiểm ngược (3): không bảng tiền, đơn hay khoản nào đổi nội dung.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('leave_notice', 'attendance_day', 'record_revision', 'person');
  IF snap IS DISTINCT FROM snap2 THEN RAISE EXCEPTION 'I-039: báo nghỉ đã làm đổi một bảng khác (tiền, khoản, đơn)'; END IF;
  -- Kiểm ngược (4): hai trigger chặn tick dùng chung khoá giao dịch theo (người, ngày).
  SELECT count(*) INTO n FROM pg_proc p JOIN pg_namespace s ON s.oid = p.pronamespace
  WHERE s.nspname = 'shop' AND p.prosrc ILIKE '%pg_advisory_xact_lock%'
    AND p.oid IN (SELECT tgfoid FROM pg_trigger WHERE tgrelid IN ('shop.leave_notice'::regclass, 'shop.attendance_day'::regclass));
  IF n < 2 THEN RAISE EXCEPTION 'I-039: chỉ % hàm trigger của leave_notice / attendance_day lấy khoá giao dịch (cần cả hai chiều)', n; END IF;
  RAISE NOTICE 'I-039 kiểm ngược: không ngày nào hai sự thật, chỉ trỏ tới người, không bảng khác đổi, hai chiều cùng khoá';
END $$;
