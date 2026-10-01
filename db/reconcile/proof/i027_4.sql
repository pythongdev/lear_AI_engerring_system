-- kêu: I-027/4
-- Tầng 3: không có ràng buộc để gỡ, chỉ đổi người tick sang người không là chủ quán.
UPDATE attendance_day SET person_id = pg_temp.bc_nguoi('Người đứng quầy')
WHERE id = (SELECT min(id) FROM attendance_day);
