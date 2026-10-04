-- kêu: I-002/2 I-012/2 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Hoá đơn phiên bàn 5 ghi số phải trả hơn tổng các lượt gọi 1.000đ (và thu đủ số ấy).
UPDATE bill SET due_vnd = due_vnd + 1000, cash_vnd = cash_vnd + 1000
WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_5');
