-- kêu: I-024/1
-- Khoá "một dấu một đơn" bị gỡ; đơn tới lấy mang cùng dấu lần gửi với đơn hotline.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_submission_code_key;
UPDATE sales_order SET submission_code = (SELECT submission_code FROM sales_order
                                          WHERE id = (SELECT id FROM bc WHERE ten = 'don_hotline'))
WHERE id = (SELECT id FROM bc WHERE ten = 'don_lay');
