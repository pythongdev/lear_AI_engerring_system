-- kêu: I-031/5
-- Người sửa là chủ quán, có lý do và vết; chỉ phá tập được gọi tên.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-031/5', true);
END $$;
ALTER TABLE training_record DROP CONSTRAINT training_record_rating_code_check;
UPDATE training_record SET rating_code = 'good' WHERE id = (SELECT min(id) FROM training_record);
