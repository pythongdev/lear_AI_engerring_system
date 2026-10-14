-- kêu: I-033/15
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-033', true);
END $$;
INSERT INTO person (display_name) VALUES ('Lỗi cài đặt lại');
INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
VALUES ('proof.datlai', 'proof.datlai@example.com', 'Lỗi cài đặt lại', 'hoat_dong',
        (SELECT max(id) FROM person), 'quay', now(), pg_temp.bc_nguoi('Chủ quán'));
INSERT INTO account_password (account_id, password_hash) VALUES ((SELECT id FROM account WHERE username = 'proof.datlai'), '$argon2id$proof');
-- Mã dùng lúc 10:10 mà không có bản mật khẩu nào mang mốc ấy.
INSERT INTO password_reset (account_id, token_hash, created_at, expires_at, used_at)
VALUES ((SELECT id FROM account WHERE username = 'proof.datlai'), sha256('proof-dat-lai'),
        '2020-01-01 10:00+07', '2020-01-01 10:30+07', '2020-01-01 10:10+07');
