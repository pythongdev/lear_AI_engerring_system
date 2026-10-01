-- kêu: I-025/1
-- Gỡ NOT NULL ngày nhập; lần sửa vẫn có vết hợp lệ.
ALTER TABLE supply_day_entry ALTER COLUMN entry_date DROP NOT NULL;
UPDATE supply_day_entry SET entry_date = NULL WHERE id = (SELECT min(id) FROM supply_day_entry);
