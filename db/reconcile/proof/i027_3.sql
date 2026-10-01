-- kêu: I-027/3
-- Gỡ ràng buộc ghi chú chỉ khi huỷ; ô còn hiệu lực mang ghi chú huỷ.
ALTER TABLE attendance_day DROP CONSTRAINT attendance_day_cancel_note_only_when_cancelled_check;
UPDATE attendance_day SET cancel_note = 'ghi chú nhưng chưa huỷ'
WHERE id = (SELECT min(id) FROM attendance_day WHERE cancelled_at IS NULL);
