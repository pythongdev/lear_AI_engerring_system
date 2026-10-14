-- kêu: I-033/6
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-033', true);
END $$;
INSERT INTO person (display_name) VALUES ('Lỗi cài tài khoản');
INSERT INTO account (username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id)
VALUES ('proof.account', 'proof.account@example.com', 'Lỗi cài tài khoản', 'hoat_dong',
        (SELECT max(id) FROM person), 'quay', now(), pg_temp.bc_nguoi('Chủ quán'));
