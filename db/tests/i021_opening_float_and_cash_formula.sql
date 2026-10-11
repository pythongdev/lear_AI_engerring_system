-- I-021 (tầng 1) và YC-23: mỗi ngày bán đúng MỘT con số tiền đầu két, ở ngoài tập tiền đã
-- thu; và mọi hạng tử của phép trừ két dựng lại được từ chi tiết — chạy trên đúng kịch bản
-- trả trước (đơn B · E), trả nợ và hoàn chéo của quality/invariants.md I-021.
-- Số tiền mặt ĐẾM ĐƯỢC cuối ngày chưa có chỗ cất (file lát §5) — test đưa nó vào như hằng số.
-- Lát: 04-luoc-do-duong-tien.md.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i021_opening_float_and_cash_formula', true); END $$;
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
DO $$
DECLARE t5 bigint; s1 bigint; oa bigint; ob bigint; oe bigint; oc bigint; od bigint; ow bigint; ot bigint;
        pb bigint; pe bigint; bb bigint; bt bigint; f1 bigint; rf bigint; d date; lech bigint; r record;
BEGIN
  -- Tiền đầu két: mỗi dòng một mệnh giá, con số của ngày là tổng các dòng (U-038).
  FOREACH d IN ARRAY ARRAY['2026-09-21', '2026-09-22', '2026-09-23']::date[] LOOP
    INSERT INTO opening_float (sale_date) VALUES (d) RETURNING id INTO f1;
    INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
    VALUES (f1, 50000, 600000), (f1, 20000, 300000), (f1, 10000, 100000),
           (f1, 5000, 100000), (f1, 2000, 60000), (f1, 1000, 40000);
  END LOOP;
  BEGIN
    INSERT INTO opening_float (sale_date) VALUES ('2026-09-21');
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối con số tiền đầu két thứ hai của một ngày';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (hai con số tiền đầu két một ngày): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f1, 500000, 700000);
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối một xấp 500.000 cộng ra 700.000';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (dòng mệnh giá không phải bội của mệnh giá): %', SQLERRM;
  END;

  -- Thứ Hai 2026-09-21: bán 800.000 tiền mặt (đơn A); bán 60.000 chuyển khoản (đơn T);
  -- nhận trả trước 50.000 tiền mặt cho đơn B và 40.000 chuyển khoản cho đơn E, lấy thứ Ba.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'completed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text) RETURNING id INTO oa;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (oa, 800000, 800000, '2026-09-21 08:00+07', '2026-09-21');
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'completed', 'shop_pickup', '0900000002', now(), gen_random_uuid()::text) RETURNING id INTO ot;
  INSERT INTO bill (sales_order_id, due_vnd, transfer_vnd, booked_at, sale_date)
  VALUES (ot, 60000, 60000, '2026-09-21 08:30+07', '2026-09-21') RETURNING id INTO bt;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('phone_preorder', 'confirmed', 'shop_pickup', '0900000003', '2026-09-22 07:00+07', gen_random_uuid()::text) RETURNING id INTO ob;
  INSERT INTO prepayment (sales_order_id, cash_vnd, booked_at, sale_date)
  VALUES (ob, 50000, '2026-09-21 10:00+07', '2026-09-21') RETURNING id INTO pb;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('phone_preorder', 'confirmed', 'shop_pickup', '0900000004', '2026-09-22 07:30+07', gen_random_uuid()::text) RETURNING id INTO oe;
  INSERT INTO prepayment (sales_order_id, transfer_vnd, booked_at, sale_date)
  VALUES (oe, 40000, '2026-09-21 10:05+07', '2026-09-21') RETURNING id INTO pe;

  -- Thứ Ba 2026-09-22: bán 700.000 tiền mặt (đơn C); đơn B đóng, 50.000 trả trước thành doanh
  -- thu; đơn E huỷ, POS trả lại 40.000 bằng tiền mặt trong két; bàn 5 ghi nợ 100.000.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'completed', 'shop_pickup', '0900000005', now(), gen_random_uuid()::text) RETURNING id INTO oc;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (oc, 700000, 700000, '2026-09-22 08:00+07', '2026-09-22');
  INSERT INTO bill (sales_order_id, due_vnd, prepaid_cash_vnd, booked_at, sale_date)
  VALUES (ob, 50000, 50000, '2026-09-22 07:05+07', '2026-09-22') RETURNING id INTO bb;
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_cash_vnd, bill_id)
  VALUES (pb, ob, 1, 50000, 0, 50000, bb);
  UPDATE sales_order SET status = 'completed' WHERE id = ob;
  INSERT INTO refund (prepayment_id, amount_vnd, method_code, reason, booked_at, sale_date)
  VALUES (pe, 40000, 'cash', 'khách huỷ đơn đặt trước', '2026-09-22 06:30+07', '2026-09-22') RETURNING id INTO rf;
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd, take_transfer_vnd, refund_id)
  VALUES (pe, oe, 1, 0, 40000, 40000, rf);
  UPDATE sales_order SET status = 'cancelled' WHERE id = oe;
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('closed') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id, session_closed) VALUES (s1, t5, true);
  INSERT INTO bill (table_session_id, due_vnd, debt_vnd, debtor_name, booked_at, sale_date)
  VALUES (s1, 100000, 100000, 'Chú Tư', '2026-09-22 09:00+07', '2026-09-22');

  -- Thứ Tư 2026-09-23: bán 800.000 tiền mặt (đơn W); Chú Tư trả 100.000 nợ bằng tiền mặt;
  -- khách đơn T (đã chuyển khoản thứ Hai) được POS hoàn 60.000 bằng TIỀN MẶT — hoàn chéo.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'completed', 'shop_pickup', '0900000006', now(), gen_random_uuid()::text) RETURNING id INTO ow;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (ow, 800000, 800000, '2026-09-23 08:00+07', '2026-09-23');
  INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, booked_at, sale_date)
  SELECT id, debt_vnd, debt_vnd, '2026-09-23 10:00+07', '2026-09-23' FROM bill WHERE table_session_id = s1;
  INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason, booked_at, sale_date)
  VALUES (bt, 60000, 'cash', 'transfer', 'khách phản ánh thiếu món', '2026-09-23 09:30+07', '2026-09-23');

  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Ba danh sách trả trước của YC-23, từng khoản.
  FOR r IN SELECT 'nhận' AS ds, p.sale_date AS ngay, p.sales_order_id AS don, p.cash_vnd AS tien_mat, p.transfer_vnd AS chuyen_khoan
             FROM prepayment p
           UNION ALL
           SELECT 'thành doanh thu', b.sale_date, u.sales_order_id, u.take_cash_vnd, u.take_transfer_vnd
             FROM prepayment_use u JOIN bill b ON b.id = u.bill_id
           UNION ALL
           SELECT 'trả lại (trả bằng ' || f.method_code || ')', f.sale_date, u.sales_order_id,
                  CASE f.method_code WHEN 'cash' THEN f.amount_vnd ELSE 0 END,
                  CASE f.method_code WHEN 'transfer' THEN f.amount_vnd ELSE 0 END
             FROM prepayment_use u JOIN refund f ON f.id = u.refund_id
           ORDER BY 2, 1 LOOP
    RAISE NOTICE 'YC-23 % ngày % — đơn %: tiền mặt %, chuyển khoản %', r.ds, r.ngay, r.don, r.tien_mat, r.chuyen_khoan;
  END LOOP;

  -- Công thức I-021, từng hạng tử cộng lại từ chi tiết, cho từng ngày.
  FOR r IN
    WITH ngay(d, dem_duoc) AS (VALUES ('2026-09-21'::date, 2050000::bigint),
                                      ('2026-09-22'::date, 1860000::bigint),
                                      ('2026-09-23'::date, 2040000::bigint))
    SELECT n.d, n.dem_duoc,
      (SELECT SUM(l.amount_vnd) FROM opening_float o JOIN opening_float_line l ON l.opening_float_id = o.id
        WHERE o.sale_date = n.d) AS dau_ket,
      -- doanh thu TIỀN MẶT: phần tiền mặt của hoá đơn đóng hôm ấy (kể cả phần trả trước nhận
      -- bằng tiền mặt) trừ hoàn cho khoản đã thu bằng tiền mặt.
      (SELECT COALESCE(SUM(cash_vnd + prepaid_cash_vnd), 0) FROM bill WHERE sale_date = n.d)
      - (SELECT COALESCE(SUM(amount_vnd), 0) FROM refund
          WHERE bill_id IS NOT NULL AND source_method_code = 'cash' AND sale_date = n.d) AS dt_tien_mat,
      (SELECT COALESCE(SUM(amount_vnd), 0) FROM refund WHERE bill_id IS NOT NULL
          AND method_code = 'cash' AND source_method_code = 'transfer' AND sale_date = n.d) AS hoan_mat_cho_ck,
      (SELECT COALESCE(SUM(amount_vnd), 0) FROM refund WHERE bill_id IS NOT NULL
          AND method_code = 'transfer' AND source_method_code = 'cash' AND sale_date = n.d) AS hoan_ck_cho_mat,
      (SELECT COALESCE(SUM(cash_vnd), 0) FROM debt_collection WHERE sale_date = n.d) AS no_cu_mat,
      (SELECT COALESCE(SUM(cash_vnd), 0) FROM prepayment WHERE sale_date = n.d) AS tt_nhan_mat,
      (SELECT COALESCE(SUM(prepaid_cash_vnd), 0) FROM bill WHERE sale_date = n.d) AS tt_thanh_dt_mat,
      (SELECT COALESCE(SUM(amount_vnd), 0) FROM refund WHERE prepayment_id IS NOT NULL
          AND method_code = 'cash' AND sale_date = n.d) AS tt_tra_lai_mat
    FROM ngay n ORDER BY n.d
  LOOP
    lech := (r.dem_duoc - r.dau_ket)
          - (r.dt_tien_mat - r.hoan_mat_cho_ck + r.hoan_ck_cho_mat + r.no_cu_mat
             + r.tt_nhan_mat - r.tt_thanh_dt_mat - r.tt_tra_lai_mat);
    RAISE NOTICE 'I-021 ngày %: két % − đầu két % = % · vế phải = dt tiền mặt % − hoàn mặt cho CK % + hoàn CK cho mặt % + nợ cũ mặt % + TT nhận mặt % − TT thành dt mặt % − TT trả lại mặt % ⇒ lệch %',
      r.d, r.dem_duoc, r.dau_ket, r.dem_duoc - r.dau_ket, r.dt_tien_mat, r.hoan_mat_cho_ck, r.hoan_ck_cho_mat,
      r.no_cu_mat, r.tt_nhan_mat, r.tt_thanh_dt_mat, r.tt_tra_lai_mat, lech;
    IF lech <> 0 THEN RAISE EXCEPTION 'I-021: ngày % lệch % đồng', r.d, lech; END IF;
    -- Bỏ một hạng tử khác 0 thì ngày ấy phải đỏ đúng bằng hạng tử ấy.
    IF r.tt_nhan_mat <> 0 THEN
      RAISE NOTICE 'I-021 ngày %: bỏ hạng tử "trả trước nhận bằng tiền mặt" ⇒ lệch %', r.d, r.tt_nhan_mat; END IF;
    IF r.tt_tra_lai_mat <> 0 THEN
      RAISE NOTICE 'I-021 ngày %: bỏ hạng tử "trả trước trả lại bằng tiền mặt" ⇒ lệch %', r.d, -r.tt_tra_lai_mat; END IF;
    IF r.no_cu_mat <> 0 THEN
      RAISE NOTICE 'I-021 ngày %: bỏ hạng tử "nợ cũ thu bằng tiền mặt" ⇒ lệch %', r.d, r.no_cu_mat; END IF;
    IF r.hoan_mat_cho_ck <> 0 THEN
      RAISE NOTICE 'I-021 ngày %: bỏ hạng tử "hoàn mặt cho khoản CK" ⇒ lệch %', r.d, -r.hoan_mat_cho_ck; END IF;
  END LOOP;

  -- I-014: doanh thu = hoá đơn đóng hôm ấy − hoàn cho lần bán hôm ấy; trả trước, trả lại trả
  -- trước và thu nợ không nằm trong nó.
  FOR r IN SELECT u.ngay,
             (SELECT COALESCE(SUM(due_vnd), 0) FROM bill WHERE sale_date = u.ngay)
             - (SELECT COALESCE(SUM(amount_vnd), 0) FROM refund WHERE bill_id IS NOT NULL AND sale_date = u.ngay) AS dt
           FROM unnest(ARRAY['2026-09-21', '2026-09-22', '2026-09-23']::date[]) AS u(ngay) LOOP
    RAISE NOTICE 'I-014 doanh thu ngày %: %', r.ngay, r.dt;
  END LOOP;
  IF (SELECT SUM(due_vnd) FROM bill WHERE sale_date = '2026-09-21') <> 860000
     OR (SELECT SUM(due_vnd) FROM bill WHERE sale_date = '2026-09-22') <> 850000 THEN
    RAISE EXCEPTION 'I-014: khoản trả trước vào doanh thu ngày nhận, hoặc lần trả lại trừ doanh thu';
  END IF;
END $$;
