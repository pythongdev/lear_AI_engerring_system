-- QD-31 (tầng 1) — ngày bán của bốn bảng tiền khớp mốc tính tiền quy bằng múi giờ quán, database buộc lúc ghi (T-342, ADR-146).
-- Trước T-342 chỉ câu QD-31/b của bộ đối chiếu bắt lệch, sau khi tiền đã ghi; sale_date DEFAULT CURRENT_DATE và câu ghi
-- `$n::timestamptz::date` của backend đều lấy ngày theo múi giờ CỦA KẾT NỐI. Test giả một kết nối quên đặt múi giờ quán
-- (TimeZone = UTC): một hoá đơn lúc 00:30 giờ quán rơi vào ngày hôm trước theo UTC.
-- Múi giờ quán: master_plan/shop-facts.md §1 (`Asia/Ho_Chi_Minh`). Số tiền là số giả.
-- Viết trước migration (T-342, Claude Code, 2026-11-20): đỏ cho tới khi bốn ràng buộc được dựng.
--
-- Tên Claude chốt: <bảng>_sale_date_of_booked_at_check (ràng buộc kiểm, ERRCODE check_violation).

DO $$
DECLARE
  p bigint; s bigint; b bigint; t text; cname text;
  moc constant timestamptz := '2026-11-20 00:30:00+07';  -- 2026-11-19 17:30 UTC
BEGIN
  -- ------------------------------------------------------------------ đủ bốn ràng buộc, đúng múi giờ quán
  FOREACH t IN ARRAY ARRAY['bill', 'debt_collection', 'prepayment', 'refund'] LOOP
    SELECT pg_get_constraintdef(c.oid) INTO cname
      FROM pg_constraint c
     WHERE c.conrelid = format('shop.%I', t)::regclass AND c.contype = 'c'
       AND c.conname = t || '_sale_date_of_booked_at_check';
    IF cname IS NULL THEN
      RAISE EXCEPTION 'QD-31: bảng % chưa có ràng buộc %_sale_date_of_booked_at_check', t, t;
    END IF;
    IF position('sale_date' IN cname) = 0 OR position('booked_at' IN cname) = 0
       OR position('Asia/Ho_Chi_Minh' IN cname) = 0 THEN
      RAISE EXCEPTION 'QD-31: ràng buộc của % không quy booked_at bằng múi giờ quán: %', t, cname;
    END IF;
  END LOOP;
  RAISE NOTICE 'QD-31 ràng buộc: bill · debt_collection · prepayment · refund đều buộc sale_date = ngày quán của booked_at';

  -- ------------------------------------------------------------------ hành vi trên một kết nối sai múi giờ
  INSERT INTO person (display_name) VALUES ('test-T342 ngày bán') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  PERFORM set_config('TimeZone', 'UTC', true);
  INSERT INTO table_session (status) VALUES ('closed') RETURNING id INTO s;

  -- Ngày theo UTC của mốc — đúng thứ `$n::timestamptz::date` tính ra trên kết nối này.
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date)
    VALUES (s, 10000, 10000, moc, moc::date);
    RAISE EXCEPTION 'QD-31: database nhận hoá đơn 00:30 giờ quán mang ngày bán theo UTC (%)', moc::date;
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS cname = CONSTRAINT_NAME;
    IF cname IS DISTINCT FROM 'bill_sale_date_of_booked_at_check' THEN
      RAISE EXCEPTION 'QD-31: hoá đơn ngày UTC bị từ chối bởi % thay vì bill_sale_date_of_booked_at_check', cname;
    END IF;
    RAISE NOTICE 'QD-31 bị từ chối (ngày bán theo múi giờ kết nối UTC): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date)
    VALUES (s, 10000, 10000, moc, DATE '2026-11-21');
    RAISE EXCEPTION 'QD-31: database nhận hoá đơn mang ngày bán hôm sau của mốc';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS cname = CONSTRAINT_NAME;
    IF cname IS DISTINCT FROM 'bill_sale_date_of_booked_at_check' THEN
      RAISE EXCEPTION 'QD-31: hoá đơn ngày hôm sau bị từ chối bởi % thay vì bill_sale_date_of_booked_at_check', cname;
    END IF;
    RAISE NOTICE 'QD-31 bị từ chối (ngày bán hôm sau của mốc): %', SQLERRM;
  END;

  -- Ngày quán của mốc thì qua, dù kết nối đang ở UTC: ràng buộc không phụ thuộc múi giờ kết nối.
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (s, 10000, 10000, moc, DATE '2026-11-20') RETURNING id INTO b;
  RAISE NOTICE 'QD-31 hoá đơn 00:30 giờ quán ghi ngày bán 2026-11-20 trên kết nối UTC: qua';

  -- Dời ngày bán của hoá đơn đã ghi (đúng lỗi mà db/reconcile/proof/qd31_b.sql cài) bị từ chối ở nơi ghi.
  BEGIN
    UPDATE bill SET sale_date = sale_date + 1 WHERE id = b;
    RAISE EXCEPTION 'QD-31: database cho dời ngày bán của hoá đơn đã ghi sang hôm sau';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS cname = CONSTRAINT_NAME;
    IF cname IS DISTINCT FROM 'bill_sale_date_of_booked_at_check' THEN
      RAISE EXCEPTION 'QD-31: dời ngày bán bị từ chối bởi % thay vì bill_sale_date_of_booked_at_check', cname;
    END IF;
    RAISE NOTICE 'QD-31 bị từ chối (dời ngày bán của hoá đơn đã ghi): %', SQLERRM;
  END;

  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
