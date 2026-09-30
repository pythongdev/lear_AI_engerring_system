-- kêu: I-020/2 I-004/2
-- Trần bị gỡ; bàn 5 gọi 6 bánh ở trạm tráng mà một mẻ ghi làm xong cái thứ 7 (còn ở bếp).
ALTER TABLE station_job DROP CONSTRAINT station_job_position_in_range_check;
DO $$ DECLARE v bigint; BEGIN
  INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                           line_quantity, component_quantity, position)
  SELECT j.sales_order_id, j.order_line_id, j.order_line_component_id, j.station_code,
         j.line_quantity, j.component_quantity, j.unit_limit + 1
  FROM station_job j JOIN order_line_component c ON c.id = j.order_line_component_id
  WHERE j.sales_order_id = (SELECT id FROM bc WHERE ten = 'don_5_qr')
    AND j.station_code = 'trang_banh' AND c.component_name = 'Bánh cuốn'
  ORDER BY j.id LIMIT 1 RETURNING id INTO v;
  PERFORM pg_temp.bc_me(ARRAY[v]);
END $$;
