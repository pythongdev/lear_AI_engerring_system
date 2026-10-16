-- kêu: I-025/3
ALTER TABLE supply_item DROP CONSTRAINT supply_item_reminder_ratio_range_check;
INSERT INTO supply_item(name, reminder_ratio) VALUES ('lỗi cài tỉ lệ nhắc', 1.01);
