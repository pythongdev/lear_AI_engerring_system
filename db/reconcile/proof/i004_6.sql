-- kêu: I-004/6
-- Bàn 10 gọi, bếp làm xong một cái bánh, rồi đơn bị huỷ — cái bánh không được chuyển cho ai.
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); o bigint; BEGIN
  o := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:00'));
  PERFORM pg_temp.bc_mon(o, 'Bánh cuốn', 1, ARRAY['Chay']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  PERFORM pg_temp.bc_me(ARRAY(SELECT min(id) FROM station_job WHERE sales_order_id = o
                                AND order_line_component_id IS NOT NULL));
  UPDATE sales_order SET status = 'cancelled' WHERE id = o;
END $$;
