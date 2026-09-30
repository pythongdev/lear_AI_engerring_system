-- kêu: I-015/2 I-005/3
-- Ràng buộc tổng khớp bị gỡ; đơn tới lấy thu vượt 1.000đ tiền mặt.
ALTER TABLE bill DROP CONSTRAINT bill_parts_equal_due_check;
UPDATE bill SET cash_vnd = cash_vnd + 1000 WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
