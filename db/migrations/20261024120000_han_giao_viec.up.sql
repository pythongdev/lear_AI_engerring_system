-- T-246: ngày giờ hạn hoàn thành; bản ghi cũ giữ NULL, không tự đặt hạn.
-- POST bắt buộc due_at ở tầng API/service; NULL còn để đọc lịch sử trước migration.
ALTER TABLE assigned_task ADD COLUMN due_at timestamptz;
GRANT UPDATE (due_at) ON assigned_task TO shop_app;
-- Trigger record_revision_capture hiện có tự giữ cả hạn trước/sau khi sửa.
