-- kêu: I-031/3
-- Người sửa là chủ quán, có lý do và vết; chỉ phá tập được gọi tên.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-031/3', true);
END $$;
UPDATE training_record SET person_id = pg_temp.bc_nguoi('Người gấp bánh')
WHERE id = (SELECT min(id) FROM training_record);
