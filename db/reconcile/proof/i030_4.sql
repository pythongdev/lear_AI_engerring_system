-- kêu: I-030/4
-- Cài một lỗi trên ngày mẫu; người sửa là chủ quán, có lý do và vết.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-030/4', true);
END $$;
ALTER TABLE assigned_task DROP CONSTRAINT assigned_task_hidden_by_iff_hidden_check;
UPDATE assigned_task SET hidden_by_person_id = NULL WHERE hidden_at IS NOT NULL;
