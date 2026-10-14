-- kêu: I-033/14
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-033', true);
END $$;
INSERT INTO person (display_name) VALUES ('Lỗi cài phiên quầy');
INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
VALUES ('proof.quay', 'proof.quay@example.com', 'Lỗi cài phiên quầy', 'hoat_dong',
        (SELECT max(id) FROM person), 'quay', now(), pg_temp.bc_nguoi('Chủ quán'));
INSERT INTO account_password (account_id, password_hash) VALUES ((SELECT id FROM account WHERE username = 'proof.quay'), '$argon2id$proof');
-- Khoảng trực mở lúc 10:00 mà phiên ghi mở lúc 10:05: hai mốc của cùng một lần đăng nhập lệch nhau.
INSERT INTO counter_duty (person_id, started_at, ended_at)
VALUES ((SELECT max(id) FROM person), '2020-01-01 10:00+07', '2020-01-01 11:00+07');
INSERT INTO login_session (account_id, token_hash, created_at, expires_at, counter_duty_id)
VALUES ((SELECT id FROM account WHERE username = 'proof.quay'), sha256('proof-phien-quay'),
        '2020-01-01 10:05+07', '2020-01-01 12:00+07', (SELECT max(id) FROM counter_duty));
