-- kêu: I-005/2
-- Ràng buộc "nợ có chủ" bị gỡ; khoản nợ của nhóm ghép bàn 3 + 4 mất tên người nợ.
ALTER TABLE bill DROP CONSTRAINT bill_debtor_iff_debt_check;
UPDATE bill SET debtor_name = NULL WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_no');
