-- kêu: I-004/4
-- Trần vị trí bị gỡ; đơn tới lấy gọi 2 bát canh mà trạm canh nhận 3 việc canh.
ALTER TABLE station_job DROP CONSTRAINT station_job_position_in_range_check;
DO $$ DECLARE o bigint; l bigint; BEGIN
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000021', pg_temp.bc_luc('10:30'),
          gen_random_uuid()::text, pg_temp.bc_luc('10:00')) RETURNING id INTO o;
  l := pg_temp.bc_mon(o, 'Canh bánh cuốn', 2, ARRAY[]::text[]);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                           line_quantity, component_quantity, position)
  SELECT o, l, c.id, 'canh', 2, c.quantity, 3 FROM order_line_component c WHERE c.order_line_id = l;
END $$;
