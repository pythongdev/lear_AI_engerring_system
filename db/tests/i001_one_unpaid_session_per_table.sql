-- I-001 (tầng 1): một bàn thuộc nhiều nhất một phiên CHƯA ĐÓNG — phủ cả chờ
-- thanh toán; ghép bàn (một phiên nhiều bàn) vẫn được. Lát: 02-luoc-do-ban-hang.md.
DO $$
DECLARE t4 bigint; t5 bigint; s1 bigint; s2 bigint;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-4') RETURNING id INTO t4;
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t4);
  RAISE NOTICE 'I-001 ghép bàn: một phiên gắn hai bàn — được';

  -- Quầy bấm tính tiền: phiên sang chờ thanh toán, vẫn là phiên chưa đóng.
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s1;
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s2;
  BEGIN
    INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s2, t5);
    RAISE EXCEPTION 'I-001: database KHÔNG từ chối phiên thứ hai khi phiên cũ đang chờ thanh toán';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-001 bị từ chối (phiên cũ đang chờ thanh toán): %', SQLERRM;
  END;

  -- Ghép bàn 4 (đang thuộc phiên s1) vào một phiên khác: cùng ràng buộc chặn.
  BEGIN
    INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s2, t4);
    RAISE EXCEPTION 'I-001: database KHÔNG từ chối ghép một bàn đang có phiên vào phiên khác';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-001 bị từ chối (ghép bàn đang có phiên): %', SQLERRM;
  END;

  -- Đóng phiên đúng cách thì bàn nhận được phiên mới.
  UPDATE table_session SET status = 'closed' WHERE id = s1;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s1;
  SET CONSTRAINTS table_session_member_session_fkey IMMEDIATE;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s2, t5);
  SET CONSTRAINTS table_session_member_session_fkey DEFERRED;
  RAISE NOTICE 'I-001 sau khi phiên cũ đã đóng: bàn nhận phiên mới — được';
END $$;
