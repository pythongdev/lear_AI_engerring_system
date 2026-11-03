-- kêu: I-038/1
-- Bảng tin rỗng trên ngày mẫu; cài sai ranh giới khoá ngoại.
ALTER TABLE station_message ADD CONSTRAINT station_message_assigned_task_fkey
  FOREIGN KEY (id) REFERENCES assigned_task (id);
