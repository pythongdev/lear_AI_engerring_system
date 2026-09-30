-- kêu: I-004/1
-- Khoá "việc trạm chỉ đứng tên đơn đã duyệt" bị gỡ; đơn tới lấy còn Chờ xác nhận đã có việc ở bếp.
ALTER TABLE station_job DROP CONSTRAINT station_job_sales_order_fkey;
DO $$ DECLARE o bigint; BEGIN
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('pickup', 'pending_confirmation', 'shop_pickup', '0900000020', pg_temp.bc_luc('10:30'),
          gen_random_uuid()::text, pg_temp.bc_luc('10:00')) RETURNING id INTO o;
  INSERT INTO station_job (sales_order_id, station_code, position) VALUES (o, 'canh', 1);
END $$;
