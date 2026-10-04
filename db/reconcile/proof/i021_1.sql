-- kêu: I-021/1
-- Két đếm THỪA đúng bằng khoản tạm ứng của ngày mẫu (khoản đã ghi mà tiền chưa rời két): phép trừ
-- két lệch. Chỗ lệch chỉ ra được đúng một thao tác có tên — khoản tạm ứng — nên I-012/2 không kêu.
UPDATE cash_count_line SET amount_vnd = amount_vnd + (SELECT amount_vnd FROM staff_advance ORDER BY id LIMIT 1)
WHERE cash_count_id = (SELECT id FROM bc WHERE ten = 'dem_ket') AND denomination_vnd = 1000;
