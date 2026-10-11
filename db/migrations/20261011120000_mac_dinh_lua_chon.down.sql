-- QC-05: không gỡ cờ mặc định đang giữ dữ liệu đã ghi (07-thu-tu-migration.md, khoá chặn bước 21).
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM menu_option WHERE is_default;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: menu_option.is_default đang giữ % giá trị đã ghi; gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
DROP INDEX menu_option_one_default_per_group_key;
ALTER TABLE menu_option DROP COLUMN is_default;
