-- kêu: I-034/5
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/5', true);
END $$;
-- Mức đổi, mà vết bị dời về trước mốc khoá: mức tại mốc khác tiền suất đã khoá.
UPDATE menu_combo_item_option_surcharge SET surcharge_vnd = 5000 WHERE id = (SELECT id FROM bc WHERE ten = 'muc_combo');
UPDATE record_revision SET revised_at = pg_temp.bc_luc('00:00')
WHERE target_table_code = 'menu_combo_item_option_surcharge' AND reason = 'lỗi cài I-034/5';
