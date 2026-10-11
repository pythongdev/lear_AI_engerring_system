-- I-015 (tầng 1 · tầng 2) và YC-19: một lần thu chia nhiều phương thức — từng phần ghi
-- riêng, mỗi phần đúng một phương thức, tổng không vượt số phải trả, mọi phần chung MỘT mốc
-- và cùng sống hoặc cùng chết. Kèm I-007 "không gộp hai đơn lẻ vào một lần thu".
-- Lát: 04-luoc-do-duong-tien.md.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i015_split_payment', true); END $$;
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
DO $$
DECLARE t5 bigint; s1 bigint; s2 bigint; o1 bigint; o2 bigint; b1 bigint; b2 bigint; r record;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('awaiting_payment') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);
  UPDATE table_session SET status = 'closed' WHERE id = s1;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s1;

  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd) VALUES (s1, 200000, 150000, 80000);
    RAISE EXCEPTION 'I-015: database KHÔNG từ chối tổng các phần vượt số phải trả';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-015 bị từ chối (thu vượt: 150.000 + 80.000 > 200.000): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd) VALUES (s1, 200000, 280000, -80000);
    RAISE EXCEPTION 'I-015: database KHÔNG từ chối một phần âm bù cho phần kia';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-015 bị từ chối (một phần âm): %', SQLERRM;
  END;
  -- Phương thức thứ ba không có chỗ ghi: mỗi phương thức của shop-facts §1 là một cột.
  BEGIN
    EXECUTE 'INSERT INTO bill (table_session_id, due_vnd, card_vnd) VALUES ($1, 200000, 200000)' USING s1;
    RAISE EXCEPTION 'I-015: database KHÔNG từ chối phần mang phương thức thứ ba';
  EXCEPTION WHEN undefined_column THEN
    RAISE NOTICE 'I-015 bị từ chối (phương thức thứ ba): %', SQLERRM;
  END;

  -- Chia đúng: 120.000 tiền mặt + 80.000 chuyển khoản, một dòng, một mốc.
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd)
  VALUES (s1, 200000, 120000, 80000) RETURNING id INTO b1;
  SELECT cash_vnd, transfer_vnd, due_vnd, booked_at, sale_date INTO r FROM bill WHERE id = b1;
  RAISE NOTICE 'I-015 chia hai phương thức — được: tiền mặt %, chuyển khoản %, phải trả %; YC-19 một mốc % (ngày %) cho cả hai phần',
    r.cash_vnd, r.transfer_vnd, r.due_vnd, r.booked_at, r.sale_date;

  -- Tầng 2: không có lần ghi nào chỉ mang một phần — cắt giữa chừng là không phần nào sống.
  BEGIN
    UPDATE bill SET transfer_vnd = 0 WHERE id = b1;
    RAISE EXCEPTION 'I-015: database KHÔNG từ chối bỏ một phần của lần thu đã ghi';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-015 bị từ chối (xoá một phần của lần thu đã ghi): %', SQLERRM;
  END;

  -- Đơn lẻ: I-007 — một lần thu không gộp hai đơn; một đơn không có hai lần thu.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text) RETURNING id INTO o1;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000002', now(), gen_random_uuid()::text) RETURNING id INTO o2;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, transfer_vnd) VALUES (o1, 90000, 50000, 40000) RETURNING id INTO b2;
  UPDATE sales_order SET status = 'completed' WHERE id = o1;
  BEGIN
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd) VALUES (o1, 90000, 90000);
    RAISE EXCEPTION 'I-007: database KHÔNG từ chối lần thu thứ hai của một đơn lẻ';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-007 bị từ chối (đơn lẻ thu hai lần): %', SQLERRM;
  END;
  BEGIN
    -- Phiên riêng, chưa có hoá đơn: lời từ chối phải đến từ bill_one_unit_check, không từ
    -- khoá một-hoá-đơn-một-phiên.
    INSERT INTO table_session (status) VALUES ('closed') RETURNING id INTO s2;
    INSERT INTO bill (table_session_id, sales_order_id, due_vnd, cash_vnd) VALUES (s2, o2, 90000, 90000);
    RAISE EXCEPTION 'I-014: database KHÔNG từ chối một lần thu gắn hai đơn vị tính tiền';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-014 bị từ chối (một lần thu gắn phiên bàn lẫn đơn lẻ): %', SQLERRM;
  END;

  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Phép đối chiếu (P2-11 gom): lần thu mà tổng các phần khác số phải trả — rỗng.
  IF EXISTS (SELECT 1 FROM bill
             WHERE cash_vnd + transfer_vnd + prepaid_cash_vnd + prepaid_transfer_vnd + debt_vnd <> due_vnd) THEN
    RAISE EXCEPTION 'I-015: tập đối chiếu không rỗng';
  END IF;
  RAISE NOTICE 'I-015 đối chiếu: tập "tổng các phần khác số phải trả" rỗng';
END $$;
