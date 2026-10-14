-- name: GhiMatKhau :exec
INSERT INTO account_password (account_id,password_hash,set_by_person_id,must_change_password) VALUES ($1,$2,$3,$4);
