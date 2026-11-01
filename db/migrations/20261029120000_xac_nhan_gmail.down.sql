-- T-270 — không mất Gmail chờ hoặc mã xác nhận đã ghi.
LOCK TABLE customer_account, customer_email_verification IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM customer_email_verification) OR
     EXISTS (SELECT 1 FROM customer_account WHERE pending_email IS NOT NULL) THEN
    RAISE EXCEPTION 'đường lùi từ chối: còn mã xác nhận hoặc Gmail chờ'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_email_verification_rollback_check';
  END IF;
END $$;
DROP TABLE customer_email_verification;
DROP FUNCTION customer_email_verification_used_guard();
REVOKE UPDATE (email, pending_email) ON customer_account FROM shop_app;
ALTER TABLE customer_account
  DROP CONSTRAINT customer_account_contact_check,
  ADD CONSTRAINT customer_account_contact_check CHECK (phone IS NOT NULL OR email IS NOT NULL),
  DROP COLUMN pending_email;
ALTER TABLE record_revision DROP CONSTRAINT record_revision_person_check,
  ADD CONSTRAINT record_revision_person_check CHECK (person_id IS NOT NULL OR target_table_code IN
    ('customer_account', 'customer_password', 'customer_session', 'customer_password_reset'));
