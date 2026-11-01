-- name: ThemTaiKhoan :one
INSERT INTO customer_account(phone,email,pending_email,display_name) VALUES ($1,$2,$3,$4) RETURNING id;
