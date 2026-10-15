-- kêu: I-034/4
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/4', true);
END $$;
-- Chủ quán sửa số phần của món trong combo đã bán: combo trên đơn đọc ra thiếu suất.
UPDATE menu_combo_item SET quantity = 3
WHERE menu_combo_id = (SELECT menu_combo_id FROM order_line WHERE id = (SELECT id FROM bc WHERE ten = 'dong_combo'));
