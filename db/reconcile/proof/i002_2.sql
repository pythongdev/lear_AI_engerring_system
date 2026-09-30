-- kêu: I-002/2
-- Hoá đơn phiên bàn 5 ghi số phải trả hơn tổng các lượt gọi 1.000đ (và thu đủ số ấy).
UPDATE bill SET due_vnd = due_vnd + 1000, cash_vnd = cash_vnd + 1000
WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_5');
