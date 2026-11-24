-- kêu: I-034/4
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/4', true);
END $$;
-- Giả lập sửa số phần nhưng vết bị dời trước mốc khoá: lịch sử bị sai và bộ đối chiếu phải kêu.
UPDATE menu_combo_item SET quantity = 3
WHERE menu_combo_id = (SELECT menu_combo_id FROM order_line WHERE id = (SELECT id FROM bc WHERE ten = 'dong_combo'));
UPDATE record_revision SET revised_at = pg_temp.bc_luc('00:00')
WHERE target_table_code = 'menu_combo_item' AND reason = 'lỗi cài I-034/4';
