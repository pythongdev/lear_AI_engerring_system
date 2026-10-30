-- name: GhiMatKhau :exec
INSERT INTO customer_password(customer_account_id,password_hash) VALUES ($1,$2);
