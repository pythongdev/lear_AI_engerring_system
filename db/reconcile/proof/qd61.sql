-- kêu: QD-61
-- Một cột mã so theo tiếng Việt.
ALTER TABLE dining_table ADD COLUMN area_code text COLLATE "vi-x-icu";
