-- name: DocTaiKhoanMa :one
SELECT a.id, a.username, a.email, a.requested_display_name, a.status, a.person_id, a.role_code, a.decided_at, a.decided_by_person_id, a.created_at FROM account a JOIN password_reset r ON r.account_id=a.id WHERE r.token_hash=$1 FOR UPDATE OF a;
