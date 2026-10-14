-- P2A-14 — I-033 · YC-38, ADR-109. Ý định: docs/product/2-db/19-luoc-do-tai-khoan.md.
CREATE TABLE account (
  id bigint GENERATED ALWAYS AS IDENTITY,
  username text COLLATE "vi-x-icu" NOT NULL,
  email text COLLATE "vi-x-icu" NOT NULL,
  requested_display_name text COLLATE "vi-x-icu" NOT NULL,
  status text NOT NULL DEFAULT 'cho_duyet',
  person_id bigint,
  role_code text,
  decided_at timestamptz,
  decided_by_person_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT account_pkey PRIMARY KEY (id),
  CONSTRAINT account_username_key UNIQUE (username),
  CONSTRAINT account_email_key UNIQUE (email),
  CONSTRAINT account_person_key UNIQUE (person_id),
  CONSTRAINT account_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT account_decided_by_person_fkey FOREIGN KEY (decided_by_person_id) REFERENCES person (id),
  CONSTRAINT account_username_check CHECK (username COLLATE "C" ~ '^[a-z0-9._-]{3,32}$'),
  CONSTRAINT account_email_check CHECK (email = lower(email) AND position('@' IN email) > 0),
  CONSTRAINT account_requested_display_name_check CHECK (btrim(requested_display_name) <> ''),
  CONSTRAINT account_status_check CHECK (status IN ('cho_duyet', 'hoat_dong', 'khoa', 'tu_choi')),
  CONSTRAINT account_role_code_check CHECK (role_code IN ('quay', 'trang_banh', 'gap_banh', 'canh_don_ban', 'owner')),
  CONSTRAINT account_status_shape_check CHECK (
    (status = 'cho_duyet' AND person_id IS NULL AND role_code IS NULL AND decided_at IS NULL AND decided_by_person_id IS NULL)
    OR (status = 'tu_choi' AND person_id IS NULL AND role_code IS NULL AND decided_at IS NOT NULL AND decided_by_person_id IS NOT NULL)
    OR (status IN ('hoat_dong', 'khoa') AND person_id IS NOT NULL AND role_code IS NOT NULL AND decided_at IS NOT NULL AND decided_by_person_id IS NOT NULL)
  )
);

CREATE TABLE account_password (
  id bigint GENERATED ALWAYS AS IDENTITY,
  account_id bigint NOT NULL,
  password_hash text NOT NULL,
  set_by_person_id bigint,
  must_change_password boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT account_password_pkey PRIMARY KEY (id),
  CONSTRAINT account_password_account_fkey FOREIGN KEY (account_id) REFERENCES account (id),
  CONSTRAINT account_password_set_by_person_fkey FOREIGN KEY (set_by_person_id) REFERENCES person (id),
  CONSTRAINT account_password_hash_check CHECK (password_hash LIKE '$argon2id$%'),
  CONSTRAINT account_password_temporary_check CHECK (must_change_password = (set_by_person_id IS NOT NULL))
);

CREATE TABLE login_session (
  id bigint GENERATED ALWAYS AS IDENTITY,
  account_id bigint NOT NULL,
  token_hash bytea NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  ended_at timestamptz,
  end_reason text COLLATE "vi-x-icu",
  counter_duty_id bigint,
  CONSTRAINT login_session_pkey PRIMARY KEY (id),
  CONSTRAINT login_session_account_fkey FOREIGN KEY (account_id) REFERENCES account (id),
  CONSTRAINT login_session_counter_duty_fkey FOREIGN KEY (counter_duty_id) REFERENCES counter_duty (id),
  CONSTRAINT login_session_token_key UNIQUE (token_hash),
  CONSTRAINT login_session_counter_duty_key UNIQUE (counter_duty_id),
  CONSTRAINT login_session_token_hash_check CHECK (octet_length(token_hash) = 32),
  CONSTRAINT login_session_expiry_check CHECK (expires_at > created_at AND expires_at <= created_at + interval '7 days'),
  CONSTRAINT login_session_end_pair_check CHECK ((ended_at IS NULL) = (end_reason IS NULL)),
  CONSTRAINT login_session_end_reason_check CHECK (end_reason IN ('dang_xuat', 'doi_mat_khau', 'dat_lai_mat_khau', 'khoa_tai_khoan')),
  CONSTRAINT login_session_ended_at_check CHECK (ended_at IS NULL OR ended_at >= created_at)
);

CREATE TABLE password_reset (
  id bigint GENERATED ALWAYS AS IDENTITY,
  account_id bigint NOT NULL,
  token_hash bytea NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  CONSTRAINT password_reset_pkey PRIMARY KEY (id),
  CONSTRAINT password_reset_account_fkey FOREIGN KEY (account_id) REFERENCES account (id),
  CONSTRAINT password_reset_token_key UNIQUE (token_hash),
  CONSTRAINT password_reset_token_hash_check CHECK (octet_length(token_hash) = 32),
  CONSTRAINT password_reset_expiry_check CHECK (expires_at > created_at AND expires_at <= created_at + interval '30 minutes'),
  CONSTRAINT password_reset_used_at_check CHECK (used_at IS NULL OR (used_at >= created_at AND used_at < expires_at))
);

-- Khoá dòng tài khoản để lần mở phiên không vượt qua lần khoá cùng lúc ở backend.
-- Không thay giao dịch backend kết thúc mọi phiên khi khoá tài khoản.
CREATE FUNCTION login_session_account_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE a account%ROWTYPE; duty_person bigint;
BEGIN
  SELECT * INTO a FROM account WHERE id = NEW.account_id FOR UPDATE;
  -- Tài khoản không tồn tại để khoá ngoại trả đúng foreign_key_violation.
  IF FOUND THEN
    IF a.status <> 'hoat_dong' AND (TG_OP = 'INSERT' OR NEW.ended_at IS NULL) THEN
      RAISE EXCEPTION 'chỉ tài khoản hoạt động mở được phiên'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'login_session_active_account_check';
    END IF;
    IF NEW.counter_duty_id IS NOT NULL THEN
      SELECT person_id INTO duty_person FROM counter_duty WHERE id = NEW.counter_duty_id;
      IF FOUND AND duty_person IS DISTINCT FROM a.person_id THEN
        RAISE EXCEPTION 'phiên phải gắn trực quầy của chính người đăng nhập'
          USING ERRCODE = 'check_violation', CONSTRAINT = 'login_session_duty_person_check';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION login_session_account_guard() FROM PUBLIC;
CREATE TRIGGER login_session_account_guard_trg BEFORE INSERT OR UPDATE OF account_id, counter_duty_id ON login_session
  FOR EACH ROW EXECUTE FUNCTION login_session_account_guard();

CREATE FUNCTION login_session_ended_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.ended_at IS NOT NULL THEN
    RAISE EXCEPTION 'phiên đã kết thúc không được sửa'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'login_session_ended_immutable_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION login_session_ended_guard() FROM PUBLIC;
CREATE TRIGGER login_session_ended_guard_trg BEFORE UPDATE ON login_session
  FOR EACH ROW EXECUTE FUNCTION login_session_ended_guard();

CREATE FUNCTION password_reset_used_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.used_at IS NOT NULL THEN
    RAISE EXCEPTION 'mã đặt lại đã dùng không được sửa'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'password_reset_used_once_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION password_reset_used_guard() FROM PUBLIC;
CREATE TRIGGER password_reset_used_guard_trg BEFORE UPDATE ON password_reset
  FOR EACH ROW EXECUTE FUNCTION password_reset_used_guard();

-- QD-50/51/52: không xoá, không dây chuyền, mọi bảng có vết cập nhật.
CREATE TRIGGER account_record_revision_trg AFTER UPDATE ON account
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON account FROM shop_app;
GRANT UPDATE (status, person_id, role_code, decided_at, decided_by_person_id) ON account TO shop_app;
CREATE TRIGGER account_password_record_revision_trg AFTER UPDATE ON account_password
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON account_password FROM shop_app;
CREATE TRIGGER login_session_record_revision_trg AFTER UPDATE ON login_session
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON login_session FROM shop_app;
GRANT UPDATE (ended_at, end_reason) ON login_session TO shop_app;
CREATE TRIGGER password_reset_record_revision_trg AFTER UPDATE ON password_reset
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON password_reset FROM shop_app;
GRANT UPDATE (used_at) ON password_reset TO shop_app;
