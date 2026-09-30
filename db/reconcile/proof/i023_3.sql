-- kêu: I-023/3
-- Mã của bàn 5 bị thay; lượt gọi QR của bàn 5 tạo SAU lúc ấy vẫn mang mã cũ (cửa tạo lượt gọi
-- của pha 3 phải từ chối — tầng 3).
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM qr_code_issue(pg_temp.bc_ban('5'));
END $$;
