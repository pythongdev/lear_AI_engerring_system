-- kêu: I-032/1
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/1', true);
END $$;
DROP INDEX menu_category_active_name_key;
INSERT INTO menu_category (name) SELECT name FROM menu_category WHERE hidden_at IS NULL LIMIT 1;
