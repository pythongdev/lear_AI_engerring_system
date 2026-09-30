-- kêu: QD-01
-- Một cột viết hoa, không phải snake_case.
ALTER TABLE dining_table ADD COLUMN "GhiChu" text COLLATE "vi-x-icu";
