-- name: TaoNguoi :one
INSERT INTO person (display_name,is_owner) VALUES ($1,$2) RETURNING id;
