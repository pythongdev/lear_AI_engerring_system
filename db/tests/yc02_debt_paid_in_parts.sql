-- YC-02 · I-005 · I-014 — khách TRẢ DẦN một khoản nợ (shop-facts.md §6.14, lời đóng U-063,
-- docs/decisions.md ADR-075): mỗi lần trả một dòng debt_collection mang ngày giờ trả, số trả và số
-- còn thiếu sau lần ấy; các lần trả nối thành chuỗi, nên trả vượt, rẽ nhánh, trả khi đã hết nợ và
-- khai sai số còn thiếu đều bị database từ chối. Viết TRƯỚC migration (T-126, Claude Code).
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0).
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
DO $$
DECLARE t5 bigint; s1 bigint; b1 bigint; r record;
BEGIN
  -- Thứ Hai 2026-09-21: bàn 5 ăn 250.000, trả 150.000 tiền mặt, nợ 100.000.
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('awaiting_payment') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);
  UPDATE table_session SET status = 'closed' WHERE id = s1;
  UPDATE table_session_member SET session_closed = true, cleaned_at = '2026-09-21 09:05+07' WHERE table_session_id = s1;
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, debt_vnd, debtor_name, booked_at, sale_date)
  VALUES (s1, 250000, 150000, 100000, 'Chú Tư, số 0912 000 111', '2026-09-21 09:00+07', '2026-09-21')
  RETURNING id INTO b1;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Thứ Ba: lần trả đầu, 30.000 tiền mặt ⇒ còn thiếu 70.000. Lần đầu không khai "còn thiếu trước".
  INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_vnd, booked_at, sale_date)
  VALUES (b1, 100000, 30000, 70000, '2026-09-22 17:10+07', '2026-09-22');

  -- Lần đầu thứ hai của cùng khoản nợ.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_vnd) VALUES (b1, 100000, 10000, 90000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối lần trả đầu thứ hai của cùng khoản nợ';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (lần trả đầu thứ hai): %', SQLERRM;
  END;
  -- Nối vào một số còn thiếu không lần trả nào để lại.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_before_vnd, remaining_vnd)
    VALUES (b1, 100000, 10000, 60000, 50000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối lần trả nối vào số còn thiếu không có thật';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (nối vào chỗ không có): %', SQLERRM;
  END;
  -- Trả 0 đồng.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, remaining_before_vnd, remaining_vnd)
    VALUES (b1, 100000, 70000, 70000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối một lần trả 0 đồng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (trả 0 đồng): %', SQLERRM;
  END;
  -- Trả thiếu mà quên khai số còn thiếu (mặc định 0 = trả đủ).
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_before_vnd) VALUES (b1, 100000, 10000, 70000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối lần trả thiếu mà khai còn thiếu 0';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (trả thiếu, quên khai còn thiếu): %', SQLERRM;
  END;
  -- Khai sai số còn thiếu: trả 10.000 từ 70.000 mà ghi còn 65.000.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_before_vnd, remaining_vnd)
    VALUES (b1, 100000, 10000, 70000, 65000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối số còn thiếu khác phép trừ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (số còn thiếu khai sai): %', SQLERRM;
  END;
  -- Trả vượt: 80.000 khi còn thiếu 70.000.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_before_vnd, remaining_vnd)
    VALUES (b1, 100000, 80000, 70000, -10000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối lần trả vượt số còn thiếu';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (trả vượt): %', SQLERRM;
  END;

  -- Thứ Năm 2026-09-24: trả 50.000 (20.000 tiền mặt + 30.000 chuyển khoản) ⇒ còn thiếu 20.000.
  INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, transfer_vnd, remaining_before_vnd, remaining_vnd,
                               booked_at, sale_date)
  VALUES (b1, 100000, 20000, 30000, 70000, 20000, '2026-09-24 16:00+07', '2026-09-24');

  -- Rẽ nhánh: một lần trả khác cũng nối vào 70.000 — hai lần trả cùng tính trên một số còn thiếu.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_before_vnd, remaining_vnd)
    VALUES (b1, 100000, 5000, 70000, 65000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối hai lần trả nối vào cùng một số còn thiếu';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (rẽ nhánh): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Đọc giữa chừng: còn thiếu bao nhiêu, đã trả xong chưa — đọc từ chuỗi, không cột trạng thái.
  SELECT b.debtor_name, b.debt_vnd,
         coalesce(min(c.remaining_vnd), b.debt_vnd) AS con_thieu,
         bool_or(c.remaining_vnd = 0) IS TRUE AS da_tra_xong,
         count(c.id) AS so_lan_tra
    INTO r FROM bill b LEFT JOIN debt_collection c ON c.bill_id = b.id WHERE b.id = b1
    GROUP BY b.id;
  RAISE NOTICE 'YC-02 sau hai lần trả: % nợ %, còn thiếu %, đã trả xong %, % lần trả',
    r.debtor_name, r.debt_vnd, r.con_thieu, r.da_tra_xong, r.so_lan_tra;
  IF r.con_thieu <> 20000 OR r.da_tra_xong OR r.so_lan_tra <> 2 THEN
    RAISE EXCEPTION 'YC-02: đọc giữa chừng sai — còn thiếu %, xong %, % lần', r.con_thieu, r.da_tra_xong, r.so_lan_tra;
  END IF;

  -- Thứ Bảy 2026-09-26: trả nốt 20.000 chuyển khoản ⇒ còn thiếu 0.
  INSERT INTO debt_collection (bill_id, debt_vnd, transfer_vnd, remaining_before_vnd, remaining_vnd,
                               booked_at, sale_date)
  VALUES (b1, 100000, 20000, 20000, 0, '2026-09-26 08:15+07', '2026-09-26');
  -- Trả thêm khi đã hết nợ.
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, remaining_before_vnd, remaining_vnd)
    VALUES (b1, 100000, 1000, 0, -1000);
    RAISE EXCEPTION 'YC-02: database KHÔNG từ chối lần trả sau khi đã hết nợ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-02 bị từ chối (trả khi đã hết nợ): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  SELECT coalesce(min(c.remaining_vnd), b.debt_vnd) AS con_thieu,
         bool_or(c.remaining_vnd = 0) IS TRUE AS da_tra_xong,
         string_agg(to_char(c.booked_at AT TIME ZONE 'Asia/Ho_Chi_Minh', 'DD/MM HH24:MI') || ' trả '
                    || (c.cash_vnd + c.transfer_vnd) || ' còn ' || c.remaining_vnd, ' · ' ORDER BY c.booked_at) AS cac_lan
    INTO r FROM bill b LEFT JOIN debt_collection c ON c.bill_id = b.id WHERE b.id = b1
    GROUP BY b.id;
  RAISE NOTICE 'YC-02 đọc lại sau năm ngày — tổng nợ 100000; %; còn thiếu %, đã trả xong %',
    r.cac_lan, r.con_thieu, r.da_tra_xong;
  IF r.con_thieu <> 0 OR NOT r.da_tra_xong THEN
    RAISE EXCEPTION 'YC-02: đọc cuối sai — còn thiếu %, xong %', r.con_thieu, r.da_tra_xong;
  END IF;

  -- I-014: doanh thu ở ngày ghi nợ, các ngày trả không có doanh thu; nợ cũ thu từng ngày cộng lại
  -- đúng số nợ. Hạng tử đối soát (ADR-075 điểm 5): mức nợ giảm của mỗi lần trả bằng tiền thực nhận.
  SELECT (SELECT COALESCE(SUM(due_vnd), 0) FROM bill WHERE id = b1 AND sale_date = '2026-09-21') AS doanh_thu_ngay_no,
         (SELECT COALESCE(SUM(due_vnd), 0) FROM bill WHERE id = b1 AND sale_date > '2026-09-21') AS doanh_thu_ngay_tra,
         (SELECT string_agg(sale_date || ': ' || s, ' · ' ORDER BY sale_date) FROM
            (SELECT sale_date, SUM(cash_vnd + transfer_vnd) AS s FROM debt_collection WHERE bill_id = b1 GROUP BY sale_date) x) AS no_cu_thu,
         (SELECT SUM(cash_vnd + transfer_vnd) FROM debt_collection WHERE bill_id = b1) AS tong_tra,
         (SELECT SUM(coalesce(remaining_before_vnd, debt_vnd) - remaining_vnd) FROM debt_collection WHERE bill_id = b1) AS tong_no_giam
    INTO r;
  RAISE NOTICE 'I-014 doanh thu ngày ghi nợ % · các ngày trả % · nợ cũ thu theo ngày (%) · tổng trả % = tổng nợ giảm %',
    r.doanh_thu_ngay_no, r.doanh_thu_ngay_tra, r.no_cu_thu, r.tong_tra, r.tong_no_giam;
  IF r.doanh_thu_ngay_no <> 250000 OR r.doanh_thu_ngay_tra <> 0 OR r.tong_tra <> 100000 OR r.tong_no_giam <> 100000 THEN
    RAISE EXCEPTION 'I-014: trả dần làm lệch doanh thu hoặc hạng tử nợ cũ thu';
  END IF;
END $$;
