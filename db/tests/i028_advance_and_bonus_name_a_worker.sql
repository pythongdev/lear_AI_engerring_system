-- I-028 (tầng 1 · tầng 3) và YC-31 · YC-32: mỗi khoản tạm ứng và mỗi khoản thưởng lễ Tết đọc ra
-- được CỦA AI · BAO NHIÊU · LÚC NÀO · AI GHI; một khoản tạm ứng không tồn tại được khi không có
-- người duyệt; sửa số tiền, người nhận hay ngày là một lần cập nhật có vết (I-018); hai loại khoản
-- này không phải tiền bán hàng và CHƯA nối vào két (task T-125 ở work/backlog.md). Vế "người duyệt
-- là chủ quán" là tầng 3 — database KHÔNG xét, test nói thẳng. Chế độ NGHIÊM của vết từ bước 20
-- (T-138, ADR-092) áp cả ở đây: sửa không khai lý do bị từ chối.
-- Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-028.
-- Lát: 14-luoc-do-khoan-cua-nguoi.md. Thiết kế: docs/decisions.md ADR-073.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i028_advance_and_bonus_name_a_worker', true); END $$;
DO $$
DECLARE chu bigint; a bigint; b bigint; u1 bigint; t1 bigint; n bigint; snap text; snap_sau text;
        cols text; r record;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người tráng bánh') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-người gấp bánh') RETURNING id INTO b;

  -- Chụp số dòng của MỌI bảng khác trước khi ghi khoản nào, để cuối file so lại: ghi, sửa một
  -- khoản tạm ứng hay thưởng không được làm đổi bảng nào của bán hàng, tiền hay két.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('staff_advance', 'holiday_bonus', 'record_revision', 'person');

  -- Kịch bản dương: chủ quán duyệt tạm ứng 500.000đ cho một người, ngày 2026-09-21. Người ghi
  -- lấy từ người thao tác của giao dịch; người duyệt là một dấu RIÊNG, phải khai, không mặc định.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
  VALUES (a, 500000, '2026-09-21', chu) RETURNING id INTO u1;
  FOR r IN
    SELECT w.display_name AS nguoi, s.amount_vnd, s.paid_date, d.display_name AS nguoi_duyet,
           g.display_name AS nguoi_ghi, s.created_at IS NOT NULL AS co_luc_ghi
    FROM staff_advance s JOIN person w ON w.id = s.worker_person_id
    JOIN person d ON d.id = s.approver_person_id JOIN person g ON g.id = s.person_id ORDER BY s.id
  LOOP
    RAISE NOTICE 'YC-31 tạm ứng — của %, % đồng, ngày %: % duyệt, % ghi, có lúc ghi: %',
      r.nguoi, r.amount_vnd, r.paid_date, r.nguoi_duyet, r.nguoi_ghi, r.co_luc_ghi;
  END LOOP;
  IF NOT EXISTS (SELECT 1 FROM staff_advance WHERE id = u1 AND worker_person_id = a
                   AND amount_vnd = 500000 AND paid_date = '2026-09-21'
                   AND approver_person_id = chu AND person_id = chu AND created_at IS NOT NULL) THEN
    RAISE EXCEPTION 'I-028: khoản tạm ứng không đọc lại được đúng của ai · bao nhiêu · lúc nào · ai duyệt · ai ghi';
  END IF;

  -- Thưởng lễ Tết: hai người, cùng ngày. Không có người duyệt — mệnh đề không nói ai duyệt thưởng.
  INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date) VALUES (a, 300000, '2026-09-25')
  RETURNING id INTO t1;
  INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date) VALUES (b, 200000, '2026-09-25');
  FOR r IN
    SELECT w.display_name AS nguoi, h.amount_vnd, h.paid_date, g.display_name AS nguoi_ghi,
           h.created_at IS NOT NULL AS co_luc_ghi
    FROM holiday_bonus h JOIN person w ON w.id = h.worker_person_id
    JOIN person g ON g.id = h.person_id ORDER BY h.id
  LOOP
    RAISE NOTICE 'YC-32 thưởng lễ Tết — của %, % đồng, ngày %: % ghi, có lúc ghi: %',
      r.nguoi, r.amount_vnd, r.paid_date, r.nguoi_ghi, r.co_luc_ghi;
  END LOOP;
  IF (SELECT COUNT(*) FROM holiday_bonus WHERE person_id = chu AND created_at IS NOT NULL) <> 2
     OR (SELECT amount_vnd FROM holiday_bonus WHERE worker_person_id = b) <> 200000 THEN
    RAISE EXCEPTION 'I-028: khoản thưởng không đọc lại được đúng của ai · bao nhiêu · lúc nào · ai ghi';
  END IF;

  -- Ngày của khoản và lúc ghi là hai thứ đọc riêng (cùng hình YC-08 · YC-28): một khoản cho ngày
  -- đã qua được nhận. Và mệnh đề không giới hạn số khoản của một người trong một ngày: khoản tạm
  -- ứng thứ hai cùng người, cùng ngày là một lần đưa tiền khác, được nhận.
  INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
  VALUES (a, 100000, '2026-09-21', chu);
  INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
  VALUES (b, 150000, '2026-09-01', chu);
  RAISE NOTICE 'I-028 khoản thứ hai cùng người cùng ngày — nhận: test-người tráng bánh có % khoản tạm ứng ngày 2026-09-21, cộng % đồng',
    (SELECT COUNT(*) FROM staff_advance WHERE worker_person_id = a AND paid_date = '2026-09-21'),
    (SELECT SUM(amount_vnd) FROM staff_advance WHERE worker_person_id = a AND paid_date = '2026-09-21');

  -- Tầng 1, tạm ứng: không người duyệt · người duyệt lạ ⇒ không tồn tại được.
  BEGIN
    INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date) VALUES (a, 50000, '2026-09-22');
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản tạm ứng không có người duyệt';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (tạm ứng không có người duyệt): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
    VALUES (a, 50000, '2026-09-22', 999999999);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối người duyệt không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (người duyệt không phải người của quán): %', SQLERRM;
  END;

  -- Tầng 1, tạm ứng: không người nhận · người nhận lạ · không số tiền · 0đ · số âm · không ngày.
  BEGIN
    INSERT INTO staff_advance (amount_vnd, paid_date, approver_person_id) VALUES (50000, '2026-09-22', chu);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản tạm ứng không có người nhận';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (tạm ứng không có người nhận): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
    VALUES (999999999, 50000, '2026-09-22', chu);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối tạm ứng cho người không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (tạm ứng — người nhận không phải người của quán): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO staff_advance (worker_person_id, paid_date, approver_person_id) VALUES (a, '2026-09-22', chu);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản tạm ứng không có số tiền';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (tạm ứng không có số tiền): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
    VALUES (a, 0, '2026-09-22', chu);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản tạm ứng 0đ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (tạm ứng 0đ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
    VALUES (a, -50000, '2026-09-22', chu);
    RAISE EXCEPTION 'QD-21: database KHÔNG từ chối một khoản tạm ứng số âm';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'QD-21 bị từ chối (tạm ứng số âm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO staff_advance (worker_person_id, amount_vnd, approver_person_id) VALUES (a, 50000, chu);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản tạm ứng không có ngày';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (tạm ứng không có ngày): %', SQLERRM;
  END;

  -- Tầng 1, thưởng: cùng sáu ca.
  BEGIN
    INSERT INTO holiday_bonus (amount_vnd, paid_date) VALUES (50000, '2026-09-25');
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản thưởng không có người nhận';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (thưởng không có người nhận): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date) VALUES (999999999, 50000, '2026-09-25');
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối thưởng cho người không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (thưởng — người nhận không phải người của quán): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO holiday_bonus (worker_person_id, paid_date) VALUES (a, '2026-09-25');
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản thưởng không có số tiền';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (thưởng không có số tiền): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date) VALUES (a, 0, '2026-09-25');
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản thưởng 0đ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (thưởng 0đ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date) VALUES (a, -50000, '2026-09-25');
    RAISE EXCEPTION 'QD-21: database KHÔNG từ chối một khoản thưởng số âm';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'QD-21 bị từ chối (thưởng số âm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO holiday_bonus (worker_person_id, amount_vnd) VALUES (a, 50000);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản thưởng không có ngày';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (thưởng không có ngày): %', SQLERRM;
  END;

  -- Tầng 1, cả hai loại: không có người ghi ⇒ không tồn tại được; người ghi lạ ⇒ từ chối.
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
    VALUES (a, 50000, '2026-09-22', chu);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản tạm ứng không có người ghi';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (tạm ứng không có người ghi): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date) VALUES (a, 50000, '2026-09-25');
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối một khoản thưởng không có người ghi';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (thưởng không có người ghi): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date, person_id)
    VALUES (a, 50000, '2026-09-25', 999999999);
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối người ghi không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-028 bị từ chối (người ghi không phải người của quán): %', SQLERRM;
  END;

  -- Tầng 3, nói thẳng: database KHÔNG xét người duyệt có phải chủ quán không — cửa ghi của pha sau
  -- xét, và tập đối chiếu "khoản tạm ứng mà người duyệt không phải chủ quán" (P2A-07) bắt.
  INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
  VALUES (b, 80000, '2026-09-22', a);
  RAISE NOTICE 'I-028 tầng 3 — tạm ứng do người KHÔNG phải chủ quán duyệt: database nhận (% khoản như thế); cửa ghi và phép đối chiếu giữ vế này',
    (SELECT COUNT(*) FROM staff_advance s JOIN person d ON d.id = s.approver_person_id WHERE NOT d.is_owner);

  -- Kịch bản sửa: đổi số tiền một khoản đã ghi, có khai lý do ⇒ đọc ra cả số cũ lẫn số mới, lý do
  -- và người sửa (I-018). Chạy bằng vai ghi của hệ thống — đường sửa của I-028 là của vai ấy.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'test-gõ nhầm số tiền', true);
    UPDATE staff_advance SET amount_vnd = 700000 WHERE id = u1;
    PERFORM set_config('shop.revision_reason', 'test-đưa vào ngày hôm sau', true);
    UPDATE holiday_bonus SET paid_date = '2026-09-26' WHERE id = t1;
    PERFORM set_config('shop.revision_reason', 'test-ghi nhầm người nhận', true);
    UPDATE holiday_bonus SET worker_person_id = b WHERE id = t1;
    PERFORM set_config('shop.revision_reason', '', true);
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-028: vai shop_app KHÔNG sửa được số tiền · ngày · người nhận của một khoản: %', SQLERRM;
  END;
  FOR r IN
    SELECT v.target_table_code, v.before_image ->> 'amount_vnd' AS tien_truoc, v.after_image ->> 'amount_vnd' AS tien_sau,
           v.before_image ->> 'paid_date' AS ngay_truoc, v.after_image ->> 'paid_date' AS ngay_sau,
           (v.before_image ->> 'worker_person_id') IS DISTINCT FROM (v.after_image ->> 'worker_person_id') AS doi_nguoi,
           v.reason, p.display_name
    FROM record_revision v JOIN person p ON p.id = v.person_id
    WHERE (v.target_table_code = 'staff_advance' AND v.target_row = u1)
       OR (v.target_table_code = 'holiday_bonus' AND v.target_row = t1) ORDER BY v.id
  LOOP
    RAISE NOTICE 'I-028 sửa khoản (%) — tiền trước %, sau %; ngày trước %, sau %; đổi người nhận: %; lý do "%", % sửa',
      r.target_table_code, r.tien_truoc, r.tien_sau, r.ngay_truoc, r.ngay_sau, r.doi_nguoi, r.reason, r.display_name;
  END LOOP;
  IF (SELECT COUNT(*) FROM record_revision WHERE target_table_code = 'staff_advance' AND target_row = u1
        AND before_image ->> 'amount_vnd' = '500000' AND after_image ->> 'amount_vnd' = '700000'
        AND reason = 'test-gõ nhầm số tiền' AND person_id = chu) <> 1
     OR (SELECT COUNT(*) FROM record_revision WHERE target_table_code = 'holiday_bonus' AND target_row = t1) <> 2
     OR (SELECT amount_vnd FROM staff_advance WHERE id = u1) <> 700000 THEN
    RAISE EXCEPTION 'I-028: lần sửa có khai lý do không để lại đủ bản trước · bản sau · lý do · người sửa';
  END IF;

  -- Chế độ nghiêm (T-138, ADR-092; F-046 đã gỡ): sửa KHÔNG khai lý do bị từ chối, nên vế "không sửa
  -- đè" của I-028 nay giữ ở tầng database.
  BEGIN
    UPDATE staff_advance SET amount_vnd = 750000 WHERE id = u1;
    RAISE EXCEPTION 'I-028: database KHÔNG từ chối lần sửa số tiền không khai lý do';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-028 chế độ nghiêm — sửa số tiền không khai lý do bị từ chối: %', SQLERRM;
  END;
  PERFORM set_config('shop.revision_reason', 'test-i028_advance_and_bonus_name_a_worker', true);

  -- Vai ghi của hệ thống: ghi được một khoản; KHÔNG đổi được người duyệt, người ghi hay lúc ghi
  -- của một khoản đã có (mệnh đề chỉ nói sửa số tiền · người nhận · ngày); KHÔNG xoá được (QD-50).
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
    VALUES (a, 60000, '2026-09-23', chu);
    INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date) VALUES (b, 60000, '2026-09-27');
    RESET ROLE;
    RAISE NOTICE 'I-028 vai shop_app ghi được một khoản tạm ứng và một khoản thưởng';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-028: vai shop_app KHÔNG ghi được một khoản: %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE staff_advance SET approver_person_id = a WHERE id = u1;
    RAISE EXCEPTION 'I-028: vai shop_app đổi được người duyệt của một khoản tạm ứng đã ghi';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-028 người duyệt của khoản đã ghi không đổi được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE staff_advance SET person_id = a WHERE id = u1;
    RAISE EXCEPTION 'I-028: vai shop_app đổi được người ghi của một khoản tạm ứng';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-028 người ghi của khoản tạm ứng không đổi được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE holiday_bonus SET person_id = a, created_at = now() WHERE id = t1;
    RAISE EXCEPTION 'I-028: vai shop_app đổi được người ghi và lúc ghi của một khoản thưởng';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-028 người ghi và lúc ghi của khoản thưởng không đổi được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM staff_advance WHERE id = u1;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một khoản tạm ứng';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 khoản tạm ứng không xoá được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM holiday_bonus WHERE id = t1;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một khoản thưởng';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 khoản thưởng không xoá được (shop_app): %', SQLERRM;
  END;

  -- Kiểm ngược của mệnh đề: không khoản tạm ứng nào thiếu người duyệt.
  SELECT COUNT(*) INTO n FROM staff_advance WHERE approver_person_id IS NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'I-028: % khoản tạm ứng thiếu người duyệt', n; END IF;
  RAISE NOTICE 'I-028 kiểm ngược — % khoản tạm ứng, 0 khoản thiếu người duyệt', (SELECT COUNT(*) FROM staff_advance);

  -- Vế "không phải tiền bán hàng" (tầng 3): sau mọi lần ghi và sửa ở trên, không bảng nào khác
  -- của schema đổi số dòng — không dòng nào sinh ra ở hoá đơn, tiền đã thu, hoàn tiền hay két.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(format('SELECT count(*) AS c FROM shop.%I', t.table_name),
                                                false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap_sau
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('staff_advance', 'holiday_bonus', 'record_revision', 'person');
  IF snap_sau IS DISTINCT FROM snap THEN
    RAISE EXCEPTION 'I-028: ghi khoản tạm ứng hay thưởng làm đổi bảng khác — trước: % — sau: %', snap, snap_sau;
  END IF;
  RAISE NOTICE 'I-028 không phải tiền bán hàng — sau % khoản tạm ứng và % khoản thưởng, không bảng nào khác của schema đổi số dòng',
    (SELECT COUNT(*) FROM staff_advance), (SELECT COUNT(*) FROM holiday_bonus);

  -- ĐỌC LƯỢC ĐỒ: lát có đúng hai bảng, và danh sách cột của từng bảng là đúng danh sách dưới đây.
  -- Thêm một cột — ngày bán, mốc tính tiền, một dấu nối két, loại thưởng, dấu đã trừ lương, một
  -- người duyệt cho thưởng — là đổi mệnh đề I-028 trước, rồi mới đổi dòng này.
  SELECT string_agg(table_name::text, ',' ORDER BY table_name::text COLLATE "C") INTO cols
  FROM information_schema.tables
  WHERE table_schema = 'shop' AND (table_name LIKE '%advance%' OR table_name LIKE '%bonus%');
  IF cols IS DISTINCT FROM 'holiday_bonus,staff_advance' THEN
    RAISE EXCEPTION 'I-028: bảng của lát khoản của người khác danh sách đã duyệt: %', cols;
  END IF;
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'staff_advance';
  IF cols IS DISTINCT FROM 'amount_vnd,approver_person_id,created_at,id,paid_date,person_id,worker_person_id' THEN
    RAISE EXCEPTION 'I-028: cột của staff_advance khác danh sách đã duyệt: %', cols;
  END IF;
  RAISE NOTICE 'I-028 đọc lược đồ — staff_advance: %', cols;
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'holiday_bonus';
  IF cols IS DISTINCT FROM 'amount_vnd,created_at,id,paid_date,person_id,worker_person_id' THEN
    RAISE EXCEPTION 'I-028: cột của holiday_bonus khác danh sách đã duyệt: %', cols;
  END IF;
  RAISE NOTICE 'I-028 đọc lược đồ — holiday_bonus: % — không người duyệt, không loại thưởng, không chỗ cho thưởng ngày đông khách', cols;

  -- Không đường nào đi từ một khoản tới tiền bán hàng hay két: không khoá ngoại nào ngoài các khoá
  -- trỏ về người, không bảng nào trỏ vào hai bảng này; không hàm nào của schema nhắc tới chúng;
  -- không trigger nào ngoài trigger vết.
  SELECT COUNT(*) INTO n FROM pg_constraint c
  JOIN pg_class x ON x.oid = c.conrelid JOIN pg_class y ON y.oid = c.confrelid
  JOIN pg_namespace ns ON ns.oid = c.connamespace
  WHERE ns.nspname = 'shop' AND c.contype = 'f'
    AND (   y.relname IN ('staff_advance', 'holiday_bonus')
         OR (x.relname IN ('staff_advance', 'holiday_bonus') AND y.relname <> 'person'));
  IF n <> 0 THEN RAISE EXCEPTION 'I-028: % khoá ngoại nối khoản tạm ứng hay thưởng với bảng ngoài người', n; END IF;
  SELECT COUNT(*) INTO n FROM pg_proc f JOIN pg_namespace ns ON ns.oid = f.pronamespace
  WHERE ns.nspname = 'shop' AND (f.prosrc ILIKE '%staff_advance%' OR f.prosrc ILIKE '%holiday_bonus%');
  IF n <> 0 THEN RAISE EXCEPTION 'I-028: % hàm của schema nhắc tới khoản tạm ứng hay thưởng — một đường nối sang thứ khác', n; END IF;
  SELECT COUNT(*) INTO n FROM pg_trigger g JOIN pg_class c ON c.oid = g.tgrelid
  JOIN pg_namespace ns ON ns.oid = c.relnamespace JOIN pg_proc f ON f.oid = g.tgfoid
  WHERE ns.nspname = 'shop' AND c.relname IN ('staff_advance', 'holiday_bonus') AND NOT g.tgisinternal
    AND f.proname <> 'record_revision_capture';
  IF n <> 0 THEN RAISE EXCEPTION 'I-028: % trigger ngoài trigger vết trên khoản tạm ứng hay thưởng', n; END IF;
  RAISE NOTICE 'I-028 đọc lược đồ — 0 khoá ngoại ngoài các khoá về người, 0 hàm nhắc tới hai bảng, 0 trigger ngoài trigger vết ⇒ không đường nào tới doanh thu, tiền đã thu hay két';
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
