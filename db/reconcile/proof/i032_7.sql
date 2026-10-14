-- kêu: I-032/7
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/7', true);
END $$;
ALTER TABLE menu_category DROP CONSTRAINT menu_category_hidden_by_iff_hidden_check;
UPDATE menu_category SET hidden_by_person_id = NULL WHERE hidden_at IS NOT NULL;
