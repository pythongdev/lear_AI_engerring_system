-- kêu: I-032/8
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/8', true);
END $$;
UPDATE menu_category SET person_id = pg_temp.bc_nguoi('Người đứng quầy')
WHERE id = (SELECT min(id) FROM menu_category);
