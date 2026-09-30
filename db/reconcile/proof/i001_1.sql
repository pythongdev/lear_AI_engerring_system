-- kêu: I-001/1
-- Khoá "một bàn một phiên chưa đóng" bị gỡ; bàn 10 mở phiên thứ hai khi phiên đầu chưa đóng.
DROP INDEX table_session_member_one_unpaid_session_key;
DO $$ BEGIN
  PERFORM pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]);
  PERFORM pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]);
END $$;
