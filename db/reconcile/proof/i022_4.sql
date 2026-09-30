-- kêu: I-022/4
-- Ràng buộc cách trao hàng bị gỡ; đơn hotline mất cách trao hàng.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_takeaway_handover_check;
UPDATE sales_order SET handover_code = NULL WHERE id = (SELECT id FROM bc WHERE ten = 'don_hotline');
