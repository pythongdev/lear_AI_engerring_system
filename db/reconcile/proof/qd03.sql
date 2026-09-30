-- kêu: QD-03
-- Một cột tiền mang hậu tố _amount thay vì _vnd.
ALTER TABLE bill ADD COLUMN tip_amount bigint;
