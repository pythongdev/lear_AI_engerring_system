-- kêu: I-033/13
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Người đứng quầy')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-033/13', true);
END $$;
INSERT INTO person (display_name) VALUES ('Lỗi cài người duyệt');
INSERT INTO account (username, email, requested_display_name)
VALUES ('proof.duyet', 'proof.duyet@example.com', 'Lỗi cài người duyệt');
INSERT INTO account_password (account_id, password_hash)
VALUES ((SELECT id FROM account WHERE username = 'proof.duyet'), '$argon2id$proof');
UPDATE account SET status = 'hoat_dong', person_id = (SELECT max(id) FROM person), role_code = 'quay',
       decided_at = now(), decided_by_person_id = pg_temp.bc_nguoi('Người đứng quầy')
WHERE username = 'proof.duyet';
