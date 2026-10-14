-- kêu: I-031/1
-- Người sửa là chủ quán, có lý do và vết; chỉ phá tập được gọi tên.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-031/1', true);
END $$;
ALTER TABLE assigned_task_guide ALTER COLUMN assigned_task_id DROP NOT NULL;
UPDATE assigned_task_guide SET assigned_task_id = NULL WHERE id = (SELECT min(id) FROM assigned_task_guide);
