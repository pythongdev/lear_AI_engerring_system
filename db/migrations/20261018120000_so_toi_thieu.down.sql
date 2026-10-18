-- T-199; khoá chặn theo 07-thu-tu-migration.md: có dữ liệu thì dùng migration mới đi tới.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM daily_minimum;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: daily_minimum đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
DROP TRIGGER daily_minimum_record_revision_trg ON daily_minimum;
DROP TABLE daily_minimum;
