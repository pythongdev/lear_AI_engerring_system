-- kêu: I-028/4 I-012/2 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Tắt vết rồi sửa khoản tạm ứng đã có vết của ngày mẫu.
DO $$ BEGIN PERFORM pg_temp.bc_vet('staff_advance', false); END $$;
UPDATE staff_advance SET amount_vnd = amount_vnd + 1
WHERE id = (SELECT min(target_row) FROM record_revision WHERE target_table_code = 'staff_advance');
DO $$ BEGIN PERFORM pg_temp.bc_vet('staff_advance', true); END $$;
