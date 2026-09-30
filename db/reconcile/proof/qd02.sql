-- kêu: QD-02
-- Ràng buộc mã kênh nhận thêm một kênh thứ sáu mà shop-facts §2 không có (ADR-015: danh sách đóng).
ALTER TABLE sales_order DROP CONSTRAINT sales_order_channel_code_check;
ALTER TABLE sales_order ADD CONSTRAINT sales_order_channel_code_check
  CHECK (channel_code IN ('delivery', 'pickup', 'qr_table', 'staff_pos', 'phone_preorder', 'grab'));
