-- kêu: QD-40 QD-40/b
-- Một cột status không có ràng buộc kiểm (và vì thế cũng không có bảng ánh xạ).
ALTER TABLE production_batch ADD COLUMN status text;
