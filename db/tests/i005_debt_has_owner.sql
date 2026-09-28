-- I-005 (tầng 1): phiên đóng mà thu thiếu thì phần thiếu PHẢI là một khoản nợ có chủ và có
-- số tiền; nợ không phải tiền đã thu; phiên đã đóng không thể thiếu hoá đơn. Kèm YC-11: tên
-- người chỉ được hỏi khi có nợ. Lát: 04-luoc-do-duong-tien.md.
-- Bộ kiểm ROLLBACK cuối file, nên mọi ràng buộc hoãn được ép chạy bằng SET CONSTRAINTS.
DO $$
DECLARE t5 bigint; t6 bigint; s1 bigint; s2 bigint; b1 bigint; r record;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO dining_table (label) VALUES ('test-6') RETURNING id INTO t6;
  INSERT INTO table_session (status) VALUES ('awaiting_payment') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);

  -- Đóng phiên: trạng thái, mọi bàn của phiên, và hoá đơn — cùng một giao dịch.
  UPDATE table_session SET status = 'closed' WHERE id = s1;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s1;

  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd) VALUES (s1, 200000, 150000);
    RAISE EXCEPTION 'I-005: database KHÔNG từ chối thu thiếu 50.000 mà không ghi nợ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-005 bị từ chối (thu thiếu, không ghi nợ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, debt_vnd) VALUES (s1, 200000, 150000, 50000);
    RAISE EXCEPTION 'I-005: database KHÔNG từ chối khoản nợ không có chủ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-005 bị từ chối (nợ không có tên người nợ): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, debt_vnd, debtor_name)
    VALUES (s1, 200000, 150000, 50000, '   ');
    RAISE EXCEPTION 'I-005: database KHÔNG từ chối tên người nợ chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-005 bị từ chối (tên người nợ trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, debt_vnd, debtor_name)
    VALUES (s1, 200000, 250000, -50000, 'Chú Tư');
    RAISE EXCEPTION 'I-005: database KHÔNG từ chối số nợ âm';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-005 bị từ chối (số nợ âm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, debtor_name) VALUES (s1, 200000, 200000, 'Chú Tư');
    RAISE EXCEPTION 'YC-11: database KHÔNG từ chối hỏi tên ở một phiên không nợ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-11 bị từ chối (tên người ở phiên không nợ): %', SQLERRM;
  END;

  -- Phiên đã đóng mà không có hoá đơn nào: tổng đã thu 0 < số phải trả, không nợ nào.
  BEGIN
    SET CONSTRAINTS table_session_bill_fkey IMMEDIATE;
    RAISE EXCEPTION 'I-005: database KHÔNG từ chối phiên đã đóng mà không có hoá đơn';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-005 bị từ chối (phiên đóng, không hoá đơn): %', SQLERRM;
  END;
  SET CONSTRAINTS table_session_bill_fkey DEFERRED;

  -- Hoá đơn cho một phiên CHƯA đóng: không có lần đóng nào để nó đứng tên.
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s2;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s2, t6);
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd) VALUES (s2, 90000, 90000);
    SET CONSTRAINTS bill_table_session_fkey IMMEDIATE;
    RAISE EXCEPTION 'I-005: database KHÔNG từ chối hoá đơn cho phiên chưa đóng';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-005 bị từ chối (hoá đơn cho phiên chưa đóng): %', SQLERRM;
  END;
  SET CONSTRAINTS bill_table_session_fkey DEFERRED;

  -- Đóng đúng: thu 150.000 tiền mặt, phần thiếu 50.000 là nợ có chủ.
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, debt_vnd, debtor_name)
  VALUES (s1, 200000, 150000, 50000, 'Chú Tư, hay ngồi bàn 5') RETURNING id INTO b1;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  SELECT cash_vnd + transfer_vnd AS da_thu, debt_vnd, debtor_name, due_vnd INTO r FROM bill WHERE id = b1;
  RAISE NOTICE 'I-005 đóng phiên thu thiếu — được: đã thu %, nợ % (%), phải trả % — nợ ở cột riêng, không trong tiền đã thu',
    r.da_thu, r.debt_vnd, r.debtor_name, r.due_vnd;

  -- Phép đối chiếu (P2-11 gom): phiên đã đóng mà đã thu + nợ khác số phải trả — rỗng.
  IF EXISTS (SELECT 1 FROM table_session s LEFT JOIN bill b ON b.table_session_id = s.id
             WHERE s.is_closed AND b.id IS NULL
                OR b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd + b.debt_vnd <> b.due_vnd) THEN
    RAISE EXCEPTION 'I-005: tập đối chiếu không rỗng';
  END IF;
  RAISE NOTICE 'I-005 đối chiếu: tập "phiên đóng mà đã thu + nợ khác phải trả" rỗng';
END $$;
