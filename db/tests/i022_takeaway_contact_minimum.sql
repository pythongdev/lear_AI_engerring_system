-- I-022 (tầng 1): đơn của ba kênh không gắn bàn không tồn tại được khi thiếu một
-- trường liên hệ mà kênh và cách trao hàng của nó đòi — lúc tạo LẪN lúc sửa.
-- Kịch bản: quality/invariants.md I-022 Verification. Lát: 02-luoc-do-ban-hang.md §2.
-- Mỗi kịch bản âm phải bị từ chối bởi ĐÚNG ràng buộc nó nhắm, không phải một ràng
-- buộc khác tình cờ chặn hộ.
CREATE FUNCTION pg_temp.expect_reject(label text, stmt text, want text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE got text;
BEGIN
  BEGIN
    EXECUTE stmt;
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS got = CONSTRAINT_NAME;
    IF got IS DISTINCT FROM want THEN
      RAISE EXCEPTION 'I-022 (%): bị chặn bởi % thay vì %', label, got, want;
    END IF;
    RAISE NOTICE 'I-022 bị từ chối (%): %', label, SQLERRM;
    RETURN;
  END;
  RAISE EXCEPTION 'I-022: database KHÔNG từ chối — %', label;
END $$;

DO $$
DECLARE d1 bigint; t5 bigint; s1 bigint; n bigint;
BEGIN
  -- Kịch bản âm, một vế một lần.
  PERFORM pg_temp.expect_reject('Delivery thiếu địa chỉ',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone)
       VALUES ('delivery', 'pending_confirmation', 'door_delivery', '0900000001')$q$,
    'sales_order_door_delivery_address_check');
  PERFORM pg_temp.expect_reject('Pickup thiếu giờ hẹn lấy',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone)
       VALUES ('pickup', 'pending_confirmation', 'shop_pickup', '0900000002')$q$,
    'sales_order_takeaway_needed_at_check');
  PERFORM pg_temp.expect_reject('Delivery thiếu số điện thoại',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, delivery_address)
       VALUES ('delivery', 'pending_confirmation', 'door_delivery', '12 Hàng Bạc')$q$,
    'sales_order_takeaway_phone_check');
  PERFORM pg_temp.expect_reject('Pickup thiếu số điện thoại',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_needed_at)
       VALUES ('pickup', 'pending_confirmation', 'shop_pickup', now())$q$,
    'sales_order_takeaway_phone_check');
  PERFORM pg_temp.expect_reject('hotline thiếu số điện thoại',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_needed_at)
       VALUES ('phone_preorder', 'confirmed', 'shop_pickup', now())$q$,
    'sales_order_takeaway_phone_check');
  PERFORM pg_temp.expect_reject('hotline số điện thoại chỉ có khoảng trắng',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
       VALUES ('phone_preorder', 'confirmed', 'shop_pickup', '   ', now())$q$,
    'sales_order_takeaway_phone_check');
  PERFORM pg_temp.expect_reject('hotline chưa có cách trao hàng',
    $q$INSERT INTO sales_order (channel_code, status, customer_phone, customer_needed_at)
       VALUES ('phone_preorder', 'confirmed', '0900000003', now())$q$,
    'sales_order_takeaway_handover_check');
  PERFORM pg_temp.expect_reject('hotline chọn giao mà thiếu địa chỉ',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
       VALUES ('phone_preorder', 'confirmed', 'door_delivery', '0900000004', now())$q$,
    'sales_order_door_delivery_address_check');
  -- Vế "Delivery là giao, Pickup là tới lấy" — lách vế địa chỉ bằng nhánh sai.
  PERFORM pg_temp.expect_reject('Delivery mang nhánh tới lấy',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone)
       VALUES ('delivery', 'pending_confirmation', 'shop_pickup', '0900000005')$q$,
    'sales_order_takeaway_handover_check');
  PERFORM pg_temp.expect_reject('Pickup mang nhánh giao',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone,
                                delivery_address, customer_needed_at)
       VALUES ('pickup', 'pending_confirmation', 'door_delivery', '0900000006', '12 Hàng Bạc', now())$q$,
    'sales_order_takeaway_handover_check');

  -- Kịch bản dương, chống đọc rộng.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
  VALUES ('phone_preorder', 'confirmed', 'shop_pickup', '0900000007', now());
  RAISE NOTICE 'I-022 tạo được: hotline tới lấy, có số và giờ, không địa chỉ';
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
  VALUES ('pickup', 'pending_confirmation', 'shop_pickup', '0900000008', now());
  RAISE NOTICE 'I-022 tạo được: Pickup không địa chỉ';
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, delivery_address)
  VALUES ('delivery', 'pending_confirmation', 'door_delivery', '0900000009', '12 Hàng Bạc')
  RETURNING id INTO d1;
  RAISE NOTICE 'I-022 tạo được: Delivery không giờ khách cần hàng, không tên';
  -- Mệnh đề không áp cho kênh gắn bàn: khách ngồi bàn ẩn danh theo số bàn.
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id)
  VALUES ('qr_table', 'new', s1, t5);
  RAISE NOTICE 'I-022 không áp: đơn qr_table không liên hệ nào vẫn tạo được';

  -- Kịch bản sửa: mệnh đề giữ ở MỌI thời điểm, không chỉ lúc tạo.
  PERFORM pg_temp.expect_reject('xoá trắng địa chỉ của một Delivery đã tạo',
    format($q$UPDATE sales_order SET delivery_address = '' WHERE id = %s$q$, d1),
    'sales_order_door_delivery_address_check');
  PERFORM pg_temp.expect_reject('xoá hẳn số điện thoại của một Delivery đã tạo',
    format($q$UPDATE sales_order SET customer_phone = NULL WHERE id = %s$q$, d1),
    'sales_order_takeaway_phone_check');

  -- Năm tập đối chiếu của hàng I-022 (03-bao-ve-invariant.md §2). Mỗi tập phải rỗng.
  SELECT count(*) INTO n FROM sales_order
   WHERE channel_code IN ('delivery', 'pickup', 'phone_preorder')
     AND btrim(coalesce(customer_phone, '')) = '';
  IF n > 0 THEN RAISE EXCEPTION 'I-022 đối chiếu 1: % đơn mang đi không có số điện thoại', n; END IF;
  SELECT count(*) INTO n FROM sales_order
   WHERE handover_code = 'door_delivery'
     AND btrim(coalesce(delivery_address, '')) = '';
  IF n > 0 THEN RAISE EXCEPTION 'I-022 đối chiếu 2: % đơn giao tận nơi không có địa chỉ', n; END IF;
  SELECT count(*) INTO n FROM sales_order
   WHERE channel_code IN ('pickup', 'phone_preorder') AND customer_needed_at IS NULL;
  IF n > 0 THEN RAISE EXCEPTION 'I-022 đối chiếu 3: % đơn Pickup/hotline không có giờ', n; END IF;
  SELECT count(*) INTO n FROM sales_order
   WHERE channel_code = 'phone_preorder'
     AND handover_code IS DISTINCT FROM 'door_delivery'
     AND handover_code IS DISTINCT FROM 'shop_pickup';
  IF n > 0 THEN RAISE EXCEPTION 'I-022 đối chiếu 4: % đơn hotline không đúng một cách trao hàng', n; END IF;
  SELECT count(*) INTO n FROM sales_order
   WHERE (channel_code = 'delivery' AND handover_code IS DISTINCT FROM 'door_delivery')
      OR (channel_code = 'pickup'   AND handover_code IS DISTINCT FROM 'shop_pickup');
  IF n > 0 THEN RAISE EXCEPTION 'I-022 đối chiếu 5: % đơn Delivery/Pickup mang nhánh sai', n; END IF;
  RAISE NOTICE 'I-022 đối chiếu: năm tập đều rỗng';
END $$;
