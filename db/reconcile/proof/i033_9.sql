-- kêu: I-033/9
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
ALTER TABLE login_session DROP CONSTRAINT login_session_token_hash_check;
UPDATE login_session SET token_hash = decode('00', 'hex') WHERE token_hash = sha256('proof-session');
