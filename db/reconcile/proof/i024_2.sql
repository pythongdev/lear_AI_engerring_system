-- kêu: I-024/2
-- Ràng buộc "dấu không trắng" bị gỡ; dấu lần gửi của đơn tới lấy chỉ còn khoảng trắng.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_submission_code_not_blank_check;
UPDATE sales_order SET submission_code = ' ' WHERE id = (SELECT id FROM bc WHERE ten = 'don_lay');
