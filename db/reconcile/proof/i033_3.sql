-- kêu: I-033/3
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-033', true);
END $$;
INSERT INTO person (display_name) VALUES ('Lỗi cài tài khoản');
INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
VALUES ('proof.account', 'proof.account@example.com', 'Lỗi cài tài khoản', 'hoat_dong',
        (SELECT max(id) FROM person), 'quay', now(), pg_temp.bc_nguoi('Chủ quán'));
INSERT INTO account_password (account_id, password_hash) VALUES ((SELECT id FROM account WHERE username = 'proof.account'), '$argon2id$proof');
INSERT INTO login_session (account_id, token_hash, expires_at) VALUES ((SELECT id FROM account WHERE username = 'proof.account'), sha256('proof-session'), now() + interval '1 day');
ALTER TABLE login_session DISABLE TRIGGER login_session_account_guard_trg;
INSERT INTO counter_duty (person_id, started_at, ended_at) VALUES (pg_temp.bc_nguoi('Chủ quán'), now() + interval '200 years', now() + interval '200 years 1 hour');
UPDATE login_session SET counter_duty_id = (SELECT max(id) FROM counter_duty) WHERE token_hash = sha256('proof-session');
ALTER TABLE login_session ENABLE TRIGGER login_session_account_guard_trg;
