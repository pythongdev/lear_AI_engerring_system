-- kêu: I-023/1 QD-11
-- Khoá "mã và bàn đi cùng nhau" bị gỡ; lượt gọi QR của bàn 5 mang mã của bàn 6. Gỡ khoá ấy cũng để
-- cột qr_code_id không còn khoá ngoại nào — QD-11 kêu cùng.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_qr_code_table_fkey;
UPDATE sales_order SET qr_code_id = (SELECT id FROM qr_code WHERE dining_table_id = pg_temp.bc_ban('6')
                                                             AND replaced_at IS NULL)
WHERE id = (SELECT id FROM bc WHERE ten = 'don_5_qr');
