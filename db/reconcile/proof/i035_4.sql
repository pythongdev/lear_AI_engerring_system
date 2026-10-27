-- kêu: I-035/4
-- Gỡ CHECK kênh và trigger bất biến để cài liên kết sai trên đơn hotline ngày mẫu.
-- Giữ trigger vết và mọi dữ liệu bán hàng, tiền, trạng thái của đơn.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_customer_account_channel_check;
ALTER TABLE sales_order DISABLE TRIGGER sales_order_customer_account_guard_trg;
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-035/4', true);
END $$;
INSERT INTO customer_account (email, display_name)
VALUES ('proof.i035.4@example.com', 'Lỗi cài khách của đơn hotline');
UPDATE sales_order
SET customer_account_id = (SELECT id FROM customer_account WHERE email = 'proof.i035.4@example.com')
WHERE id = (SELECT id FROM bc WHERE ten = 'don_hotline');
ALTER TABLE sales_order ENABLE TRIGGER sales_order_customer_account_guard_trg;
