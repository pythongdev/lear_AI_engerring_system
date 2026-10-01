-- kêu: I-026/3
-- Gỡ khoá một loại mỗi thứ mỗi ngày; chèn thêm cùng con số mua vào.
ALTER TABLE supply_day_entry DROP CONSTRAINT supply_day_entry_one_kind_per_item_day_key;
INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure, person_id)
SELECT supply_item_id, entry_date, kind_code, entered_measure, person_id
FROM supply_day_entry WHERE kind_code = 'purchased' ORDER BY id LIMIT 1;
