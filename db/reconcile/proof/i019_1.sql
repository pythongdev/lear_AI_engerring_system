-- kêu: I-019/1 I-004/2
-- Khoá "đơn vị đứng tên đúng đơn của dòng nó" bị gỡ; một cái bánh bàn 10 gọi bị đếm về bàn 11.
ALTER TABLE station_job DROP CONSTRAINT station_job_order_line_fkey;
DO $$ DECLARE s10 bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]);
              s11 bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('11')]); a bigint; b bigint; BEGIN
  a := pg_temp.bc_don('staff_pos', s10, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:00'));
  PERFORM pg_temp.bc_mon(a, 'Bánh cuốn', 2, ARRAY['Chay']);
  b := pg_temp.bc_don('staff_pos', s11, pg_temp.bc_ban('11'), pg_temp.bc_luc('10:01'));
  PERFORM pg_temp.bc_mon(b, 'Bánh cuốn', 2, ARRAY['Chay']);
  UPDATE sales_order SET status = 'confirmed' WHERE id IN (a, b);
  PERFORM pg_temp.bc_no(a); PERFORM pg_temp.bc_no(b);
  UPDATE table_session SET status = 'serving' WHERE id IN (s10, s11);
  UPDATE station_job SET sales_order_id = b
  WHERE id = (SELECT min(id) FROM station_job WHERE sales_order_id = a AND order_line_id IS NOT NULL);
END $$;
