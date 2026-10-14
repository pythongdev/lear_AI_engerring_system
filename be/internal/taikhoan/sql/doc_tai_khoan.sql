-- name: DocTaiKhoan :one
SELECT id, username, email, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id, created_at FROM account WHERE id=$1 FOR UPDATE;
