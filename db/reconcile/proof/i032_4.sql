-- kêu: I-032/4
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/4', true);
END $$;
ALTER TABLE menu_combo_item DROP CONSTRAINT menu_combo_item_quantity_positive_check;
UPDATE menu_combo_item SET quantity = 0 WHERE id = (SELECT min(x.id) FROM menu_combo_item x JOIN menu_combo c ON c.id = x.menu_combo_id WHERE c.name = 'Mẫu combo');
