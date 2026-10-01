-- kêu: I-028/4
-- Tắt lý do rồi sửa khoản tạm ứng đã có vết của ngày mẫu.
SELECT set_config('shop.revision_reason', '', true);
UPDATE staff_advance SET amount_vnd = amount_vnd + 1
WHERE id = (SELECT min(target_row) FROM record_revision WHERE target_table_code = 'staff_advance');
