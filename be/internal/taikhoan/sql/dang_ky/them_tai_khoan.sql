-- name: ThemTaiKhoan :one
INSERT INTO account (username,email,requested_display_name,phone) VALUES ($1,$2,$3,$4) RETURNING id;
