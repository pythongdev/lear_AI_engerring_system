-- kêu: I-032/6
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/6', true);
END $$;
-- Vết đổi giá có sẵn của ngày mẫu: chỉ dời lúc sửa vào giờ bán.
UPDATE record_revision SET revised_at = pg_temp.bc_luc('08:00')
WHERE target_table_code = 'menu_combo'
  AND before_image -> 'price_vnd' IS DISTINCT FROM after_image -> 'price_vnd';
