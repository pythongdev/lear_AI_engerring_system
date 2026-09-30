-- kêu: I-016/1
-- Một lượt gọi của bàn 10 nhảy thẳng Mới → Đang thực hiện, bỏ qua Đã xác nhận (có vết).
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); o bigint; BEGIN
  o := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:00'));
  PERFORM pg_temp.bc_mon(o, 'Giò bán rời', 1, ARRAY[]::text[]);
  PERFORM pg_temp.bc_no(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
END $$;
