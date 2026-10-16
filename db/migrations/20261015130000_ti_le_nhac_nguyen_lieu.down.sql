-- QC-05: không gỡ cột tỉ lệ đang giữ giá trị, kể cả mặc định (07-thu-tu-migration.md §2).
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM supply_item WHERE reminder_ratio IS NOT NULL;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: supply_item.reminder_ratio đang giữ % giá trị đã ghi', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
ALTER TABLE supply_item DROP COLUMN reminder_ratio;
