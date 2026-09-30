-- kêu: I-012/4
-- Ràng buộc "lần hoàn có lý do" bị gỡ; lần hoàn của đơn tới lấy chỉ còn khoảng trắng ở ô lý do.
ALTER TABLE refund DROP CONSTRAINT refund_reason_not_blank_check;
UPDATE refund SET reason = '   ' WHERE id = (SELECT id FROM bc WHERE ten = 'hoan_lay');
