-- kêu: I-014/2
-- Ràng buộc "một khoản một nguồn" bị gỡ; một hoá đơn 10.000đ tiền mặt không đứng tên đơn vị nào.
ALTER TABLE bill DROP CONSTRAINT bill_one_unit_check;
INSERT INTO bill (due_vnd, cash_vnd, booked_at, sale_date)
VALUES (10000, 10000, pg_temp.bc_luc('10:00'), pg_temp.bc_ngay());
