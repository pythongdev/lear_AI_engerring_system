-- kêu: I-018/1
-- Ràng buộc "vết có lý do" bị gỡ; một vết của ngày mẫu chỉ còn khoảng trắng ở ô lý do.
ALTER TABLE record_revision DROP CONSTRAINT record_revision_reason_not_blank_check;
UPDATE record_revision SET reason = ' ' WHERE id = (SELECT min(id) FROM record_revision);
