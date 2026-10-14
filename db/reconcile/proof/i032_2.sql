-- kêu: I-032/2
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/2', true);
END $$;
ALTER TABLE menu_item_category DROP CONSTRAINT menu_item_category_menu_item_key;
INSERT INTO menu_item_category (menu_item_id, menu_category_id)
SELECT menu_item_id, menu_category_id FROM menu_item_category LIMIT 1;
