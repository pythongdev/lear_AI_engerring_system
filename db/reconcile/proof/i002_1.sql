-- kêu: I-002/1
-- Khoá "phiên đã đóng phải có hoá đơn" bị gỡ; phiên bàn 10 đóng mà không hoá đơn nào.
ALTER TABLE table_session DROP CONSTRAINT table_session_bill_fkey;
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); BEGIN
  UPDATE table_session SET status = 'serving' WHERE id = s;
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  UPDATE table_session SET status = 'closed' WHERE id = s;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
END $$;
