-- kêu: I-022/1
-- Ràng buộc số điện thoại bị gỡ; số của đơn tới lấy bị xoá trắng.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_takeaway_phone_check;
UPDATE sales_order SET customer_phone = ' ' WHERE id = (SELECT id FROM bc WHERE ten = 'don_lay');
