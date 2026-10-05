-- kêu: I-021/1
-- Két đếm THỪA đúng bằng khoản tạm ứng của ngày mẫu (khoản đã ghi mà tiền chưa rời két): phép trừ
-- két lệch. Chỗ lệch chỉ ra được đúng một thao tác có tên — khoản tạm ứng — nên I-012/2 không kêu.
-- T-134: lỗi cài cố ý vượt khoá ngày đã ký để dựng dữ liệu hỏng cho phép đối chiếu.
ALTER TABLE cash_count_line DISABLE TRIGGER cash_count_line_reconciled_guard_trg;
UPDATE cash_count_line SET amount_vnd = amount_vnd + (SELECT amount_vnd FROM staff_advance ORDER BY id LIMIT 1)
WHERE cash_count_id = (SELECT id FROM bc WHERE ten = 'dem_ket') AND denomination_vnd = 1000;
ALTER TABLE cash_count_line ENABLE TRIGGER cash_count_line_reconciled_guard_trg;
