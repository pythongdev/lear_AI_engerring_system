-- kêu: I-034/1
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/1', true);
END $$;
-- Một nhóm tuỳ chọn mới mà món của combo không mang; vượt trigger kiểm để mô phỏng một mức đã nằm sẵn cho nó.
INSERT INTO option_group (name) VALUES ('lỗi cài nhóm lạ');
INSERT INTO menu_option (option_group_id, name, surcharge_vnd)
SELECT id, 'lỗi cài lựa chọn lạ', 0 FROM option_group WHERE name = 'lỗi cài nhóm lạ';
ALTER TABLE menu_combo_item_option_surcharge DISABLE TRIGGER menu_combo_item_option_surcharge_option_of_item_check;
INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd, created_at)
SELECT s.menu_combo_item_id, o.id, 1000, pg_temp.bc_luc('00:00')
FROM menu_combo_item_option_surcharge s, menu_option o
WHERE s.id = (SELECT id FROM bc WHERE ten = 'muc_combo') AND o.name = 'lỗi cài lựa chọn lạ';
ALTER TABLE menu_combo_item_option_surcharge ENABLE TRIGGER menu_combo_item_option_surcharge_option_of_item_check;
