-- Đường lùi bước 34 (T-210). KHOÁ CHẶN: còn lựa chọn đang ẩn thì từ chối — gỡ cột lúc ấy là xoá "ai ẩn, lúc nào" đã ghi
-- và làm lựa chọn ẩn bán lại được (luật 2 của 07-thu-tu-migration.md). Lựa chọn thêm qua cửa mới là dòng thường, ở lại.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM menu_option WHERE hidden_at IS NOT NULL;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: menu_option đang giữ % lựa chọn đã ẩn', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
ALTER TABLE menu_option
  DROP CONSTRAINT menu_option_hidden_after_created_check,
  DROP CONSTRAINT menu_option_hidden_by_iff_hidden_check,
  DROP CONSTRAINT menu_option_hidden_by_person_fkey,
  DROP COLUMN hidden_by_person_id,
  DROP COLUMN hidden_at;
