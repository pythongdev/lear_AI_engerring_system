-- kêu: I-014/4 I-002/1 I-002/2
-- Khoá "một phiên một hoá đơn" bị gỡ; sáng hôm sau khách trả nợ được ghi thành một hoá đơn MỚI của
-- phiên ghép — một lần bán thứ hai.
ALTER TABLE bill DROP CONSTRAINT bill_one_per_session_key CASCADE;
INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date)
SELECT table_session_id, debt_vnd, debt_vnd, pg_temp.bc_luc('06:35', 1), pg_temp.bc_ngay(1)
FROM bill WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_no');
