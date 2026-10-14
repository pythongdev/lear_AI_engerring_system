-- kêu: I-031/2
-- Người sửa là chủ quán, có lý do và vết; chỉ phá tập được gọi tên.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-031/2', true);
END $$;
ALTER TABLE training_record ALTER COLUMN created_at DROP NOT NULL;
UPDATE training_record SET created_at = NULL WHERE id = (SELECT min(id) FROM training_record);
