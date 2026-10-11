-- YC-01 · I-012: mỗi lần hoàn tiền đọc lại được sau nhiều ngày — bao nhiêu · cho lượt bán
-- nào · lúc mấy giờ · lý do · trả lại bằng gì; thiếu lý do là không ghi được. Vế "ai bấm" là
-- chỗ trống có tên — bảng người là của P2-08. Lát: 04-luoc-do-duong-tien.md.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-yc01_refund_trace', true); END $$;
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
DO $$
DECLARE o1 bigint; b1 bigint; rf bigint; r record;
BEGIN
  -- Thứ Hai 2026-09-21: bán một đơn tới lấy, khách chuyển khoản 60.000.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text) RETURNING id INTO o1;
  INSERT INTO bill (sales_order_id, due_vnd, transfer_vnd, booked_at, sale_date)
  VALUES (o1, 60000, 60000, '2026-09-21 07:15+07', '2026-09-21') RETURNING id INTO b1;
  UPDATE sales_order SET status = 'completed' WHERE id = o1;

  BEGIN
    INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code) VALUES (b1, 60000, 'cash', 'transfer');
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối lần hoàn không lý do';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'YC-01 bị từ chối (hoàn không lý do): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason) VALUES (b1, 60000, 'cash', 'transfer', '  ');
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối lý do chỉ có khoảng trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-01 bị từ chối (lý do trắng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason) VALUES (b1, 0, 'cash', 'transfer', 'nhầm món');
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối lần hoàn 0 đồng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-01 bị từ chối (hoàn 0 đồng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO refund (amount_vnd, method_code, reason) VALUES (60000, 'cash', 'nhầm món');
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối lần hoàn không gắn lượt bán nào';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-01 bị từ chối (hoàn không cho lượt bán nào): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO refund (bill_id, amount_vnd, source_method_code, reason) VALUES (b1, 60000, 'transfer', 'nhầm món');
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối lần hoàn không ghi trả lại bằng gì';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'YC-01 bị từ chối (không ghi trả lại bằng gì): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason) VALUES (b1, 60000, 'voucher', 'transfer', 'nhầm món');
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối trả lại bằng phương thức thứ ba';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-01 bị từ chối (trả lại bằng phương thức thứ ba): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO refund (bill_id, amount_vnd, method_code, reason) VALUES (b1, 60000, 'cash', 'nhầm món');
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối hoàn cho lần bán mà không ghi khoản ấy đã thu bằng gì';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (không đọc ra được hoàn chéo): %', SQLERRM;
  END;

  -- Thứ Tư 2026-09-23: POS hoàn tiền mặt cho khoản đã chuyển khoản — hoàn CHÉO.
  INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason, booked_at, sale_date)
  VALUES (b1, 60000, 'cash', 'transfer', 'bánh nguội, khách không nhận', '2026-09-23 08:40+07', '2026-09-23')
  RETURNING id INTO rf;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Đọc lại từ một câu truy vấn, không từ biến vừa ghi.
  SELECT f.amount_vnd, b.sales_order_id, b.sale_date AS ngay_ban, f.booked_at, f.sale_date AS ngay_hoan,
         f.reason, f.method_code, f.source_method_code
    INTO r FROM refund f JOIN bill b ON b.id = f.bill_id WHERE f.id = rf;
  RAISE NOTICE 'YC-01 đọc lại: hoàn % cho đơn % (bán ngày %) lúc % (ngày hoàn %), lý do "%", trả lại bằng %, khoản ấy đã thu bằng % — "ai bấm" chờ P2-08',
    r.amount_vnd, r.sales_order_id, r.ngay_ban, r.booked_at, r.ngay_hoan, r.reason, r.method_code, r.source_method_code;
  RAISE NOTICE 'I-014 doanh thu thứ Hai % · thứ Tư % (hoàn trừ ngày hoàn, ngày bán giữ nguyên)',
    (SELECT SUM(due_vnd) FROM bill WHERE sale_date = '2026-09-21'),
    - (SELECT SUM(amount_vnd) FROM refund WHERE bill_id IS NOT NULL AND sale_date = '2026-09-23');

  -- Vết sống độc lập với bản ghi nó nói về: hệ thống không xoá được vết (QD-50), và cả chủ
  -- bảng cũng không xoá được lần bán mà vết đang trỏ tới (QD-51).
  BEGIN
    EXECUTE 'SET LOCAL ROLE shop_app';
    DELETE FROM refund WHERE id = rf;
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối xoá vết hoàn tiền';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'YC-01 bị từ chối (shop_app xoá vết hoàn): %', SQLERRM;
  END;
  BEGIN
    DELETE FROM bill WHERE id = b1;
    RAISE EXCEPTION 'YC-01: database KHÔNG từ chối xoá lần bán đang có vết hoàn';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-01 bị từ chối (xoá lần bán mà vết hoàn trỏ tới): %', SQLERRM;
  END;

  -- Phép đối chiếu (P2-11 gom): lần hoàn thiếu một trong năm thứ viết được hôm nay — rỗng.
  IF EXISTS (SELECT 1 FROM refund
             WHERE amount_vnd IS NULL OR num_nonnulls(bill_id, prepayment_id) <> 1 OR booked_at IS NULL
                OR btrim(coalesce(reason, '')) = '' OR method_code IS NULL) THEN
    RAISE EXCEPTION 'YC-01: tập đối chiếu không rỗng';
  END IF;
  RAISE NOTICE 'YC-01 đối chiếu: tập "lần hoàn thiếu bao nhiêu · lượt bán · lúc · lý do · trả bằng gì" rỗng';
END $$;
