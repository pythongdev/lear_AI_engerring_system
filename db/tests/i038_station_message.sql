-- I-038 (tầng 1): tin báo trên hộp tin KHÔNG BAO GIỜ đổi tiến độ, bàn hay việc giao. Một dòng `station_message`
-- chỉ thêm — không sửa, không xoá; người gửi là người của quán (mặc định người thao tác của giao dịch), khác người
-- nhận; người nhận rỗng là gửi về quầy; `work_code` ∈ canh · don_ban · trang_banh · gap_banh · khac; `body` 1–500 ký
-- tự, không chỉ khoảng trắng; `submission_code` duy nhất — gửi lại cùng mã không thêm dòng (vế "trả đúng tin cũ" là
-- tầng 3, backend). Bảng không có khoá ngoại nào tới việc trạm, phiên, đơn hay việc giao.
-- Vế "tin riêng chỉ người gửi, người nhận (hoặc quầy) đọc được" là tầng 3 (cửa đọc của CHAT-13) — database KHÔNG xét.
-- Thiết kế: docs/decisions.md ADR-137 điểm 3 · 6 · 9. Chạy đúng kịch bản Verification của quality/invariants.md I-038.
-- Viết trước lược đồ (CHAT-12, Claude Code, 2026-11-03): đỏ cho tới khi migration hộp tin dựng.

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i038_station_message', true); END $$;
DO $$
DECLARE pos bigint; canh bigint; trang bigint; ban bigint; m1 bigint; m2 bigint; m3 bigint; n int; r record;
        snap text; snap2 text;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO pos;
  INSERT INTO person (display_name) VALUES ('test-người canh và dọn') RETURNING id INTO canh;
  INSERT INTO person (display_name) VALUES ('test-người tráng bánh') RETURNING id INTO trang;
  INSERT INTO dining_table (label) VALUES ('test-bàn i038') RETURNING id INTO ban;

  -- Chụp NỘI DUNG mọi bảng khác (không chỉ số dòng): ghi tin không được đổi một dòng nào của tiến độ, bàn,
  -- phiên, đơn, việc giao hay tiền.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('station_message', 'record_revision');

  -- Kịch bản dương, bằng vai ghi của hệ thống. Người gửi lấy từ người thao tác của giao dịch, không ai gõ tay.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', pos::text, true);
    -- (1) POS gửi tới một người, gắn bàn.
    INSERT INTO station_message (recipient_person_id, work_code, body, dining_table_id, submission_code)
    VALUES (canh, 'don_ban', 'test-bàn 3 khách về, dọn giúp', ban, 'test-i038-m1') RETURNING id INTO m1;
    -- (2) Cùng người nhận, loại việc khác: một người kiêm canh + dọn nhận hai tin, hai nhãn.
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code)
    VALUES (canh, 'canh', 'test-múc thêm 2 bát canh bàn 3', 'test-i038-m3') RETURNING id INTO m3;
    -- (3) Người canh + dọn trả lời về quầy: người nhận rỗng.
    PERFORM set_config('shop.actor_person_id', canh::text, true);
    INSERT INTO station_message (work_code, body, reply_to_message_id, submission_code)
    VALUES ('don_ban', 'test-đã dọn bàn 3', m1, 'test-i038-m2') RETURNING id INTO m2;
    -- Biên trên của `body`: đúng 500 ký tự (chữ có dấu, đếm ký tự không đếm byte) được nhận.
    INSERT INTO station_message (work_code, body, submission_code)
    VALUES ('khac', repeat('ạ', 500), 'test-i038-500');
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-038: vai shop_app KHÔNG gửi được tin: %', SQLERRM;
  END;

  SELECT s.sender_person_id, s.recipient_person_id, s.work_code, s.dining_table_id, s.created_at IS NOT NULL AS co_luc
  INTO r FROM station_message s WHERE s.id = m1;
  IF r.sender_person_id IS DISTINCT FROM pos OR r.recipient_person_id IS DISTINCT FROM canh
     OR r.work_code IS DISTINCT FROM 'don_ban' OR r.dining_table_id IS DISTINCT FROM ban OR NOT r.co_luc THEN
    RAISE EXCEPTION 'I-038: tin POS gửi không đọc lại được đủ người gửi · người nhận · loại việc · bàn · lúc gửi';
  END IF;
  SELECT s.sender_person_id, s.recipient_person_id, s.reply_to_message_id INTO r FROM station_message s WHERE s.id = m2;
  IF r.sender_person_id IS DISTINCT FROM canh OR r.recipient_person_id IS NOT NULL OR r.reply_to_message_id IS DISTINCT FROM m1 THEN
    RAISE EXCEPTION 'I-038: tin trả lời về quầy không đọc lại được người gửi · người nhận rỗng · tin được trả lời';
  END IF;
  SELECT count(*) INTO n FROM station_message WHERE recipient_person_id = canh;
  IF n <> 2 THEN
    RAISE EXCEPTION 'I-038: người kiêm canh + dọn nhận % dòng thay vì 2', n;
  END IF;
  SELECT count(DISTINCT work_code) INTO n FROM station_message WHERE recipient_person_id = canh;
  IF n <> 2 THEN
    RAISE EXCEPTION 'I-038: hai tin tới người kiêm canh + dọn không giữ hai nhãn loại việc';
  END IF;
  RAISE NOTICE 'I-038 dương: gửi tới một người, gửi về quầy, trả lời một tin; một người nhận hai nhãn; body 500 ký tự';

  -- Tầng 1: ca âm, mỗi ca một lỗi riêng.
  PERFORM set_config('shop.actor_person_id', pos::text, true);
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code) VALUES (canh, 'canh', '', 'test-i038-x1');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối tin rỗng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (tin rỗng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code) VALUES (canh, 'canh', '   ', 'test-i038-x2');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối tin chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (tin chỉ khoảng trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code)
    VALUES (canh, 'canh', repeat('ạ', 501), 'test-i038-x3');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối tin quá 500 ký tự';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (tin 501 ký tự): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code) VALUES (canh, 'thu_tien', 'test-x', 'test-i038-x4');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối loại việc lạ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (loại việc lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code) VALUES (pos, 'canh', 'test-x', 'test-i038-x6');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối người gửi trùng người nhận';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (gửi cho chính mình): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code) VALUES (-1, 'canh', 'test-x', 'test-i038-x7');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối người nhận không phải người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (người nhận lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (sender_person_id, recipient_person_id, work_code, body, submission_code)
    VALUES (-1, canh, 'canh', 'test-x', 'test-i038-x8');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối người gửi không phải người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (người gửi lạ): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', '', true);
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code) VALUES (canh, 'canh', 'test-x', 'test-i038-x9');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối tin không có người gửi';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (không người gửi): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', pos::text, true);
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, reply_to_message_id, submission_code)
    VALUES (canh, 'canh', 'test-x', -1, 'test-i038-x10');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối trả lời một tin không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (trả lời tin lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, dining_table_id, submission_code)
    VALUES (canh, 'don_ban', 'test-x', -1, 'test-i038-x11');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối bàn không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (bàn lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, submission_code) VALUES (canh, 'canh', 'test-x', '  ');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối mã gửi trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (mã gửi trắng): %', SQLERRM;
  END;
  -- Gửi lại cùng mã: cùng người gửi hay người khác đều không thêm được dòng thứ hai.
  BEGIN
    INSERT INTO station_message (recipient_person_id, work_code, body, dining_table_id, submission_code)
    VALUES (canh, 'don_ban', 'test-bàn 3 khách về, dọn giúp', ban, 'test-i038-m1');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối cùng người gửi ghi hai dòng cùng mã gửi';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (gửi lại cùng mã, cùng người): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', trang::text, true);
  BEGIN
    INSERT INTO station_message (work_code, body, submission_code) VALUES ('trang_banh', 'test-x', 'test-i038-m1');
    RAISE EXCEPTION 'I-038: database KHÔNG từ chối người khác dùng mã gửi đã có';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-038 bị từ chối (mã gửi của người khác): %', SQLERRM;
  END;

  -- Chỉ thêm: vai ghi không sửa, không xoá được tin.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE station_message SET body = 'test-sửa lời' WHERE id = m1;
    RESET ROLE;
    RAISE EXCEPTION 'I-038: vai shop_app SỬA ĐƯỢC một tin đã gửi';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-038 bị từ chối (sửa tin đã gửi): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM station_message WHERE id = m1;
    RESET ROLE;
    RAISE EXCEPTION 'I-038: vai shop_app XOÁ ĐƯỢC một tin đã gửi';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-038 bị từ chối (xoá tin đã gửi): %', SQLERRM;
  END;

  -- Kiểm ngược (1): khoá ngoại từ station_message chỉ trỏ tới người, bàn và chính nó.
  SELECT count(*) INTO n
  FROM information_schema.referential_constraints rc
  JOIN information_schema.table_constraints src ON src.constraint_name = rc.constraint_name AND src.constraint_schema = rc.constraint_schema
  JOIN information_schema.table_constraints dst ON dst.constraint_name = rc.unique_constraint_name AND dst.constraint_schema = rc.unique_constraint_schema
  WHERE src.table_schema = 'shop' AND src.table_name = 'station_message'
    AND dst.table_name NOT IN ('person', 'dining_table', 'station_message');
  IF n <> 0 THEN
    RAISE EXCEPTION 'I-038: % khoá ngoại từ station_message trỏ ra ngoài người · bàn · chính nó', n;
  END IF;
  RAISE NOTICE 'I-038 kiểm ngược: tin chỉ trỏ tới người, bàn và tin khác';

  -- Kiểm ngược (2): sau mọi lần ghi ở trên, không bảng nào khác đổi nội dung.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('station_message', 'record_revision');
  IF snap IS DISTINCT FROM snap2 THEN
    RAISE EXCEPTION 'I-038: ghi tin đã làm đổi một bảng khác (tiến độ, bàn, phiên, việc giao hay tiền)';
  END IF;
  RAISE NOTICE 'I-038 kiểm ngược: ghi tin không đổi một dòng nào của bảng khác';
END $$;
