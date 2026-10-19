-- T-197; khoá chặn theo 07-thu-tu-migration.md: có dữ liệu thì dùng migration mới đi tới.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM workers_present_declaration;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: workers_present_declaration đang giữ % lần khai đã ghi — gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
DROP TRIGGER workers_present_declaration_record_revision_trg ON workers_present_declaration;
DROP TABLE workers_present_declaration;
