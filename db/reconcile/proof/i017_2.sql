-- kêu: I-017/2 I-017/1
-- Bàn 10 sang Chờ thanh toán lúc 10:15, khách gọi thêm lúc 10:16, quầy đóng phiên trước khi món ra.
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); o bigint; o2 bigint; BEGIN
  o := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:00'));
  PERFORM pg_temp.bc_mon(o, 'Giò bán rời', 1, ARRAY[]::text[]);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  PERFORM pg_temp.bc_lam_het(o);
  UPDATE sales_order SET status = 'completed' WHERE id = o;
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  UPDATE record_revision SET revised_at = pg_temp.bc_luc('10:15')
   WHERE target_table_code = 'table_session' AND target_row = s
     AND after_image ->> 'status' = 'awaiting_payment';
  o2 := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:16'));
  PERFORM pg_temp.bc_mon(o2, 'Giò bán rời', 1, ARRAY[]::text[]);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o2;
  PERFORM pg_temp.bc_no(o2);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  PERFORM pg_temp.bc_dong(s, pg_temp.bc_luc('10:20'), pg_temp.bc_tong_phien(s), 0);
END $$;
