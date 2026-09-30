-- kêu: I-022/2
-- Ràng buộc địa chỉ bị gỡ; địa chỉ của đơn giao bị xoá.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_door_delivery_address_check;
UPDATE sales_order SET delivery_address = NULL WHERE id = (SELECT id FROM bc WHERE ten = 'don_giao');
