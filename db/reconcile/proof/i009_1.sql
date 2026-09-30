-- kêu: I-009/1
-- Tên món đã khoá trên dòng đơn tới lấy bị ghi đè theo menu mới, mốc khoá đứng yên (có vết).
UPDATE order_line SET item_name = item_name || ' (tên mới)'
WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
