-- kêu: I-028/1 I-012/2 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Gỡ NOT NULL ngày của cả hai bảng; hai khoản thiếu ngày, các vết sửa vẫn hợp lệ.
ALTER TABLE staff_advance ALTER COLUMN paid_date DROP NOT NULL;
ALTER TABLE holiday_bonus ALTER COLUMN paid_date DROP NOT NULL;
UPDATE staff_advance SET paid_date = NULL;
UPDATE holiday_bonus SET paid_date = NULL;
