-- kêu: I-002/3
-- Ràng buộc "kênh gắn bàn ⟺ có phiên" bị gỡ; một lượt gọi staff_pos không thuộc phiên nào.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_session_iff_table_channel_check;
INSERT INTO sales_order (channel_code, status, submission_code, created_at)
VALUES ('staff_pos', 'new', gen_random_uuid()::text, pg_temp.bc_luc('10:00'));
