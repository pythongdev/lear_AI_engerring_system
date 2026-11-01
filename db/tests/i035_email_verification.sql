-- I-035 (tầng 1), phần xác nhận Gmail của khách (ADR-133): Gmail khách tự gõ lúc đăng ký nằm ở `pending_email` cho tới
-- khi bấm link; chỉ `email` đã xác nhận mới duy nhất và mới dùng để đăng nhập; mã xác nhận băm 32 byte, sống tối đa 24
-- giờ, dùng một lần; lần khách tự xác nhận để lại vết với người sửa rỗng.
-- Viết trước lược đồ (T-270, Claude Code): đỏ cho tới khi migration xác nhận Gmail dựng.

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i035_email_verification', true); END $$;
DO $$
DECLARE a bigint; b bigint; c bigint; v bigint; n int;
BEGIN
  SET LOCAL ROLE shop_app;

  -- Dương: khách đăng ký chỉ bằng Gmail ⇒ Gmail chờ xác nhận, chưa có `email`, vẫn mở phiên (dùng được ngay).
  INSERT INTO customer_account (pending_email, display_name) VALUES ('test.xacnhan@gmail.com', 'test-khách chờ xác nhận') RETURNING id INTO a;
  INSERT INTO customer_session (customer_account_id, token_hash, expires_at)
  VALUES (a, sha256('test-i035-xacnhan-phien'), now() + interval '7 days');
  RAISE NOTICE 'I-035 dương: khách chỉ có Gmail chờ xác nhận vẫn tạo được và mở phiên';

  -- Dương: Gmail chờ xác nhận KHÔNG giữ chỗ — người khác cũng chờ cùng địa chỉ được, và một tài khoản đã xác nhận
  -- địa chỉ ấy vẫn tồn tại song song.
  INSERT INTO customer_account (pending_email, display_name) VALUES ('test.xacnhan@gmail.com', 'test-kẻ gõ nhầm') RETURNING id INTO b;
  INSERT INTO customer_account (email, display_name) VALUES ('test.daxacnhan@gmail.com', 'test-chủ thật') RETURNING id INTO c;
  INSERT INTO customer_account (pending_email, display_name) VALUES ('test.daxacnhan@gmail.com', 'test-chờ trùng thư đã xác nhận');
  RAISE NOTICE 'I-035 dương: Gmail chờ xác nhận không giữ chỗ';

  BEGIN
    INSERT INTO customer_account (pending_email, display_name) VALUES ('Test.HOA@gmail.com', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối Gmail chờ xác nhận có chữ hoa';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (Gmail chờ có chữ hoa): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_account (pending_email, display_name) VALUES ('khong-co-a-cong', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối Gmail chờ xác nhận thiếu @';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (Gmail chờ thiếu @): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_account (email, pending_email, display_name) VALUES ('test.trung@gmail.com', 'test.trung@gmail.com', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối Gmail chờ trùng Gmail đã xác nhận của chính tài khoản';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (chờ trùng đã xác nhận cùng tài khoản): %', SQLERRM;
  END;

  -- Mã xác nhận: băm 32 byte, sống tối đa 24 giờ, dùng một lần.
  INSERT INTO customer_email_verification (customer_account_id, email, token_hash, expires_at)
  VALUES (a, 'test.xacnhan@gmail.com', sha256('test-i035-ma-xacnhan'), now() + interval '24 hours') RETURNING id INTO v;
  RAISE NOTICE 'I-035 dương: mã xác nhận 24 giờ';
  BEGIN
    INSERT INTO customer_email_verification (customer_account_id, email, token_hash, expires_at)
    VALUES (a, 'test.xacnhan@gmail.com', sha256('test-i035-ma-dai'), now() + interval '25 hours');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối mã xác nhận sống quá 24 giờ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (mã quá 24 giờ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_email_verification (customer_account_id, email, token_hash, expires_at)
    VALUES (a, 'test.xacnhan@gmail.com', '\x0102'::bytea, now() + interval '1 hour');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối mã xác nhận không phải băm 32 byte';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (mã không phải băm 32 byte): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_email_verification (customer_account_id, email, token_hash, expires_at)
    VALUES (a, 'Test.XacNhan@gmail.com', sha256('test-i035-ma-hoa'), now() + interval '1 hour');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối mã xác nhận mang Gmail có chữ hoa';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (mã mang Gmail chữ hoa): %', SQLERRM;
  END;
  BEGIN
    UPDATE customer_email_verification SET token_hash = sha256('test-i035-doi-ma') WHERE id = v;
    RAISE EXCEPTION 'I-035: vai ghi sửa được băm của mã xác nhận';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-035 bị từ chối (vai ghi sửa băm mã): %', SQLERRM;
  END;

  -- Khách tự xác nhận: dùng mã, chuyển Gmail chờ sang `email` — vết ghi với người sửa rỗng phải được nhận.
  UPDATE customer_email_verification SET used_at = now() WHERE id = v;
  UPDATE customer_account SET email = pending_email, pending_email = NULL WHERE id = a;
  RAISE NOTICE 'I-035 dương: khách tự xác nhận, Gmail chờ thành Gmail đăng nhập';
  BEGIN
    UPDATE customer_email_verification SET used_at = now() WHERE id = v;
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối dùng lại mã xác nhận đã dùng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (mã xác nhận dùng lần hai): %', SQLERRM;
  END;

  -- Kẻ gõ nhầm xác nhận sau chủ thật ⇒ trùng `email` đã xác nhận ⇒ từ chối.
  BEGIN
    UPDATE customer_account SET email = pending_email, pending_email = NULL WHERE id = b;
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối hai tài khoản khách cùng một Gmail đã xác nhận';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (xác nhận Gmail đã thuộc tài khoản khác): %', SQLERRM;
  END;
  RESET ROLE;

  -- Vết của lần khách tự sửa: có bản ghi cho cả hai bảng, người sửa rỗng.
  SELECT count(*) INTO n FROM record_revision
  WHERE person_id IS NULL AND target_table_code IN ('customer_account', 'customer_email_verification')
    AND reason = 'test-i035_email_verification';
  IF n < 2 THEN
    RAISE EXCEPTION 'I-035: lần khách tự xác nhận không để lại đủ vết (% dòng)', n;
  END IF;
  RAISE NOTICE 'I-035 dương: lần tự xác nhận để lại vết, người sửa rỗng';

  -- Kiểm ngược: bảng mã xác nhận chỉ trỏ tới tài khoản khách.
  SELECT count(*) INTO n
  FROM information_schema.referential_constraints rc
  JOIN information_schema.table_constraints src ON src.constraint_name = rc.constraint_name AND src.constraint_schema = rc.constraint_schema
  JOIN information_schema.table_constraints dst ON dst.constraint_name = rc.unique_constraint_name AND dst.constraint_schema = rc.unique_constraint_schema
  WHERE src.table_schema = 'shop' AND src.table_name = 'customer_email_verification'
    AND dst.table_name <> 'customer_account';
  IF n <> 0 THEN
    RAISE EXCEPTION 'I-035: % khoá ngoại từ customer_email_verification trỏ ra ngoài tài khoản khách', n;
  END IF;
  RAISE NOTICE 'I-035 kiểm ngược: mã xác nhận chỉ trỏ tới tài khoản khách';
END $$;
