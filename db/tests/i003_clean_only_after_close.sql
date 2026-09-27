-- I-003 (tầng 3 — lược đồ không mở đường ghi thứ hai): trạng thái "Trống" của bàn
-- KHÔNG cất thành cột, mà đọc ra từ chi tiết. Để phép đọc ấy đúng, mốc đã dọn chỉ
-- ghi được cho một bàn của phiên đã đóng. Lát: 02-luoc-do-ban-hang.md.
DO $$
DECLARE t5 bigint; s1 bigint; m1 bigint;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('awaiting_payment') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5)
    RETURNING id INTO m1;
  BEGIN
    UPDATE table_session_member SET cleaned_at = now() WHERE id = m1;
    RAISE EXCEPTION 'I-003: database KHÔNG từ chối ghi đã dọn khi phiên còn chờ thanh toán';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-003 bị từ chối (dọn khi phiên chưa đóng): %', SQLERRM;
  END;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_schema = 'shop' AND table_name = 'dining_table'
                   AND column_name = 'status') THEN
    RAISE NOTICE 'I-003 bàn không có cột trạng thái cất sẵn — "Trống" chỉ đọc ra từ chi tiết';
  ELSE
    RAISE EXCEPTION 'I-003: dining_table có cột status — đường ghi thứ hai tới "Trống"';
  END IF;
END $$;
