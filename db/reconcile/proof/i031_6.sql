-- kêu: I-031/6
-- Người sửa là chủ quán, có lý do và vết; chỉ phá tập được gọi tên.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-031/6', true);
END $$;
ALTER TABLE assigned_task_guide DROP CONSTRAINT assigned_task_guide_hidden_by_iff_hidden_check;
UPDATE assigned_task_guide SET hidden_by_person_id = NULL WHERE hidden_at IS NOT NULL;
