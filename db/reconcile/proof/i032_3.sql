-- kêu: I-032/3
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-032/3', true);
END $$;
-- Vượt quyền xoá để mô phỏng trạng thái hỏng đã tồn tại sau giao dịch.
DELETE FROM menu_combo_item WHERE menu_combo_id = (SELECT min(id) FROM menu_combo);
