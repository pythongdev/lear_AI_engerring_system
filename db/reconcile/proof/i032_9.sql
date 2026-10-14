-- kêu: I-032/8
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Người đứng quầy')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/8 xếp món', true);
END $$;
INSERT INTO menu_item_category (menu_item_id, menu_category_id)
VALUES ((SELECT min(id) FROM menu_item WHERE id NOT IN (SELECT menu_item_id FROM menu_item_category)),
        (SELECT min(id) FROM menu_category));
