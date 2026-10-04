-- kêu: QD-31/b I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Ngày bán của hoá đơn đơn tới lấy bị dời sang hôm sau, mốc tính tiền đứng yên.
UPDATE bill SET sale_date = sale_date + 1 WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
