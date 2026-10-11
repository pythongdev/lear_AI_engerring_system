-- I-018 (tầng 1 · tầng 2) — CHẾ ĐỘ NGHIÊM của vết, bước 20 (T-138, ADR-092; gỡ F-046): mọi lần sửa đổi
-- nội dung, và mọi lần thêm dòng con vào một bản ghi đã có, mà giao dịch không khai lý do thì database
-- từ chối, tên `record_revision_reason_declared_check`. Một ngoại lệ hẹp cho lượt gọi thêm của khách QR
-- (F-060 vế b); cửa đổi mã QR tự khai lý do; ghép bàn phải có người (I-012). Lát:
-- 06-luoc-do-nguoi-va-vet.md §3 · §5.

-- Chạy một câu, chờ nó bị từ chối đúng tên; trả câu báo lỗi để in.
CREATE FUNCTION pg_temp.tu_choi(p_sql text, p_ten text) RETURNS text LANGUAGE plpgsql AS $f$
DECLARE c text; m text;
BEGIN
  BEGIN
    EXECUTE p_sql;
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME, m = MESSAGE_TEXT;
    IF c IS DISTINCT FROM p_ten THEN
      RAISE EXCEPTION 'T-138: chờ từ chối tên %, nhận tên % — %', p_ten, c, m;
    END IF;
    RETURN m;
  END;
  RAISE EXCEPTION 'T-138: database KHÔNG từ chối: %', p_sql;
END $f$;

DO $$
DECLARE b bigint; t1 bigint; t2 bigint; t3 bigint; s bigint; s2 bigint; q bigint; q_cu bigint;
        o bigint; f bigint; n bigint; r record;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-B đứng quầy') RETURNING id INTO b;
  PERFORM set_config('shop.actor_person_id', b::text, true);
  PERFORM set_config('shop.revision_reason', 'test-dựng tình huống', true);
  INSERT INTO dining_table (label) VALUES ('test-1') RETURNING id INTO t1;
  INSERT INTO dining_table (label) VALUES ('test-2') RETURNING id INTO t2;
  INSERT INTO dining_table (label) VALUES ('test-3') RETURNING id INTO t3;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text)
  RETURNING id INTO o;
  INSERT INTO opening_float (sale_date, created_at) VALUES (DATE '2026-10-08', now() - interval '1 hour')
  RETURNING id INTO f;

  -- 1. Sửa đổi nội dung mà không khai lý do ⇒ từ chối đúng tên; dòng không đổi, không vết.
  PERFORM set_config('shop.revision_reason', '', true);
  n := (SELECT count(*) FROM record_revision);
  RAISE NOTICE 'T-138 sửa không lý do bị từ chối: %', pg_temp.tu_choi(
    format('UPDATE sales_order SET customer_phone = %L WHERE id = %s', '0900000009', o),
    'record_revision_reason_declared_check');
  IF (SELECT customer_phone FROM sales_order WHERE id = o) <> '0900000001'
     OR (SELECT count(*) FROM record_revision) <> n THEN
    RAISE EXCEPTION 'T-138: lần sửa bị từ chối vẫn để lại một nửa';
  END IF;

  -- 2. Câu sửa không đổi gì: đi qua dù không lý do — không có gì để giữ vết.
  UPDATE sales_order SET customer_phone = customer_phone WHERE id = o;
  IF (SELECT count(*) FROM record_revision) <> n THEN
    RAISE EXCEPTION 'T-138: câu sửa không đổi gì lại sinh vết';
  END IF;
  RAISE NOTICE 'T-138 câu sửa không đổi gì, không lý do: đi qua, 0 vết';

  -- 3. Có lý do và người ⇒ đúng một vết mang đủ bốn thứ.
  PERFORM set_config('shop.revision_reason', 'test-khách đọc lại số', true);
  UPDATE sales_order SET customer_phone = '0911111111' WHERE id = o;
  SELECT * INTO STRICT r FROM record_revision WHERE target_table_code = 'sales_order' AND target_row = o;
  IF r.before_image ->> 'customer_phone' <> '0900000001' OR r.after_image ->> 'customer_phone' <> '0911111111'
     OR r.reason <> 'test-khách đọc lại số' OR r.person_id <> b THEN
    RAISE EXCEPTION 'T-138: vết của lần sửa có lý do thiếu một trong bốn thứ: %', row_to_json(r);
  END IF;
  RAISE NOTICE 'T-138 sửa có lý do — trước %, sau %, lý do "%", người %', r.before_image ->> 'customer_phone',
    r.after_image ->> 'customer_phone', r.reason, (SELECT display_name FROM person WHERE id = r.person_id);

  -- 4. Thêm dòng con vào một bản ghi cha đã có mà không lý do ⇒ từ chối cùng tên (ADR-081 phủ cả nó).
  PERFORM set_config('shop.revision_reason', '', true);
  RAISE NOTICE 'T-138 thêm dòng con không lý do bị từ chối: %', pg_temp.tu_choi(
    format('INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (%s, 1000, 5000)', f),
    'record_revision_reason_declared_check');

  -- 5. Ghép bàn phải có người; mở phiên được trống người (khách QR mở phiên bằng lượt gọi).
  PERFORM set_config('shop.actor_person_id', '', true);
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, t1);
  RAISE NOTICE 'T-138 mở phiên không người (khách QR): được, người của dòng bàn: %',
    coalesce((SELECT person_id::text FROM table_session_member WHERE table_session_id = s), 'trống');
  RAISE NOTICE 'T-138 ghép bàn không người bị từ chối: %', pg_temp.tu_choi(
    format('INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (%s, %s)', s, t2),
    'table_session_member_merge_person_required_check');
  PERFORM set_config('shop.actor_person_id', b::text, true);
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, t2);
  IF (SELECT person_id FROM table_session_member WHERE table_session_id = s AND dining_table_id = t2)
     IS DISTINCT FROM b THEN
    RAISE EXCEPTION 'T-138: dòng ghép bàn không mang người của giao dịch';
  END IF;
  RAISE NOTICE 'T-138 ghép bàn có người: được, người %', (SELECT display_name FROM person WHERE id = b);

  -- 6. Đổi mã QR mà người gọi không khai lý do: hàm tự khai, mã cũ có vết, cài đặt trả về như cũ.
  q_cu := qr_code_issue(t1);
  q := qr_code_issue(t1);
  SELECT * INTO STRICT r FROM record_revision WHERE target_table_code = 'qr_code' AND target_row = q_cu;
  IF r.before_image ->> 'replaced_at' IS NOT NULL OR r.after_image ->> 'replaced_at' IS NULL
     OR r.person_id <> b OR current_setting('shop.revision_reason', true) <> '' THEN
    RAISE EXCEPTION 'T-138: đổi mã QR không để đúng vết, hay không trả lý do về như cũ: %', row_to_json(r);
  END IF;
  RAISE NOTICE 'T-138 đổi mã QR — vết trên mã cũ, lý do "%", người %', r.reason,
    (SELECT display_name FROM person WHERE id = r.person_id);
  PERFORM set_config('shop.actor_person_id', '', true);
  BEGIN
    PERFORM qr_code_issue(t1);
    RAISE EXCEPTION 'T-138: database KHÔNG từ chối đổi mã QR không có người';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'T-138 đổi mã QR không người bị từ chối: %', SQLERRM;
  END;

  -- 7. Ngoại lệ của khách QR (F-060 vế b): phiên Chờ thanh toán → Đang phục vụ, không người, không lý
  -- do, chỉ khi CHÍNH giao dịch này vừa thêm một đơn qr_table vào phiên.
  PERFORM set_config('shop.actor_person_id', b::text, true);
  PERFORM set_config('shop.revision_reason', 'test-dựng phiên chờ thanh toán', true);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  PERFORM set_config('shop.revision_reason', '', true);
  PERFORM set_config('shop.actor_person_id', '', true);
  -- 7a. Chưa có lượt gọi QR nào trong giao dịch ⇒ từ chối.
  RAISE NOTICE 'T-138 phiên quay về Đang phục vụ mà không lượt gọi QR nào bị từ chối: %', pg_temp.tu_choi(
    format('UPDATE table_session SET status = %L WHERE id = %s', 'serving', s),
    'record_revision_reason_declared_check');
  -- 7b. Lượt gọi QR của khách vừa vào phiên ⇒ đi qua, không vết.
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code, qr_code_id)
  VALUES ('qr_table', 'pending_confirmation', s, t1, gen_random_uuid()::text, q);
  n := (SELECT count(*) FROM record_revision WHERE target_table_code = 'table_session' AND target_row = s);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  IF (SELECT count(*) FROM record_revision WHERE target_table_code = 'table_session' AND target_row = s) <> n THEN
    RAISE EXCEPTION 'T-138: ngoại lệ của khách QR lại sinh vết không người';
  END IF;
  RAISE NOTICE 'T-138 khách QR gọi thêm lúc Chờ thanh toán: phiên về %, 0 vết (F-060)',
    (SELECT status FROM table_session WHERE id = s);
  -- 7c. Cùng lượt gọi ấy, nhưng cặp chuyển khác ⇒ từ chối.
  RAISE NOTICE 'T-138 cặp chuyển khác của phiên, không người, bị từ chối: %', pg_temp.tu_choi(
    format('UPDATE table_session SET status = %L WHERE id = %s', 'awaiting_payment', s),
    'record_revision_reason_declared_check');
  -- 7d. Cùng cặp, có người mà không lý do ⇒ từ chối: người của quán luôn khai lý do.
  PERFORM set_config('shop.actor_person_id', b::text, true);
  PERFORM set_config('shop.revision_reason', 'test-dựng lại chờ thanh toán', true);
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  PERFORM set_config('shop.revision_reason', '', true);
  RAISE NOTICE 'T-138 cùng cặp, có người mà không lý do, bị từ chối: %', pg_temp.tu_choi(
    format('UPDATE table_session SET status = %L WHERE id = %s', 'serving', s),
    'record_revision_reason_declared_check');
  -- 7e. Phiên khác, không lượt gọi QR nào của chính nó trong giao dịch ⇒ từ chối dù phiên s có.
  PERFORM set_config('shop.revision_reason', 'test-dựng phiên thứ hai', true);
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s2;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s2, t3);
  UPDATE table_session SET status = 'serving' WHERE id = s2;
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s2;
  PERFORM set_config('shop.revision_reason', '', true);
  PERFORM set_config('shop.actor_person_id', '', true);
  RAISE NOTICE 'T-138 phiên không có lượt gọi QR của chính nó bị từ chối: %', pg_temp.tu_choi(
    format('UPDATE table_session SET status = %L WHERE id = %s', 'serving', s2),
    'record_revision_reason_declared_check');
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
