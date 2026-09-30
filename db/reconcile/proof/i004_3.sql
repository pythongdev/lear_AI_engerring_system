-- kêu: I-004/3
-- Khoá "mỗi đơn một phần nước chấm" bị gỡ; đơn QR bàn 5 có phần nước chấm thứ hai.
DROP INDEX station_job_one_sauce_per_order_key;
INSERT INTO station_job (sales_order_id, station_code, position)
VALUES ((SELECT id FROM bc WHERE ten = 'don_5_qr'), 'canh', 1);
