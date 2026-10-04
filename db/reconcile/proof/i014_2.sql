-- kêu: I-014/2 I-012/2 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Ràng buộc "một khoản một nguồn" bị gỡ; một hoá đơn 10.000đ tiền mặt không đứng tên đơn vị nào.
ALTER TABLE bill DROP CONSTRAINT bill_one_unit_check;
INSERT INTO bill (due_vnd, cash_vnd, booked_at, sale_date)
VALUES (10000, 10000, pg_temp.bc_luc('10:00'), pg_temp.bc_ngay());
