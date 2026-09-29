-- I-023: mã QR của bàn. Tầng 1 — một bàn ≤ một mã hiện hành · một mã ≤ một bàn kể cả mã đã
-- thay · lượt gọi qr_table mang mã và đứng đúng bàn của mã. Tầng 3 — mã cũ không tạo được
-- lượt gọi (cửa tạo lượt gọi, pha 3: test dựng trạng thái sai và cho thấy câu đối chiếu bắt
-- được) · một cửa sinh mã không đoán được. Kịch bản: quality/invariants.md I-023 Verification.
-- Lát: 02-luoc-do-ban-hang.md §2. Mỗi kịch bản âm phải bị từ chối bởi ĐÚNG ràng buộc nó nhắm.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
CREATE FUNCTION pg_temp.expect_reject(label text, stmt text, want text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE got text;
BEGIN
  BEGIN
    EXECUTE stmt;
  EXCEPTION WHEN unique_violation OR check_violation OR foreign_key_violation THEN
    GET STACKED DIAGNOSTICS got = CONSTRAINT_NAME;
    IF got IS DISTINCT FROM want THEN
      RAISE EXCEPTION 'I-023 (%): bị chặn bởi % thay vì %', label, got, want;
    END IF;
    RAISE NOTICE 'I-023 bị từ chối (%): %', label, SQLERRM;
    RETURN;
  END;
  RAISE EXCEPTION 'I-023: database KHÔNG từ chối — %', label;
END $$;

-- Một lượt gọi qr_table vào một bàn, mang một dòng mã cho trước.
CREATE FUNCTION pg_temp.qr_order(s bigint, t bigint, q bigint) RETURNS text LANGUAGE sql AS $$
  SELECT format($q$INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id,
                                             submission_code, qr_code_id)
                   VALUES ('qr_table', 'new', %s, %s, gen_random_uuid()::text, %s)$q$,
                s, t, coalesce(q::text, 'NULL'))
$$;

DO $$
DECLARE t5 bigint; t7 bigint; s5 bigint; s7 bigint; q5 bigint; q5b bigint; q7 bigint;
        o_old bigint; n bigint; old_code text; cur_code text; st text;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO dining_table (label) VALUES ('test-7') RETURNING id INTO t7;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s5;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s7;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s5, t5), (s7, t7);
  q5 := qr_code_issue(t5);
  q7 := qr_code_issue(t7);

  -- Kịch bản âm 1: mã của bàn 5, kèm "số bàn 7" từ phía khách ⇒ không đứng được ở bàn 7.
  -- (Cửa tạo lượt gọi của pha 3 tra bàn TỪ mã và bỏ số bàn khách gửi; lược đồ bảo đảm hai
  -- cột không nói khác nhau.)
  PERFORM pg_temp.expect_reject('mã bàn 5, số bàn 7 từ phía khách', pg_temp.qr_order(s7, t7, q5),
    'sales_order_qr_code_table_fkey');

  -- Kịch bản âm 2: mã không chỉ tới bàn nào · lượt gọi qr_table không mang mã.
  PERFORM pg_temp.expect_reject('mã không chỉ tới bàn nào', pg_temp.qr_order(s5, t5, -1),
    'sales_order_qr_code_table_fkey');
  PERFORM pg_temp.expect_reject('lượt gọi qr_table không mang mã', pg_temp.qr_order(s5, t5, NULL),
    'sales_order_qr_code_iff_qr_channel_check');

  -- Kịch bản dương 1 (phần trước lần đổi): một lượt gọi bằng mã hiện tại của bàn 5.
  EXECUTE pg_temp.qr_order(s5, t5, q5) || ' RETURNING id' INTO o_old;

  -- Đổi mã bàn 5 qua cửa duy nhất.
  SELECT code INTO old_code FROM qr_code WHERE id = q5;
  q5b := qr_code_issue(t5);
  SELECT code INTO cur_code FROM qr_code WHERE id = q5b;
  SELECT count(*) INTO n FROM qr_code WHERE dining_table_id = t5 AND replaced_at IS NULL;
  RAISE NOTICE 'I-023 đổi mã bàn 5: mã cũ đã có lúc bị thay, bàn 5 còn % mã hiện hành', n;

  -- Kịch bản âm 3 (tầng 3): lượt gọi mang MÃ CŨ, tạo SAU lần đổi. Cửa tạo lượt gọi của pha 3
  -- phải từ chối; lược đồ không đọc được "mã này còn hiện hành không" từ một ràng buộc kiểm.
  -- Dựng trạng thái sai trong một khối tự rollback và cho thấy câu đối chiếu 3 bắt được nó.
  BEGIN
    INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id,
                             submission_code, qr_code_id, created_at)
    SELECT 'qr_table', 'new', s5, t5, gen_random_uuid()::text, q5, replaced_at + interval '1 minute'
      FROM qr_code WHERE id = q5;
    SELECT count(*) INTO n FROM sales_order o JOIN qr_code q ON q.id = o.qr_code_id
     WHERE o.channel_code = 'qr_table' AND o.created_at > q.replaced_at;
    RAISE NOTICE 'I-023 tầng 3 — lượt gọi mang mã cũ tạo sau lần đổi: database nhận (việc của cửa pha 3), câu đối chiếu 3 bắt được % lượt', n;
    IF n <> 1 THEN RAISE EXCEPTION 'I-023: câu đối chiếu 3 không bắt được lượt gọi mang mã cũ'; END IF;
    RAISE EXCEPTION USING ERRCODE = 'P0099', MESSAGE = 'rollback kịch bản tầng 3';
  EXCEPTION WHEN SQLSTATE 'P0099' THEN NULL;
  END;

  -- Kịch bản âm 4: cấp cho bàn 7 một mã đang hoặc đã từng là mã của bàn 5.
  PERFORM pg_temp.expect_reject('cấp cho bàn 7 mã ĐÃ THAY của bàn 5',
    format($q$INSERT INTO qr_code (dining_table_id, code, issued_at) VALUES (%s, %L, now())$q$, t7, old_code),
    'qr_code_code_key');
  PERFORM pg_temp.expect_reject('cấp cho bàn 7 mã HIỆN HÀNH của bàn 5',
    format($q$INSERT INTO qr_code (dining_table_id, code, issued_at) VALUES (%s, %L, now())$q$, t7, cur_code),
    'qr_code_code_key');
  -- Và một bàn không có hai mã hiện hành.
  PERFORM pg_temp.expect_reject('mã hiện hành thứ hai cho bàn 5',
    format($q$INSERT INTO qr_code (dining_table_id, code, issued_at) VALUES (%s, 'test-ma-thu-hai', now())$q$, t5),
    'qr_code_one_current_per_table_key');

  -- Một cửa: vai ghi của hệ thống không ghi thẳng vào bảng mã, chỉ gọi được cửa sinh mã.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO shop.qr_code (dining_table_id, code, issued_at) VALUES (t7, 'test-ma-tu-che', now());
    RAISE EXCEPTION 'I-023: shop_app ghi thẳng được vào qr_code — cửa thứ hai';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-023 bị từ chối (shop_app tự ghi mã): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE shop.qr_code SET replaced_at = NULL WHERE id = q5;
    RAISE EXCEPTION 'I-023: shop_app sửa thẳng được qr_code — hồi sinh mã cũ';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-023 bị từ chối (shop_app hồi sinh mã cũ): %', SQLERRM;
  END;
  SET LOCAL ROLE shop_app;
  q7 := shop.qr_code_issue(t7);
  RESET ROLE;
  RAISE NOTICE 'I-023 shop_app đổi được mã bàn 7 qua cửa qr_code_issue';

  -- Kịch bản dương 1: lượt gọi tạo bằng mã cũ TRƯỚC lần đổi giữ nguyên bàn, phiên, trạng thái.
  SELECT status INTO st FROM sales_order
   WHERE id = o_old AND dining_table_id = t5 AND table_session_id = s5 AND qr_code_id = q5;
  IF st IS DISTINCT FROM 'new' THEN RAISE EXCEPTION 'I-023: lượt gọi trước lần đổi bị chạm (%)', st; END IF;
  RAISE NOTICE 'I-023 lượt gọi tạo trước lần đổi: vẫn bàn 5, phiên cũ, mã cũ, trạng thái %', st;
  -- Kịch bản dương 2: đổi mã khi bàn đang có phiên ⇒ phiên và số bàn giữ nguyên.
  SELECT status INTO st FROM table_session WHERE id = s5;
  SELECT count(*) INTO n FROM dining_table WHERE id = t5 AND label = 'test-5';
  IF st <> 'serving' OR n <> 1 THEN RAISE EXCEPTION 'I-023: đổi mã chạm phiên hay số bàn'; END IF;
  RAISE NOTICE 'I-023 đổi mã giữa bữa: phiên bàn 5 vẫn %, số bàn vẫn test-5', st;
  EXECUTE pg_temp.qr_order(s5, t5, q5b);
  RAISE NOTICE 'I-023 lượt gọi bằng mã mới vào đúng phiên bàn 5 — được';

  -- Kịch bản đoán: sinh mã cho mười bàn trong một lượt, và sinh lại mã bàn 5 hai lần nữa.
  INSERT INTO dining_table (label) SELECT 'test-doan-' || lpad(g::text, 2, '0') FROM generate_series(1, 10) g;
  PERFORM qr_code_issue(id) FROM dining_table WHERE label LIKE 'test-doan-%' ORDER BY label;
  PERFORM qr_code_issue(t5);
  PERFORM qr_code_issue(t5);
  SELECT count(*) INTO n FROM qr_code WHERE code !~ '^[0-9a-f]{32}$';
  IF n > 0 THEN RAISE EXCEPTION 'I-023: % mã do cửa sinh không đúng dạng 32 hex', n; END IF;
  SELECT count(*) INTO n FROM qr_code a JOIN qr_code b ON a.id < b.id
   WHERE left(a.code, 6) = left(b.code, 6) OR right(a.code, 6) = right(b.code, 6);
  IF n > 0 THEN RAISE EXCEPTION 'I-023: % cặp mã chung đầu hoặc đuôi 6 ký tự', n; END IF;
  SELECT count(*) INTO n FROM (
    SELECT id, row_number() OVER (ORDER BY id) AS by_issue, row_number() OVER (ORDER BY code) AS by_code
      FROM qr_code) r WHERE by_issue <> by_code;
  IF n = 0 THEN RAISE EXCEPTION 'I-023: thứ tự sắp theo mã trùng thứ tự cấp — mã đọc ra thứ tự'; END IF;
  SELECT count(*) INTO n FROM qr_code;
  RAISE NOTICE 'I-023 kịch bản đoán: % mã, không cặp nào chung đầu/đuôi 6 ký tự, thứ tự mã khác thứ tự cấp, không mã nào mang số bàn', n;

  -- Tập đối chiếu của hàng I-023 (03-bao-ve-invariant.md §1). Mỗi tập phải rỗng.
  SELECT count(*) INTO n FROM sales_order o JOIN qr_code q ON q.id = o.qr_code_id
   WHERE o.dining_table_id <> q.dining_table_id;
  IF n > 0 THEN RAISE EXCEPTION 'I-023 đối chiếu 1: % lượt gọi đứng khác bàn của mã', n; END IF;
  SELECT count(*) INTO n FROM sales_order WHERE channel_code = 'qr_table' AND qr_code_id IS NULL;
  IF n > 0 THEN RAISE EXCEPTION 'I-023 đối chiếu 2: % lượt gọi QR không đọc ra mã', n; END IF;
  SELECT count(*) INTO n FROM sales_order o JOIN qr_code q ON q.id = o.qr_code_id
   WHERE o.channel_code = 'qr_table' AND o.created_at > q.replaced_at;
  IF n > 0 THEN RAISE EXCEPTION 'I-023 đối chiếu 3: % lượt gọi tạo sau khi mã bị thay', n; END IF;
  SELECT count(*) INTO n FROM qr_code a JOIN qr_code b
    ON a.dining_table_id = b.dining_table_id AND a.id < b.id
   WHERE a.issued_at < coalesce(b.replaced_at, 'infinity')
     AND b.issued_at < coalesce(a.replaced_at, 'infinity');
  IF n > 0 THEN RAISE EXCEPTION 'I-023 đối chiếu 4: % cặp mã hiện hành chồng thời gian trên một bàn', n; END IF;
  SELECT count(*) INTO n FROM (
    SELECT code FROM qr_code GROUP BY code HAVING count(DISTINCT dining_table_id) > 1) d;
  IF n > 0 THEN RAISE EXCEPTION 'I-023 đối chiếu 5: % mã từng chỉ tới hơn một bàn', n; END IF;
  SELECT count(*) INTO n FROM qr_code WHERE dining_table_id IS NULL OR issued_at IS NULL;
  IF n > 0 THEN RAISE EXCEPTION 'I-023 đối chiếu 6: % lần cấp/đổi không đọc ra bàn hay lúc', n; END IF;
  RAISE NOTICE 'I-023 đối chiếu: sáu tập viết được đều rỗng (vế "ai" của tập 6 chờ P2-08; tập 7 giữ bằng cấu trúc — file lát §2)';
END $$;
