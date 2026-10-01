-- kêu: I-025/2
-- Tắt lý do rồi sửa chính con số đã có vết trong ngày mẫu.
SELECT set_config('shop.revision_reason', '', true);
UPDATE supply_day_entry SET entered_measure = entered_measure + 1
WHERE id = (SELECT min(target_row) FROM record_revision WHERE target_table_code = 'supply_day_entry');
-- Sửa tiếp có lý do: bản sau mới nhất lại khớp dòng hiện tại, nhưng khe đứt giữa hai vết còn đó.
-- Như vậy lỗi này chứng minh nhánh nối vết; i028_4 chứng minh nhánh bản sau mới nhất lệch dòng.
SELECT set_config('shop.revision_reason', 'sửa tiếp sau lần mất vết', true);
UPDATE supply_day_entry SET entered_measure = entered_measure + 1
WHERE id = (SELECT min(target_row) FROM record_revision WHERE target_table_code = 'supply_day_entry');
