-- kêu: I-023/4
-- Khoá "một bàn một mã hiện hành" bị gỡ; bàn 6 có hai mã cùng hiện hành.
DROP INDEX qr_code_one_current_per_table_key;
INSERT INTO qr_code (dining_table_id, code, issued_at)
VALUES (pg_temp.bc_ban('6'), 'ma-thu-hai-cua-ban-6', now());
