-- I-035 (tầng 1): tài khoản mang SỐ ĐIỆN THOẠI hoặc GMAIL, mỗi thứ đứng một lần trong một loại, ở dạng đã chuẩn hoá;
-- tài khoản KHÁCH không bao giờ là người của quán; một đơn gắn tài khoản khách chỉ khi là đơn web.
-- Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-035.
-- Lát: 23-luoc-do-tai-khoan-khach.md. Viết trước khi có lược đồ (T-262, Claude Code): đỏ cho tới khi T-263 dựng.

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i035_customer_account_apart_from_staff', true); END $$;
DO $$
DECLARE chu bigint; acc_sdt bigint; k1 bigint; o1 bigint; n int;
        h text := '$argon2id$v=19$m=65536,t=3,p=4$c2FsdHNhbHRzYWx0$aGFzaGhhc2hoYXNoaGFzaGhhc2hoYXNoaGFzaA';
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán i035', true) RETURNING id INTO chu;

  -- Người làm: chỉ có số điện thoại, không tên đăng nhập, không Gmail ⇒ được (ADR-131 điểm 2).
  INSERT INTO account (phone, requested_display_name) VALUES ('0912345678', 'test-người chỉ có số') RETURNING id INTO acc_sdt;
  RAISE NOTICE 'I-035 dương: tài khoản người làm chỉ có số điện thoại';

  BEGIN
    INSERT INTO account (requested_display_name) VALUES ('test-không liên hệ');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối tài khoản người làm không số không thư';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (người làm không số không thư): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (phone, requested_display_name) VALUES ('+84912345679', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối số chưa chuẩn hoá (+84)';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (số mang +84): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (phone, requested_display_name) VALUES ('912345679', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối số thiếu 0 đầu';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (số thiếu 0 đầu): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (phone, requested_display_name) VALUES ('0912 345 679', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối số có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (số có khoảng trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (phone, requested_display_name) VALUES ('09123', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối số quá ngắn';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (số quá ngắn): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (phone, requested_display_name) VALUES ('0912345678', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối hai người làm cùng số';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (người làm trùng số): %', SQLERRM;
  END;

  -- Khách: tự đăng ký bằng vai ghi, chỉ bằng số, CÙNG số với tài khoản người làm ⇒ được (hai loại tách nhau).
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO customer_account (phone, display_name) VALUES ('0912345678', 'test-khách một') RETURNING id INTO k1;
    INSERT INTO customer_password (customer_account_id, password_hash) VALUES (k1, h);
    INSERT INTO customer_session (customer_account_id, token_hash, expires_at)
    VALUES (k1, sha256('test-i035-phien-1'), now() + interval '7 days');
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-035: vai shop_app KHÔNG đăng ký, đặt mật khẩu hoặc mở phiên cho khách được: %', SQLERRM;
  END;
  RAISE NOTICE 'I-035 dương: khách đăng ký chỉ bằng số, trùng số một người làm, mở được phiên';

  BEGIN
    INSERT INTO customer_account (display_name) VALUES ('test-khách không liên hệ');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối khách không số không thư';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (khách không số không thư): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_account (phone, display_name) VALUES ('0912345678', 'test-khách hai');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối hai khách cùng số';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (khách trùng số): %', SQLERRM;
  END;
  INSERT INTO customer_account (email, display_name) VALUES ('test.khach@gmail.com', 'test-khách thư');
  BEGIN
    INSERT INTO customer_account (email, display_name) VALUES ('test.khach@gmail.com', 'test-khách thư hai');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối hai khách cùng Gmail';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (khách trùng Gmail): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_account (email, display_name) VALUES ('Test.Khach2@Gmail.com', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối Gmail khách có chữ hoa';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (Gmail khách có chữ hoa): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_account (phone, display_name) VALUES ('+84987654321', 'test-x');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối số khách chưa chuẩn hoá';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (số khách mang +84): %', SQLERRM;
  END;

  -- Cất băm và có hạn như I-033.
  BEGIN
    INSERT INTO customer_password (customer_account_id, password_hash) VALUES (k1, 'mat-khau-tho');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối mật khẩu khách không phải argon2id';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (mật khẩu khách thô): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_session (customer_account_id, token_hash, expires_at)
    VALUES (k1, '\x00'::bytea, now() + interval '1 day');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối mã phiên khách không phải băm 32 byte';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (mã phiên khách không phải băm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_session (customer_account_id, token_hash, expires_at)
    VALUES (k1, sha256('test-i035-phien-2'), now() + interval '8 days');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối phiên khách sống quá 7 ngày';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (phiên khách quá 7 ngày): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_password_reset (customer_account_id, token_hash, expires_at)
    VALUES (k1, sha256('test-i035-dat-lai'), now() + interval '31 minutes');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối mã đặt lại khách sống quá 30 phút';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (mã đặt lại khách quá 30 phút): %', SQLERRM;
  END;

  -- Kiểm ngược: không khoá ngoại nào từ bảng khách tới người của quán hay trực quầy.
  SELECT count(*) INTO n
  FROM information_schema.referential_constraints rc
  JOIN information_schema.table_constraints src ON src.constraint_name = rc.constraint_name AND src.constraint_schema = rc.constraint_schema
  JOIN information_schema.table_constraints dst ON dst.constraint_name = rc.unique_constraint_name AND dst.constraint_schema = rc.unique_constraint_schema
  WHERE src.table_schema = 'shop' AND src.table_name LIKE 'customer\_%'
    AND dst.table_name IN ('person', 'counter_duty', 'account');
  IF n <> 0 THEN
    RAISE EXCEPTION 'I-035: % khoá ngoại từ bảng khách trỏ tới người của quán, trực quầy hay tài khoản người làm', n;
  END IF;
  RAISE NOTICE 'I-035 kiểm ngược: bảng khách không trỏ tới người của quán';

  -- Đơn web mang tài khoản khách ⇒ được; kênh khác ⇒ từ chối.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code, customer_account_id)
  VALUES ('pickup', 'new', 'shop_pickup', '0912345678', now(), gen_random_uuid()::text, k1) RETURNING id INTO o1;
  RAISE NOTICE 'I-035 dương: đơn đến lấy mang tài khoản khách';
  BEGIN
    INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code, customer_account_id)
    VALUES ('phone_preorder', 'confirmed', 'shop_pickup', '0912345678', now(), gen_random_uuid()::text, k1);
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối đơn đặt trước qua điện thoại mang tài khoản khách';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (đơn kênh không phải web mang tài khoản khách): %', SQLERRM;
  END;
END $$;
