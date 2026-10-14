-- kêu: I-030/3
-- Cài một lỗi trên ngày mẫu; người sửa là chủ quán, có lý do và vết.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-030/3', true);
END $$;
ALTER TABLE assigned_task_mark ALTER COLUMN created_at DROP NOT NULL;
UPDATE assigned_task_mark SET created_at = NULL WHERE id = (SELECT min(id) FROM assigned_task_mark);
