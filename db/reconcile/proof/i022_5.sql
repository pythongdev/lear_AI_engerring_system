-- kêu: I-022/5
-- Ràng buộc cách trao hàng bị gỡ; đơn Pickup mang nhánh giao tận nơi (kèm một địa chỉ).
ALTER TABLE sales_order DROP CONSTRAINT sales_order_takeaway_handover_check;
UPDATE sales_order SET handover_code = 'door_delivery', delivery_address = '5 Hàng Gai'
WHERE id = (SELECT id FROM bc WHERE ten = 'don_lay');
