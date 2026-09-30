-- kêu: I-017/1
-- Bàn 10 đóng phiên khi lượt gọi của nó còn Đang thực hiện (lượt gọi tạo TRƯỚC lúc tính tiền).
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); o bigint; BEGIN
  o := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:00'));
  PERFORM pg_temp.bc_mon(o, 'Giò bán rời', 1, ARRAY[]::text[]);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  PERFORM pg_temp.bc_dong(s, pg_temp.bc_luc('10:20'), pg_temp.bc_tong_phien(s), 0);
  UPDATE record_revision SET revised_at = pg_temp.bc_luc('10:15')
   WHERE target_table_code = 'table_session' AND target_row = s
     AND after_image ->> 'status' = 'awaiting_payment';
END $$;
