-- kêu: I-005/3 QD-21 QD-22
-- Ràng buộc "thu nợ đủ khoản" bị gỡ; lần thu nợ ghi khoản nợ đủ mà tiền chuyển khoản thiếu 1.000đ.
-- Gỡ ràng buộc ấy cũng làm ba cột tiền của bảng mất ràng buộc không âm (QD-21) và mất quan hệ số
-- học (QD-22) — nhóm quy ước kêu cùng, đúng việc của nó.
ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_amounts_check;
UPDATE debt_collection SET transfer_vnd = transfer_vnd - 1000
WHERE bill_id = (SELECT id FROM bc WHERE ten = 'hoa_don_no');
