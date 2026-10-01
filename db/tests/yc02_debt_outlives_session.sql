-- YC-02 · YC-09 · YC-10 · I-014: một khoản nợ đứng được sau khi phiên của nó đã đóng và qua
-- nhiều ngày — ai nợ · bao nhiêu · thuộc đúng một phiên · lúc ghi · lúc thu · đã thu hay chưa;
-- một lần trả nợ KHÔNG là một lần bán mới. Lát: 04-luoc-do-duong-tien.md.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
DO $$
DECLARE t5 bigint; s1 bigint; b1 bigint; r record;
BEGIN
  -- Thứ Hai 2026-09-21: bàn 5 ăn 200.000, trả 150.000 tiền mặt, nợ 50.000.
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('awaiting_payment') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);
  UPDATE table_session SET status = 'closed' WHERE id = s1;
  UPDATE table_session_member SET session_closed = true, cleaned_at = '2026-09-21 09:05+07' WHERE table_session_id = s1;
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, debt_vnd, debtor_name, booked_at, sale_date)
  VALUES (s1, 200000, 150000, 50000, 'Chú Tư, số 0912 000 111', '2026-09-21 09:00+07', '2026-09-21')
  RETURNING id INTO b1;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Thứ Ba: phiên đã đóng, bàn đã dọn — khoản nợ vẫn đọc được, trạng thái "chưa thu".
  SELECT b.debtor_name, b.debt_vnd, b.table_session_id, b.booked_at,
         c.booked_at AS luc_thu, (c.id IS NOT NULL) AS da_thu, s.is_closed
    INTO r FROM bill b JOIN table_session s ON s.id = b.table_session_id
    LEFT JOIN debt_collection c ON c.bill_id = b.id WHERE b.id = b1;
  RAISE NOTICE 'YC-02 sau khi phiên đóng: % nợ %, phiên % (đã đóng %), ghi lúc %, thu lúc %, đã thu %',
    r.debtor_name, r.debt_vnd, r.table_session_id, r.is_closed, r.booked_at, coalesce(r.luc_thu::text, '—'), r.da_thu;

  -- Trả nợ ghi thành một lần bán thứ hai của cùng phiên — tính doanh thu hai lần.
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date)
    VALUES (s1, 50000, 50000, '2026-09-24 16:00+07', '2026-09-24');
    RAISE EXCEPTION 'YC-10: database KHÔNG từ chối ghi lần trả nợ thành một lần bán mới';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-10 bị từ chối (trả nợ ghi thành lần bán thứ hai): %', SQLERRM;
  END;
  -- Thu nợ khác số nợ.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd) VALUES (b1, 30000, 30000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối lần thu nợ khác số nợ đã ghi';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (bản soi số nợ khác số nợ của hoá đơn): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd) VALUES (b1, 50000, 60000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối thu nợ vượt số nợ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (thu nợ vượt số nợ): %', SQLERRM;
  END;

  -- Thứ Năm 2026-09-24: Chú Tư quay lại trả 50.000, 20.000 tiền mặt + 30.000 chuyển khoản.
  INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, transfer_vnd, booked_at, sale_date)
  VALUES (b1, 50000, 20000, 30000, '2026-09-24 16:00+07', '2026-09-24');
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, booked_at, sale_date)
    VALUES (b1, 50000, 50000, '2026-09-25 10:00+07', '2026-09-25');
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối thu một khoản nợ hai lần';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (thu một khoản nợ hai lần): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  SELECT b.debtor_name, b.debt_vnd, b.table_session_id, b.booked_at,
         c.booked_at AS luc_thu, c.cash_vnd, c.transfer_vnd, (c.id IS NOT NULL) AS da_thu
    INTO r FROM bill b LEFT JOIN debt_collection c ON c.bill_id = b.id WHERE b.id = b1;
  RAISE NOTICE 'YC-02 đọc lại sau ba ngày — sáu thứ: ai nợ "%", bao nhiêu %, phiên %, lúc ghi %, lúc thu % (tiền mặt % + chuyển khoản %), đã thu %',
    r.debtor_name, r.debt_vnd, r.table_session_id, r.booked_at, r.luc_thu, r.cash_vnd, r.transfer_vnd, r.da_thu;

  -- I-014 kịch bản nợ: doanh thu ngày ghi nợ có đủ bữa ăn, ngày trả không tăng, hai ngày cộng
  -- lại đúng một bữa ăn. Doanh thu một ngày = hoá đơn đóng hôm ấy − hoàn cho lần bán hôm ấy.
  SELECT (SELECT COALESCE(SUM(due_vnd), 0) FROM bill WHERE sale_date = '2026-09-21') AS thu_hai,
         (SELECT COALESCE(SUM(due_vnd), 0) FROM bill WHERE sale_date = '2026-09-24') AS thu_nam,
         (SELECT COALESCE(SUM(cash_vnd + transfer_vnd), 0) FROM debt_collection WHERE sale_date = '2026-09-24') AS no_cu_thu
    INTO r;
  RAISE NOTICE 'I-014 doanh thu thứ Hai % · thứ Năm % (nợ cũ thu được thứ Năm %, không vào doanh thu) · hai ngày cộng lại %',
    r.thu_hai, r.thu_nam, r.no_cu_thu, r.thu_hai + r.thu_nam;
  IF r.thu_hai + r.thu_nam <> 200000 OR r.thu_nam <> 0 THEN
    RAISE EXCEPTION 'I-014: trả nợ đã bị tính thành doanh thu';
  END IF;

  -- Phép đối chiếu (P2-11 gom): khoản nợ không truy được về đúng một phiên và một người — rỗng.
  IF EXISTS (SELECT 1 FROM bill WHERE debt_vnd > 0
             AND (num_nonnulls(table_session_id, sales_order_id) <> 1 OR btrim(coalesce(debtor_name, '')) = '')) THEN
    RAISE EXCEPTION 'I-005: tập đối chiếu không rỗng';
  END IF;
  RAISE NOTICE 'I-005 đối chiếu: tập "khoản nợ không truy được về một đơn vị tính tiền và một người" rỗng';
END $$;
