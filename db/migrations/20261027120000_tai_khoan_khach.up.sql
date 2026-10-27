-- T-263 — ADR-131, I-035; ý định: 23-luoc-do-tai-khoan-khach.md.
ALTER TABLE account
  ADD COLUMN phone text COLLATE "vi-x-icu",
  ADD CONSTRAINT account_phone_key UNIQUE (phone),
  ADD CONSTRAINT account_phone_check CHECK (phone COLLATE "C" ~ '^0[1-9][0-9]{8,9}$'),
  ALTER COLUMN email DROP NOT NULL,
  ALTER COLUMN username DROP NOT NULL,
  ADD CONSTRAINT account_contact_check CHECK (phone IS NOT NULL OR email IS NOT NULL);

CREATE TABLE customer_account (
  id bigint GENERATED ALWAYS AS IDENTITY,
  phone text COLLATE "vi-x-icu",
  email text COLLATE "vi-x-icu",
  display_name text COLLATE "vi-x-icu" NOT NULL,
  delivery_name text COLLATE "vi-x-icu",
  delivery_phone text COLLATE "vi-x-icu",
  delivery_address text COLLATE "vi-x-icu",
  delivery_updated_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT customer_account_pkey PRIMARY KEY (id),
  CONSTRAINT customer_account_phone_key UNIQUE (phone),
  CONSTRAINT customer_account_email_key UNIQUE (email),
  CONSTRAINT customer_account_phone_check CHECK (phone COLLATE "C" ~ '^0[1-9][0-9]{8,9}$'),
  CONSTRAINT customer_account_email_check CHECK (email = lower(email) AND position('@' IN email) > 0),
  CONSTRAINT customer_account_contact_check CHECK (phone IS NOT NULL OR email IS NOT NULL),
  CONSTRAINT customer_account_display_name_check CHECK (btrim(display_name) <> ''),
  CONSTRAINT customer_account_delivery_name_check CHECK (btrim(delivery_name) <> ''),
  CONSTRAINT customer_account_delivery_phone_check CHECK (btrim(delivery_phone) <> ''),
  CONSTRAINT customer_account_delivery_address_check CHECK (btrim(delivery_address) <> '')
);

CREATE TABLE customer_password (
  id bigint GENERATED ALWAYS AS IDENTITY,
  customer_account_id bigint NOT NULL,
  password_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT customer_password_pkey PRIMARY KEY (id),
  CONSTRAINT customer_password_account_fkey FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  CONSTRAINT customer_password_hash_check CHECK (password_hash LIKE '$argon2id$%')
);

CREATE TABLE customer_session (
  id bigint GENERATED ALWAYS AS IDENTITY,
  customer_account_id bigint NOT NULL,
  token_hash bytea NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  ended_at timestamptz,
  end_reason text COLLATE "vi-x-icu",
  CONSTRAINT customer_session_pkey PRIMARY KEY (id),
  CONSTRAINT customer_session_account_fkey FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  CONSTRAINT customer_session_token_key UNIQUE (token_hash),
  CONSTRAINT customer_session_token_hash_check CHECK (octet_length(token_hash) = 32),
  CONSTRAINT customer_session_expiry_check CHECK (expires_at > created_at AND expires_at <= created_at + interval '7 days'),
  CONSTRAINT customer_session_end_pair_check CHECK ((ended_at IS NULL) = (end_reason IS NULL)),
  CONSTRAINT customer_session_end_reason_check CHECK (end_reason IN ('dang_xuat', 'doi_mat_khau', 'dat_lai_mat_khau')),
  CONSTRAINT customer_session_ended_at_check CHECK (ended_at IS NULL OR ended_at >= created_at)
);

CREATE TABLE customer_password_reset (
  id bigint GENERATED ALWAYS AS IDENTITY,
  customer_account_id bigint NOT NULL,
  token_hash bytea NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  CONSTRAINT customer_password_reset_pkey PRIMARY KEY (id),
  CONSTRAINT customer_password_reset_account_fkey FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  CONSTRAINT customer_password_reset_token_key UNIQUE (token_hash),
  CONSTRAINT customer_password_reset_token_hash_check CHECK (octet_length(token_hash) = 32),
  CONSTRAINT customer_password_reset_expiry_check CHECK (expires_at > created_at AND expires_at <= created_at + interval '30 minutes'),
  CONSTRAINT customer_password_reset_used_at_check CHECK (used_at IS NULL OR (used_at >= created_at AND used_at < expires_at))
);


CREATE FUNCTION customer_session_ended_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.ended_at IS NOT NULL THEN
    RAISE EXCEPTION 'phiên đã kết thúc không được sửa'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_session_ended_immutable_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_session_ended_guard() FROM PUBLIC;
CREATE TRIGGER customer_session_ended_guard_trg BEFORE UPDATE ON customer_session
  FOR EACH ROW EXECUTE FUNCTION customer_session_ended_guard();

CREATE FUNCTION customer_password_reset_used_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.used_at IS NOT NULL THEN
    RAISE EXCEPTION 'mã đặt lại đã dùng không được sửa'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_password_reset_used_once_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_password_reset_used_guard() FROM PUBLIC;
CREATE TRIGGER customer_password_reset_used_guard_trg BEFORE UPDATE ON customer_password_reset
  FOR EACH ROW EXECUTE FUNCTION customer_password_reset_used_guard();

-- QC-03: SELECT/INSERT và quyền sequence theo mặc định; QD-50/51/52 giữ vết, không xoá.
CREATE TRIGGER customer_account_record_revision_trg AFTER UPDATE ON customer_account
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON customer_account FROM shop_app;
GRANT UPDATE (display_name, delivery_name, delivery_phone, delivery_address, delivery_updated_at) ON customer_account TO shop_app;
CREATE TRIGGER customer_password_record_revision_trg AFTER UPDATE ON customer_password
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON customer_password FROM shop_app;
CREATE TRIGGER customer_session_record_revision_trg AFTER UPDATE ON customer_session
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON customer_session FROM shop_app;
GRANT UPDATE (ended_at, end_reason) ON customer_session TO shop_app;
CREATE TRIGGER customer_password_reset_record_revision_trg AFTER UPDATE ON customer_password_reset
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON customer_password_reset FROM shop_app;
GRANT UPDATE (used_at) ON customer_password_reset TO shop_app;

-- ADR-131 điểm 5; cơ chế bất biến do Claude chốt bổ sung cho T-263.
ALTER TABLE sales_order
  ADD COLUMN customer_account_id bigint,
  ADD CONSTRAINT sales_order_customer_account_fkey
    FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  ADD CONSTRAINT sales_order_customer_account_channel_check
    CHECK (customer_account_id IS NULL OR channel_code IN ('delivery', 'pickup'));

CREATE FUNCTION sales_order_customer_account_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.customer_account_id IS DISTINCT FROM NEW.customer_account_id THEN
    RAISE EXCEPTION 'tài khoản khách của đơn chỉ được đặt lúc tạo'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'sales_order_customer_account_immutable_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION sales_order_customer_account_guard() FROM PUBLIC;
CREATE TRIGGER sales_order_customer_account_guard_trg
  BEFORE UPDATE OF customer_account_id ON sales_order
  FOR EACH ROW EXECUTE FUNCTION sales_order_customer_account_guard();
