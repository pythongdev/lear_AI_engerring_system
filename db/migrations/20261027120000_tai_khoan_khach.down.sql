-- T-263 — đường lùi chỉ khi hình cũ còn giữ nguyên dữ liệu (ADR-127, ADR-131).
-- Khoá trước khi xét để không có lần ghi chen giữa phép kiểm và DDL.
LOCK TABLE account, customer_account IN ACCESS EXCLUSIVE MODE;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM account WHERE email IS NULL OR username IS NULL OR phone IS NOT NULL) THEN
    RAISE EXCEPTION 'đường lùi từ chối: account có định danh không giữ được trong lược đồ cũ'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'account_contact_rollback_check';
  END IF;
  IF EXISTS (SELECT 1 FROM customer_account) THEN
    RAISE EXCEPTION 'đường lùi từ chối: customer_account đang giữ dữ liệu đã ghi'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_account_rollback_check';
  END IF;
END $$;
DROP TRIGGER sales_order_customer_account_guard_trg ON sales_order;
DROP FUNCTION sales_order_customer_account_guard();
ALTER TABLE sales_order
  DROP CONSTRAINT sales_order_customer_account_channel_check,
  DROP CONSTRAINT sales_order_customer_account_fkey,
  DROP COLUMN customer_account_id;
DROP TABLE customer_password_reset;
DROP TABLE customer_session;
DROP TABLE customer_password;
DROP TABLE customer_account;
DROP FUNCTION customer_password_reset_used_guard();
DROP FUNCTION customer_session_ended_guard();
ALTER TABLE account
  DROP CONSTRAINT account_contact_check,
  ALTER COLUMN username SET NOT NULL,
  ALTER COLUMN email SET NOT NULL,
  DROP COLUMN phone;
