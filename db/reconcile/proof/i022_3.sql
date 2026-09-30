-- kêu: I-022/3
-- Ràng buộc giờ khách cần hàng bị gỡ; giờ của đơn tới lấy bị xoá.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_takeaway_needed_at_check;
UPDATE sales_order SET customer_needed_at = NULL WHERE id = (SELECT id FROM bc WHERE ten = 'don_lay');
