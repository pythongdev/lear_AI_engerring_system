-- kêu: I-003/1
-- Ràng buộc "chỉ dọn sau khi đóng" bị gỡ; bàn 10 ghi đã dọn khi phiên còn mở.
ALTER TABLE table_session_member DROP CONSTRAINT table_session_member_cleaned_after_close_check;
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); BEGIN
  UPDATE table_session_member SET cleaned_at = pg_temp.bc_luc('10:00') WHERE table_session_id = s;
END $$;
