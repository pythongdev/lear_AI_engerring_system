-- kêu: I-012/2 I-021/1
-- Két đếm thừa 1.000đ mà không thao tác nào trong ngày mang phần tiền 1.000đ: chỗ lệch vô danh.
-- Phép trừ két lệch theo, nên I-021/1 kêu cùng.
UPDATE cash_count_line SET amount_vnd = amount_vnd + 1000
WHERE cash_count_id = (SELECT id FROM bc WHERE ten = 'dem_ket') AND denomination_vnd = 1000;
