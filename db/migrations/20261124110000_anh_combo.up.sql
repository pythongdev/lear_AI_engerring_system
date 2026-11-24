-- T-315, ADR-142: ảnh combo dùng chung kho BANHCUON_FILE_DIR với ảnh món.
ALTER TABLE menu_combo ADD COLUMN image_code text;
ALTER TABLE menu_combo ADD CONSTRAINT menu_combo_image_code_format_check
  CHECK (image_code IS NULL OR image_code ~ '^images/menu-combos/[0-9a-f]{32}\.(jpg|png|webp)$');
GRANT UPDATE (image_code) ON menu_combo TO shop_app;
