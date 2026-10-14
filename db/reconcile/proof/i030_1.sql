-- kêu: I-030/1
-- Cài một lỗi trên ngày mẫu; người sửa là chủ quán, có lý do và vết.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-030/1', true);
END $$;
ALTER TABLE assigned_task ALTER COLUMN content DROP NOT NULL;
UPDATE assigned_task SET content = NULL WHERE id = (SELECT min(id) FROM assigned_task);
