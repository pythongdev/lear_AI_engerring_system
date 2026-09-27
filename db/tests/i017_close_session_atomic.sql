-- I-017 (tầng 2): phần lược đồ nợ — đóng phiên và đánh dấu mọi bàn của phiên sống
-- hoặc chết CÙNG MỘT giao dịch. Đọc trạng thái mọi đơn trong giao dịch ấy là việc
-- của thao tác đóng phiên ở pha 3. Lát: 02-luoc-do-ban-hang.md.
DO $$
DECLARE t4 bigint; t5 bigint; s1 bigint; st text;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-4') RETURNING id INTO t4;
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('awaiting_payment') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id)
  VALUES (s1, t4), (s1, t5);
  SET CONSTRAINTS table_session_member_session_fkey IMMEDIATE;
  SET CONSTRAINTS table_session_member_session_fkey DEFERRED;

  -- Cắt giữa chừng: phiên ghi "đã đóng", bàn 5 chưa được cập nhật.
  BEGIN
    UPDATE table_session SET status = 'closed' WHERE id = s1;
    UPDATE table_session_member SET session_closed = true
      WHERE table_session_id = s1 AND dining_table_id = t4;
    SET CONSTRAINTS table_session_member_session_fkey IMMEDIATE;
    RAISE EXCEPTION 'I-017: database KHÔNG từ chối đóng phiên nửa vời';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-017 bị từ chối (đóng phiên mà một bàn chưa theo): %', SQLERRM;
  END;
  SET CONSTRAINTS table_session_member_session_fkey DEFERRED;
  SELECT status INTO st FROM table_session WHERE id = s1;
  RAISE NOTICE 'I-017 sau lần cắt: phiên ở %, bàn đã đánh dấu đóng: % — không nửa nào sống sót',
    st, (SELECT COUNT(*) FROM table_session_member WHERE table_session_id = s1 AND session_closed);

  UPDATE table_session SET status = 'closed' WHERE id = s1;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s1;
  SET CONSTRAINTS table_session_member_session_fkey IMMEDIATE;
  SET CONSTRAINTS table_session_member_session_fkey DEFERRED;
  RAISE NOTICE 'I-017 đóng phiên cùng mọi bàn trong một giao dịch — được';
END $$;
