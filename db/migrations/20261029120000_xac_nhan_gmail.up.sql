-- T-270 — ADR-133; ý định: 25-luoc-do-xac-nhan-gmail.md.
ALTER TABLE customer_account
  ADD COLUMN pending_email text COLLATE "vi-x-icu",
  ADD CONSTRAINT customer_account_pending_email_check CHECK (pending_email = lower(pending_email) AND position('@' IN pending_email) > 0),
  ADD CONSTRAINT customer_account_pending_email_differs_check CHECK (pending_email IS NULL OR pending_email IS DISTINCT FROM email),
  DROP CONSTRAINT customer_account_contact_check,
  ADD CONSTRAINT customer_account_contact_check CHECK (phone IS NOT NULL OR email IS NOT NULL OR pending_email IS NOT NULL);
GRANT UPDATE (email, pending_email) ON customer_account TO shop_app;

CREATE TABLE customer_email_verification (
  id bigint GENERATED ALWAYS AS IDENTITY,
  customer_account_id bigint NOT NULL,
  email text COLLATE "vi-x-icu" NOT NULL,
  token_hash bytea NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  CONSTRAINT customer_email_verification_email_check CHECK (email = lower(email) AND position('@' IN email) > 0),
  CONSTRAINT customer_email_verification_pkey PRIMARY KEY (id),
  CONSTRAINT customer_email_verification_account_fkey FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  CONSTRAINT customer_email_verification_token_key UNIQUE (token_hash),
  CONSTRAINT customer_email_verification_token_hash_check CHECK (octet_length(token_hash) = 32),
  CONSTRAINT customer_email_verification_expiry_check CHECK (expires_at > created_at AND expires_at <= created_at + interval '24 hours'),
  CONSTRAINT customer_email_verification_used_at_check CHECK (used_at IS NULL OR (used_at >= created_at AND used_at < expires_at))
);

CREATE FUNCTION customer_email_verification_used_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.used_at IS NOT NULL THEN
    RAISE EXCEPTION 'mã xác nhận đã dùng không được sửa'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_email_verification_used_once_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_email_verification_used_guard() FROM PUBLIC;
CREATE TRIGGER customer_email_verification_used_guard_trg BEFORE UPDATE ON customer_email_verification
  FOR EACH ROW EXECUTE FUNCTION customer_email_verification_used_guard();

CREATE TRIGGER customer_email_verification_record_revision_trg AFTER UPDATE ON customer_email_verification
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON customer_email_verification FROM shop_app;
GRANT UPDATE (used_at) ON customer_email_verification TO shop_app;

ALTER TABLE record_revision DROP CONSTRAINT record_revision_person_check,
  ADD CONSTRAINT record_revision_person_check CHECK (person_id IS NOT NULL OR target_table_code IN
    ('customer_account', 'customer_password', 'customer_session', 'customer_password_reset', 'customer_email_verification'));
