-- kêu: QD-33/b
-- Mốc tính tiền của hoá đơn đơn tới lấy bị dời sớm một phút (có vết).
UPDATE bill SET booked_at = booked_at - interval '1 minute'
WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
