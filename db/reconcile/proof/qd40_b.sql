-- kêu: QD-40/b
-- Ràng buộc trạng thái đơn nhận thêm một mã không có dòng ánh xạ nào ở file lát.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_status_check;
ALTER TABLE sales_order ADD CONSTRAINT sales_order_status_check
  CHECK (status IN ('new', 'pending_confirmation', 'confirmed', 'in_progress', 'delivering',
                    'completed', 'cancelled', 'on_hold'));
