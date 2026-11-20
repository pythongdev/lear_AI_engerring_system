-- đường lùi từ chối khi còn món đã gắn ảnh; không bỏ khoá tệp đang dùng.
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM menu_item WHERE image_code IS NOT NULL) THEN
    RAISE EXCEPTION 'menu_item_image_code_in_use';
  END IF;
END $$;
ALTER TABLE menu_item DROP CONSTRAINT menu_item_image_code_format_check;
ALTER TABLE menu_item DROP COLUMN image_code;
