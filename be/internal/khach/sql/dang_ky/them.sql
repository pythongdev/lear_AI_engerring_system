-- name: ThemTaiKhoan :one
INSERT INTO customer_account(phone,email,display_name) VALUES ($1,$2,$3) RETURNING id;
