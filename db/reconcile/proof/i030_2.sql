-- kêu: I-030/2
-- Cài một lỗi trên ngày mẫu; người sửa là chủ quán, có lý do và vết.
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-030/2', true);
END $$;
UPDATE assigned_task SET person_id = pg_temp.bc_nguoi('Người gấp bánh')
WHERE id = (SELECT min(id) FROM assigned_task);
