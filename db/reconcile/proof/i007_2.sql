-- kêu: I-007/2
-- Quầy thu gộp: hoá đơn của đơn tới lấy thu thêm 30.000đ của một đơn khác.
UPDATE bill SET due_vnd = due_vnd + 30000, cash_vnd = cash_vnd + 30000
WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
