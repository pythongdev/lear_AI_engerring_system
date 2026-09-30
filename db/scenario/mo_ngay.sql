-- Mở ngày diễn (P2-13) — chạy sau prelude.sql, trước s1 · s2 · s3, cùng một phiên kết nối.
-- Chuẩn bị ngày (không phải bước của scenario nào): người đứng quầy vào ca cả buổi và khai tiền
-- đầu két — một ngày bán có đúng một con số ấy (I-021, shop-facts §8.5).
DO $$
DECLARE a bigint := pg_temp.sc_nguoi('Người đứng quầy'); f bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'mở ngày diễn scenario P2-13');
  INSERT INTO counter_duty (person_id, started_at, ended_at)
  VALUES (a, pg_temp.sc_luc('05:30'), pg_temp.sc_luc('11:30'));
  INSERT INTO opening_float (sale_date) VALUES (pg_temp.sc_ngay()) RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
  VALUES (f, 10000, 200000), (f, 5000, 100000);
  RAISE NOTICE 'ngày diễn %: Người đứng quầy vào ca 05:30–11:30, khai tiền đầu két', pg_temp.sc_ngay();
END $$;
