-- T-307: khoá tệp ảnh của món; ảnh nằm trong BANHCUON_FILE_DIR.
ALTER TABLE menu_item ADD COLUMN image_code text;
ALTER TABLE menu_item ADD CONSTRAINT menu_item_image_code_format_check
  CHECK (image_code IS NULL OR image_code ~ '^images/menu-items/[0-9a-f]{32}\.(jpg|png|webp)$');
