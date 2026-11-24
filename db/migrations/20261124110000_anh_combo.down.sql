-- đường lùi từ chối khi còn combo đã gắn ảnh; không bỏ khoá tệp đang dùng. Migration chạy trong giao dịch.
LOCK TABLE menu_combo IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM menu_combo WHERE image_code IS NOT NULL) THEN
    RAISE EXCEPTION 'menu_combo_image_code_in_use';
  END IF;
END $$;
REVOKE UPDATE (image_code) ON menu_combo FROM shop_app;
ALTER TABLE menu_combo DROP CONSTRAINT menu_combo_image_code_format_check;
ALTER TABLE menu_combo DROP COLUMN image_code;
