-- kêu: I-001/2 I-001/1
-- Khoá bị gỡ; bàn 10 + 11 ghép một phiên, rồi bàn 11 mở thêm một phiên riêng.
DROP INDEX table_session_member_one_unpaid_session_key;
DO $$ BEGIN
  PERFORM pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10'), pg_temp.bc_ban('11')]);
  PERFORM pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('11')]);
END $$;
