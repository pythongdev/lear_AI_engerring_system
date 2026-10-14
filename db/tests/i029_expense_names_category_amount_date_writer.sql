-- I-029 (tầng 1) và YC-33: mỗi khoản chi ngoài tiền hàng và lương đọc ra được LOẠI · SỐ TIỀN · NGÀY ·
-- AI GHI; mỗi LOẠI mang nguồn tiền của nó (két bán hàng hay không), và một loại không khai nguồn thì
-- không tồn tại được (ADR-074 điểm 3); tổng chi một khoảng ngày là phép cộng các khoản; sửa một khoản
-- là một lần cập nhật có vết (I-018, chế độ nghiêm T-138); không xoá (QD-50). Hạng tử "chi từ két"
-- của I-021 là việc của bộ đối chiếu (db/reconcile/prelude.sql), không của file này.
-- Chạy đúng kịch bản của mục Verification ở quality/invariants.md I-029.
-- Lát: 15-luoc-do-khoan-chi.md. Thiết kế: docs/decisions.md ADR-074. Viết trước code (P2A-05, Claude).

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i029_expense_names_category_amount_date_writer', true); END $$;
DO $$
DECLARE chu bigint; a bigint; dien bigint; xang bigint; mkt bigint; moi bigint; e1 bigint; r record;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO a;
  PERFORM set_config('shop.actor_person_id', chu::text, true);

  -- Loại chi mang nguồn: điện, xăng xe trả từ két (E46, U-066); marketing trả bằng tiền riêng (U-093).
  INSERT INTO expense_category (name, paid_from_till) VALUES ('test-điện', true) RETURNING id INTO dien;
  INSERT INTO expense_category (name, paid_from_till) VALUES ('test-xăng xe', true) RETURNING id INTO xang;
  INSERT INTO expense_category (name, paid_from_till) VALUES ('test-marketing', false) RETURNING id INTO mkt;

  -- Kịch bản dương: tiền điện và tiền xăng xe trong cùng một tuần, một khoản marketing.
  INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (dien, 300000, '2026-10-05')
  RETURNING id INTO e1;
  INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (xang, 120000, '2026-10-07');
  INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (mkt, 500000, '2026-10-08');
  FOR r IN
    SELECT c.name AS loai, c.paid_from_till AS tu_ket, e.amount_vnd, e.paid_date, g.display_name AS nguoi_ghi,
           e.created_at IS NOT NULL AS co_luc_ghi
    FROM expense e JOIN expense_category c ON c.id = e.expense_category_id
    JOIN person g ON g.id = e.person_id WHERE c.name LIKE 'test-%' ORDER BY e.id
  LOOP
    RAISE NOTICE 'YC-33 khoản chi — loại %, nguồn két: %, % đồng, ngày %, % ghi, có lúc ghi: %',
      r.loai, r.tu_ket, r.amount_vnd, r.paid_date, r.nguoi_ghi, r.co_luc_ghi;
  END LOOP;
  IF NOT EXISTS (SELECT 1 FROM expense WHERE id = e1 AND expense_category_id = dien AND amount_vnd = 300000
                   AND paid_date = '2026-10-05' AND person_id = chu AND created_at IS NOT NULL) THEN
    RAISE EXCEPTION 'I-029: khoản chi không đọc lại được đúng loại · số tiền · ngày · ai ghi';
  END IF;
  -- Tổng chi của một khoảng ngày là phép cộng các khoản; nguồn đọc ra từ loại.
  IF (SELECT SUM(e.amount_vnd) FROM expense e JOIN expense_category c ON c.id = e.expense_category_id
      WHERE c.name LIKE 'test-%' AND e.paid_date BETWEEN '2026-10-05' AND '2026-10-11') <> 920000
     OR (SELECT SUM(e.amount_vnd) FROM expense e JOIN expense_category c ON c.id = e.expense_category_id
         WHERE c.name LIKE 'test-%' AND c.paid_from_till) <> 420000 THEN
    RAISE EXCEPTION 'I-029: tổng chi một tuần hay phần chi từ két không ra bằng phép cộng các khoản';
  END IF;
  RAISE NOTICE 'I-029 tổng chi tuần 2026-10-05…11: 920000 đồng, trong đó từ két 420000 đồng';

  -- Loại mới kèm nguồn ⇒ ghi được, và khoản của nó ghi được.
  INSERT INTO expense_category (name, paid_from_till) VALUES ('test-loại mới', true) RETURNING id INTO moi;
  INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (moi, 10000, '2026-10-09');
  RAISE NOTICE 'I-029 loại mới kèm nguồn — ghi được, khoản của nó ghi được';

  -- Tầng 1, loại: không khai nguồn · tên rỗng · tên trùng ⇒ không tồn tại được.
  BEGIN
    INSERT INTO expense_category (name) VALUES ('test-loại không nguồn');
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một loại chi không khai nguồn tiền';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (loại không khai nguồn): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO expense_category (name, paid_from_till) VALUES ('  ', true);
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một loại chi tên rỗng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (loại tên rỗng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO expense_category (name, paid_from_till) VALUES ('test-điện', false);
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối hai loại chi cùng tên';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (hai loại cùng tên): %', SQLERRM;
  END;

  -- Tầng 1, khoản: không loại · loại ngoài danh sách · không số tiền · 0đ · số âm · không ngày.
  BEGIN
    INSERT INTO expense (amount_vnd, paid_date) VALUES (50000, '2026-10-05');
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một khoản chi không có loại';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (khoản không có loại): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (999999999, 50000, '2026-10-05');
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một khoản chi mang loại ngoài danh sách';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (loại ngoài danh sách): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO expense (expense_category_id, paid_date) VALUES (dien, '2026-10-05');
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một khoản chi không có số tiền';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (khoản không có số tiền): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (dien, 0, '2026-10-05');
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một khoản chi 0đ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (khoản 0đ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (dien, -50000, '2026-10-05');
    RAISE EXCEPTION 'QD-21: database KHÔNG từ chối một khoản chi số âm';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'QD-21 bị từ chối (khoản số âm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO expense (expense_category_id, amount_vnd) VALUES (dien, 50000);
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một khoản chi không có ngày';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (khoản không có ngày): %', SQLERRM;
  END;

  -- Tầng 1, người ghi: không có ⇒ từ chối; người lạ ⇒ từ chối.
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (dien, 50000, '2026-10-05');
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối một khoản chi không có người ghi';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (khoản không có người ghi): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  BEGIN
    INSERT INTO expense (expense_category_id, amount_vnd, paid_date, person_id) VALUES (dien, 50000, '2026-10-05', 999999999);
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối người ghi không thuộc tập người của quán';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-029 bị từ chối (người ghi không phải người của quán): %', SQLERRM;
  END;

  -- Kịch bản sửa bằng vai ghi của hệ thống: số tiền · loại · ngày sửa được, có khai lý do ⇒ vết đủ.
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'test-gõ nhầm số tiền điện', true);
    UPDATE expense SET amount_vnd = 320000 WHERE id = e1;
    PERFORM set_config('shop.revision_reason', 'test-khai nhầm ngày', true);
    UPDATE expense SET paid_date = '2026-10-06' WHERE id = e1;
    PERFORM set_config('shop.revision_reason', 'test-ghi nhầm loại', true);
    UPDATE expense SET expense_category_id = xang WHERE id = e1;
    PERFORM set_config('shop.revision_reason', '', true);
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-029: vai shop_app KHÔNG sửa được số tiền · ngày · loại của một khoản chi: %', SQLERRM;
  END;
  IF (SELECT COUNT(*) FROM record_revision WHERE target_table_code = 'expense' AND target_row = e1) <> 3
     OR NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'expense' AND target_row = e1
                      AND before_image ->> 'amount_vnd' = '300000' AND after_image ->> 'amount_vnd' = '320000'
                      AND reason = 'test-gõ nhầm số tiền điện' AND person_id = chu) THEN
    RAISE EXCEPTION 'I-029: lần sửa khoản chi có khai lý do không để lại đủ bản trước · bản sau · lý do · người sửa';
  END IF;
  RAISE NOTICE 'I-029 sửa khoản chi — 3 lần sửa, mỗi lần một dòng vết có lý do và người sửa';

  -- Chế độ nghiêm: sửa không khai lý do ⇒ từ chối.
  BEGIN
    UPDATE expense SET amount_vnd = 330000 WHERE id = e1;
    RAISE EXCEPTION 'I-029: database KHÔNG từ chối lần sửa khoản chi không khai lý do';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-029 chế độ nghiêm — sửa không khai lý do bị từ chối: %', SQLERRM;
  END;
  PERFORM set_config('shop.revision_reason', 'test-i029_expense_names_category_amount_date_writer', true);

  -- Vai ghi: ghi được loại và khoản; KHÔNG đổi người ghi · lúc ghi; KHÔNG đổi nguồn tiền của một loại
  -- đã có (đổi nguồn là viết lại két của mọi ngày cũ — thêm loại mới thay vì sửa); KHÔNG xoá (QD-50).
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO expense_category (name, paid_from_till) VALUES ('test-nước', true);
    INSERT INTO expense (expense_category_id, amount_vnd, paid_date) VALUES (dien, 60000, '2026-10-10');
    RESET ROLE;
    RAISE NOTICE 'I-029 vai shop_app ghi được một loại chi và một khoản chi';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-029: vai shop_app KHÔNG ghi được loại chi hay khoản chi: %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE expense SET person_id = a, created_at = now() WHERE id = e1;
    RAISE EXCEPTION 'I-029: vai shop_app đổi được người ghi và lúc ghi của một khoản chi';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-029 người ghi và lúc ghi của khoản chi không đổi được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE expense_category SET paid_from_till = false WHERE id = dien;
    RAISE EXCEPTION 'I-029: vai shop_app đổi được nguồn tiền của một loại chi đã có';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-029 nguồn tiền của loại đã có không đổi được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM expense WHERE id = e1;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một khoản chi';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 khoản chi không xoá được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM expense_category WHERE id = mkt;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một loại chi';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 loại chi không xoá được (shop_app): %', SQLERRM;
  END;
END $$;
