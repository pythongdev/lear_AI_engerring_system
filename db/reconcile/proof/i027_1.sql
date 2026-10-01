-- kêu: I-027/1
-- Gỡ NOT NULL ngày; ô thiếu ngày vẫn qua các ràng buộc còn lại.
ALTER TABLE attendance_day ALTER COLUMN work_date DROP NOT NULL;
UPDATE attendance_day SET work_date = NULL WHERE id = (SELECT min(id) FROM attendance_day);
