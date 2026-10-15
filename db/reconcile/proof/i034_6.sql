-- kêu: I-034/6
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/6', true);
END $$;
-- Vết đổi mức có sẵn của ngày mẫu: chỉ dời lúc sửa vào giờ bán, trước mốc khoá của đơn combo.
UPDATE record_revision SET revised_at = pg_temp.bc_luc('08:00')
WHERE target_table_code = 'menu_combo_item_option_surcharge'
  AND before_image -> 'surcharge_vnd' IS DISTINCT FROM after_image -> 'surcharge_vnd';
