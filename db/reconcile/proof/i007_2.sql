-- kêu: I-007/2 I-012/2 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Quầy thu gộp: hoá đơn của đơn tới lấy thu thêm 30.000đ của một đơn khác.
UPDATE bill SET due_vnd = due_vnd + 30000, cash_vnd = cash_vnd + 30000
WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
