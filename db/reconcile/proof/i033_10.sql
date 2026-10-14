-- kêu: I-033/10
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-033', true);
END $$;
INSERT INTO person (display_name) VALUES ('Lỗi cài tài khoản');
INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
VALUES ('proof.account', 'proof.account@example.com', 'Lỗi cài tài khoản', 'hoat_dong',
        (SELECT max(id) FROM person), 'quay', now(), pg_temp.bc_nguoi('Chủ quán'));
INSERT INTO account_password (account_id, password_hash) VALUES ((SELECT id FROM account WHERE username = 'proof.account'), '$argon2id$proof');
INSERT INTO password_reset (account_id, token_hash, expires_at) VALUES ((SELECT id FROM account WHERE username = 'proof.account'), sha256('proof-reset'), now() + interval '30 minutes');
ALTER TABLE password_reset DROP CONSTRAINT password_reset_expiry_check;
UPDATE password_reset SET expires_at = created_at + interval '31 minutes' WHERE token_hash = sha256('proof-reset');
