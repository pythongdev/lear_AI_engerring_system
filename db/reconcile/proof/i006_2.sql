-- kêu: I-006/2
-- Suất "đem về" của khách ngồi bàn bị ghi vào một đơn tới lấy — rời phiên bàn sang nguồn đơn lẻ.
UPDATE order_line SET is_takeaway = true
WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
