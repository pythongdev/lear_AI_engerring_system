-- I-033 (tầng 1) và YC-38: mỗi tài khoản gắn NHIỀU NHẤT MỘT người, chỉ dùng được sau khi chủ quán DUYỆT;
-- mật khẩu chỉ tồn tại dạng BĂM argon2id, mỗi lần đặt là một bản mới; mã phiên và mã đặt lại chỉ tồn
-- tại dạng băm 32 byte, có hạn; phiên đã kết thúc không mở lại; mã đặt lại dùng một lần; đăng nhập ở
-- quầy gắn đúng một khoảng trực của chính người ấy; tài khoản không xoá cứng, đổi trạng thái có vết.
-- Vế số lần sai và số thư một giờ là tầng 3 — database KHÔNG xét (docs/decisions.md ADR-109).
-- Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-033.
-- Lát: 19-luoc-do-tai-khoan.md. Viết trước khi có lược đồ (P2A-14, Claude Code): đỏ cho tới khi lát dựng.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i033_account_session_and_reset', true); END $$;
DO $$
DECLARE chu bigint; a bigint; b bigint; acc_chu bigint; acc_a bigint; acc_b bigint; acc_x bigint;
        duty_a bigint; duty_b bigint; s1 bigint; s2 bigint; rs bigint; r record; snap text; snap2 text;
        h text := '$argon2id$v=19$m=65536,t=3,p=4$c2FsdHNhbHRzYWx0$aGFzaGhhc2hoYXNoaGFzaGhhc2hoYXNoaGFzaA';
        tok1 bytea := sha256('test-token-1'); tok2 bytea := sha256('test-token-2'); tok3 bytea := sha256('test-token-3');
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người tráng bánh') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-người gấp bánh') RETURNING id INTO b;

  -- Chụp số dòng mọi bảng khác: tài khoản, phiên và mã đặt lại không được làm đổi bảng nào của bán hàng hay tiền.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('account', 'account_password', 'login_session', 'password_reset',
                             'counter_duty', 'record_revision', 'person');

  -- Khởi tạo chủ quán đầu tiên (ADR-109 điểm 10): tài khoản hoạt động, chính chủ quán là người duyệt.
  INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
  VALUES ('test.chu', 'test.chu@gmail.com', 'test-chủ quán', 'hoat_dong', chu, 'owner', now(), chu) RETURNING id INTO acc_chu;

  -- Kịch bản dương: tự đăng ký (chưa gắn người), đặt mật khẩu, chủ quán duyệt và gán vai. Chạy bằng vai ghi.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO account (username, email, requested_display_name)
    VALUES ('test.trang', 'test.trang@gmail.com', 'test-người tráng bánh') RETURNING id INTO acc_a;
    INSERT INTO account_password (account_id, password_hash) VALUES (acc_a, h);
    PERFORM set_config('shop.actor_person_id', chu::text, true);
    PERFORM set_config('shop.revision_reason', 'test-chủ quán duyệt', true);
    UPDATE account SET status = 'hoat_dong', person_id = a, role_code = 'trang_banh',
                       decided_at = now(), decided_by_person_id = chu WHERE id = acc_a;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-033: vai shop_app KHÔNG đăng ký, đặt mật khẩu hoặc duyệt được một tài khoản: %', SQLERRM;
  END;
  PERFORM set_config('shop.revision_reason', 'test-i033_account_session_and_reset', true);
  SELECT x.status, x.role_code, p.display_name AS nguoi, d.display_name AS nguoi_duyet, x.decided_at IS NOT NULL AS co_luc_duyet
  INTO r FROM account x JOIN person p ON p.id = x.person_id JOIN person d ON d.id = x.decided_by_person_id WHERE x.id = acc_a;
  IF r.status IS DISTINCT FROM 'hoat_dong' OR r.role_code IS DISTINCT FROM 'trang_banh' OR r.nguoi IS DISTINCT FROM 'test-người tráng bánh'
     OR r.nguoi_duyet IS DISTINCT FROM 'test-chủ quán' OR NOT r.co_luc_duyet THEN
    RAISE EXCEPTION 'I-033: tài khoản đã duyệt không đọc lại được người · vai · ai duyệt · lúc duyệt';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'account' AND target_row = acc_a
                 AND person_id = chu AND reason = 'test-chủ quán duyệt' AND before_image ->> 'status' = 'cho_duyet'
                 AND after_image ->> 'status' = 'hoat_dong') THEN
    RAISE EXCEPTION 'I-033: duyệt tài khoản không để lại vết bản trước · bản sau · lý do · người sửa';
  END IF;
  RAISE NOTICE 'YC-38 tài khoản — % (%), vai %, % duyệt (có lúc: %), đổi trạng thái có vết',
    r.nguoi, r.status, r.role_code, r.nguoi_duyet, r.co_luc_duyet;

  -- Tầng 1: hình của từng trạng thái.
  BEGIN
    INSERT INTO account (username, email, requested_display_name, person_id) VALUES ('test.x1', 'test.x1@gmail.com', 'test-x', b);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một tài khoản chờ duyệt đã gắn người';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (chờ duyệt mà đã gắn người): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status, person_id, decided_at, decided_by_person_id)
    VALUES ('test.x2', 'test.x2@gmail.com', 'test-x', 'hoat_dong', b, now(), chu);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một tài khoản hoạt động không có vai';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (hoạt động mà không có vai): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status, person_id, role_code)
    VALUES ('test.x3', 'test.x3@gmail.com', 'test-x', 'hoat_dong', b, 'gap_banh');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một tài khoản hoạt động không có người duyệt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (hoạt động mà không có người duyệt): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status, role_code, decided_at, decided_by_person_id)
    VALUES ('test.x4', 'test.x4@gmail.com', 'test-x', 'khoa', 'gap_banh', now(), chu);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một tài khoản khoá không gắn người';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (khoá mà không gắn người): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status) VALUES ('test.x5', 'test.x5@gmail.com', 'test-x', 'tu_choi');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một lần từ chối không có người quyết';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (từ chối mà không có người quyết): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status) VALUES ('test.x6', 'test.x6@gmail.com', 'test-x', 'tam_nghi');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một trạng thái ngoài bốn trạng thái';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (trạng thái lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
    VALUES ('test.x7', 'test.x7@gmail.com', 'test-x', 'hoat_dong', b, 'giam_doc', now(), chu);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một vai ngoài bốn vai của shop-facts §3';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (vai lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
    VALUES ('test.x8', 'test.x8@gmail.com', 'test-x', 'hoat_dong', 999999999, 'gap_banh', now(), chu);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một tài khoản gắn người không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (gắn người lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
    VALUES ('test.x9', 'test.x9@gmail.com', 'test-x', 'hoat_dong', a, 'gap_banh', now(), chu);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối tài khoản thứ hai của cùng một người';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (một người hai tài khoản): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name) VALUES ('test.y1', 'test.y1@gmail.com', '   ');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối tên hiển thị chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (tên hiển thị trắng): %', SQLERRM;
  END;

  -- Tầng 1: tên đăng nhập và Gmail đứng một lần, không phân biệt hoa thường — cất chữ thường, khoá duy nhất.
  BEGIN
    INSERT INTO account (username, email, requested_display_name) VALUES ('test.trang', 'khac@gmail.com', 'test-x');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối tên đăng nhập trùng';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (tên đăng nhập trùng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name) VALUES ('Test.Trang', 'khac2@gmail.com', 'test-x');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối tên đăng nhập có chữ hoa — trùng khác hoa thường lọt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (tên đăng nhập không phải chữ thường): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name) VALUES ('test.y2', 'test.trang@gmail.com', 'test-x');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối Gmail trùng';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (Gmail trùng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name) VALUES ('test.y3', 'Test.Trang@Gmail.com', 'test-x');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối Gmail có chữ hoa — trùng khác hoa thường lọt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (Gmail không phải chữ thường): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account (username, email, requested_display_name) VALUES ('test.y4', 'khong-phai-thu', 'test-x');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một địa chỉ thư không có @';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (địa chỉ thư sai dạng): %', SQLERRM;
  END;

  -- Tầng 1: mật khẩu chỉ dạng băm argon2id; mỗi lần đặt là bản mới, không sửa, không xoá.
  BEGIN
    INSERT INTO account_password (account_id, password_hash) VALUES (acc_a, 'matkhau123');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một mật khẩu thô';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mật khẩu thô): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account_password (account_id, password_hash) VALUES (acc_a, '$2a$10$abcdefghijklmnopqrstuv');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một băm không phải argon2id';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (băm không phải argon2id): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account_password (account_id, password_hash) VALUES (999999999, h);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối mật khẩu của một tài khoản không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mật khẩu của tài khoản lạ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO account_password (account_id, password_hash, must_change_password) VALUES (acc_a, h, true);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối mật khẩu tạm không mang tên người đặt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mật khẩu tạm không có người đặt): %', SQLERRM;
  END;
  -- Kịch bản đổi mật khẩu: chủ quán đặt mật khẩu tạm ⇒ hai bản còn, bản mới nhất là hiện hành, buộc đổi.
  INSERT INTO account_password (account_id, password_hash, set_by_person_id, must_change_password)
  VALUES (acc_a, h || 'x', chu, true);
  SELECT COUNT(*) AS so_ban,
         (SELECT must_change_password FROM account_password WHERE account_id = acc_a ORDER BY created_at DESC, id DESC LIMIT 1) AS buoc_doi
  INTO r FROM account_password WHERE account_id = acc_a;
  IF r.so_ban <> 2 OR r.buoc_doi IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'I-033: đặt lại mật khẩu không để lại hai bản, hoặc bản mới nhất không buộc đổi';
  END IF;
  RAISE NOTICE 'I-033 mật khẩu — % bản còn, bản hiện hành buộc đổi: %', r.so_ban, r.buoc_doi;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE account_password SET password_hash = h WHERE account_id = acc_a;
    RESET ROLE;
    RAISE EXCEPTION 'I-033: vai shop_app SỬA ĐƯỢC một bản mật khẩu — bản cũ bị đè';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-033 bị từ chối (sửa một bản mật khẩu): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM account_password WHERE account_id = acc_a;
    RESET ROLE;
    RAISE EXCEPTION 'I-033: vai shop_app XOÁ ĐƯỢC một bản mật khẩu';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-033 bị từ chối (xoá một bản mật khẩu): %', SQLERRM;
  END;
  -- Không cột nào ngoài account_password.password_hash mang chữ "password" hay "mat_khau" (đọc lược đồ).
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
             AND (column_name LIKE '%password%' OR column_name LIKE '%mat_khau%')
             AND NOT (table_name = 'account_password' AND column_name IN ('password_hash', 'must_change_password'))) THEN
    RAISE EXCEPTION 'I-033: một cột ngoài bảng mật khẩu cất mật khẩu';
  END IF;

  -- Tầng 1: phiên đăng nhập — mã là băm 32 byte, hạn nhiều nhất 7 ngày, chỉ tài khoản hoạt động mở được.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', a::text, true);
    INSERT INTO login_session (account_id, token_hash, expires_at) VALUES (acc_a, tok1, now() + interval '7 days') RETURNING id INTO s1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-033: vai shop_app KHÔNG mở được một phiên: %', SQLERRM;
  END;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at) VALUES (acc_a, convert_to('test-token-tho', 'UTF8'), now() + interval '1 day');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một mã phiên không phải băm 32 byte';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mã phiên không phải băm 32 byte): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at) VALUES (acc_a, tok1, now() + interval '1 day');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối hai phiên cùng một mã';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (hai phiên cùng mã): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at) VALUES (acc_a, tok2, now() + interval '8 days');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một phiên sống quá 7 ngày';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (phiên quá 7 ngày): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at) VALUES (acc_a, tok2, now());
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một phiên hết hạn ngay lúc mở';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (phiên hết hạn ngay lúc mở): %', SQLERRM;
  END;
  INSERT INTO account (username, email, requested_display_name) VALUES ('test.cho', 'test.cho@gmail.com', 'test-người chờ') RETURNING id INTO acc_x;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at) VALUES (acc_x, tok2, now() + interval '1 day');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một phiên của tài khoản chờ duyệt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (phiên của tài khoản chưa duyệt): %', SQLERRM;
  END;

  -- Kết thúc phiên: kèm lý do, một lần; phiên đã kết thúc không mở lại; không xoá.
  BEGIN
    UPDATE login_session SET ended_at = now() WHERE id = s1;
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối kết thúc phiên mà không có lý do';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (kết thúc phiên không lý do): %', SQLERRM;
  END;
  BEGIN
    UPDATE login_session SET ended_at = now(), end_reason = 'chan_qua' WHERE id = s1;
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một lý do kết thúc lạ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (lý do kết thúc lạ): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE login_session SET ended_at = now(), end_reason = 'dang_xuat' WHERE id = s1;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-033: vai shop_app KHÔNG kết thúc được một phiên: %', SQLERRM;
  END;
  BEGIN
    UPDATE login_session SET ended_at = NULL, end_reason = NULL WHERE id = s1;
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối mở lại một phiên đã kết thúc';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mở lại phiên đã kết thúc): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE login_session SET expires_at = now() + interval '1 day' WHERE id = s1;
    RESET ROLE;
    RAISE EXCEPTION 'I-033: vai shop_app ĐỔI ĐƯỢC hạn của một phiên';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-033 bị từ chối (đổi hạn phiên): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM login_session WHERE id = s1;
    RESET ROLE;
    RAISE EXCEPTION 'I-033: vai shop_app XOÁ ĐƯỢC một phiên';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-033 bị từ chối (xoá một phiên): %', SQLERRM;
  END;
  SELECT end_reason, ended_at IS NOT NULL AS co_luc INTO r FROM login_session WHERE id = s1;
  RAISE NOTICE 'YC-38 phiên — kết thúc vì %, có lúc: %', r.end_reason, r.co_luc;

  -- Đăng nhập ở quầy: phiên gắn đúng một khoảng trực của chính người ấy. Khoảng đặt xa trong tương lai
  -- để không đụng trực quầy của dữ liệu mồi (khoảng không chồng nhau, YC-15).
  INSERT INTO counter_duty (person_id, started_at, ended_at)
  VALUES (a, now() + interval '100 years', now() + interval '100 years 1 hour') RETURNING id INTO duty_a;
  INSERT INTO counter_duty (person_id, started_at, ended_at)
  VALUES (b, now() + interval '100 years 2 hours', now() + interval '100 years 3 hours') RETURNING id INTO duty_b;
  INSERT INTO login_session (account_id, token_hash, expires_at, counter_duty_id)
  VALUES (acc_a, tok2, now() + interval '7 days', duty_a) RETURNING id INTO s2;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at, counter_duty_id) VALUES (acc_a, tok3, now() + interval '1 day', duty_a);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối hai phiên cùng một khoảng trực';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (hai phiên một khoảng trực): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at, counter_duty_id) VALUES (acc_a, tok3, now() + interval '1 day', duty_b);
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối phiên gắn khoảng trực của người khác';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (phiên gắn trực quầy của người khác): %', SQLERRM;
  END;
  SELECT p.display_name AS nguoi_truc INTO r FROM login_session s JOIN counter_duty d ON d.id = s.counter_duty_id
  JOIN person p ON p.id = d.person_id WHERE s.id = s2;
  IF r.nguoi_truc IS DISTINCT FROM 'test-người tráng bánh' THEN
    RAISE EXCEPTION 'I-033: phiên đăng nhập ở quầy không đọc ra khoảng trực của chính người ấy';
  END IF;
  RAISE NOTICE 'YC-38 đăng nhập ở quầy — phiên gắn khoảng trực của %', r.nguoi_truc;

  -- Mã đặt lại: băm 32 byte, hạn nhiều nhất 30 phút, dùng một lần, trong hạn.
  BEGIN
    INSERT INTO password_reset (account_id, token_hash, expires_at) VALUES (acc_a, sha256('test-reset-1'), now() + interval '31 minutes');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một mã đặt lại sống quá 30 phút';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mã đặt lại quá 30 phút): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO password_reset (account_id, token_hash, expires_at) VALUES (acc_a, convert_to('ma-tho', 'UTF8'), now() + interval '30 minutes');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một mã đặt lại không phải băm 32 byte';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mã đặt lại không phải băm): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO password_reset (account_id, token_hash, expires_at) VALUES (acc_a, sha256('test-reset-1'), now() + interval '30 minutes') RETURNING id INTO rs;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-033: vai shop_app KHÔNG cấp được một mã đặt lại: %', SQLERRM;
  END;
  BEGIN
    UPDATE password_reset SET used_at = now() + interval '31 minutes' WHERE id = rs;
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối dùng một mã đặt lại sau hạn';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (dùng mã đặt lại sau hạn): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE password_reset SET used_at = now() WHERE id = rs;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-033: vai shop_app KHÔNG dùng được một mã đặt lại: %', SQLERRM;
  END;
  BEGIN
    UPDATE password_reset SET used_at = now() + interval '1 minute' WHERE id = rs;
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối dùng một mã đặt lại lần thứ hai';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (mã đặt lại dùng hai lần): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM password_reset WHERE id = rs;
    RESET ROLE;
    RAISE EXCEPTION 'I-033: vai shop_app XOÁ ĐƯỢC một mã đặt lại';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-033 bị từ chối (xoá một mã đặt lại): %', SQLERRM;
  END;

  -- Khoá: đổi trạng thái có vết; tài khoản khoá không mở được phiên; không xoá cứng tài khoản.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.actor_person_id', chu::text, true);
    PERFORM set_config('shop.revision_reason', 'test-người nghỉ việc', true);
    UPDATE account SET status = 'khoa' WHERE id = acc_a;
    UPDATE login_session SET ended_at = now(), end_reason = 'khoa_tai_khoan' WHERE id = s2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-033: vai shop_app KHÔNG khoá được một tài khoản: %', SQLERRM;
  END;
  PERFORM set_config('shop.revision_reason', 'test-i033_account_session_and_reset', true);
  IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'account' AND target_row = acc_a
                 AND person_id = chu AND reason = 'test-người nghỉ việc' AND after_image ->> 'status' = 'khoa') THEN
    RAISE EXCEPTION 'I-033: khoá tài khoản không để lại vết người khoá · lý do';
  END IF;
  BEGIN
    INSERT INTO login_session (account_id, token_hash, expires_at) VALUES (acc_a, tok3, now() + interval '1 day');
    RAISE EXCEPTION 'I-033: database KHÔNG từ chối một phiên của tài khoản đã khoá';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-033 bị từ chối (phiên của tài khoản đã khoá): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE account SET username = 'test.doi' WHERE id = acc_a;
    RESET ROLE;
    RAISE EXCEPTION 'I-033: vai shop_app ĐỔI ĐƯỢC tên đăng nhập — lời không nói có đường ấy';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-033 bị từ chối (đổi tên đăng nhập): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM account WHERE id = acc_x;
    RESET ROLE;
    RAISE EXCEPTION 'I-033: vai shop_app XOÁ CỨNG được một tài khoản';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-033 bị từ chối (xoá cứng một tài khoản): %', SQLERRM;
  END;

  -- Từ chối một lần đăng ký: có người quyết và lúc, vẫn không gắn người.
  PERFORM set_config('shop.revision_reason', 'test-không nhận', true);
  UPDATE account SET status = 'tu_choi', decided_at = now(), decided_by_person_id = chu WHERE id = acc_x;
  PERFORM set_config('shop.revision_reason', 'test-i033_account_session_and_reset', true);
  RAISE NOTICE 'YC-38 từ chối — tài khoản % ở trạng thái %, không gắn người: %',
    (SELECT username FROM account WHERE id = acc_x), (SELECT status FROM account WHERE id = acc_x),
    (SELECT person_id IS NULL FROM account WHERE id = acc_x);

  -- Không bảng nào ngoài lát này đổi số dòng.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('account', 'account_password', 'login_session', 'password_reset',
                             'counter_duty', 'record_revision', 'person');
  IF snap IS DISTINCT FROM snap2 THEN
    RAISE EXCEPTION 'I-033: tài khoản, phiên hay mã đặt lại làm đổi số dòng của một bảng khác';
  END IF;
  RAISE NOTICE 'I-033 không chạm bảng khác — số dòng mọi bảng ngoài lát giữ nguyên';
END $$;
