-- name: DocTen :one
SELECT id, username, email, phone, requested_display_name, status, person_id, role_code, decided_at, decided_by_person_id, created_at FROM account WHERE phone=$1 OR email=$1 FOR UPDATE;
