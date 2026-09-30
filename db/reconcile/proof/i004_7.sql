-- kêu: I-004/7
-- Quầy chuyển quả trứng tái NHÂN THỊT của đơn bàn 10 bị huỷ sang bàn 11 đang chờ trứng tái CHAY —
-- máy không ngăn (tầng 4), câu đối chiếu bắt.
DO $$ DECLARE s10 bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]);
              s11 bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('11')]);
              a bigint; b bigint; va bigint; vb bigint; it bigint; BEGIN
  a := pg_temp.bc_don('staff_pos', s10, pg_temp.bc_ban('10'), pg_temp.bc_luc('10:00'));
  PERFORM pg_temp.bc_mon(a, 'Suất trứng tái', 1, ARRAY['Thịt', 'Thường']);
  b := pg_temp.bc_don('staff_pos', s11, pg_temp.bc_ban('11'), pg_temp.bc_luc('10:01'));
  PERFORM pg_temp.bc_mon(b, 'Suất trứng tái', 1, ARRAY['Chay']);
  UPDATE sales_order SET status = 'confirmed' WHERE id IN (a, b);
  PERFORM pg_temp.bc_no(a); PERFORM pg_temp.bc_no(b);
  UPDATE table_session SET status = 'serving' WHERE id IN (s10, s11);
  SELECT j.id INTO va FROM station_job j JOIN order_line_component c ON c.id = j.order_line_component_id
   WHERE j.sales_order_id = a AND j.station_code = 'trang_banh' AND c.component_name = 'Trứng tái';
  SELECT j.id INTO vb FROM station_job j JOIN order_line_component c ON c.id = j.order_line_component_id
   WHERE j.sales_order_id = b AND j.station_code = 'trang_banh' AND c.component_name = 'Trứng tái';
  PERFORM pg_temp.bc_me(ARRAY[va]);
  UPDATE sales_order SET status = 'cancelled' WHERE id = a;
  SELECT id INTO it FROM production_batch_item WHERE station_job_id = va;
  UPDATE production_batch_item SET station_job_id = vb WHERE id = it;
  INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
  VALUES (it, va, vb);
  UPDATE station_job SET status = 'pending' WHERE id = va;
  UPDATE station_job SET status = 'made' WHERE id = vb;
END $$;
