-- name: ThemTaiKhoan :one
INSERT INTO account (username,email,requested_display_name) VALUES ($1,$2,$3) RETURNING id;
