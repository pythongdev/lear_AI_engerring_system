-- name: DocNguoi :one
SELECT id, display_name, is_owner, created_at FROM person WHERE id=$1;
