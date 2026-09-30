-- kêu: I-021/2
-- Khoá "một ngày một con số tiền đầu két" bị gỡ; ngày mẫu có con số tiền đầu két thứ hai.
ALTER TABLE opening_float DROP CONSTRAINT opening_float_one_per_day_key;
DO $$ DECLARE f bigint; BEGIN
  INSERT INTO opening_float (sale_date) VALUES (pg_temp.bc_ngay()) RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 10000, 50000);
END $$;
