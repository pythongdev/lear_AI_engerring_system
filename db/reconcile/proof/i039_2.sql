-- kêu: I-039/2
-- Bảng rỗng trên ngày mẫu; chỉ cài sai ranh giới khoá ngoại.
ALTER TABLE leave_notice ADD CONSTRAINT leave_notice_assigned_task_fkey
  FOREIGN KEY (id) REFERENCES assigned_task (id);
