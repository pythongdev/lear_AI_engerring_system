-- kêu: I-007/3
-- Khoá "đơn lẻ Hoàn thành phải có hoá đơn" bị gỡ; một đơn tới lấy làm xong, trao hàng, không thu.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_bill_fkey;
DO $$ DECLARE o bigint; BEGIN
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000023', pg_temp.bc_luc('10:30'),
          gen_random_uuid()::text, pg_temp.bc_luc('10:00')) RETURNING id INTO o;
  PERFORM pg_temp.bc_mon(o, 'Giò bán rời', 1, ARRAY[]::text[]);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  PERFORM pg_temp.bc_lam_het(o);
  UPDATE sales_order SET status = 'completed' WHERE id = o;
END $$;
