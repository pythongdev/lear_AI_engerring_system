-- kêu: I-015/1 I-005/3 I-012/2 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Ràng buộc tổng khớp bị gỡ; đơn tới lấy thu thiếu 1.000đ tiền mặt mà không ghi nợ.
ALTER TABLE bill DROP CONSTRAINT bill_parts_equal_due_check;
UPDATE bill SET cash_vnd = cash_vnd - 1000 WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
