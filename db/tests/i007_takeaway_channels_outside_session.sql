-- I-007 · I-006 (tầng 1, một ranh giới, một cơ chế): đơn của ba kênh không gắn
-- bàn không thuộc phiên bàn nào, ở mọi thời điểm. Lát: 02-luoc-do-ban-hang.md.
DO $$
DECLARE t5 bigint; s1 bigint; o1 bigint;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);

  BEGIN
    -- Đủ liên hệ của I-022 (T-111): lời từ chối phải đến từ ranh giới phiên, không từ I-022.
    INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id,
                             handover_code, customer_phone, customer_needed_at)
    VALUES ('pickup', 'new', s1, t5, 'shop_pickup', '0900000000', now());
    RAISE EXCEPTION 'I-007: database KHÔNG từ chối đơn pickup tạo trong phiên bàn';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-007 bị từ chối (tạo đơn pickup trong phiên bàn): %', SQLERRM;
  END;

  -- Khách đặt hotline rồi tới quán ngồi: thử NỐI đơn cũ vào phiên bàn 5.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
  VALUES ('phone_preorder', 'confirmed', 'shop_pickup', '0900000000', now())
    RETURNING id INTO o1;
  BEGIN
    UPDATE sales_order SET table_session_id = s1, dining_table_id = t5 WHERE id = o1;
    RAISE EXCEPTION 'I-007: database KHÔNG từ chối nối đơn phone_preorder vào phiên bàn';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-007/I-006 bị từ chối (nối đơn không gắn bàn vào phiên): %', SQLERRM;
  END;

  BEGIN
    UPDATE sales_order SET channel_code = 'qr_table' WHERE id = o1;
    RAISE EXCEPTION 'I-007: database KHÔNG từ chối đổi kênh để lách ranh giới';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-007 bị từ chối (đổi kênh đơn lẻ thành kênh gắn bàn mà không có phiên): %', SQLERRM;
  END;
END $$;
