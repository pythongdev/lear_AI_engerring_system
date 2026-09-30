-- kêu: I-023/5
-- Khoá "một mã một bàn" bị gỡ; mã hiện hành của bàn 7 từng là mã (đã thay) của bàn 6.
ALTER TABLE qr_code DROP CONSTRAINT qr_code_code_key CASCADE;
INSERT INTO qr_code (dining_table_id, code, issued_at, replaced_at)
SELECT pg_temp.bc_ban('6'), q.code, c6.issued_at - interval '2 hours', c6.issued_at - interval '1 hour'
FROM qr_code q, qr_code c6
WHERE q.dining_table_id = pg_temp.bc_ban('7') AND q.replaced_at IS NULL
  AND c6.dining_table_id = pg_temp.bc_ban('6') AND c6.replaced_at IS NULL;
