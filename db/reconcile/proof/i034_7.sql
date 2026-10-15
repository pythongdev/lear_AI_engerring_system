-- kêu: I-034/7
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/7', true);
END $$;
-- Giá combo đổi, mà vết bị dời về trước mốc khoá: giá tại mốc khác giá dòng combo đã khoá.
UPDATE menu_combo SET price_vnd = 35000
WHERE id = (SELECT menu_combo_id FROM order_line WHERE id = (SELECT id FROM bc WHERE ten = 'dong_combo'));
UPDATE record_revision SET revised_at = pg_temp.bc_luc('00:00')
WHERE target_table_code = 'menu_combo' AND reason = 'lỗi cài I-034/7';
