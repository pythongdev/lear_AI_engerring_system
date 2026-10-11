-- kêu: I-024/3
-- Lần gửi lại của đơn hotline (đã huỷ) thêm một dòng lúc 09:30, không lần sửa nào mang vết.
DO $$ DECLARE l bigint; BEGIN
  PERFORM pg_temp.bc_vet('order_line', false);
  l := pg_temp.bc_mon((SELECT id FROM bc WHERE ten = 'don_hotline'), 'Giò bán rời', 1, ARRAY[]::text[]);
  UPDATE order_line SET created_at = pg_temp.bc_luc('09:30'), priced_at = pg_temp.bc_luc('09:30') WHERE id = l;
  PERFORM pg_temp.bc_vet('order_line', true);
END $$;
