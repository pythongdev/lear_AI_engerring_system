-- kêu: QD-31/b
-- Ngày bán của hoá đơn đơn tới lấy bị dời sang hôm sau, mốc tính tiền đứng yên.
UPDATE bill SET sale_date = sale_date + 1 WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
