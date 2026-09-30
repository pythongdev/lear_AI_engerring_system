-- kêu: I-023/2
-- Ràng buộc "lượt gọi QR mang mã" bị gỡ; lượt gọi QR của bàn 5 mất mã.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_qr_code_iff_qr_channel_check;
UPDATE sales_order SET qr_code_id = NULL WHERE id = (SELECT id FROM bc WHERE ten = 'don_5_qr');
