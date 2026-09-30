-- kêu: I-007/1
-- Ràng buộc ranh giới bị gỡ; một đơn tới lấy gắn vào phiên đang mở của bàn 10.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_session_iff_table_channel_check;
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); BEGIN
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, handover_code,
                           customer_phone, customer_needed_at, submission_code, created_at)
  VALUES ('pickup', 'new', s, pg_temp.bc_ban('10'), 'shop_pickup', '0900000022',
          pg_temp.bc_luc('10:30'), gen_random_uuid()::text, pg_temp.bc_luc('10:00'));
END $$;
