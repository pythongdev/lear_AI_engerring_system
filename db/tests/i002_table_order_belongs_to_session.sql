-- I-002 (tầng 1, vế một phiên một hoá đơn): đơn của kênh gắn bàn không đứng ngoài
-- phiên thành một đơn vị tính tiền thứ hai, và bàn gửi đơn phải là bàn của chính
-- phiên ấy. Lát: 02-luoc-do-ban-hang.md.
DO $$
DECLARE t5 bigint; t7 bigint; s1 bigint; q5 bigint;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  q5 := qr_code_issue(t5);  -- lượt gọi qr_table mang mã của bàn (I-023, T-114)
  INSERT INTO dining_table (label) VALUES ('test-7') RETURNING id INTO t7;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);

  BEGIN
    INSERT INTO sales_order (channel_code, status, submission_code, qr_code_id)
    VALUES ('qr_table', 'new', gen_random_uuid()::text, q5);
    RAISE EXCEPTION 'I-002: database KHÔNG từ chối đơn qr_table không thuộc phiên nào';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-002 bị từ chối (đơn kênh gắn bàn không có phiên): %', SQLERRM;
  END;

  BEGIN
    INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
    VALUES ('staff_pos', 'confirmed', s1, t7, gen_random_uuid()::text);
    RAISE EXCEPTION 'I-002: database KHÔNG từ chối đơn của bàn 7 đổ vào phiên của bàn 5';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-002 bị từ chối (bàn không thuộc phiên): %', SQLERRM;
  END;

  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code, qr_code_id)
  VALUES ('qr_table', 'new', s1, t5, gen_random_uuid()::text, q5),
         ('staff_pos', 'confirmed', s1, t5, gen_random_uuid()::text, NULL);
  RAISE NOTICE 'I-002 hai lượt gọi QR + POS của bàn 5: % đơn, % phiên',
    (SELECT COUNT(*) FROM sales_order WHERE table_session_id = s1),
    (SELECT COUNT(DISTINCT table_session_id) FROM sales_order WHERE table_session_id = s1);
END $$;
