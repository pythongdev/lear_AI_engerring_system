-- I-012 (tầng 1 · tầng 4) và YC-04 · YC-12: mọi thao tác chạm tiền — và mẻ, lần lùi mẻ, lần cấp
-- mã QR — mang AI BẤM; thiếu thì database từ chối. Người bấm ở quầy phải là người đang đứng quầy lúc
-- ấy: máy không ngăn được (tầng 4 — hai người chung một chỗ đứng), câu đối chiếu bắt. Người đi giao
-- bấm "đã giao + đã thu tiền" tại chỗ khách, POS khai tên (shop-facts §8.8, U-057).
-- Lát: 06-luoc-do-nguoi-va-vet.md.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i012_money_operation_names_a_person', true); END $$;

-- Thao tác chạm tiền ở quầy mà người bấm không phải người đứng quầy lúc bấm — P2-11 gom. Hai ca
-- không bấm ở quầy đứng ngoài: hoá đơn nhập bù (người bấm là người nhập, 06-… §2 hàng YC-08) và
-- hoá đơn đơn giao tận nơi (người đi giao thu tại chỗ khách).
CREATE FUNCTION pg_temp.doi_chieu_i012() RETURNS TABLE (bang text, dong bigint, nguoi_bam text,
  dang_truc text) LANGUAGE sql AS $f$
  WITH op AS (
    SELECT 'bill' AS bang, b.id, b.person_id, b.booked_at
    FROM bill b LEFT JOIN sales_order o ON o.id = b.sales_order_id
    WHERE b.paper_ledger_id IS NULL AND o.handover_code IS DISTINCT FROM 'door_delivery'
    UNION ALL SELECT 'debt_collection', id, person_id, booked_at FROM debt_collection
    UNION ALL SELECT 'prepayment', id, person_id, booked_at FROM prepayment
    UNION ALL SELECT 'refund', id, person_id, booked_at FROM refund)
  SELECT op.bang, op.id, p.display_name, q.display_name
  FROM op JOIN person p ON p.id = op.person_id
  LEFT JOIN counter_duty d ON tstzrange(d.started_at, d.ended_at, '[)') @> op.booked_at
  LEFT JOIN person q ON q.id = d.person_id
  WHERE d.person_id IS DISTINCT FROM op.person_id
$f$;

DO $$
DECLARE a bigint; chu bigint; giao bigint; o1 bigint; o2 bigint; o3 bigint; o4 bigint; b1 bigint; b3 bigint;
        b4 bigint;
        pb bigint; t5 bigint; r record; n integer;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-A đứng quầy') RETURNING id INTO a;
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  INSERT INTO person (display_name) VALUES ('test-người đi giao') RETURNING id INTO giao;
  INSERT INTO counter_duty (person_id, started_at) VALUES (a, now() - interval '1 hour');
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;

  -- Không khai người thao tác: mỗi bảng từ chối lần ghi (I-012 tầng 1 — thiếu "ai bấm").
  PERFORM set_config('shop.actor_person_id', '', true);
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text)
  RETURNING id INTO o1;
  BEGIN
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd) VALUES (o1, 50000, 50000);
    RAISE EXCEPTION 'I-012: database KHÔNG từ chối lần thu không có người bấm';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-012 bị từ chối (thu tiền, không ai bấm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO prepayment (sales_order_id, cash_vnd) VALUES (o1, 20000);
    RAISE EXCEPTION 'I-012: database KHÔNG từ chối khoản trả trước không có người nhận';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-012 bị từ chối (nhận trả trước, không ai bấm): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO opening_float (sale_date) VALUES (CURRENT_DATE);
    RAISE EXCEPTION 'I-012: database KHÔNG từ chối tiền đầu két không có người khai';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-012 bị từ chối (tiền đầu két, không ai khai): %', SQLERRM;
  END;
  BEGIN
    PERFORM qr_code_issue(t5);
    RAISE EXCEPTION 'I-023: database KHÔNG từ chối cấp mã QR không có người cấp';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-023 bị từ chối (cấp mã QR, không ai cấp): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO production_batch DEFAULT VALUES;
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối mẻ không có người bấm';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (bấm mẻ, không ai bấm): %', SQLERRM;
  END;

  -- A đứng quầy khai mình là người thao tác: thu tiền đơn 1, và ghi được.
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd) VALUES (o1, 50000, 50000) RETURNING id INTO b1;
  UPDATE sales_order SET status = 'completed' WHERE id = o1;
  -- Đơn 4 ghi nợ 20.000 (người nợ có tên, I-005) để có một khoản nợ mà thu.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000004', now(), gen_random_uuid()::text)
  RETURNING id INTO o4;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, debt_vnd, debtor_name, debt_note)
  VALUES (o4, 50000, 30000, 20000, 'test-chú Tư', 'test-nợ đơn lẻ, hẹn trả sau (T-140)') RETURNING id INTO b4;
  UPDATE sales_order SET status = 'completed' WHERE id = o4;
  BEGIN
    INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd, person_id) VALUES (b4, 20000, 20000, NULL);
    RAISE EXCEPTION 'I-012: database KHÔNG từ chối lần thu nợ ghi tường minh không người';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-012 bị từ chối (thu nợ, người bấm để trống tường minh): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason, person_id)
    VALUES (b1, 10000, 'cash', 'cash', 'test-nhầm món', NULL);
    RAISE EXCEPTION 'I-012: database KHÔNG từ chối lần hoàn không người bấm';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-012 bị từ chối (hoàn tiền, không ai bấm): %', SQLERRM;
  END;
  INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO pb;
  BEGIN
    UPDATE production_batch SET rolled_back_at = clock_timestamp() WHERE id = pb;
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối lần lùi mẻ không có người lùi';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (lùi mẻ, không ai lùi): %', SQLERRM;
  END;

  -- Người đi giao thu tiền tại chỗ khách: POS khai tên người ấy (U-057), không phải A.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, delivery_address,
                           customer_needed_at, submission_code)
  VALUES ('delivery', 'delivering', 'door_delivery', '0900000002', 'test-12 Hàng Bạc', now(),
          gen_random_uuid()::text) RETURNING id INTO o2;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, person_id) VALUES (o2, 70000, 70000, giao);
  UPDATE sales_order SET status = 'completed' WHERE id = o2;

  -- Chủ quán KHÔNG đứng quầy mà tự bấm hoàn cho đơn 3 (§6.13: phải nhờ người đứng quầy). Máy nhận
  -- (tầng 4); câu đối chiếu gọi đúng thao tác ấy bằng tên người bấm và người đang đứng quầy.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000003', now(), gen_random_uuid()::text)
  RETURNING id INTO o3;
  INSERT INTO bill (sales_order_id, due_vnd, transfer_vnd) VALUES (o3, 40000, 40000) RETURNING id INTO b3;
  UPDATE sales_order SET status = 'completed' WHERE id = o3;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  IF EXISTS (SELECT 1 FROM pg_temp.doi_chieu_i012()) THEN
    RAISE EXCEPTION 'I-012: tập đối chiếu không rỗng trước khi cài lỗi';
  END IF;
  RAISE NOTICE 'I-012 đối chiếu trước khi cài lỗi: rỗng (hoá đơn người đi giao đứng ngoài tập)';
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason)
  VALUES (b3, 40000, 'cash', 'transfer', 'test-khách đổi ý');

  -- YC-04: mỗi thao tác đọc ra người bấm VÀ người đang đứng quầy lúc ấy — không phải chức vụ.
  FOR r IN
    SELECT x.bang, x.id, p.display_name AS bam, q.display_name AS truc
    FROM (SELECT 'bill' AS bang, id, person_id, booked_at FROM bill
          UNION ALL SELECT 'refund', id, person_id, booked_at FROM refund) x
    JOIN person p ON p.id = x.person_id
    LEFT JOIN counter_duty d ON tstzrange(d.started_at, d.ended_at, '[)') @> x.booked_at
    LEFT JOIN person q ON q.id = d.person_id
    ORDER BY x.bang, x.id
  LOOP
    RAISE NOTICE 'YC-04 % % — người bấm: %, đang đứng quầy: %', r.bang, r.id, r.bam, r.truc;
  END LOOP;
  n := 0;
  FOR r IN SELECT * FROM pg_temp.doi_chieu_i012() LOOP
    n := n + 1;
    RAISE NOTICE 'I-012 đối chiếu biết kêu — % %: người bấm %, người đứng quầy lúc ấy %',
      r.bang, r.dong, r.nguoi_bam, r.dang_truc;
  END LOOP;
  IF n <> 1 THEN
    RAISE EXCEPTION 'I-012: câu đối chiếu phải bắt đúng MỘT thao tác (chủ quán hoàn khi không đứng quầy), được %', n;
  END IF;
END $$;
