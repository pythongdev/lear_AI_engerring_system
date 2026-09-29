-- I-014 (tầng 1) và YC-23: một khoản tiền gắn với đúng MỘT đơn vị tính tiền; khoản trả
-- trước chỉ vào doanh thu qua hoá đơn của chính đơn nó, và phần đã thành doanh thu cộng phần
-- đã trả lại không bao giờ vượt số đã nhận. Lát: 04-luoc-do-duong-tien.md.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
DO $$
DECLARE t5 bigint; s1 bigint; o_tbl bigint; o1 bigint; o2 bigint; o3 bigint;
        p1 bigint; b1 bigint; b2 bigint; rf bigint; r record;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
  VALUES ('staff_pos', 'confirmed', s1, t5, gen_random_uuid()::text) RETURNING id INTO o_tbl;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text) RETURNING id INTO o1;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000002', now(), gen_random_uuid()::text) RETURNING id INTO o2;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000003', now(), gen_random_uuid()::text) RETURNING id INTO o3;

  -- Vế "không khoản nào đứng ở hai nguồn": lượt gọi của phiên bàn không có hoá đơn riêng.
  BEGIN
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd) VALUES (o_tbl, 50000, 50000);
    RAISE EXCEPTION 'I-014: database KHÔNG từ chối hoá đơn riêng cho một lượt gọi của phiên bàn';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-014 bị từ chối (lượt gọi phiên bàn tính tiền riêng): %', SQLERRM;
  END;
  -- shop-facts §6.3: luồng ăn tại bàn không có nhánh trả trước.
  BEGIN
    INSERT INTO prepayment (sales_order_id, cash_vnd) VALUES (o_tbl, 50000);
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối trả trước cho lượt gọi của phiên bàn';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (trả trước ở phiên bàn): %', SQLERRM;
  END;
  -- Đơn lẻ Hoàn thành mà không có hoá đơn: doanh thu của nó không đứng ở nguồn nào.
  BEGIN
    UPDATE sales_order SET status = 'completed' WHERE id = o3;
    SET CONSTRAINTS sales_order_bill_fkey IMMEDIATE;
    RAISE EXCEPTION 'I-014: database KHÔNG từ chối đơn lẻ hoàn thành mà không có hoá đơn';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-014 bị từ chối (đơn lẻ hoàn thành, không hoá đơn): %', SQLERRM;
  END;
  SET CONSTRAINTS sales_order_bill_fkey DEFERRED;

  -- Khoản trả trước của o1: nhận 50.000 tiền mặt.
  INSERT INTO prepayment (sales_order_id, cash_vnd) VALUES (o1, 50000) RETURNING id INTO p1;
  BEGIN
    INSERT INTO prepayment (sales_order_id, transfer_vnd) VALUES (o1, 20000);
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối khoản trả trước thứ hai của một đơn';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (khoản trả trước thứ hai cho một đơn — phiên chọn): %', SQLERRM;
  END;

  -- Mắt 1 phải bắt đầu đúng bằng số đã nhận.
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, prepaid_cash_vnd) VALUES (o1, 80000, 50000, 30000) RETURNING id INTO b1;
  BEGIN
    INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_cash_vnd, bill_id)
    VALUES (p1, o1, 1, 90000, 0, 30000, b1);
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối chuỗi bắt đầu từ số dư bịa';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (mắt đầu không bằng số đã nhận): %', SQLERRM;
  END;
  -- Hoá đơn ghi "trả trước" mà không có mắt chuỗi nào.
  BEGIN
    SET CONSTRAINTS bill_prepayment_use_fkey IMMEDIATE;
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối hoá đơn ghi trả trước mà khoản trả trước không giảm';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (hoá đơn ghi trả trước, không mắt chuỗi): %', SQLERRM;
  END;
  SET CONSTRAINTS bill_prepayment_use_fkey DEFERRED;
  -- Mắt chuỗi khớp số với hoá đơn của ĐƠN KHÁC.
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd) VALUES (o2, 70000, 70000) RETURNING id INTO b2;
  BEGIN
    INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_cash_vnd, bill_id)
    VALUES (p1, o1, 1, 50000, 0, 30000, b2);
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối trả trước của đơn này vào hoá đơn đơn khác';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (trả trước vào hoá đơn đơn khác): %', SQLERRM;
  END;
  -- Đúng: 30.000 thành doanh thu ở hoá đơn của o1, còn lại 20.000.
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_cash_vnd, bill_id)
  VALUES (p1, o1, 1, 50000, 0, 30000, b1);
  UPDATE sales_order SET status = 'completed' WHERE id IN (o1, o2);

  -- Trả lại vượt phần còn lại: 30.000 thành doanh thu + 30.000 trả lại > 50.000 đã nhận.
  INSERT INTO refund (prepayment_id, amount_vnd, method_code, reason)
  VALUES (p1, 30000, 'cash', 'khách bớt món') RETURNING id INTO rf;
  BEGIN
    INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_cash_vnd, refund_id)
    VALUES (p1, o1, 2, 20000, 0, 30000, rf);
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối dùng quá số đã nhận';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (đã thành doanh thu + trả lại vượt số đã nhận): %', SQLERRM;
  END;
  -- Lách bằng cách bắt đầu lại từ số đã nhận ở mắt 2.
  BEGIN
    INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_cash_vnd, refund_id)
    VALUES (p1, o1, 2, 50000, 0, 30000, rf);
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối mắt chuỗi quên mắt trước';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (mắt 2 không bắt đầu từ số dư sau mắt 1): %', SQLERRM;
  END;
  -- Lần trả lại khoản trả trước mà không có mắt chuỗi nào.
  BEGIN
    SET CONSTRAINTS refund_prepayment_use_fkey IMMEDIATE;
    RAISE EXCEPTION 'YC-23: database KHÔNG từ chối lần trả lại không trừ vào khoản trả trước';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-23 bị từ chối (trả lại không có mắt chuỗi): %', SQLERRM;
  END;
  SET CONSTRAINTS refund_prepayment_use_fkey DEFERRED;
  -- Trả lại đúng phần còn lại: 20.000.
  UPDATE refund SET amount_vnd = 20000 WHERE id = rf;
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_cash_vnd, refund_id)
  VALUES (p1, o1, 2, 20000, 0, 20000, rf);
  UPDATE sales_order SET status = 'cancelled' WHERE id = o3;

  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  SELECT p.cash_vnd + p.transfer_vnd AS nhan,
         (SELECT COALESCE(SUM(u.take_vnd), 0) FROM prepayment_use u WHERE u.prepayment_id = p.id AND u.bill_id IS NOT NULL) AS vao_doanh_thu,
         (SELECT COALESCE(SUM(u.take_vnd), 0) FROM prepayment_use u WHERE u.prepayment_id = p.id AND u.refund_id IS NOT NULL) AS tra_lai
    INTO r FROM prepayment p WHERE p.id = p1;
  RAISE NOTICE 'YC-23 khoản trả trước o1: nhận %, thành doanh thu %, trả lại % — không vượt', r.nhan, r.vao_doanh_thu, r.tra_lai;

  -- Phép đối chiếu (P2-11 gom): khoản trả trước mà đã dùng + trả lại vượt số đã nhận — rỗng.
  IF EXISTS (SELECT 1 FROM prepayment p
             WHERE (SELECT COALESCE(SUM(take_vnd), 0) FROM prepayment_use u WHERE u.prepayment_id = p.id)
                   > p.cash_vnd + p.transfer_vnd) THEN
    RAISE EXCEPTION 'YC-23: tập đối chiếu không rỗng';
  END IF;
  RAISE NOTICE 'YC-23 đối chiếu: tập "đã dùng + trả lại vượt số đã nhận" rỗng';
END $$;
