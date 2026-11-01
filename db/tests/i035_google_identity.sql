-- I-035 (tầng 1), phần Google (ADR-132): tài khoản khách tạo bằng Google mang thư, không mật khẩu; mỗi `sub` Google nối
-- đúng một tài khoản khách, mỗi tài khoản khách nối nhiều nhất một `sub`; dòng nối chỉ thêm, không trỏ tới người của quán.
-- Viết trước lược đồ (T-267, Claude Code): đỏ cho tới khi migration `customer_google_identity` dựng.

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i035_google_identity', true); END $$;
DO $$
DECLARE k1 bigint; k2 bigint; n int;
BEGIN
  SET LOCAL ROLE shop_app;

  -- Dương: khách tạo bằng Google — chỉ thư, không dòng mật khẩu — rồi nối `sub` và mở phiên bằng vai ghi.
  INSERT INTO customer_account (email, display_name) VALUES ('test.google.mot@gmail.com', 'test-khách Google một') RETURNING id INTO k1;
  INSERT INTO customer_google_identity (customer_account_id, google_sub_code) VALUES (k1, '110000000000000000001');
  INSERT INTO customer_session (customer_account_id, token_hash, expires_at)
  VALUES (k1, sha256('test-i035-google-phien-1'), now() + interval '7 days');
  RAISE NOTICE 'I-035 dương: khách tạo bằng Google, không mật khẩu, nối sub và mở phiên';

  INSERT INTO customer_account (email, display_name) VALUES ('test.google.hai@gmail.com', 'test-khách Google hai') RETURNING id INTO k2;

  BEGIN
    INSERT INTO customer_google_identity (customer_account_id, google_sub_code) VALUES (k2, '110000000000000000001');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối một sub Google nối hai tài khoản khách';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (một sub hai tài khoản): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_google_identity (customer_account_id, google_sub_code) VALUES (k1, '110000000000000000002');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối một tài khoản khách nối hai sub Google';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (một tài khoản hai sub): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_google_identity (customer_account_id, google_sub_code) VALUES (k2, '   ');
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối sub Google rỗng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (sub rỗng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO customer_google_identity (customer_account_id, google_sub_code) VALUES (k2, repeat('1', 256));
    RAISE EXCEPTION 'I-035: database KHÔNG từ chối sub Google dài quá 255 ký tự';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-035 bị từ chối (sub quá dài): %', SQLERRM;
  END;
  BEGIN
    UPDATE customer_google_identity SET google_sub_code = '110000000000000000003' WHERE customer_account_id = k1;
    RAISE EXCEPTION 'I-035: vai ghi sửa được dòng nối Google';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-035 bị từ chối (vai ghi UPDATE dòng nối): %', SQLERRM;
  END;
  BEGIN
    UPDATE customer_google_identity SET customer_account_id = k2 WHERE customer_account_id = k1;
    RAISE EXCEPTION 'I-035: vai ghi chuyển được dòng nối Google sang tài khoản khác';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-035 bị từ chối (vai ghi chuyển dòng nối): %', SQLERRM;
  END;
  RESET ROLE;

  -- Kiểm ngược: bảng nối chỉ trỏ tới tài khoản khách.
  SELECT count(*) INTO n
  FROM information_schema.referential_constraints rc
  JOIN information_schema.table_constraints src ON src.constraint_name = rc.constraint_name AND src.constraint_schema = rc.constraint_schema
  JOIN information_schema.table_constraints dst ON dst.constraint_name = rc.unique_constraint_name AND dst.constraint_schema = rc.unique_constraint_schema
  WHERE src.table_schema = 'shop' AND src.table_name = 'customer_google_identity'
    AND dst.table_name <> 'customer_account';
  IF n <> 0 THEN
    RAISE EXCEPTION 'I-035: % khoá ngoại từ customer_google_identity trỏ ra ngoài tài khoản khách', n;
  END IF;
  RAISE NOTICE 'I-035 kiểm ngược: dòng nối Google chỉ trỏ tới tài khoản khách';
END $$;
