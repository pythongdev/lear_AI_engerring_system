-- kêu: I-028/1
-- Gỡ NOT NULL ngày của cả hai bảng; hai khoản thiếu ngày, các vết sửa vẫn hợp lệ.
ALTER TABLE staff_advance ALTER COLUMN paid_date DROP NOT NULL;
ALTER TABLE holiday_bonus ALTER COLUMN paid_date DROP NOT NULL;
UPDATE staff_advance SET paid_date = NULL;
UPDATE holiday_bonus SET paid_date = NULL;
