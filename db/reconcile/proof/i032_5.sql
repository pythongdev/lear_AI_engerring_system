-- kêu: I-032/5
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/5', true);
END $$;
ALTER TABLE menu_combo ALTER COLUMN price_vnd DROP NOT NULL;
UPDATE menu_combo SET price_vnd = NULL WHERE id = (SELECT min(id) FROM menu_combo);
-- Lỗi giá không phải lỗi giờ bán: đặt vết vừa tạo ngoài buổi như ngày mẫu.
UPDATE record_revision SET revised_at = pg_temp.bc_luc('00:00')
WHERE target_table_code = 'menu_combo' AND reason = 'lỗi cài I-032/5';
