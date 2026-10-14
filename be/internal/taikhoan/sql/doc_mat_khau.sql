-- name: DocMatKhau :one
SELECT id, account_id, password_hash, set_by_person_id, must_change_password, created_at FROM account_password WHERE account_id=$1 ORDER BY created_at DESC,id DESC LIMIT 1;
