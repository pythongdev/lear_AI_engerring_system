-- name: ThemBo :one
INSERT INTO customer_favourite_set (customer_account_id, kind, name)
VALUES ($1, $2, $3) RETURNING id;
