-- kêu: I-021/3 I-012/2 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Khoá "một ngày một con số tiền đầu két" bị gỡ; ngày mẫu có con số tiền đầu két thứ hai.
-- Dấu đối soát xong trỏ vào khoá ấy (T-133), nên khoá ngoại của nó gỡ trước.
ALTER TABLE reconciled_day DROP CONSTRAINT reconciled_day_opening_float_fkey;
ALTER TABLE opening_float DROP CONSTRAINT opening_float_one_per_day_key;
DO $$ DECLARE f bigint; BEGIN
  INSERT INTO opening_float (sale_date) VALUES (pg_temp.bc_ngay()) RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 10000, 50000);
END $$;
