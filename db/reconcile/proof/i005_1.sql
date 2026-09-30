-- kêu: I-005/1 I-015/1 I-005/3
-- Ràng buộc "đã thu + nợ = phải trả" bị gỡ; phiên bàn 5 đóng với 1.000đ tiền mặt thiếu mà không ghi nợ.
ALTER TABLE bill DROP CONSTRAINT bill_parts_equal_due_check;
UPDATE bill SET cash_vnd = cash_vnd - 1000 WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_5');
